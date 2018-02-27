function [cache_node,access_list,total_cost] = RandomizedGreedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,...
    lambda,mu,ce,Tpr,delta,path,R_k,C_l)
%RANDOMGREEDY

TIMES_HARDCODE = 100;

[pre_allocate,ar_list,pre_cost] = Greedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish);

cache_node = pre_allocate;
access_list = ar_list;
total_cost = pre_cost;

for ii = 1:TIMES_HARDCODE
    flow = randi(length(Flows));
    pos = randi(length(edge_clouds));
    pre_allocate(flow) = pos;
    
    legal_flag = check_space(pre_allocate,Wsize,Rspace,Rtotal);
    
    if(legal_flag == 1)
        pre_cost = cost_calculator(pre_allocate,ar_list,Wsize,probability,...
            Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish);
        time_flag_pre = delay_detector(pre_allocate,path,R_k,C_l,lambda,...
            mu,ce,Tpr,delta);
        
        if(pre_cost <= total_cost && time_flag_pre ==1)
            cache_node = pre_allocate;
            access_list = ar_list;
            total_cost = pre_cost;
        end
    end
end

end


function legal_flag=check_space(pre_allocate,Wsize,Rspace,Rtotal)

NF=length(pre_allocate);
flow_flag=zeros(size(pre_allocate));

for ii=1:NF
    if(Wsize(ii) < Rspace(pre_allocate(ii))) && (Rtotal > Wsize(ii))
        Rspace(pre_allocate(ii))=Rspace(pre_allocate(ii))-Wsize(ii);
        Rtotal=Rtotal - Wsize(ii);
        flow_flag(ii)=1;
    end
end

legal_flag=all(flow_flag);

end

%%further check
function cost = cost_calculator(pre_allocate,ar_list,Wsize,probability,...
    Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish)

NF=length(pre_allocate);
cost=0;

for ii=1:NF
    Rspace(pre_allocate(ii))=Rspace(pre_allocate(ii))-Wsize(ii);
    Rtotal=Rtotal - Wsize(ii);
    
    cache_cost=alpha/(1-utilization(pre_allocate(ii)));
    utilization(pre_allocate(ii))=Rspace(pre_allocate(ii))/Fullspace;
    
    [~,path_cost]=shortestpath(graph,ar_list(ii),pre_allocate(ii));
    cache_hit_cost=probability(ii,ar_list(ii))*(path_cost+2);
    
    cache_miss_cost=(1-probability(ii,ar_list(ii)))*punish;
    
    cost=cost+cache_cost+cache_hit_cost+cache_miss_cost;
end

end

function delay_flag = delay_detector(pre_allocate,path,R_k,C_l,lambda,mu,ce,Tpr,delta)

delay_flag = 1;

delay_link = GetWorstLinkDelay(C_l, R_k, path);

delay_edge = delta-Tpr-delay_link;

lammax = GetMaxLambda(mu,ce,delay_edge);
NF=length(pre_allocate);
for ii=1:NF
    lammax(pre_allocate(ii))=lammax(pre_allocate(ii))-lambda(ii,pre_allocate(ii));
    if(lammax(pre_allocate(ii))<0)
        delay_flag=0;
        break
    end
end

end