function dynareOBC = SetDefaultOptions( dynareOBC )
    dynareOBC = SetDefaultOption( dynareOBC, 'AltPTest', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Bypass', false );    
    dynareOBC = SetDefaultOption( dynareOBC, 'CalculateTheoreticalVariance', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'CompileSimulationCode', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'CubaturePruningCutOff', 0.01 );
    dynareOBC = SetDefaultOption( dynareOBC, 'CubatureSmoothing', -eps );
    dynareOBC = SetDefaultOption( dynareOBC, 'CubatureTolerance', 1e-5 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Debug', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'DisplayBoundsSolutionProgress', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'Estimation', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationSkipStandardErrors', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationPredictSparseCubatureDegree', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationUpdateSparseCubatureDegree', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationDataFile', [ dynareOBC.BaseFileName '.xlsx' ] );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationFixedPointMaxIterations', 1000 );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationFixedParameters', '' );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationPrior', 'FlatPrior' );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationStdDevThreshold', 1e-6 );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationTimeOutLikelihoodEvaluation', 60 );
    dynareOBC = SetDefaultOption( dynareOBC, 'FastCubature', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'FeasibilityTestGridSize', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'FirstOrderAroundRSS1OrMean2', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'FirstOrderConditionalCovariance', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'EstimationMinimisationFunctions', 'CMAESWrapper#FMinConWrapper' );   
    dynareOBC = SetDefaultOption( dynareOBC, 'FSolveFunctor', @( OptiFunction, OptiX0, varargin ) lsqnonlin( OptiFunction, OptiX0, [], [], optimset( 'algorithm', 'trust-region-reflective', 'display', 'iter', 'MaxFunEvals', Inf, 'MaxIter', Inf, 'TolX', sqrt( eps ), 'TolFun', sqrt( eps ), varargin{:} ) ) );   
    dynareOBC = SetDefaultOption( dynareOBC, 'FullHorizon', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'FullTest', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Global', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'IgnoreBoundFailures', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'IntegerTolerance', sqrt( sqrt( eps ) ) );
    dynareOBC = SetDefaultOption( dynareOBC, 'IRFPeriods', 40 );
    dynareOBC = SetDefaultOption( dynareOBC, 'IRFsAroundZero', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'LPSolver', 'xpress,gurobi,cplex,mosek,scip,linprog,glpk,lpsolve,cdd,qsopt,*' );
    dynareOBC = SetDefaultOption( dynareOBC, 'MaxCubatureDegree', 5 );    
    dynareOBC = SetDefaultOption( dynareOBC, 'MaxCubatureDimension', 128 );
    dynareOBC = SetDefaultOption( dynareOBC, 'MILPSolver', 'gurobi,cplex,xpress,mosek,scip,cbc,intlinprog,lpsolve,glpk,*' );
    dynareOBC = SetDefaultOption( dynareOBC, 'MLVSimulationAccuracy', 9 );
    dynareOBC = SetDefaultOption( dynareOBC, 'MLVSimulationMode', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'MLVSimulationSubSample', 1 );
    dynareOBC = SetDefaultOption( dynareOBC, 'NoCleanUp', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'NoCorr', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'NoCubature', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'NoDisplay', false );    
    dynareOBC = SetDefaultOption( dynareOBC, 'NoGraph', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'NoMoments', false );    
    dynareOBC = SetDefaultOption( dynareOBC, 'Omega', 1000 * ( 1 + eps ) );
    dynareOBC = SetDefaultOption( dynareOBC, 'Order', 2 );
    dynareOBC = SetDefaultOption( dynareOBC, 'OrderOverride', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'PeriodsOfUncertainty', 16 );
    dynareOBC = SetDefaultOption( dynareOBC, 'PTest', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'QuasiMonteCarloLevel', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Replications', 50 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Resume', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'ReverseSearch', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'SaveMacro', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'SaveMacroName', [ dynareOBC.BaseFileName '-macroexp.mod' ] );
    dynareOBC = SetDefaultOption( dynareOBC, 'ShockScale', 1-eps );
    dynareOBC = SetDefaultOption( dynareOBC, 'ShockSequenceFile', '' );
    dynareOBC = SetDefaultOption( dynareOBC, 'SimulateOnGridPoints', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'SimulationDrop', 100 );    
    dynareOBC = SetDefaultOption( dynareOBC, 'SimulationPeriods', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'SkipFirstSolutions', 0 );
    dynareOBC = SetDefaultOption( dynareOBC, 'SlowIRFs', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'Sparse', false );
    dynareOBC = SetDefaultOption( dynareOBC, 'TimeToSolveParametrically', 4 );
    dynareOBC = SetDefaultOption( dynareOBC, 'TimeToEscapeBounds', 32 );
    dynareOBC = SetDefaultOption( dynareOBC, 'TimeToReturnToSteadyState', 64 );
    dynareOBC = SetDefaultOption( dynareOBC, 'Tolerance', 1e-4 );
    dynareOBC = SetDefaultOption( dynareOBC, 'UseSimulationCode', true );
    dynareOBC = SetDefaultOption( dynareOBC, 'UseVPA', false );
    
    dynareOBC = orderfields( dynareOBC );
end
