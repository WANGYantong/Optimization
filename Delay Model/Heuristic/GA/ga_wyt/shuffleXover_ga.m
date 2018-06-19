function [c1, c2] = shuffleXover_ga(p1, p2, opts)
% SHUFFLEXOVER Shuffle the paprents chromosomes before crossvoer,
% and reshuffle after accordingly.
%
% function [c1,c2] = shuffleXover(p1,p2,opts)
% p1      - the first parent ( binary matrix )
% p2      - the second parent ( binary matrix )
% opts   - choose crossover method, 0 for simpleXover;
%              1 for maskXover. Default 0.

if nargin<3
    opts=0;
end

p1=p1{1};
p2=p2{1};

[p1_shuffle,p2_shuffle,rule]=shuffle_ga(p1,p2);

if opts == 0
    [c1_shuffle,c2_shuffle]=simpleXover_ga({p1_shuffle},{p2_shuffle});
else
    [c1_shuffle,c2_shuffle]=maskXover_ga({p1_shuffle},{p2_shuffle});
end

[c1,c2]=reshuffle_ga(c1_shuffle,c2_shuffle,rule);

end

