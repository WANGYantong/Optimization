function solution = Greedy(Flows,data,para)

edge_clouds=data.edge_cloud;
access_routers=data.access_router;
Wsize=data.W_k;
probability=data.probability;
Rspace=data.W_re_e;
Fullspace=data.W_e;
Rtotal=data.W_re_t;
utilization=data.utilization;
graph=data.graph;

NF=length(Flows);
cache_node=zeros(NF,1);
ar_list=zeros(NF,1);
total_cost=0;

punish_buff=ones(1,NF)*para.miss_penalty;

label_found=zeros(NF,1);

for ii = 1:NF
    for jj = 1:length(access_routers)
        [flow,ar,list_ec]=FindEcForFlow(probability,access_routers,graph,...
            edge_clouds,punish_buff);
        punish_buff(flow)=0;
        
        for kk = 1:length(list_ec)
            if (Wsize(flow) < Rspace(list_ec(kk))) && (Rtotal > Wsize(flow))
                cache_node(flow) = list_ec(kk);
                ar_list(flow) = ar;
                Rspace(list_ec(kk)) = Rspace(list_ec(kk)) - Wsize(flow);
                Rtotal = Rtotal - Wsize(flow);
                utilization(cache_node(flow))=(Fullspace-Rspace(cache_node(flow)))/Fullspace;
                label_found=1;
                break
            end
        end
        if(label_found==1)
            break
        end
    end
    if (label_found==1)
        cache_cost=1/(1-utilization(cache_node(flow)));
              
        cache_hit_cost=0;
        for jj=1:length(access_routers)
            [~,path_cost]=shortestpath(graph,access_routers(jj),edge_clouds(cache_node(flow)));
            cache_hit_cost=cache_hit_cost+probability(ii,access_routers(jj))*path_cost;
        end
        
        %cache_miss_cost=(1-probability(flow,ar))*punish;
        cache_miss_cost=0;
        
        total_cost=total_cost+(1/para.alpha)*cache_cost+(1/para.beta)*cache_hit_cost+(1/para.gamma)*cache_miss_cost;
    else
        total_cost=total_cost+(1/para.gamma)*para.miss_penalty;
    end
    
end

solution.allocation=cache_node;
solution.total_cost=total_cost;

end

