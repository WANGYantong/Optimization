s = [1 1 2 3 3 4 4 6 6 7 8 7 5]';
t = [2 3 4 4 5 5 6 1 8 1 3 2 8]';

nnode = max(s);
nedge = length(s);

adj = sparse(s,t,ones(nedge,1),nnode,nnode);
pth = GetPathBet

weenNode(adj,7,8);
