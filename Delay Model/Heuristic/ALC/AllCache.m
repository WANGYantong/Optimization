function solution = AllCache(flows,data,para)

edge_clouds=data.edge_cloud;
Wsize=data.W_k;
probability=data.probability;
access_router=data.access_router;
Rspace=data.W_re_e;
Fullspace=data.W_e;
Rtotal=data.W_re_t;
graph=data.graph;
server=data.server;

NF=length(flows);
NE=length(data.edge_cloud);
ND=length(access_router);
cache_node=zeros(NF,NE);

[~,I]=sort(Rspace);

for ii=1:NF   
    if ((Rspace(I(1))>(Wsize(ii)+10)) && (Rtotal>(Wsize(ii)+10)))
        for jj=1:NE
            Rspace(jj)=Rspace(jj)-Wsize(ii);
            Rtotal=Rtotal-Wsize(ii);
        end
        cache_node(ii,:)=1;
    else
        cache_node(ii,:)=server;
    end
end

solution.allocation=cache_node;
utilization=zeros(NE,1);

for ii=1:NE
    utilization(ii)=(Fullspace-Rspace(ii))/Fullspace;
end

total_cost=0;
for ii=1:NF
    if (cache_node(ii,1)==server)
         total_cost=total_cost+(1/para.gamma)*para.miss_penalty; 
    else
        cache_cost=0;
        for jj=1:NE
            cache_cost=cache_cost+1/(1-utilization(jj));
        end
        cache_hit_cost=0;
        for jj=1:ND
            if probability(ii,jj)>0
                list_ec = Construct_EC_List(graph,edge_clouds,access_router(jj));
                [~,path_cost]=shortestpath(graph,access_router(jj),data.edge_cloud(list_ec(1)));
                cache_hit_cost=cache_hit_cost+probability(ii,access_router(jj))*path_cost;
            end
        end
        total_cost=total_cost+(1/para.alpha)*cache_cost+(1/para.beta)*cache_hit_cost;
    end
end

solution.total_cost=total_cost;

end

