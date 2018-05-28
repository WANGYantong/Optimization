function [x,endPop,bPop,traceInfo] = GO_ga(evalFN,evalOps,startPop,opts,...
    termFN,termOps,selectFN,selectOps,xOverFN,xOverOps,mutFN,mutOps)
% GO_GA run a genetic algorithm
% function [x,endPop,bPop,traceInfo]=GO_ga(evalFN,evalOps,startPop,opts,
%                                       termFN,termOps,selectFN,selectOps,
%                                       xOverFNs,xOverOps,mutFNs,mutOps)
%
% Output Arguments:
%   x            - the best solution found during the course of the run
%   endPop       - the final population
%   bPop         - a trace of the best population
%   traceInfo    - a matrix of best and means of the ga for each generation
%
% Input Arguments:
%   evalFN       - the name of the evaluation .m function
%   evalOps      - options to pass to the evaluation function
%   startPop     - a matrix of solutions that can be initialized
%                  from initialize.m
%   opts         - [epsilon display] change required to consider two
%                  solutions different and display is 1 to output progress 0 for
%                  quiet. ([1e-6 0])
%   termFN       - name of the .m termination function
%   termOps      - options string to be passed to the termination function
%   selectFN     - name of the .m selection function
%   selectOpts   - options string to be passed to select function
%   xOverFNS     - names of Xover.m files
%   xOverOps     - A matrix of options to pass to Xover.m files
%   mutFNs       - names of mutation.m files
%   mutOps       - A matrix of options to pass to Xover.m files
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
%%$Log: ga.m,v $
%Revision 1.10  1996/02/02  15:03:00  jjoine
% Fixed the ordering of imput arguments in the comments to match
% the actual order in the ga function.
%
%Revision 1.9  1995/08/28  20:01:07  chouck
% Updated initialization parameters, updated mutation parameters to reflect
% b being the third option to the nonuniform mutations
%
%Revision 1.8  1995/08/10  12:59:49  jjoine
%Started Logfile to keep track of revisions
%
% Modified by WANG,Yantong

if nargin<12
    error('Error. \n Insufficient arguements')
end

if any(evalFN<48) %Not using a .m file
    error('Error. \n Not a file name');
else %Are using a .m file
    e1str=['x=decoding_ga(c1{1,1});[x v]=' evalFN ...
        '(x,evalOps); c1{1,1}=encoding_ga(x,size_mat);c1{1,2}=v;'];
    e2str=['x=decoding_ga(c2{1,1});[x v]=' evalFN ...
        '(x,evalOps); c2{1,1}=encoding_ga(x,size_mat);c2{1,2}=v;'];
end

size_mat     = size(startPop{1,1});
xZomeLength  = size(startPop,2); 	%Length of the xzome
popSize      = size(startPop,1); 	%Number of individuals in the pop

if rem(popSize,2) ~= 0
    error('Error. \n Do not support hoploid yet')
end

endPop       = cell(popSize,xZomeLength); %A secondary population cell array
epsilon      = opts(1);                 %Threshold for two fittness to differ
oval         = min(cell2mat(startPop(:,xZomeLength))); %Best value in start pop
bFoundIn     = 1; 			%Number of times best has changed
done         = 0;                       %Done with simulated evolution
gen          = 1; 			%Current Generation Number
collectTrace = (nargout>3); 		%Should we collect info every gen
display      = opts(2);                 %Display progress
cnt          = 0;           %stable performance counter
c1           = cell(1,xZomeLength);
c2           = cell(1,xZomeLength);

while(~done)
    
    [bval,bindx] = min(cell2mat(startPop(:,xZomeLength))); %Best of current pop
    best =  startPop(bindx,:);
    
    if collectTrace
        traceInfo(gen,1)=gen; 		          %current generation
        traceInfo(gen,2)=startPop{bindx,xZomeLength};       %Best fittness
        traceInfo(gen,3)=mean([startPop{:,xZomeLength}]);     %Avg fittness
        traceInfo(gen,4)=std([startPop{:,xZomeLength}]);
    end
    
    if ((abs(bval-oval)>epsilon) || (gen==1)) %If we have a new best sol
        if display
            fprintf(1,'\n%d %f\n',gen,bval);          %Update the display
        end
        
        bPop(bFoundIn,:)={gen, startPop(bindx,:)};
        
        bFoundIn=bFoundIn+1;                      %Update number of changes
        oval=bval;                                %Update the best val
    else
        if display
            fprintf(1,'%d ',gen);	              %Otherwise just update num gen
        end
    end
    
    % selection
    endPop = feval(selectFN,startPop,selectOps);
    
    % crossover
    for ii=1:2:popSize
        
        [c1{1},c2{1}] = feval(xOverFN,endPop(ii,:),endPop(ii+1,:));
        
        if c1{1,1}==endPop{ii,1} %Make sure we created a new
            c1{1,xZomeLength}=endPop{ii,xZomeLength}; %solution before evaluating
        elseif c1{1,1}==endPop{ii+1,1}
            c1{1,xZomeLength}=endPop{ii+1,xZomeLength};
        else
            eval(e1str);
        end
        if c2{1,1}==endPop{ii,1}
            c2{1,xZomeLength}=endPop{ii,xZomeLength};
        elseif c2{1,1}==endPop{ii+1,1}
            c2{1,xZomeLength}=endPop{ii+1,xZomeLength};
        else
            eval(e2str);
        end
        endPop(ii,:)=c1;
        endPop(ii+1,:)=c2;
    end
    
    % mutation
    for ii=1:popSize
    
%     ii=randi(popSize);
        c1 = feval(mutFN,endPop(ii,:),mutOps);
        if c1{1,1}==endPop{ii,1}
            c1{1,xZomeLength}=endPop{ii,xZomeLength};
        else
            eval(e1str);
        end
        endPop(ii,:)=c1;
    end
    
    gen=gen+1;
    
    %termination
    [done,cnt]=feval(termFN,[gen,oval,termOps],cnt,endPop);
    
    startPop=endPop; 			%Swap the populations
    
    [bval,bindx] = max((cell2mat(startPop(:,xZomeLength)))); %Keep the best solution
    startPop(bindx,:) = best; 		%replace it with the worst
end

[bval,bindx] = min(cell2mat(startPop(:,xZomeLength)));
if display
    fprintf(1,'\n%d %f\n',gen,bval);
end

x=startPop(bindx,:);
bPop(bFoundIn,:)={gen, startPop(bindx,:)};

if collectTrace
    traceInfo(gen,1)=gen; 		%current generation
    traceInfo(gen,2)=startPop{bindx,xZomeLength}; %Best fittness
    traceInfo(gen,3)=mean([startPop{:,xZomeLength}]); %Avg fittness
end

end






