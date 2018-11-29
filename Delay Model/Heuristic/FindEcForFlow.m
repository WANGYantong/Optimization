function [flow,ar,list_ec] = FindEcForFlow(probability,access_routers,...
    graph,edge_clouds,punish)

[~,I]=sort(punish,'descend');
flow=I(1);
[~,II]=sort(probability(flow,:),'descend');
ar = access_routers(II(1));

list_ec=Construct_EC_List(graph,edge_clouds,ar);

end

