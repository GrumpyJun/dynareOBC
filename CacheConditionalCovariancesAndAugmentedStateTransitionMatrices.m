function dynareOBC_ = CacheConditionalCovariancesAndAugmentedStateTransitionMatrices( M_, options_, oo_, dynareOBC_ )

    T = dynareOBC_.InternalIRFPeriods;
    Ts = dynareOBC_.TimeToEscapeBounds;
    TsM2 = Ts - 2;
    ns = dynareOBC_.NumberOfMax;
    SelectState = dynareOBC_.SelectState;
    nEndo = M_.endo_nbr;
    
    dynareOBC_.MaxIntegrationDimension = min( dynareOBC_.MaxIntegrationDimension, TsM2 * ns );
    
    % pre-calculations for order=1 terms
    A1 = sparse( nEndo, nEndo );
    A1( :, SelectState ) = oo_.dr.ghx;
    A1( abs(A1)<eps ) = 0;

    B1 = spsparse( oo_.dr.ghu );

    Sigma = spsparse( M_.Sigma_e );
    dynareOBC_.OriginalSigma = Sigma;

    if ( dynareOBC_.Order == 1 ) && dynareOBC_.CalculateTheoreticalVariance
        dynareOBC_.Var_z1 = SparseLyapunovSymm( A1, B1*Sigma*B' );
    end
        
    CurrentInternal = B1 * Sigma * B1';
    VarianceZ1 = cell( TsM2, 1 );
    VarianceZ1{1} = CurrentInternal;

    for k = 2 : TsM2
        CurrentInternal = A1 * CurrentInternal * A1';
        CurrentInternal( abs(CurrentInternal)<eps ) = 0;
        VarianceZ1{ k } = VarianceZ1{ k - 1 } + CurrentInternal;
    end

    Order2ConditionalCovariance = dynareOBC_.Accuracy > 0 && ~( options_.order == 1 || dynareOBC_.FirstOrderConditionalCovariance );
    Order2VarianceRequired = ( dynareOBC_.Order == 2 ) && dynareOBC_.CalculateTheoreticalVariance;
    
    if dynareOBC_.Order > 1 || Order2ConditionalCovariance
        % pre-calculations common to finding the state transition when dynareOBC_.Order > 1 and to finding the conditional covariance when Order2ConditionalCovariance=true
        
        nState = length( SelectState );
        nExo = M_.exo_nbr;
        nExo2 = nExo * nExo;
        
        % Idx1 =  1:nEndo;
        % Idx2 = (nEndo+1):(2*nEndo);
        % Idx3 = (2*nEndo+1):LengthZ2;
        
        % A2( Idx1, Idx1 ) = A1;
        [ A2i, A2j, A2s ] = spfind( A1 );
        
        % A2( Idx2, Idx2 ) = A1;
        A2i = [ A2i; A2i + nEndo ];
        A2j = [ A2j; A2j + nEndo ];
        A2s = [ A2s; A2s ];
        
        % A2( Idx2, Idx3 ) = 0.5 * oo_.dr.ghxx;
        beta22 = spsparse( oo_.dr.ghxx );
        [ Tmpi, Tmpj, Tmps ] = find( beta22 );
        A2i = [ A2i; Tmpi + nEndo ];
        A2j = [ A2j; Tmpj + 2*nEndo ];
        A2s = [ A2s; 0.5 * Tmps ];
        
        % A2( Idx3, Idx3 ) = spkron( oo_.dr.ghx( SelectState, : ), oo_.dr.ghx( SelectState, : ) );
        A1S = A1( SelectState, SelectState );
        A1S2 = spkron( A1S, A1S );
        [ Tmpi, Tmpj, Tmps ] = find( A1S2 );
        A2i = [ A2i; Tmpi + 2*nEndo ];
        A2j = [ A2j; Tmpj + 2*nEndo ];
        A2s = [ A2s; Tmps ];
        
        nState2 = nState * nState;
        LengthZ2 = 2 * nEndo + nState2;
        
        A2 = sparse( A2i, A2j, A2s, LengthZ2, LengthZ2 );
 
        B1S = B1( SelectState, : );
        B1S2 = ( spkron( B1S, B1S ) );
        
    end
    
    if dynareOBC_.Order > 2 || Order2ConditionalCovariance || Order2VarianceRequired

        K_nState_nState = commutation_sparse( nState, nState );
        
    end
    
    if Order2ConditionalCovariance || Order2VarianceRequired

        % Jdx1 = 1:nExo;
        % Jdx2 = (nExo+1):(nExo + nExo2);
        % Jdx3 = (nExo + nExo2 + 1):LengthXi;

        % B2( Idx1, Jdx1 ) = oo_.dr.ghu;
        [ B2i, B2j, B2s ] = find( B1 );

        % B2( Idx2, Jdx2 ) = 0.5 * oo_.dr.ghuu;
        [ Tmpi, Tmpj, Tmps ] = spfind( 0.5 * oo_.dr.ghuu );
        B2i = [ B2i; Tmpi + nEndo ];
        B2j = [ B2j; Tmpj + nExo ];
        B2s = [ B2s; Tmps ];

        % B2( Idx2, Jdx3 ) = oo_.dr.ghxu;
        [ Tmpi, Tmpj, Tmps ] = spfind( oo_.dr.ghxu );
        B2i = [ B2i; Tmpi + nEndo ];
        B2j = [ B2j; Tmpj + nExo + nExo2 ];
        B2s = [ B2s; Tmps ];

        % B2( Idx3, Jdx2 ) = spkron( oo_.dr.ghu( SelectState, : ), oo_.dr.ghu( SelectState, : ) );
        [ Tmpi, Tmpj, Tmps ] = find( B1S2 );
        B2i = [ B2i; Tmpi + 2*nEndo ];
        B2j = [ B2j; Tmpj + nExo ];
        B2s = [ B2s; Tmps ];

        % B2( Idx3, Jdx3 ) = ( speye( nState * nState ) + commutation_sparse( nState, nState ) ) * spkron( oo_.dr.ghx( SelectState, : ), oo_.dr.ghu( SelectState, : ) );
        [ Tmpi, Tmpj, Tmps ] = find( ( speye( nState2 ) + K_nState_nState ) * spkron( A1S, B1S ) );
        B2i = [ B2i; Tmpi + 2*nEndo ];
        B2j = [ B2j; Tmpj + nExo + nExo2 ];
        B2s = [ B2s; Tmps ];

        LengthXi = nExo + nExo2 + nState * nExo;

        B2 = sparse( B2i, B2j, B2s, LengthZ2, LengthXi );  

        % BCovXiB{i}( Jdx1, Jdx1 ) = Sigma;
        [ Vi, Vj, Vs ] = find( Sigma );

        % BCovXiB{i}( Jdx2, Jdx2 ) = dynareOBC_.Variance_exe;
        [ Tmpi, Tmpj, Tmps ] = find( ( speye( nExo2 ) + commutation_sparse( nExo, nExo ) ) * spkron( Sigma, Sigma ) );
        Vi = [ Vi; Tmpi + nExo ];
        Vj = [ Vj; Tmpj + nExo ];
        Vs = [ Vs; Tmps ];
        
    end
        
    if Order2VarianceRequired
        
        [ Tmpi, Tmpj, Tmps ] = spkron( dynareOBC_.Var_z1( SelectState, SelectState ), Sigma );
        Ui = [ Vi; Tmpi + nExo + nExo2 ];
        Uj = [ Vj; Tmpj + nExo + nExo2 ];
        Us = [ Vs; Tmps ];

        UnconditionalVarXi = sparse( Ui, Uj, Us, LengthXi, LengthXi );

        dynareOBC_.Var_z = SparseLyapunovSymm( A2, B2*UnconditionalVarXi*B2' );
        
    end
    
    if dynareOBC_.Order > 2
        
        [ A3i, A3j, A3s ] = find( A2 );
        
        T1 = sparse( nEndo, nEndo );
        T1( :, SelectState ) = 0.5 * oo_.dr.ghxss_nlma;

        [ Tmpi, Tmpj, Tmps ] = spfind( T1 );
        A3i = [ A3i; Tmpi + LengthZ2 ];
        A3j = [ A3j; Tmpj ];
        A3s = [ A3s; Tmps ];
        
        k1 = LengthZ2 + nEndo;
        [ Tmpi, Tmpj, Tmps ] = find( A1 );
        A3i = [ A3i; Tmpi + LengthZ2; Tmpi + k1 ];
        A3j = [ A3j; Tmpj + LengthZ2; Tmpj + k1 ];
        A3s = [ A3s; Tmps; Tmps ];
        
        IKVecSigma = spkron( speye( nState ), vec( Sigma ) );
        T1 = sparse( nEndo, nEndo );
        T1( :, SelectState ) = 0.5 * oo_.dr.ghxuu * IKVecSigma;
        [ Tmpi, Tmpj, Tmps ] = spfind( T1 );
        A3i = [ A3i; Tmpi + k1 ];
        A3j = [ A3j; Tmpj ];
        A3s = [ A3s; Tmps ];
        
        k2 = k1 + nEndo;
        [ Tmpi, Tmpj, Tmps ] = find( beta22 );
        A3i = [ A3i; Tmpi + k1 ];
        A3j = [ A3j; Tmpj + k2 ];
        A3s = [ A3s; Tmps ];

        k3 = k2 + nState2;
        [ Tmpi, Tmpj, Tmps ] = spfind( (1/6) * oo_.dr.ghxxx );
        A3i = [ A3i; Tmpi + k1 ];
        A3j = [ A3j; Tmpj + k3 ];
        A3s = [ A3s; Tmps ];
        
        [ Tmpi, Tmpj, Tmps ] = spfind( ( spkron( oo_.dr.ghxu( SelectState, : ), B1S ) + 0.5 * K_nState_nState * spkron( A1S, oo_.dr.ghuu( SelectState, : ) ) ) * IKVecSigma );
        A3i = [ A3i; Tmpi + k2 ];
        A3j = [ A3j; Tmpj ];
        A3s = [ A3s; Tmps ];
        
        [ Tmpi, Tmpj, Tmps ] = find( A1S2 );
        A3i = [ A3i; Tmpi + k2 ];
        A3j = [ A3j; Tmpj + k2 ];
        A3s = [ A3s; Tmps ];
        
        [ Tmpi, Tmpj, Tmps ] = spkron( 0.5 * beta22( SelectState, : ), A1S );
        A3i = [ A3i; Tmpi + k2 ];
        A3j = [ A3j; Tmpj + k3 ];
        A3s = [ A3s; Tmps ];
        
        [ Tmpi, Tmpj, Tmps ] = find( ( ( spkron( speye( nState2 ) + K_nState_nState, speye( nState ) ) + commutation_sparse( nState2, nState ) ) * spkron( A1S, B1S2 ) ) * IKVecSigma );
        A3i = [ A3i; Tmpi + k3 ];
        A3j = [ A3j; Tmpj ];
        A3s = [ A3s; Tmps ];
        
        [ Tmpi, Tmpj, Tmps ] = spkron( A1S, A1S2 );
        A3i = [ A3i; Tmpi + k3 ];
        A3j = [ A3j; Tmpj + k3 ];
        A3s = [ A3s; Tmps ];
        
        LengthZ3 = k3 + nState2 * nState;
        A3 = sparse( A3i, A3j, A3s, LengthZ3, LengthZ3 );
        
    end
    
    % Save augmented state transition matrices
    if dynareOBC_.Order == 1
        dynareOBC_.A = A1;
        % dynareOBC_.B = B1;
        dynareOBC_.AugmentedToTotal = speye( nEndo );
    elseif dynareOBC_.Order == 2
        dynareOBC_.A = A2;
        % dynareOBC_.B = B2;
        dynareOBC_.AugmentedToTotal = [ speye( nEndo ) speye( nEndo ) sparse( nEndo, nState2 ) ];
    elseif dynareOBC_.Order == 3
        dynareOBC_.A = A3;
        % dynareOBC_.B = B2;
        dynareOBC_.AugmentedToTotal = [ speye( nEndo ) speye( nEndo ) sparse( nEndo, nState2 ) speye( nEndo ) speye( nEndo ) sparse( nEndo, nState2 + nState2 * nState ) ];
    else
        error( 'dynareOBC:UnsupportedOrder', 'Order %d is unsupported at present. The only currently supported orders are 1, 2 and 3.', dynareOBC_.Order );
    end

    % Calculate mean
    if dynareOBC_.Order == 1
        c = sparse( nEndo, 1 );
    else
        [ MOi, MOj, MOs ] = spfind( 0.5 * ( oo_.dr.ghuu * vec( Sigma ) ) );
        [ Tmpi, Tmpj, Tmps ] = spfind( B1S2 * vec( Sigma ) );
        MOi = [ MOi + nEndo; Tmpi + 2*nEndo ];
        MOj = [ MOj; Tmpj ];
        MOs = [ MOs; Tmps ];
        if dynareOBC_.Order == 2
            c = sparse( MOi, MOj, MOs, LengthZ2, 1 );
        else
            c = sparse( MOi, MOj, MOs, LengthZ3, 1 );
        end
    end
    dynareOBC_.c = c;
    Mean_z = ( speye( size( dynareOBC_.A ) ) - dynareOBC_.A ) \ c;
    dynareOBC_.Mean_z = Mean_z;
    
    % disp( eigs( dynareOBC_.A, 5 ) );
    
    RelativeMean = dynareOBC_.AugmentedToTotal * Mean_z;
    dynareOBC_.RelativeMean = RelativeMean( oo_.dr.inv_order_var );
    dynareOBC_.Mean = dynareOBC_.RelativeMean + dynareOBC_.Constant;
    
    % Calculate conditional covariances
    if dynareOBC_.Accuracy > 0
        OpenPool;
        if ~Order2ConditionalCovariance

            A1Powers = cell( TsM2, 1 );
            A1Powers{1} = speye( size( A1 ) );

            for k = 2 : TsM2
                A1Powers{ k } = A1 * A1Powers{ k - 1 };
                A1Powers{ k }( abs(A1Powers{ k })<eps ) = 0;
            end

            ConditionalCovariance = zeros( T * ns, T * ns );
            StepIndices = 0:T:T*(ns-1);

            inv_order_var = oo_.dr.inv_order_var;
            VarIndices_ZeroLowerBounded = dynareOBC_.VarIndices_ZeroLowerBounded;

            LengthConditionalCovarianceTemp = 0.5 * TsM2 * ( TsM2 + 1 );
            ConditionalCovarianceTemp = cell( LengthConditionalCovarianceTemp, 1 );

            parfor i = 1 : LengthConditionalCovarianceTemp
                p = floor( 0.5 * ( 1 + sqrt( 8 * i - 7 ) ) );
                q = i - 0.5 * p * ( p - 1 );
                pWeight = ( 1 - ( p - 1 ) / TsM2 );
                qWeight = ( 1 - ( q - 1 ) / TsM2 );
                CurrentCov = A1Powers{ p - q + 1 } * VarianceZ1{ q }; %#ok<PFBNS>
                ReducedCov = full( CurrentCov( inv_order_var( VarIndices_ZeroLowerBounded ), inv_order_var( VarIndices_ZeroLowerBounded ) ) ); %#ok<PFBNS>
                ConditionalCovarianceTemp{i} = ( pWeight * qWeight * 0.5 ) * ( ReducedCov + ReducedCov' );
            end
            for p = 1 : TsM2
                for q = 1 : p
                    i = 0.5 * p * ( p - 1 ) + q;
                    ConditionalCovariance( 1 + p + StepIndices, 1 + q + StepIndices ) = ConditionalCovarianceTemp{i};
                end
                for q = (p+1) : TsM2
                    i = 0.5 * q * ( q - 1 ) + p;
                    ConditionalCovariance( 1 + p + StepIndices, 1 + q + StepIndices ) = ConditionalCovarianceTemp{i}';
                end
            end

            [U,D] = schur( ConditionalCovariance, 'complex' );
            assert( isreal( U ) );
            diagD = diag( D );
            assert( isreal( diagD ) );
            RootD = sqrt( max( 0, diagD ) );
            RootD( 1 : end - dynareOBC_.MaxIntegrationDimension ) = 0;
            IDv = RootD > sqrt( eps );
            dynareOBC_.RootConditionalCovariance = U( :, IDv ) * diag( RootD( IDv ) );

            % [L,D] = ldl( ConditionalCovariance );
            % assert( isdiag( D ) );
            % diagD = diag( D );
            % RootD = sqrt( max( 0, diagD ) );
            % NRootD = sort( RootD );
            % RootD( RootD <= NRootD( end - dynareOBC_.MaxIntegrationDimension ) ) = 0;
            % IDv = RootD > sqrt( eps );
            % dynareOBC_.RootConditionalCovariance = L( :, IDv ) * diag( RootD( IDv ) );

        else

            if options_.order > 2
                warning( 'dynareOBC:ApproximatingConditionalCovariance', 'At present, dynareOBC approximates the conditional covariance of third order approximations with the conditional covariance of a second order approximation.' );
            end

            A2Powers = cell( TsM2, 1 );
            A2Powers{1} = speye( size( A2 ) );

            for k = 2 : TsM2
                A2Powers{ k } = A2 * A2Powers{ k - 1 };
                A2Powers{ k }( abs(A2Powers{ k })<eps ) = 0;
            end

            VarianceY1State = cell( TsM2, 1 );
            VarianceY1State{1} = zeros( nState );

            parfor k = 2 : TsM2
                VarianceY1State{k} = VarianceZ1{ k - 1 }( SelectState, SelectState );
            end

            % dynareOBC_.A1Powers = A1Powers;
            dynareOBC_.A2Powers = A2Powers;
            dynareOBC_.B2 = B2;
            dynareOBC_.VarianceY1State = VarianceY1State;
            dynareOBC_.LengthXi = LengthXi;

            dynareOBC_.VarianceXiSkeleton = sparse( Vi, Vj, Vs, LengthXi, LengthXi );

        end
    end

end