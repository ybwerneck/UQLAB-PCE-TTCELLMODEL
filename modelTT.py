###Base e modelo 
import subprocess 
import sys
import numpy as np
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import mpld3
from scipy.integrate import odeint
import lmfit
from lmfit.lineshapes import gaussian, lorentzian
import chaospy as cp
from scipy.integrate import odeint
from lmfit import minimize, Parameters, Parameter, report_fit
from SALib.sample import saltelli
from SALib.analyze import sobol
import timeit
import re
import collections

class TTCellModel:
    tf=1000
    ti=0
    dt=0.01
    dtS=1
    parametersN=["gK1","gKs","gKr","gNa","gbna","gCal","gbca","gto"]
    def setParametersOfInterest(parametersN):
        TTCellModel.parametersN=parametersN
    def parametize(self,ps):
        params={}
        i=0;
      
        if(np.isscalar(ps) and ps!='' ):
            params[TTCellModel.parametersN[0]]=ps
            return params
        
        for val  in (TTCellModel.parametersN):
               try:
                    if(ps!=''):
                        params[val]=ps[i]
                    else:
                        params[val]=-100
               except:
                    params[val]=-100
               
               i=i+1
        return params;
    
    def __init__(self,params):
        self.parameters = self.parametize(params)
    
    @staticmethod
    def getSimSize(): #Returns size of result vector for given simulation size parameters, usefull for knowing beforehand the number of datapoints to compare
        n=TTCellModel("").run()["Wf"].shape
        return n
    
    @staticmethod
    def setSizeParameters(ti,tf,dt,dtS):
        TTCellModel.ti=ti
        TTCellModel.tf=tf
        TTCellModel.dt=dt
        TTCellModel.dtS=dtS
        return (400, 2)
    @staticmethod   #runs the model once for the given size parameters and returns the time points at wich there is evalution
    def getEvalPoints():
        n=TTCellModel("").run()["Wf"]
        tss= np.zeros(n.shape[0])
        for i,timepoint in enumerate(n[:,0]):
            tss[i]=float(timepoint[0]);
            
        return tss
    
    
    @staticmethod      
    def ads(sol,repoCofs): ##calculo da velocidade de repolarização
        k=0
        i=0;
        out={}
        x=sol
        flag=0
        try: 
            try:
                x=sol[0:+TTCellModel.tf,0].ravel().transpose()
            except:
                x=sol
            index=0
            for value in x:
                index+=1  
                if(value==x.max()):
                        flag=1                
                        out[len(repoCofs)]=index  + TTCellModel.ti
                if(flag==1):
                        k+=1
                if(flag==1 and repoCofs[i]*x.min() >= value):
                        out[i]=k  
                        i+=1
                if(i>=len(repoCofs)):
                        break
        except:
            print("ADCALCERROR")
            print(x)       
        return out
    
    def callCppmodel(self,params):     
        args="C:\\s\\uriel-numeric\\Release\\cardiac-cell-solver.exe " +"--tf="+str(TTCellModel.tf)+" --ti="+str(TTCellModel.ti)+" --dt="+str(TTCellModel.dt)+" --dt_save="+str(TTCellModel.dtS)  
        for value in params:
            if(params[value]!=-100):
                args+= " "
                args+=" --"+value+"="+(str(params[value]))[:9]
        output = subprocess.Popen(args,stdout=subprocess.PIPE)
        matrix={}
        try:
            string = output.stdout.read().decode("utf-8")
            matrix = np.matrix(string)
            
        
        except:
            print(args)
            print(string)
            print(params)
            print("\n")
        
      
       
        try: 
            ads=TTCellModel.ads(matrix[:-1,1],[0.5,0.9])
         
            return {"Wf": matrix[:-1],"dVmax":matrix[-1,1],"ADP90":ads[1],"ADP50":ads[0],"Vrepos":matrix[-2,1]}
        except:
           
           return {"Wf":0,"dVmax":0,"ADP90":0,"ADP50":0,"Vrepos":0}
       
    def plot_sir(r, labels):
        
        x=(r[:,0])
        y=(r[:,1])
        plt.plot(x, y,label=labels[0])

   
            
        plt.xlabel("tempo")
        plt.ylabel("Variação no potencial")
        plt.legend(loc='best')
        plt.show()
        
        # parametros 
  
    def run(self):  
        x = self.callCppmodel(self.parameters)
        return x
    
   
    
    