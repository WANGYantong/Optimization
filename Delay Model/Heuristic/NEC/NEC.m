function result = NEC(flow,data,para)

NF=length(flow);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);
Qos_penalty=para.QoS_penalty(1:NF);

result=zeros(1,6);

tic;
solution=Nominal(flow,data,para);
Nominal_time=toc;

delay_time = TimeCalculator(solution,data);

failed_number=0;
total_cost_add=solution.total_cost;
for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        total_cost_add=total_cost_add+Qos_penalty(ii)*(delay_time(ii)-data.delta(ii));
        failed_number=failed_number+1;
    end
end

result(1,1)=total_cost_add;
result(1,2)=total_cost_add-solution.total_cost;
result(1,3)=failed_number;
result(1,4)=Nominal_time;

%% Monte Carlo test

buff=MonteCarlo(flow,solution,data,para);
result(1,5:6)=buff;

end

