
clearvars
rng(100,'twister')
uqlab
methodLabels = {'Quadrature', 'OLS', 'LARS', 'OMP', 'SP', 'BCS'};



% Define full model using mfile
% Mfile calls Python header for TTCellModel



%6 parameters  "gK1","gKs","gKr","gto","gNa","gCal"
Model1Opts.mFile = 'model';
%4 outputs ADP90, ADP50, dVmax, Vrest
myModel = uq_createModel(Model1Opts);
vals=[5.4050e+00  0.245  0.096  2.940e-01   1.48380e+01 1.750e-04 ]
for ii = 1:6
    InputOpts.Marginals(ii).Type = 'Uniform';
    InputOpts.Marginals(ii).Parameters = [0.9*vals(ii),1.1*vals(ii)];
end
myInput = uq_createInput(InputOpts);
MetaOpts.Type = 'Metamodel';
MetaOpts.MetaType = 'PCE';
MetaOpts.FullModel = myModel;

%LARS 
MetaOpts.Method = 'LARS';
MetaOpts.Degree = 1:8;
MetaOpts.TruncOptions.qNorm = 0.75;
MetaOpts.ExpDesign.NSamples = 150;
MetaOpts.ExpDesign.Sampling = 'LHS';
myPCE_LARS = uq_createModel(MetaOpts);
uq_print(myPCE_LARS)

%%OLS ordinary least square method
MetaOpts.Method = 'OLS';
MetaOpts.Degree = 3:15;
MetaOpts.ExpDesign.NSamples = 150;
MetaOpts.ExpDesign.Sampling = 'LHS';
myPCE_OLS = uq_createModel(MetaOpts);
uq_print(myPCE_OLS)


%OMP 
MetaOpts.Method = 'OMP';
MetaOpts.Degree = 3:15;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_OMP = uq_createModel(MetaOpts);
uq_print(myPCE_OMP)

% SP subspace pursuit

MetaOpts.Method = 'SP';
MetaOpts.Degree = 3:15;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_SP = uq_createModel(MetaOpts);
uq_print(myPCE_SP)

%BCS
MetaOpts.Method = 'BCS';
MetaOpts.Degree = 3:15;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_BCS = uq_createModel(MetaOpts);
uq_print(myPCE_BCS)

