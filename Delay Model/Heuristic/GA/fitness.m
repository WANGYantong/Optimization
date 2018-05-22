function [sol, fitnessVal] = fitness(sol, options)

global data_buff;

punish=log(max(data_buff.delta)+50-data_buff.delta)*200;

Wsize=data_buff.W_k;
Rspace=data_buff.Zeta_e;
Rtotal=data_buff.Zeta_t;
server=data_buff.server;

NF=length(sol);
sol_mod=sol;

for ii=1:NF
    
    Rspace(sol_mod(ii))=Rspace(sol_mod(ii))-Wsize(ii);
    Rtotal=Rtotal-Wsize(ii);
    
    if((Rspace(sol_mod(ii))<0)||(Rtotal<0))      
        Rspace(sol_mod(ii))=Rspace(sol_mod(ii))+Wsize(ii);
        Rtotal=Rtotal+Wsize(ii);
        sol_mod(ii)=server;
    end   
end

result=CostCalculator(sol_mod,data_buff,data_buff.alpha,punish);
delay_time=TimeCalculator(sol_mod,data_buff);

for ii=1:NF
    if delay_time(ii) > data_buff.delta(ii)
        result=result+(1/data_buff.penalty)*punish(ii)*(delay_time(ii)...
            -data_buff.delta(ii));
    end
end

fitnessVal=result;

end

