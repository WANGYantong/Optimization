function[newPop] = tournSelect_ga(oldPop,options)
% Performs a tournament selection.
% choose k (the tournament size) individuals from the population at random
% choose the best individual from the tournament with probability p
% choose the second best individual with probability p*(1-p)
% choose the third best individual with probability p*((1-p)^2)
% and so on
%
% function[newPop] = tournSelect_ga(oldPop,options)
% newPop  - the new population selected from the oldPop
% oldPop  - the current population
% options - options to normGeomSelect [tournament_size probability_best]
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

tournSize=options(1); 			% Get the number of tournaments
proBest=options(2);             % the probability to choose the best individual
e = size(oldPop,2); 			% xZome length
n = size(oldPop,1); 			% number in Population
newPop = cell(n,e); 			% Create the memory for newPop

roulette=ones(tournSize,1);
roulette(1)=proBest;
for ii=2:tournSize-1
    roulette(ii)=roulette(ii-1)+proBest*((1-proBest)^(ii-1));
end

for ii=1:n
    pos=randperm(n);
    athlete=oldPop(pos(1:tournSize),:);
    athlete=sortrows(athlete,2);
    
    pick=rand;
    for jj=1:tournSize
        if pick<roulette(jj)
            break;
        end
    end
    
    newPop(ii,:)=athlete(jj,:);
end

end

