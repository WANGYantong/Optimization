function w = GetRoutingCost(graph,direction,path)
%GETROUTINGCOST return the routing cost of graph
%
%Input variables:
%
%   graph:      the graph
%
%   direction:  indicate link(graph) is 'directed' (in default) or 
%               'undirected'
%
%   path:       the possible route of the graph, cell array;
%
%Output variables:
%
%   w:          cell array, with each cell holding the cost of each route
%
%By Wang Yantong 12/12/2017   

if nargin ~= 3
	error('Error. \n Illegal input number')
end

w = cell(size(path));

% get adjency matrix
nn = numnodes(graph);
[s,t] = findedge(graph);
adj = sparse(s,t,graph.Edges.Weight,nn,nn);
if direction == "undirected"
    adj = adj + adj.' - diag(diag(adj));
end
% adj=adjacency(graph);

for ii = 1:size(path,1)
	for jj = 1:size(path,2)
		for kk = 1:size(path{ii,jj},1)
			w{ii,jj}{kk} = GetEachPathCost(path{ii,jj}{kk}, adj);
		end
	end
end

end

function w = GetEachPathCost(path, adj)

w = 0;

for ii = 1:(length(path)-1)
	w = w + adj(path(ii),path(ii+1));
end
    
end

