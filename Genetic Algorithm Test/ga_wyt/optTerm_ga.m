function [done,cnt] = optTerm_ga(ops,cnt,endPop)
% function [done,cnt] = optTerm_ga(ops,cnt,endPop)
%
% Returns 1, i.e. terminates the GA, when either the maximal_generation is
% reached or the performance hasn't changed in several generations.
%
% ops    - a vector of options [current_generation_number, optimal_solution,
%          maximum_generation, maximum_cnt, epsilon]
% cnt    - the current number for performance not changing
% endPop - the current generation of solutions
%
% Binary and Real-Valued Simulation Evolution for Matlab 
% Copyright (C) 1996 C.R. Houck, J.A. Joines, M.G. Kay 
%
% C.R. Houck, J.Joines, and M.Kay. A genetic algorithm for function
% optimization: A Matlab implementation. ACM Transactions on Mathmatical
% Software, Submitted 1996.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 1, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. A copy of the GNU 
% General Public License can be obtained from the 
% Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%
% Modified by WANG,Yantong

currentGen = ops(1);
optimal    = ops(2);
maxGen     = ops(3);
maxCnt     = ops(4);
epsilon    = ops(5);

fitIndex   = size(endPop,2);
bestSolVal = min(cell2mat(endPop(:,fitIndex)));

if (optimal-bestSolVal)<=epsilon
    cnt=cnt+1;
else
    cnt=0;
end

done       = (currentGen >= maxGen) | (cnt >= maxCnt);

end