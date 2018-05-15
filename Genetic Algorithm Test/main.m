%% I. clear memory and screen
clear
clc

addpath(genpath(pwd));
%% II. outline
% encoding : each individual as a binary array...
%   row for flows, column for caching edge clouds;...
%   population as a cell array;
% initial population size : 50(fixed);
% initial population : 80% randomized; 20% greedy; 
% fitness function : with constraints penalty;
% crossover : simple crossover(one point);
% mutation : binary mutation (bit exchange, P=0.05);
% selection : ranking
% terminable criteria : epsilon

initPara();

%% III. initialize population
initPop = initialize_ga(10,'fitness',[5,10],[],[1,0.2],[1,2,3,4,5]);

%% IV. call genetic algorithm
[x endPop bpop trace] = gaot_ga([-5,5;-5,5],'fitness',[],initPop,[1e-6 1 1],'maxGenTerm',25,...
                           'normGeomSelect',0.08,'arithXover',2,'nonUnifMutation',[2 25 3]);


%% V. output the optimal solution found by gaot_ga
x

%% VI. convergence figure
plot(trace(:,1),trace(:,3),'b:')
hold on
plot(trace(:,1),trace(:,2),'r-')
xlabel('Generation'); ylabel('Fittness');
legend('Mean Fitness', 'Best Fitness')

