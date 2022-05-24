

    


clearvars
rng(100,'twister')
uqlab

p=2
Ns=500

folder=sprintf("dataset/%d/",Ns)
qoiLabels = {'ADP90', 'ADP50', 'dVmax', 'Vrest'};

X=dlmread(strcat(folder,"X.csv"));
Xval=dlmread(strcat(folder,"validation/X.csv"));

Y=Yread(folder,qoiLabels);
Yval=Yread(strcat(folder,"validation/"),qoiLabels);



methodLabels = {'OLS', 'LARS', 'OMP', 'SP', 'BCS'};
methodTimes = {0,0,0,0,0}


% Define full model using mfile
% Mfile calls Python header for TTCellModel



%6 parameters  "gK1","gKs","gKr","gto","gNa","gCal"

%4 outputs ADP90, ADP50, dVmax, Vrest

vals=[5.4050e+00  0.245  0.096  2.940e-01   1.48380e+01 1.750e-04 ]
for ii = 1:6
     InputOpts.Marginals(ii).Type = 'Uniform';
    InputOpts.Marginals(ii).Parameters = [0.9*vals(ii),1.1*vals(ii)];
end


myInput = uq_createInput(InputOpts);
MetaOpts.Type = 'Metamodel';
MetaOpts.MetaType = 'PCE';
MetaOpts.ExpDesign.X = X;
MetaOpts.ExpDesign.Y = Y;
MetaOpts.ValidationSet.X = Xval;
MetaOpts.ValidationSet.Y = Yval;

%%2*factorial(p+6)/(factorial(6)*factorial(p))




%%OLS ordinary least square method
MetaOpts.Method = 'OLS';
MetaOpts.Degree = 2:4;

tic
myPCE_OLS = uq_createModel(MetaOpts);
methodTimes{1}=toc

%LARS 
MetaOpts.Method = 'LARS';
MetaOpts.Degree = 2:4;
MetaOpts.TruncOptions.qNorm = 0.75;

tic
myPCE_LARS = uq_createModel(MetaOpts);
methodTimes{2}=toc


%OMP 
MetaOpts.Method = 'OMP';
MetaOpts.Degree = 2:4;
MetaOpts.TruncOptions.qNorm = 0.75;

tic
myPCE_OMP = uq_createModel(MetaOpts);
methodTimes{3}=toc
% SP subspace pursuit

MetaOpts.Method = 'SP';
MetaOpts.Degree = 2:4;
MetaOpts.TruncOptions.qNorm = 0.75;

tic
myPCE_SP = uq_createModel(MetaOpts);
methodTimes{4}=toc

%BCS
MetaOpts.Method = 'BCS';
MetaOpts.Degree = 2:4;
MetaOpts.TruncOptions.qNorm = 0.75;

tic
myPCE_BCS = uq_createModel(MetaOpts);
methodTimes{5}=toc

myPCEs = { myPCE_OLS, myPCE_LARS, myPCE_OMP, myPCE_SP, myPCE_BCS};

%YQuadrature = uq_evalModel(myPCE_Quadrature,Xval);
YOLS = uq_evalModel(myPCE_OLS,Xval);
YLARS = uq_evalModel(myPCE_LARS,Xval);
YOMP = uq_evalModel(myPCE_OMP,Xval);
YSP = uq_evalModel(myPCE_SP,Xval);
YBCS = uq_evalModel(myPCE_BCS,Xval);
YPCE = {YOLS, YLARS, YOMP, YSP, YBCS};

mkdir(folder,'results')
file = fopen(strcat(folder,"results/numeric.csv"),'w');

fprintf(file,'%s,%s,Degree,Val. error,LOOERROR,Ns,Time\n','QOI' ,'Method');


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
    methodTimes{i}
    hold off;
    title(methodLabels{i});
    xlabel('$\mathrm{Y_{true}}$');
    ylabel(sprintf('$\\mathrm{Y_{PC}}$'));
    fprintf(file,'%s,%s,%d,%10.4e,%10.4e,%7d, %10.4e\n',qoiLabels{q}, methodLabels{i},myPCEs{i}.PCE(q).Basis.Degree, mean((Yv - Ypce ).^2)/var(Yv),myPCEs{i}.Error(q).LOO, myPCEs{i}.ExpDesign.NSamples,methodTimes{i});


end
annotation('textbox', [0.05,0.85 , 0.1,0.1], 'string', sprintf('Ns %d',Ns))
annotation('textbox', [0.05,0.8 , 0.1,0.1], 'string', sprintf(' %s',qoiLabels{q}))
saveas(gcf,strcat(folder,'results/',sprintf("%s.png",qoiLabels{q})))








hold off
end
fclose(file);
