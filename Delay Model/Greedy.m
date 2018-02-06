function [cache_node, total_cost] = Greedy(probability,utilization,Wsize,...
    Rspace, Fullspace, Rtotal, graph, alpha, sources, w_max)

%GREEDY 
%   

if nargin ~= 10
   error('Error. \n Illegal input number') 
end

[row,col]=size(probability);

cache_node=zeros(row,1);
total_cost=0;
cache_cost=0;
cache_hit_cost=0;
cache_miss_cost=0;

[B,I]=sort(probability,2,'descend');

for ii = 1:row
    [~,II] = max(B(:,1));
    for jj = 1:col
        ec = I(II,jj);
        B(II,1) = 0;
        if (Wsize(II) < Rspace(ec)) && (Rtotal > 0)
            cache_node(II) = ec;
            Rspace(ec) = Rspace(ec) - Wsize(II);          
            Rtotal = Rtotal - Wsize(II);
            break
        end
    end
    
    cache_cost=alpha/(1-utilization(cache_node(II)));
    utilization(ec)=Rspace(ec)/Fullspace;
    
    source_ec=neighbors(graph,sources);
    [~,path_cost]=shortestpath(graph,source_ec,cache_node(II));
    cache_hit_cost=probability(II,cache_node(II))*(path_cost+2); %2 is the cost from ec to bs...
    
    cache_miss_cost=(1-probability(II,cache_node(II)))*w_max;
    
    total_cost=total_cost+cache_cost+cache_hit_cost+cache_miss_cost;
end

end