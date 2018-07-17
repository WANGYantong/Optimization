function result=MonteCarlo(flow,solution,data,para)

rng(1);
result=zeros(1,2);

HARDCODE=1000;
NF=length(flow);

Qos_penalty=para.QoS_penalty(1:NF);

if isstruct(solution)
    pre_allocate=solution.allocation;
else
    pre_allocate=solution;
end

Wsize=data.W_k;
probability=data.probability;
Rspace=data.W_re_e;
Rtotal=data.W_re_t;
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
    
    Rspace_buff=Rspace;
    Rtotal_buff=Rtotal;
    utilization_buff=utilization;
    
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
        Rspace_buff(pre_allocate(jj))=Rspace_buff(pre_allocate(jj))-Wsize(jj);
        Rtotal_buff=Rtotal_buff-Wsize(jj);      
        utilization_buff(pre_allocate(jj))=(Fullspace-Rspace_buff(pre_allocate(jj)))/Fullspace;
    end
    cost=0;
    for jj=1:NF
        if(label(jj)==0)
            cache_cost=1/(1-utilization_buff(pre_allocate(jj)));
            
            cache_hit_cost=0;
            [~,path_cost]=shortestpath(graph,ar(jj),edge_clouds(pre_allocate(jj)));
            cache_hit_cost=cache_hit_cost+path_cost;
            cache_miss_cost=0;
            
            cost=cost+(1/para.alpha)*cache_cost+(1/para.beta)*cache_hit_cost+(1/para.gamma)*cache_miss_cost;
        else
            cost=cost+(1/para.gamma)*para.miss_penalty;
        end
    end
    ops={1,ar};
    delay_time = TimeCalculator(solution,data,ops);
    failed_number=0;
    total_cost=cost;
    for jj=1:NF
        if delay_time(jj) > data.delta(jj)
            total_cost=total_cost+Qos_penalty(jj)*(delay_time(jj)-data.delta(jj));
            failed_number=failed_number+1;
        end
    end

    total_cost_add=total_cost_add+total_cost;
    total_failed_number=total_failed_number+failed_number;
end

result(1,1)=total_cost_add/HARDCODE;
result(1,2)=total_failed_number/HARDCODE;

end

