function result = RGR(flow,data,alpha,penalty)

NF=length(flow);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);

punish=log(max(data.delta)+50-data.delta)*200;
result=zeros(1,6);

tic;
solution=Randomized(flow,data,alpha,punish);
Randomized_time=toc;

delay_time = TimeCalculator(solution,data);

failed_number=0;
total_cost_add=solution.total_cost;
for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        total_cost_add=total_cost_add+(1/penalty)*punish(ii)*(delay_time(ii)-data.delta(ii));
        failed_number=failed_number+1;
    end
end

result(1,1)=total_cost_add;
result(1,2)=total_cost_add-solution.total_cost;
result(1,3)=failed_number;
result(1,4)=Randomized_time;

%% Monte Carlo test

buff=MonteCarlo(flow,solution,data,punish,alpha,penalty);
result(1,5:6)=buff;

end
