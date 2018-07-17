function cost = CostCalculator(solution,data,para)

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

NF=length(pre_allocate);
cost=0;

label=zeros(size(pre_allocate));

for ii=1:NF    
    if pre_allocate(ii) == server
       label(ii)=1;
       continue
    end
    
    Rspace(pre_allocate(ii))=Rspace(pre_allocate(ii))-Wsize(ii);
    Rtotal=Rtotal-Wsize(ii);
      
    utilization(pre_allocate(ii))=(Fullspace-Rspace(pre_allocate(ii)))/Fullspace;
end

for ii=1:NF
    if(label(ii)==0)
        cache_cost=1/(1-utilization(pre_allocate(ii)));
        
        cache_hit_cost=0;
        for jj=1:length(access_router)
            [~,path_cost]=shortestpath(graph,access_router(jj),edge_clouds(pre_allocate(ii)));
            cache_hit_cost=cache_hit_cost+probability(ii,access_router(jj))*path_cost;
        end
        
        %cache_miss_cost=(1-probability(ii,ar_list(ii)))*punish(ii);
        cache_miss_cost=0;
        
        cost=cost+(1/para.alpha)*cache_cost+(1/para.beta)*cache_hit_cost+(1/para.gamma)*cache_miss_cost;
    else
        cost=cost+(1/para.gamma)*para.miss_penalty; 
    end
end

end
