function alpha = PerformCubature( alpha, UnconstrainedReturnPath, ConstrainedReturnPath, options, oo, dynareOBC, FirstOrderSimulation, varargin )
   
    RootConditionalCovariance = RetrieveConditionalCovariances( options, oo, dynareOBC, FirstOrderSimulation );
    d = size( RootConditionalCovariance, 2 );
    if d == 0
        return;
    end
    
    if dynareOBC.FastCubature
        NumPoints = 1 + 2 * d;
        CubatureWeights = ones( NumPoints, 1 ) * ( 1 / NumPoints );
        wTemp = 0.5 * sqrt( 2 * NumPoints );
        CubaturePoints = [ zeros( d, 1 ), eye( d ) * wTemp, eye( d ) * (-wTemp) ];
        CubatureOrder = 1;
    else
        CubatureOrder = ceil( 0.5 * ( dynareOBC.MaxCubatureDegree - 1 ) );
        [ CubatureWeightsCurrent, CubaturePoints, NumPointsCurrent ] = fwtpts( d, CubatureOrder );
        CubatureWeights = zeros( NumPointsCurrent, CubatureOrder );
        CubatureWeights( :, end ) = CubatureWeightsCurrent;
        NumPoints = zeros( 1, CubatureOrder );
        NumPoints( end ) = NumPointsCurrent;
        for i = 1 : ( CubatureOrder - 1 )
            CubatureWeightsCurrent = fwtpts( d, i );
            NumPointsCurrent = length( CubatureWeightsCurrent );
            CubatureWeights( 1:NumPointsCurrent, i ) = CubatureWeightsCurrent;
            NumPoints( i ) = NumPointsCurrent;
        end
    end
    
    NumPoints = [ 1 NumPoints ];

    if nargin > 7
        p = TimedProgressBar( NumPoints( end ), 20, varargin{:} );
    else
        p = [];
    end

    alphaMatrix = alpha * CubatureWeights( 1, : );
    ReturnPathMatrix = ConstrainedReturnPath * CubatureWeights( 1, : );
    
    alpha_orig = alpha;
    ReturnPath_orig = ConstrainedReturnPath;

    exitflag = Inf;
    
    OpenPool;
    if ~isempty( p )
        p.progress;
    end
    
    HyperParams = [ 0; 0; 0.5 ];
    
    for i = 1 : CubatureOrder
    
        parfor j = ( NumPoints( i ) + 1 ) : NumPoints( i + 1 )
            WarningState = warning( 'off', 'all' );
            try
                [ alpha_new, exitflag_new, ReturnPath_new ] = SolveBoundsProblem( UnconstrainedReturnPath + RootConditionalCovariance * CubaturePoints( :, j ), dynareOBC );
                exitflag = min( exitflag, exitflag_new );
                alphaMatrix = alphaMatrix + alpha_new * CubatureWeights( j, : );
                ReturnPathMatrix = ReturnPathMatrix + ReturnPath_new * CubatureWeights( j, : );
            catch Error
                warning( WarningState );
                rethrow( Error );
            end
            warning( WarningState );
            if ~isempty( p )
                p.progress;
            end
        end
		
        if dynareOBC.FastCubature || dynareOBC.NoStatisticalCubature || ( i == 1 && dynareOBC.KappaPriorParameter == 0 )
            alpha_new = alphaMatrix( :, i );
            ReturnPath_new = ReturnPathMatrix( :, i );
            ReturnPathError = max( abs( ConstrainedReturnPath - ReturnPath_new ) );
            alpha = alpha_new;
            ConstrainedReturnPath = ReturnPath_new;
        else
            x_alpha = [ alpha_orig alphaMatrix( :, 1:i ) ];
            x_ReturnPath = [ ReturnPath_orig ReturnPathMatrix( :, 1:i ) ];
            HyperParams = fmincon( @( HP ) GetTwoNLogL( HP, x_ReturnPath, dynareOBC.KappaPriorParameter ), HyperParams, [], [], [], [], [ -1; -1; 0 ], [ 1; 1; 1 ], [], optimset( 'algorithm', 'sqp', 'display', 'off', 'MaxFunEvals', Inf, 'MaxIter', Inf, 'TolX', sqrt( eps ), 'TolFun', sqrt( eps ), 'UseParallel', false, 'ObjectiveLimit', -Inf ) );
            alpha_new = GetMu( HyperParams, x_alpha );
            ReturnPath_new = GetMu( HyperParams, x_ReturnPath );
            ReturnPathError = max( abs( ConstrainedReturnPath - ReturnPath_new ) );
            alpha = alpha_new;
            ConstrainedReturnPath = ReturnPath_new;
        end
        
        if ReturnPathError < 10 ^ ( -dynareOBC.CubatureAccuracy )
            break;
        end
    
    end

    if ~isempty( p )
        p.stop;
    end
    
    M = dynareOBC.MMatrix;
    
    [ alpha, ~, ~, exitflag_new ] = lsqlin( M, ConstrainedReturnPath - UnconstrainedReturnPath, -M, UnconstrainedReturnPath, [], [], [], [], alpha, dynareOBC.LSqLinOptions );
    exitflag = min( exitflag, exitflag_new );
