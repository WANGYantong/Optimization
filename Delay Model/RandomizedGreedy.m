function [cache_node,total_cost] = RandomizedGreedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish)
%RANDOMGREEDY 

    [pre_allocate,ar_list,pre_cost] = Greedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish);

% remove a randomly chosen item in pre_allocate list

% recall Greedy function, replace probability by probability_new (pro_ka==0)

% calculate delay time, if delay time is less then constraints, then
% compare the cost with pre_cost, if less then pre_cost, update [pre_allocate, pre_cost]

% repeat 1000 times

end

