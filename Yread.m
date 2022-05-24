function [m]= Yread(adrs,qoiLabels)
 for q = 1:length(qoiLabels)
   m(:,q)=dlmread(sprintf(adrs+qoiLabels{q}+'.csv'));

 
end



    