%     figure;
%     hold on;
%     plot( ReturnPath );
%     plot( V + M * alpha );
    
    T = dynareOBC.InternalIRFPeriods;
    Ts = dynareOBC.TimeToEscapeBounds;
    ns = dynareOBC.NumberOfMax;
    Tolerance = dynareOBC.Tolerance;
    
    SelectNow = 1 + ( 0:T:(T*(ns-1)) );
    SelectNows = 1 + ( 0:Ts:(Ts*(ns-1)) );
    ConstraintNow = UnconstrainedReturnPath( SelectNow ) + M( SelectNow, : ) * alpha;
    SelectError = ( ConstraintNow < -2 * Tolerance );

    % Force the constraint not to be violated in the first period.
    if any( SelectError )
        SelectNowError = SelectNow( SelectError );
        SelectNowsError = SelectNows( SelectError );
        alpha( SelectNowsError ) = alpha( SelectNowsError ) - M( SelectNowError, SelectNowsError ) \ ConstraintNow( SelectError );
        exitflag = -1;
    end
%     plot( V + M * alpha );
%     hold off;
    
    if exitflag < 0
        warning( 'dynareOBC:QuadratureWarnings', 'Critical warnings were generated in the inner quadrature loop; accuracy may be compromised.' );
    end

end

% function ARCovMat = GetARCovMat( rho, T )
%     ARCovMat = ( rho .^ abs( bsxfun( @minus, 0:(T-1), (0:(T-1))' ) ) ) * ( 1 / ( 1 - rho * rho ) );
% end

function InvARCovMat = GetInvARCovMat( rho, T )
    if T == 1
        InvARCovMat = 1 - rho * rho;
    else
        d0 = ones( T, 1 ) * ( 1 + rho * rho );
        d0( 1 ) = 1;
        d0( end ) = 1;
        d1 = -rho * ones( T - 1, 1 );
        InvARCovMat = diag( d0 ) + diag( d1, -1 ) + diag( d1, 1 );
    end
end

function [ mu, sigma, PhiInv, diagKappaInvRhoInvdiagKappaInv, Error ] = GetMu( HyperParams, x )
    rho = HyperParams( 1 );
    phi = HyperParams( 2 );
    kappa = HyperParams( 3 );
    I = size( x, 1 );
    T = size( x, 2 );
    RhoInv = GetInvARCovMat( rho, T );
    PhiInv = GetInvARCovMat( phi, I );
    KappaInv = kappa .^ (-(0:(T-1))');
    diagKappaInv = diag( KappaInv );
    diagKappaInvRhoInvdiagKappaInv = diagKappaInv * RhoInv * diagKappaInv;
    II = eye( I );
    OI = ones( I, 1 );
    OT = ones( T, 1 );
    mu = ( x * diagKappaInvRhoInvdiagKappaInv * OT ) / ( OT' * diagKappaInvRhoInvdiagKappaInv * OT );
    Error = x(:) - kron( OT, mu );
    Temp = diag( Error ) * kron( KappaInv, II );
    sigma = sqrt( eps + max( 0, 1 / T * Temp' * kron( RhoInv, PhiInv ) * Temp * OI ) );
end

function TwoNLogL = GetTwoNLogL( HyperParams, x, KappaPriorParameter )
    rho = HyperParams( 1 );
    phi = HyperParams( 2 );
    kappa = HyperParams( 3 );
    [ ~, sigma, PhiInv, diagKappaInvRhoInvdiagKappaInv, Error ] = GetMu( HyperParams, x );
    I = size( x, 1 );
    T = size( x, 2 );
    OI = ones( I, 1 );
    diag_sigmaInv = diag( 1 ./ sigma );
    log_kappa = log( kappa );
    TwoNLogL = I * ( T * ( T - 1 ) * log_kappa - log( 1 - rho ) - log( 1 + rho ) ) + T * ( 2 * OI' * log( sigma ) - log( 1 - phi ) - log( 1 + phi ) ) + Error' * kron( diagKappaInvRhoInvdiagKappaInv, diag_sigmaInv * PhiInv * diag_sigmaInv ) * Error;
    if KappaPriorParameter > 0
        alpha = 1 / KappaPriorParameter;
        OPalpha = 1 + alpha;
        TwoNLogL = TwoNLogL + KappaPriorParameter * ( kappa ^ ( -alpha ) * OPalpha + alpha * OPalpha * log_kappa );
    end
end