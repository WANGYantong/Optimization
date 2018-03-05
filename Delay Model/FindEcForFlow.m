function [flow,ar,list_ec] = FindEcForFlow(probability,access_routers,...
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