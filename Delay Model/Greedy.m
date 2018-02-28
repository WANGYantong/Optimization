function [cache_node, ar_list, total_cost] = Greedy(Flows,edge_clouds,access_routers,...
    Wsize,probability,Rspace,Fullspace,Rtotal,utilization,graph,alpha,punish)
%Greedy Algorithm to find the edge cloud and calculate total cost
%
%   Input Variables:
%       Flows:          the set of flows in this network
%
%       edge_clouds:    the set of edge clouds
%
%       access_routers: the set of access routers
%
%       Wsize:          the size of flow
%
%       probability:    the mobile user movement probability to access
%                       router
%
%       Rspace:         the remaining space for hosting content in edge
%                       cloud
%
%       Fullspace:      the total space in edge cloud
%
%       Rtotal:         the total remaining space in network for hosting
%                       content
%
%       utilization:    the utilization of each edge cloud
%
%       graph:          the network topology
%
%       alpha:          the coefficient factor
%
%       sources:        the access router which moble user connect
%                       currently
%
%       punish:         the punishment factor for miss caching
%
%   Output Variables:
%
%       cache_node:     the edge clouds which are chosen as content hoster
%
%       ac_list:        the access router for connection by assumption
%
%       total_cost:     the total cost for proactive cache

if nargin ~= 12
    error('Error. \n Illegal input number')
end

NF=length(Flows);
cache_node=zeros(NF,1);
ar_list=zeros(NF,1);
total_cost=0;

probability_buff=probability;

label_found=zeros(NF,1);

for ii = 1:length(Flows)  
    for jj = 1:length(access_routers)
        [flow,ar,list_ec]=find_ec_for_flow(probability,access_routers,graph,...
            edge_clouds);
        
        probability(flow,ar)=0;
        
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
        cache_cost=alpha/(1-utilization(cache_node(flow)));
        
        
        [~,path_cost]=shortestpath(graph,ar,edge_clouds(cache_node(flow)));
        cache_hit_cost=probability_buff(flow,ar)*path_cost; 
        
        cache_miss_cost=(1-probability_buff(flow,ar))*punish;
        
        total_cost=total_cost+cache_cost+cache_hit_cost+cache_miss_cost;
    else
        total_cost=total_cost+punish;
    end
    
end

end

function [flow,ar,list_ec] = find_ec_for_flow(probability,access_routers,...
    graph,edge_clouds)

[B,I]=sort(probability,2,'descend');
[~,flow]=max(B(:,1));
ar = access_routers(I(flow,1));

list_ec=Construct_EC_List(graph,edge_clouds,ar);

end

function list_ec = Construct_EC_List(graph,edge_clouds,ar)

list_cost=zeros(1,length(edge_clouds));

for ii = 1:length(edge_clouds)
    [~,path_cost]=shortestpath(graph,ar,edge_clouds(ii));
    list_cost(ii)=path_cost;
end

[~,list_ec]=sort(list_cost,2);

end