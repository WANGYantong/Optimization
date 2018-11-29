function result = RGR(flow,data,para)

NF=length(flow);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);
Qos_penalty=para.QoS_penalty(1:NF);

result=cell(1,8);

tic;
solution=Randomized(flow,data,para);
Randomized_time=toc;

delay_time = TimeCalculator(solution,data);

failed_number=0;
total_cost_add=solution.total_cost;
for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        total_cost_add=total_cost_add+Qos_penalty(ii)*(delay_time(ii)-data.delta(ii));
        failed_number=failed_number+1;
    end
end

matrix=encoding_ga(solution.allocation,[NF,length(data.edge_cloud)]);
[edge_jam,link_jam]=JamCalculator(flow,matrix,data);

result{1}=total_cost_add;
result{2}=total_cost_add-solution.total_cost;
result{3}=failed_number;
result{4}=Randomized_time;
result{7}=edge_jam;
result{8}=link_jam;

%% Monte Carlo test

buff=MonteCarlo(flow,solution,data,para);
result{5}=buff(1);
result{6}=buff(2);

end
