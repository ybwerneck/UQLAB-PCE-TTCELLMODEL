uqlab
Model1Opts.mFile = 'model';
%4 outputs ADP90, ADP50, dVmax, Vrest
myModel = uq_createModel(Model1Opts);
MetaOpts.ExpDesign.Sampling = 'LHS';


%6 parameters  "gK1","gKs","gKr","gto","gNa","gCal"
vals=[5.4050e+00  0.245  0.096  2.940e-01   1.48380e+01 1.750e-04 ]
for ii = 1:6
    InputOpts.Marginals(ii).Type = 'Uniform';
    InputOpts.Marginals(ii).Parameters = [0.9*vals(ii),1.1*vals(ii)];
end
myInput = uq_createInput(InputOpts);

