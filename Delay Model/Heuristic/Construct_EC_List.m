function list_ec = Construct_EC_List(graph,edge_clouds,ar)

list_cost=zeros(1,length(edge_clouds));

for ii = 1:length(edge_clouds)
    [~,path_cost]=shortestpath(graph,ar,edge_clouds(ii));
    list_cost(ii)=path_cost;
end

[~,list_ec]=sort(list_cost,2);

end
