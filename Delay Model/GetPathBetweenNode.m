function pth = GetPathBetweenNode(graph, src, snk, verbose)
%PATHBETWEENNODES Return all paths between two nodes of a graph
%
% pth = GetPathBetweenNode(graph, direction, src, snk, verbose)
% pth = GetPathBetweenNode(graph, direction, src, snk)
%
%
% This function returns all simple paths (i.e. no cycles) between two nodes
% in a graph.  Not sure this is the most efficient algorithm, but it seems
% to work quickly for small graphs, and isn't too terrible for graphs with
% ~50 nodes.
%
% Input variables:
%
%   graph:  the graph
%
%   src:    index of starting node
%
%   snk:    index of target node
%
%   vflag:  logical scalar for verbose mode.  If true, prints paths to
%           screen as it traverses them (can be useful for larger,
%           time-consuming graphs). [false]
%
% Output variables:
%
%   pth:    cell array, with each cell holding the indices of a unique path
%           of nodes from src to snk.

% Copyright 2014 Kelly Kearney
% 1st Modified by Wang Yantong 11/12/2017
% 2nd Modified by Wang Yantong 30/01/2018

if nargin < 4
    verbose = false;
end

pth = cell(0); % possible path

if src == snk % parameter checking
    return
end

% get adjacency matrix
% nn = numnodes(graph);
% [s,t] = findedge(graph);
% adj = sparse(s,t,graph.Edges.Weight,nn,nn);
% if direction == "undirected"
%     adj = adj + adj.' - diag(diag(adj));
% end
adj=adjacency(graph);

n = size(adj,1);
stack = src; % current path
stop = false;
cycles = cell(0); % cycles in the path

next = cell(n,1);
for in = 1:n
    next{in} = find(adj(in,:)); % possible node in one step
end

visited = cell(0); % path in history

pred = src;
while 1
    
    visited = AddHistoryPath(visited, stack);
    
    [stack, pred] = addnode(stack, next, visited, pred);
    if verbose
        fprintf('%2d ', stack);
        fprintf('\n');
    end
    
    if isempty(stack)
        break;
    end
    
    if stack(end) == snk % reach the destination
        pth = [pth; {stack}];
        visited = AddHistoryPath(visited, stack);
        stack = popnode(stack);
    elseif length(unique(stack)) < length(stack) % cycle in the path
        cycles = [cycles; {stack}];
        visited = AddHistoryPath(visited, stack);
        stack = popnode(stack);  
    end

end


function [stack, pred] = addnode(stack, next, visited, pred)

newnode = setdiff(next{stack(end)}, pred);
possible = arrayfun(@(x) sprintf('%d,', [stack x]), newnode, 'uni', 0);

isnew = ~ismember(possible, visited);

if any(isnew)
    idx = find(isnew, 1);
    stack = str2num(possible{idx});
    pred = stack(end-1);
else
    [stack, pred] = popnode(stack);
end


function [stack, pred] = popnode(stack)

stack = stack(1:end-1);
if length(stack) > 1
    pred = stack(end-1);
else
    pred = [];
end

function visited = AddHistoryPath(VisitedLog, stack)

possible = sprintf('%d,', stack);
isnew = ~ismember(VisitedLog, possible);
if (all(isnew) || isempty(VisitedLog))
    visited = [VisitedLog; sprintf('%d,', stack)];
else
    visited = VisitedLog;
end
