function [c1,c2] = reshuffle_ga(c1_shuffle,c2_shuffle,rule)

c1(rule,:)=c1_shuffle;
c2(rule,:)=c2_shuffle;

end

