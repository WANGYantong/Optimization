function [sol, fitnessVal] = fitness(sol, options)

global data_buff;

para=options{1};

Wsize=data_buff.W_k;
Rspace=data_buff.W_re_e;
Rtotal=data_buff.W_re_t;
server=data_buff.server;

NF=length(sol);
sol_mod=sol;

Qos_penalty=para.QoS_penalty(1:NF);

for ii=1:NF
    
    Rspace(sol_mod(ii))=Rspace(sol_mod(ii))-Wsize(ii);
    Rtotal=Rtotal-Wsize(ii);
    
    if((Rspace(sol_mod(ii))<0)||(Rtotal<0))      
        Rspace(sol_mod(ii))=Rspace(sol_mod(ii))+Wsize(ii);
        Rtotal=Rtotal+Wsize(ii);
        sol_mod(ii)=server;
    end   
end

result=CostCalculator(sol_mod,data_buff,para);
delay_time=TimeCalculator(sol_mod,data_buff);

for ii=1:NF
    if delay_time(ii) > data_buff.delta(ii)
        result=result+Qos_penalty(ii)*(delay_time(ii)...
            -data_buff.delta(ii));
    end
end

fitnessVal=result;

end

