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
flow=1:1:5;
NF=length(flow);
sol_greed=Greedy_mod(flow);
sizePop=20;

initPop = initialize_ga(sizePop,'fitness',[NF,10],[],[1,0.2],sol_greed);

%% IV. call genetic algorithm
maxGen=100;
maxCnt=10;
numTourn=10;
ChampionPro=0.5;
mutPro=0.05;
[x endPop bpop trace] = GO_ga('fitness',[],initPop,[1e-6,1],'optTerm_ga',[maxGen,maxCnt,1e-6],...
                           'tournSelect_ga',[numTourn,ChampionPro],'simpleXover_ga',[],...
                           'binaryMut_ga',[mutPro]);


%% V. output the optimal solution found by gaot_ga
x

%% VI. convergence figure
plot(trace(:,1),trace(:,3),'b:','LineWidth',1)
hold on
plot(trace(:,1),trace(:,2),'r-','LineWidth',1)
xlabel('Generation'); ylabel('Fittness');
legend('Mean Fitness', 'Best Fitness')

