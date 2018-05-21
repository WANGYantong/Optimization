%% I. clear memory and screen
clear
clc

addpath(genpath(pwd));
%% II. Genetic Algorithm
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

flow=1:1:12;
NF=length(flow);
flow_parallel=cell(size(flow));
NF_parallel=zeros(size(flow));
for ii=1:NF
    flow_parallel{ii}=flow(1:ii);
    NF_parallel(ii)=length(flow_parallel{ii});
end

% sizePop=50;

maxGen=100;
maxCnt=10;
numTourn=10;
ChampionPro=0.5;
mutPro=0.05;

value=zeros(NF,2);

tic;
for ii=1:NF
    
    sizePop=ceil(ii/5)*10;

    %% III. initialize population
    sol_greed=Greedy_mod(flow_parallel{ii});
    
    initPop = initialize_ga(sizePop,'fitness',[NF_parallel(ii),10],[],[1,0.2],sol_greed);
    
    %% IV. call genetic algorithm
    
    [x,endPop,bpop,trace] = GO_ga('fitness',[],initPop,[1e-6,0],'optTerm_ga',[maxGen,maxCnt,1e-6],...
        'tournSelect_ga',[numTourn,ChampionPro],'simpleXover_ga',[],...
        'binaryMut_ga',[mutPro]);
    
    value(ii,1)=trace(end,1);
    value(ii,2)=x{2};
% %% V. output the optimal solution found by gaot_ga
%     x
% %% VI. convergence figure
%     plot(trace(:,1),trace(:,3),'b:','LineWidth',1)
%     hold on
%     plot(trace(:,1),trace(:,2),'r-','LineWidth',1)
%     xlabel('Generation'); ylabel('Fittness');
%     legend('Mean Fitness', 'Best Fitness')
end
run_time=toc;

figure(1);
bar(value(:,1));
ylim([0,100]);
xlabel('num of flow'); ylabel('terminal gen');
print('pic\ceil5_N_1','-depsc');

load 'result.mat';
figure(2);
cost_PCDG=result(1:NF,3);
cost_NEC=result(1:NF,10);
cost_GRD=result(1:NF,17);
cost_RGR=result(1:NF,24);
plot(flow,value(:,2),'-+','LineWidth',1.6);
hold on;
plot(flow,cost_PCDG,'-o',flow,cost_NEC,'-*',...
    flow,cost_GRD,'-x',flow,cost_RGR,'-s','LineWidth',1.6);
ylim([0,10000]);
set(gca,'ytick',[1000:1000:10000],'yticklabel',{'1K','2K','3K','4K','5K','6K','7K','8K','9K','10K'});
xlabel('num of flow'); ylabel('fitness');
lgd=legend('Gene', 'PCDG','NEC','GRD','RGR','Location','northwest');
lgd.FontSize=12;
print('pic\ceil5_N_2','-depsc');
