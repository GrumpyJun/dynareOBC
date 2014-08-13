function alpha = PerformQuadrature( alpha, ZeroLowerBoundedReturnPath, options_, oo_, dynareOBC_, FirstOrderSimulation, varargin )

    if dynareOBC_.MaxIntegrationDimension == 0
        return;
    end
    
    RootConditionalCovariance = RetrieveConditionalCovariances( options_, oo_, dynareOBC_, FirstOrderSimulation );
    d = size( RootConditionalCovariance, 2 );

    kappa = dynareOBC_.kappa;
    kappa2 = kappa * kappa;
    kappa_alt = dynareOBC_.kappa_alt;
    
    if dynareOBC_.OrderFiveQuadrature
        assert( d > 4 );
        kappa4 = kappa2 * kappa2;
        v = kappa2 + d - 4;
        dm1 = d - 1;
        lambda = kappa * sqrt( v * dm1 ) / v;
        w2 = 0.5 * ( 4 - d ) / kappa4;
        w3 = 0.25 * v * v / ( kappa4 * dm1 * dm1 );
        w1 = 1 - 2 * d * w2 - 2 * d * dm1 * w3;
    elseif dynareOBC_.PseudoOrderFiveQuadrature
        w1 = 1;
        w2 = 0.5 / ( kappa2 - kappa_alt * kappa_alt );
        w3 = 0;
    else
        w1 = ( kappa2 - d ) / kappa2;
        w2 = 0.5 / kappa2;
        w3 = 0;
    end
    if dynareOBC_.RemoveNegativeQuadratureWeights
        w1 = max( 0, w1 );
        w2 = max( 0, w2 );
        w3 = max( 0, w3 );
    end
    if dynareOBC_.ForceEqualQuadratureWeights
        if w1 ~= 0
            w1 = 1;
        end
        if w2 ~= 0
            w2 = 1;
        end
        if w3 ~= 0
            w3 = 1;
        end
    end
    TotalLoopLength = 0;
    if w2 ~= 0
        TotalLoopLength = TotalLoopLength + d;
    end
    if w3 ~= 0
        TotalLoopLength = TotalLoopLength + d*(d-1);
    end

    alpha = w1 * alpha;
    wSum = w1;

    if nargin > 7 && TotalLoopLength > 0
        p = TimedProgressBar( TotalLoopLength, 20, varargin{:} );
    else
        p = [];
    end

    exitflag = Inf;
    
    OpenPool;
    if w2 ~= 0
        parfor j = 1 : d
            WarningState = warning( 'off', 'all' );
            try
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath + kappa * RootConditionalCovariance( :, j ), dynareOBC_ );
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w2 * alpha_new;
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath - kappa * RootConditionalCovariance( :, j ), dynareOBC_ );
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w2 * alpha_new;
                if dynareOBC_.PseudoOrderFiveQuadrature
                    [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath + kappa_alt * RootConditionalCovariance( :, j ), dynareOBC_ );
                    exitflag = min( exitflag, exitflag_new );
                    alpha = alpha - w2 * alpha_new;
                    [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath - kappa_alt * RootConditionalCovariance( :, j ), dynareOBC_ );
                    exitflag = min( exitflag, exitflag_new );
                    alpha = alpha - w2 * alpha_new;
                end
                if ~isempty( p )
                    p.progress;
                end
            catch Error
                warning( WarningState );
                rethrow( Error );
            end
            warning( WarningState );
        end
        if ~dynareOBC_.PseudoOrderFiveQuadrature
            wSum = wSum + 2 * d * w2;
        end
    end
    % figure( 3 ); plot( alpha );
    % alpha_alt = alpha_alt / ( 1 + 2 * d );
    % figure( 4 ); plot( alpha_alt );

    if w3 ~= 0
        parfor k = 1 : d*(d-1)/2
            WarningState = warning( 'off', 'all' );
            try
                c = floor( 0.5*(1+sqrt(8*k-7)) ) + 1;
                r = k - 0.5*(c-1)*(c-2);
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath + lambda * RootConditionalCovariance( :, r ) + kappa * RootConditionalCovariance( :, c ), dynareOBC_ ); %#ok<PFBNS>
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w3 * alpha_new;
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath + lambda * RootConditionalCovariance( :, r ) - kappa * RootConditionalCovariance( :, c ), dynareOBC_ );
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w3 * alpha_new;
                if ~isempty( p )
                    p.progress;
                end
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath - lambda * RootConditionalCovariance( :, r ) + kappa * RootConditionalCovariance( :, c ), dynareOBC_ );
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w3 * alpha_new;
                [ alpha_new, exitflag_new ] = SolveBoundsProblem( ZeroLowerBoundedReturnPath - lambda * RootConditionalCovariance( :, r ) -+ kappa * RootConditionalCovariance( :, c ), dynareOBC_ );
                exitflag = min( exitflag, exitflag_new );
                alpha = alpha + w3 * alpha_new;
                if ~isempty( p )
                    p.progress;
                end
            catch Error
                warning( WarningState );
                rethrow( Error );
            end
            warning( WarningState );
        end
        wSum = wSum + 2 * d*(d-1) * w3;
    end
    if ~isempty( p )
        p.stop;
    end
    alpha = alpha / wSum;
    
    if exitflag < 0
        warning( 'dynareOBC:QuadratureWarnings', 'Critical warnings were generated in the inner quadrature loop; accuracy may be compromised.' );
    end

end
