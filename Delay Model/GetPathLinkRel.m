function beta = GetPathLinkRel(graph,direction,path,counter_path)
%GETPATHLINKREL generate a binary matrix beta to show the ownership
%between paths and links
%
%   Input variables:
%     
%        graph:  the graph
%
%        direction: indicate graph is 'directed' or 'undirected'
%
%        path: the possible route of the graph, cell array
%
%        counter_path: the number of the paths
%
% 	Output variables:
%
%        beta: if beta(i,j)=1, it means the path(j) go across link(i),
%              a (link, size) matrix.

if nargin ~= 4
    error('Error. \n Illegal input number')
end

[s,t] = findedge(graph);

beta = zeros(length(s),counter_path);
arcs = [s,t]; 

path_index = 1;
for ii = 1:length(path)
    if isempty(path{ii})
        path_index = path_index+1;
        continue;
    end
%     for jj = 1:length(path{ii})
%         for kk = 1:length(path{ii}{jj})-1
%             link = FindLink(path{ii}{jj}(kk:kk+1),arcs,direction);
    for jj = 1:length(path{ii})-1
        link=FindLink(path{ii}(jj:jj+1),arcs,direction);
            if link
                beta(link,path_index) = 1;
            end
    end
        path_index = path_index+1;
end

end

% end

function link = FindLink(path,arcs,direction)

link = 0;
if direction == "directed"
    for ii = 1:length(arcs)
        if arcs(ii,1) == path(1) && arcs(ii,2) == path(2)
            link = ii;
            break;
        end
    end
else
    for ii = 1:length(arcs)
        if (arcs(ii,1) == path(1) && arcs(ii,2) == path(2))...
                || (arcs(ii,1) == path(2) && arcs(ii,2) == path(1))           
            link = ii;
            break;
        end
    end
end

end
