function [flow,ar,list_ec] = FindEcForFlow(probability,access_routers,...
    graph,edge_clouds,punish)

[~,I]=sort(punish,'descend');
flow=I(1);
[~,II]=sort(probability(flow,:),'descend');
ar = access_routers(II(1));

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