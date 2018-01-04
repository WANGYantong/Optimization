function link_path = GetPathLinkRel(s,t,path,direction)
%GETPATHLINKREL Summary of this function goes here
%   Detailed explanation goes here

% direction directed OR undirected

link_path = cell(size(s)); %link belongs to which path
arcs = [s;t]; 

path_counter = 0;
for ii = 1:length(path)
    if isempty(path{ii})
        path_counter = path_counter+1;
        continue;
    end
    for jj = 1:length(path{ii})
        
    end
end

