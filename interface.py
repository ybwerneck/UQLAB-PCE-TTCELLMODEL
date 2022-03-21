# -*- coding: utf-8 -*-
"""
Created on Wed Dec  8 22:44:43 2021

@author: yanbw
"""

from modelTT import TTCellModel

import timeit
import matplotlib.pyplot as plt
import warnings


import sys

labels=["gK1","gKs","gKr","gto","gNa","gCal"]


TTCellModel.setParametersOfInterest(labels)
##Simple model use, usefull for
ti=0
ti=3000
tf=3400
dt=0.01
dtS=1
TTCellModel.setSizeParameters(ti, tf, dt, dtS)


try: 
    sample=[sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6]]
    model=TTCellModel(sample)
except:
    model=TTCellModel("")
result=model.run()

try:
    x=((result["Wf"]))[:,0]
    y=((result["Wf"]))[:,1]

except:
    x=0
    y=0


#
#plt.plot(x, y,label="W",color="r")

   
#plt.axvline(x=result["ADP90"], label='ADP90')
#plt.axvline(x=result["ADP50"], label='ADP50',color='g') 
#plt.axhline(y=result["Vrepos"], label='Vrepos',color='b')

#plt.xlabel("tempo")
#plt.ylabel("Variação no potencial")
#plt.legend(loc='best')
#plt.show()
#        

matrix=[0,0,0,0]
matrix[0]=result["ADP90"]
matrix[1]=result["ADP50"]
matrix[2]=result["dVmax"]
matrix[3]=result["Vrepos"] 
print(matrix)