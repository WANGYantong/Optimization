function [fine, failed_number] = fitness_mod(sol, data,para)

Wsize=data.W_k;
Rspace=data.W_re_e;
Rtotal=data.W_re_t;
server=data.server;

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

fine=0;
failed_number=0;
delay_time=TimeCalculator(sol_mod,data);

for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        fine=fine+Qos_penalty(ii)*(delay_time(ii)...
            -data.delta(ii));
        failed_number=failed_number+1;
    end
end

end


