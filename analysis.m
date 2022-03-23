
clearvars
rng(100,'twister')
uqlab



Xval=dlmread('Xval.txt');
Yval=dlmread('Yval.txt');



methodLabels = {'OLS', 'LARS', 'OMP', 'SP', 'BCS'};

qoiLabels = {'ADP90', 'ADP50', 'dVmax', 'Vrest'};

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


myPCEs = { myPCE_OLS, myPCE_LARS, myPCE_OMP, myPCE_SP, myPCE_BCS};

%YQuadrature = uq_evalModel(myPCE_Quadrature,Xval);
YOLS = uq_evalModel(myPCE_OLS,Xval);
YLARS = uq_evalModel(myPCE_LARS,Xval);
YOMP = uq_evalModel(myPCE_OMP,Xval);
YSP = uq_evalModel(myPCE_SP,Xval);
YBCS = uq_evalModel(myPCE_BCS,Xval);
YPCE = {YOLS, YLARS, YOMP, YSP, YBCS};
file = fopen(sprintf("Results/methodscomp/numeric/ErrornumericNs%d.txt",Ns),'w');

fprintf(file,'Validation error:\n');
fprintf(file,'%s,%s,Degree,Val. error,LOOERROR,Ns\n','QOI' ,'Method');

for q = 1:length(qoiLabels)
 uq_figure
    
for i = 1:length(YPCE)

    Yv=Yval(:,q);
    subplot(2,3,i);
    Ypce=YPCE{i}(:,q);
    uq_plot(Yv, Ypce, '+');
    hold on
    uq_plot([min(Yv) max(Yv)], [min(Yv) max(Yv)], 'k');
   
    axis equal;
 
    hold off;
    title(methodLabels{i});
    xlabel('$\mathrm{Y_{true}}$');
    ylabel(sprintf('$\\mathrm{Y_{PC}}$'));
    fprintf(file,'%s,%s,%d,%10.2e,%10.2e,%7d\n',qoiLabels{q}, methodLabels{i},myPCEs{q}.PCE(q).Basis.Degree, mean((Yv - Ypce ).^2)/var(Yv),myPCEs{i}.Error(2).LOO, myPCEs{i}.ExpDesign.NSamples);


end
annotation('textbox', [0.05,0.85 , 0.1,0.1], 'string', sprintf('Ns %d',Ns))
annotation('textbox', [0.05,0.8 , 0.1,0.1], 'string', sprintf(' %s',qoiLabels{q}))
saveas(gcf,sprintf("Results/methodscomp/%s/compNs%d.png",qoiLabels{q},Ns))








hold off
end
fclose(file);
