function result = ALC(flow,data,para)

NF=length(flow);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);
Qos_penalty=para.QoS_penalty(1:NF);

result=cell(1,8);

tic;
solution=AllCache(flow,data,para);
AllCache_time=toc;

% Use the maximum probability as the Access Router to estimate the delay
% time
solution_pso=zeros(NF,1);
for ii=1:NF
    if solution.allocation(ii,1)==data.server
        solution_pso(ii)=data.server;
    else
        [~,I]=sort(data.probability(ii,:),'descend');
        list_ec = Construct_EC_List(data.graph,data.edge_cloud,I(1));
        solution_pso(ii)=data.edge_cloud(list_ec(1));
    end
end

delay_time = TimeCalculator(solution_pso,data);

failed_number=0;
total_cost_add=solution.total_cost;
for ii=1:NF
%     if delay_time(ii) > data.delta(ii)
    if ii>=(data.ce*data.mu'-length(data.ce))
        total_cost_add=total_cost_add+Qos_penalty(ii)*(delay_time(ii)-data.delta(ii));
        failed_number=failed_number+1;
    end
end

[edge_jam,link_jam]=JamCalculator(flow,solution.allocation,data);

result{1}=total_cost_add;
result{2}=total_cost_add-solution.total_cost;
result{3}=failed_number;
result{4}=AllCache_time;
result{7}=edge_jam;
result{8}=link_jam;

%% Monte Carlo test

% buff=MonteCarlo(flow,solution_pso,data,para);
% result{5}=buff(1);
% result{6}=buff(2);

end

