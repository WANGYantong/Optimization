function [cache_node,access_list,total_cost] = RandomizedGreedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,...
    lambda,mu,ce,Tpr,delta,path,R_k,C_l,server)
%RANDOMGREEDY

TIMES_HARDCODE = 10000;

[pre_allocate,ar_list,pre_cost] = Greedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish);

time_flag_ori = delay_detector(pre_allocate,path,R_k,C_l,lambda,...
    mu,ce,Tpr,delta);

cache_node = pre_allocate;
access_list = ar_list;
total_cost = pre_cost;

if(time_flag_ori==1)
    TIMES_HARDCODE = 100;
%     return
end

for ii = 1:TIMES_HARDCODE
% while(1)
    flow = randi(length(Flows));
    pos = randi(length(edge_clouds));
    pre_allocate(flow) = pos;
    
    legal_flag = check_space(pre_allocate,Wsize,Rspace,Rtotal);
    
    if(legal_flag == 1)
        pre_cost = CostCalculator(pre_allocate,ar_list,Wsize,probability,...
            Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish,edge_clouds,server);
        time_flag_pre = delay_detector(pre_allocate,path,R_k,C_l,lambda,...
            mu,ce,Tpr,delta);
        
        if(time_flag_pre ==1)
            if(time_flag_ori == 0) || ((time_flag_ori == 1) && (pre_cost < total_cost))
                cache_node = pre_allocate;
                access_list = ar_list;
                total_cost = pre_cost;
%                 time_flag_ori = time_flag_pre;
                return
            end
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

function delay_flag = delay_detector(pre_allocate,path,R_k,C_l,lambda,mu,ce,Tpr,delta)

delay_flag = 1;

delay_link = GetWorstLinkDelay(C_l, R_k, path);

NF=length(pre_allocate);

% delay_edge = (delta-Tpr-delay_link)/length(ce);
delay_edge = delta-Tpr-delay_link; 

lammax = GetMaxLambda(mu,ce,delay_edge);

for ii=1:NF
    lammax(pre_allocate(ii))=lammax(pre_allocate(ii))-lambda(ii,pre_allocate(ii));
    if(lammax(pre_allocate(ii))<0)
        delay_flag=0;
        break
    end
end

end