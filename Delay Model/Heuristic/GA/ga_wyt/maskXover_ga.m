function [c1,c2] = maskXover_ga(p1,p2,opts)
% masked crossover takes two parents P1,P2
% copy the gene from both parents depends on a randomly masked vector,
% where 0 means from from one parent and 1 from another
%
% function [c1,c2] = maskXover(p1,p2)
% p1      - the first parent ( binary matrix )
% p2      - the second parent ( binary matrix )

p1=p1{1};
p2=p2{1};
numVar = size(p1,1);

c1=p1;
c2=p2;

if rand<opts(1)
    mask = round(rand(1,numVar));
    while(mask==zeros(1,numVar))
        mask = round(rand(1,numVar));
    end
    idx1 = find(mask==1);
    
    c1(idx1,:)=p2(idx1,:);
    c2(idx1,:)=p1(idx1,:);
end


end

