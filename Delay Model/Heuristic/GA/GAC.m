function result = GAC(flow,data,alpha,penalty,punish)
%Genetic Algorithm
%
% encoding : binary array
% initial population size : ceil(N/5)*10;
% initial population : 80% randomized; 20% greedy;
% fitness function : with constraints penalty;
% crossover : simple crossover(one point);
% mutation : binary mutation (bit exchange, P=0.05);
% selection : tournament
% terminable criteria : stable performance or max generation

global data_buff;
NF=length(flow);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);
punish=punish(1:NF);

num_ec=length(data.edge_cloud);

result=zeros(1,6);

data_buff=data;
data_buff.alpha=alpha;
data_buff.penalty=penalty;

maxGen=100;
maxCnt=10;
% numTourn=10;
% ChampionPro=0.5;
mutPro=0.05;  
sizePop=ceil(NF/5)*10;

solution=Greedy(flow,data,alpha,punish);
sol_greed=solution.allocation;

tic;
%initialize population
initPop = initialize_ga(sizePop,'fitness',{punish},[NF,num_ec],[1,0.2],sol_greed);
    
%call genetic algorithm
[x,endPop,bpop,trace] = GO_ga('fitness',{punish},initPop,[1e-6,1],'optTerm_ga',[maxGen,maxCnt,1e-6],...
    'rankSelect_ga',[],'shuffleXover_ga',[1],...
    'binaryMut_ga',[mutPro]);
run_time=toc;

vector=decoding_ga(x{1});
[result(2),result(3)]=fitness_mod(vector,data,penalty,punish);

result(1)=x{2};
result(4)=run_time;

buff=MonteCarlo(flow,vector,data,punish,alpha,penalty);
result(1,5:6)=buff;
%convergence figure
%     plot(trace(:,1),trace(:,3),'b:','LineWidth',1)
%     hold on
%     plot(trace(:,1),trace(:,2),'r-','LineWidth',1)
%     xlabel('Generation'); ylabel('Fittness');
%     legend('Mean Fitness', 'Best Fitness')



% figure(1);
% bar(value(:,1));
% ylim([0,100]);
% xlabel('num of flow'); ylabel('terminal gen');
% print('pic\ceil_N_1','-depsc');
% 
% load 'result50.mat';
% figure(2);
% % cost_PCDG=result(1:NF,3);
% cost_NEC=result(1:NF,10);
% cost_GRD=result(1:NF,17);
% cost_RGR=result(1:NF,24);
% plot(flow,value(:,2),'-+','LineWidth',1.6);
% hold on;
% % plot(flow,cost_PCDG,'-o',flow,cost_NEC,'-*',...
% %     flow,cost_GRD,'-x',flow,cost_RGR,'-s','LineWidth',1.6);
% plot(flow,cost_NEC,'-*',...
%     flow,cost_GRD,'-x',flow,cost_RGR,'-s','LineWidth',1.6);
% ylim([0,40000]);
% set(gca,'ytick',[0:10000:40000],'yticklabel',{'0K','10K','20K','30K','40K'});
% xlabel('num of flow'); ylabel('fitness');
% lgd=legend('Gene','NEC','GRD','RGR','Location','northwest');
% lgd.FontSize=12;
% print('pic\ceil_N_2','-depsc');
% 
% figure(3);
% time_NEC=result(1:NF,13);
% time_GRD=result(1:NF,20);
% time_RGR=result(1:NF,27);
% plot(flow,value(:,3),'-+','LineWidth',1.6);
% hold on;
% plot(flow,cost_NEC,'-*',...
%     flow,cost_GRD,'-x',flow,cost_RGR,'-s','LineWidth',1.6);
% xlabel('num of flow'); ylabel('running time');
% lgd=legend('Gene','NEC','GRD','RGR','Location','northwest');
% lgd.FontSize=12;
% print('pic\ceil_N_3','-depsc');
end