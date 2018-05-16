function [parent] = binaryMut_ga(parent,pm)
% Binary mutation changes each of the bits of the parent
% based on the probability of mutation
%
% function [newSol] = binaryMut_ga(parent,bounds,Ops)
% parent  - the first parent ( [solution string function value] )
% pm      - probability of mutation happens
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

% pm=Ops(2);
% numVar = size(parent,2)-1; 		% Get the number of variables 
% % Pick a variable to mutate randomly from 1-number of vars
% rN=rand(1,numVar)<pm;
% parent=[abs(parent(1:numVar) - rN) parent(numVar+1)];

if rand < pm    
    
    numRow = size(parent,1);
    numCol = size(parent,2);
    
    rRow = randi([1,numRow]);
    rCol = randi([1,numCol]);
    
    parent(rRow,:)=0;
    parent(rRow,rCol) = 1;
    
end

end

  