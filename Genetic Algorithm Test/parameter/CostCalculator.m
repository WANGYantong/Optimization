function cost = CostCalculator(solution,data,punish)

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
alpha=data.alpha;

NF=length(solution);
cost=0;

label=zeros(size(solution));

for ii=1:NF    
    if solution(ii) == server
       label(ii)=1;
       continue
    end
    
    Rspace(solution(ii))=Rspace(solution(ii))-Wsize(ii);
    Rtotal=Rtotal-Wsize(ii);
      
    utilization(solution(ii))=(Fullspace-Rspace(solution(ii)))/Fullspace;
end

for ii=1:NF
    if(label(ii)==0)
        cache_cost=alpha/(1-utilization(solution(ii)));
        
        cache_hit_cost=0;
        for jj=1:length(access_router)
            [~,path_cost]=shortestpath(graph,access_router(jj),edge_clouds(solution(ii)));
            cache_hit_cost=cache_hit_cost+probability(ii,access_router(jj))*path_cost;
        end
        
        %cache_miss_cost=(1-probability(ii,ar_list(ii)))*punish(ii);
        cache_miss_cost=0;
        
        cost=cost+cache_cost+cache_hit_cost+cache_miss_cost;
    else
        cost=cost+punish(ii); 
    end
end

end
