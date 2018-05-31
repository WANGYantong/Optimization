function result=MonteCarlo(flow,solution,data,punish,alpha,penalty)

rng(1);
result=zeros(1,2);

HARDCODE=1000;
NF=length(flow);

if isstruct(solution)
    pre_allocate=solution.allocation;
else
    pre_allocate=solution;
end

Wsize=data.W_k;
probability=data.probability;
Rspace=data.Zeta_e;
Rtotal=data.Zeta_t;
Fullspace=data.W_e;
utilization=data.utilization;
access_router=data.access_router;
graph=data.graph;
edge_clouds=data.edge_cloud;
server=data.server;

total_cost_add=0;
total_failed_number=0;
% Monte Carlo test times
for ii=1:HARDCODE
    % for each flow/mobile user
    ar=zeros(1,NF);
    label=zeros(size(pre_allocate));
    for jj=1:NF
        % the connect access router for flow jj
        test=rand;
        for kk=1:length(access_router)
            test=test-probability(jj,kk);
            if test<=0
                ar(jj)=access_router(kk);
                break;
            end
        end
        % update the edge cloud storage info
        if pre_allocate(jj) == server
            label(jj)=1;
            continue
        end       
        Rspace(pre_allocate(jj))=Rspace(pre_allocate(jj))-Wsize(jj);
        Rtotal=Rtotal-Wsize(jj);      
        utilization(pre_allocate(jj))=(Fullspace-Rspace(pre_allocate(jj)))/Fullspace;
    end
    cost=0;
    for jj=1:NF
        if(label(jj)==0)
            cache_cost=alpha/(1-utilization(pre_allocate(jj)));
            
            cache_hit_cost=0;
            [~,path_cost]=shortestpath(graph,ar(jj),edge_clouds(pre_allocate(jj)));
            cache_hit_cost=cache_hit_cost+path_cost;
            cache_miss_cost=0;
            
            cost=cost+cache_cost+cache_hit_cost+cache_miss_cost;
        else
            cost=cost+punish(jj);
        end
    end
    ops={1,ar};
    delay_time = TimeCalculator(solution,data,ops);
    failed_number=0;
    total_cost=cost;
    for jj=1:NF
        if delay_time(jj) > data.delta(jj)
            total_cost=total_cost+(1/penalty)*punish(jj)*(delay_time(jj)-data.delta(jj));
            failed_number=failed_number+1;
        end
    end

    total_cost_add=total_cost_add+total_cost;
    total_failed_number=total_failed_number+failed_number;
end

result(1,1)=total_cost_add/HARDCODE;
result(1,2)=total_failed_number/HARDCODE;

end

