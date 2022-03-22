
clearvars
rng(100,'twister')
uqlab



Xval=dlmread('Xval.txt');
Yval=dlmread('Yval.txt');



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
Ns=150
%%OLS ordinary least square method
MetaOpts.Method = 'OLS';
MetaOpts.Degree = 2:6;
MetaOpts.ExpDesign.NSamples = Ns;
MetaOpts.ExpDesign.Sampling = 'LHS';
myPCE_OLS = uq_createModel(MetaOpts);
uq_print(myPCE_OLS)


%LARS 
MetaOpts.Method = 'LARS';
MetaOpts.Degree = 2:6;
MetaOpts.TruncOptions.qNorm = 0.75;
MetaOpts.ExpDesign.NSamples = Ns;
MetaOpts.ExpDesign.Sampling = 'LHS';
myPCE_LARS = uq_createModel(MetaOpts);
uq_print(myPCE_LARS)


%OMP 
MetaOpts.Method = 'OMP';
MetaOpts.Degree = 2:6;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_OMP = uq_createModel(MetaOpts);
uq_print(myPCE_OMP)

% SP subspace pursuit

MetaOpts.Method = 'SP';
MetaOpts.Degree = 2:6;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_SP = uq_createModel(MetaOpts);
uq_print(myPCE_SP)

%BCS
MetaOpts.Method = 'BCS';
MetaOpts.Degree = 2:6;
MetaOpts.TruncOptions.qNorm = 0.75;
myPCE_BCS = uq_createModel(MetaOpts);
uq_print(myPCE_BCS)

%Quadrature
MetaOpts.Method = 'Quadrature';     
MetaOpts.Degree = 7;
myPCE_Quadrature = uq_createModel(MetaOpts);
uq_print(myPCE_Quadrature)

YQuadrature = uq_evalModel(myPCE_Quadrature,Xval);
YOLS = uq_evalModel(myPCE_OLS,Xval);
YLARS = uq_evalModel(myPCE_LARS,Xval);
YOMP = uq_evalModel(myPCE_OMP,Xval);
YSP = uq_evalModel(myPCE_SP,Xval);
YBCS = uq_evalModel(myPCE_BCS,Xval);
YPCE = {YQuadrature, YOLS, YLARS, YOMP, YSP, YBCS};
uq_figure
for i = 1:length(YPCE)

    subplot(2,3,i)
    uq_plot(Yval, YPCE{i}, '+')
    hold on
    uq_plot([min(Yval) max(Yval)], [min(Yval) max(Yval)], 'k')
    hold off
    axis equal
 

    title(methodLabels{i})
    xlabel('$\mathrm{Y_{true}}$')
    ylabel('$\mathrm{Y_{PC}}$')

end