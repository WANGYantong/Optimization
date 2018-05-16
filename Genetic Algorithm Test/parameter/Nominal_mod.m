function [totalcost,solution] = Nominal_mod(solution,data,punish)

Wsize=data.W_k;
Rspace=data.Zeta_e;
Rtotal=data.Zeta_t;
server=data.server;

NF=length(solution);

for ii=1:NF
    
    Rspace(solution(ii))=Rspace(solution(ii))-Wsize(ii);
    Rtotal=Rtotal-Wsize(ii);
    
    if((Rspace(solution(ii))<0)||(Rtotal<0))      
        Rspace(solution(ii))=Rspace(solution(ii))+Wsize(ii);
        Rtotal=Rtotal+Wsize(ii);
        solution(ii)=server;
    end   
end

totalcost=CostCalculator(solution,data,punish);

end

