
clearvars
rng(100,'twister')
uqlab



Xval=dlmread('Xval.txt');
Yval=dlmread('Yval.txt');
sobolref=zeros(6,4)
sensitivity={}
sobolref(:,1)=[1.55538786e-02, 1.82850519e-01, 9.61438769e-02, 2.99173145e-03, 1.56245611e-05, 7.60818660e-01];
sobolref(:,2)=[ 5.31159406e-02 , 1.68227767e-01 , 1.13413410e-01, -3.96239115e-04,  1.25679367e-03, 7.20783737e-01 ];
sobolref(:,3)=[3.98217241e-04 , 3.09025984e-05, -4.28701329e-05 , 1.58306471e-05,  9.94885997e-01 , 3.35410661e-04 ];
sobolref(:,4)=[7.48449580e-01,3.65262866e-03, 2.01777153e-03 ,4.39363109e-04, 1.82630159e-05, 2.43027627e-01];

methodLabels = 'OLS'

qoiLabels = {'ADP90', 'ADP50', 'dVmax', 'Vrest'};
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
p=2
Ns=2*factorial(p+6)/(factorial(6)*factorial(p))




%%OLS ordinary least square method
MetaOpts.Method = 'OLS';
MetaOpts.Degree = 2:6;
MetaOpts.ExpDesign.NSamples = Ns;
MetaOpts.ExpDesign.Sampling = 'LHS';
myPCE = uq_createModel(MetaOpts);
uq_print(myPCE)

YPCE = uq_evalModel(myPCE,Xval);
file = fopen(sprintf("Results/%s/numError.csv",methodLabels),'a');

%fprintf(file,'%s,%5s, Degree , Val. error , LOOERROR ,Max Sobol Error, Mean Sobol Error,Ns\n','QOI' ,'Method');


SobolOpts.Type = 'Sensitivity';
SobolOpts.Method = 'Sobol';

SobolOpts.Sobol.Order = 1;
SobolOpts.Sobol.SampleSize = 1e5;
mySobolAnalysisMC = uq_createAnalysis(SobolOpts);
mySobolResultsMC = mySobolAnalysisMC.Results;


 uq_figure
for q = 1:length(qoiLabels)

    Yv=Yval(:,q);
    Ypce=YPCE(:,q);
    
    a=mySobolResultsMC.FirstOrder(:,q);
    sobolavgerror=mean(abs(a-sobolref(:,q)));
    sobolmaxerror=max(abs(a-sobolref(:,q)));
    
    
    
    subplot(2,2,q);
    uq_plot(Yv, Ypce, '+');
    hold on
    uq_plot([min(Yv) max(Yv)], [min(Yv) max(Yv)], 'k');
    axis equal;
    hold off;
    title(qoiLabels{q});
    xlabel('$\mathrm{Y_{true}}$');
    ylabel(sprintf('$\\mathrm{Y_{PC}}$'));
   
    
    
    fprintf(file,'%s,%s,%5d,%f,%f,%f,%f,%4d\n',qoiLabels{q}, methodLabels,myPCE.PCE(q).Basis.Degree, mean((Yv - Ypce ).^2)/var(Yv),myPCE.Error(q).LOO,sobolavgerror,sobolmaxerror, myPCE.ExpDesign.NSamples);
   

end
 annotation('textbox', [0.05,0.85 , 0.1,0.1], 'string', sprintf('Ns %d',Ns))
 annotation('textbox', [0.05,0.8 , 0.1,0.1], 'string', sprintf(' %s',methodLabels))
 saveas(gcf,sprintf("Results/%s/Ns%d.png",methodLabels,Ns))
fclose(file);