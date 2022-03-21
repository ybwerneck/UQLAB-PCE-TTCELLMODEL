

function Y = model(P)
     
    Ns=size(P,1);
    
    Y=zeros(Ns,4);
    ADP90=[];
    ADP50=[];
    dVmax=[];
    vRest=[];
    
    f=Ns;
    parfor ii =1:Ns
    %call python handler
   %"gK1","gKs","gKr","gto","gNa","gCal"
    a='';
    Pt=P(ii,1:6);
    a=sprintf(' %.6f %.6f %.6f %.6f %.6f %.6f ',Pt(1),Pt(2),Pt(3),Pt(4),Pt(5),Pt(6),a);
    command = 'python C:\Users\yanbw\.spyder-py3\projeto\simplemodel.py ';
    command = strcat(command,a);
    [status,cmdout] = system(command);
    %%process output
      C = strsplit(cmdout,'\n');
 
    cmdout=C(3);
    cmdout=strrep(cmdout,'[','');
    cmdout=strrep(cmdout,']','');
    cmdout=strrep(cmdout,"'","");
    cmdout=strip(cmdout);
 
    
    Yt =str2num(cmdout);
    
    ADP90(ii)=Yt(1);
    ADP50(ii)=Yt(2);
    dVmax(ii)=Yt(3);
    vRest(ii)=Yt(4);

    end
    Y(:,1)=  ADP90;
    Y(:,2)=  ADP50;
    Y(:,3)=  dVmax;
    Y(:,4)=  vRest;
    

