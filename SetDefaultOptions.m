function dynareOBC_ = SetDefaultOptions( dynareOBC_ )
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Accuracy', 1 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Algorithm', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'CalculateTheoreticalVariance', false );    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'DensityAccuracy', 10 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'DensityEstimationSimulationLengthMultiplier', 10 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'FastIRFs', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'FirstOrderAroundRSS1OrMean2', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'FirstOrderConditionalCovariance', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'ForceEqualQuadratureWeights', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'HomotopySteps', 10 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'IRFPeriods', 40 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'IRFsAroundZero', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'MaxIntegrationDimension', Inf );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'MaxIterations', 1000 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'NoCleanUp', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'NoCorr', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'NoDisplay', false );    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'NoGraph', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'NoMoments', false );    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Objective', 2 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Order', 2 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'OrderFiveQuadrature', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'PseudoOrderFiveQuadrature', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'RegressionBaseSampleSize', 1000 );    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'RegressionSampleSizeMultiplier', 30 );   
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'RemoveNegativeQuadratureWeights', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Replications', 50 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Resume', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'SaveMacro', false );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'SaveMacroName', [ dynareOBC_.BaseFileName '-macroexp.mod' ] );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Scale_kappa_lambda', 1 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'ShadowShockNumberMultiplier', [] ); % set later
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'ShadowApproximatingOrder', [] ); % set later    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'SimulationDrop', 100 );    
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'SimulationPeriods', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Sparse', 1 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'TimeToEscapeBounds', 10 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'TimeToReturnToSteadyState', 0 );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'Tolerance', sqrt( eps ) );
    dynareOBC_ = SetDefaultOption( dynareOBC_, 'UseFICOXpress', false );
    
    dynareOBC_ = orderfields( dynareOBC_ );
end