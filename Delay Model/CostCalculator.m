function cost = CostCalculator(pre_allocate,ar_list,Wsize,probability,...
    Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,edge_clouds,server)

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
        cache_cost=alpha/(1-utilization(pre_allocate(ii)));
        
        [~,path_cost]=shortestpath(graph,ar_list(ii),edge_clouds(pre_allocate(ii)));
        cache_hit_cost=probability(ii,ar_list(ii))*path_cost;
        
        cache_miss_cost=(1-probability(ii,ar_list(ii)))*punish;
        
        cost=cost+cache_cost+cache_hit_cost+cache_miss_cost;
    else
        cost=cost+punish; 
    end
end

end
