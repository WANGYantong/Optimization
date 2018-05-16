function [pop] = initialize_ga(num,evalFN,size_mat,evalOps,options,seed)
%function [pop] = initialize_ga(num, bounds, evalFN,evalOps,options)
%   initialize_ga creates a cell array, with size num*2, where the first
%   element in each row represents a possible assignment(individual, a
%   matrix), and the second is the according fitness value(a real number).
%
% mandatory
% pop    - the initial, evaluated, random population
% num    - the row size of the population
% evalFN - the evaluation fn, usually the name of the .m file for evaluation
% size_mat-the size for the assignment [m,n]
%
% optional
% evalOps- any options to be passed to the eval function defaults []
% options- options to the initialize function, ie. [combined_opt,percentage]
%           where combine_opt is 0 for all randomized, 1 for introducing
%           potentially good solutions, and the ratio of such solution is
%           defined by percentage, defaults [0,0]
% seed   - potentially good solutions, from other heuristic algorithm, such
%          as greedy, or practices.
%
% MODIFIED BASED ON GAOT

%% input detector
if nargin<5
    options=[0,0];
end
if nargin<4
    evalOps=[];
end
if nargin<3
    error('Error. \n Illegal input number')
end

%% generate initial assignment
pop=cell(num,2);

if options(1)==0 % all randomized
    for ii=1:num
        pop{ii,1}=randpop_ga(size_mat);
    end
else % hybrid combination
    sol=encoding_ga(seed,size_mat);
    point=ceil(num*options(2));
    for ii=1:point
        pop{ii,1}=sol;
    end
    for ii=point+1:num
        pop{ii,1}=randpop_ga(size_mat);
    end
end

%% calculate according fitness value
if any(evalFN<48) %Not a .m file
    error('Error. \n Not a file name');
else %A .m file
    estr=['x=decoding_ga(pop{ii,1});[x v]=' evalFN ...
        '(x,[0 evalOps]); pop{ii,1}=encoding_ga(x,size_mat);pop{ii,2}=v;'];
end

for ii=1:num
    eval(estr);
end

end

