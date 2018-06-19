function [p1_shuffle,p2_shuffle,rule] = shuffle_ga(p1,p2)

numVar = size(p1,1);
rule = randperm(numVar);

p1_shuffle=p1(rule,:);
p2_shuffle=p2(rule,:);

end

