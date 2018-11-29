clear
clc

addpath(genpath(pwd));
rng(1);

%% I. establish parameter

%%%%%%%% construct network topology %%%%%%%%
[G_full,vertice_names,edge_cloud,p]=GenerateGraph();
N=length(vertice_names);
for v=1:N
    eval([vertice_names{v},'=',num2str(v),';']);
end

%%%%%%%% generate analysis variables %%%%%%%%
step=10;
% each flow reprerents a mobile user
flow=1:60;
NF=length(flow)/step;
% for stable, like rng
NF_TOTAL=60;
% flow_parallel=cell(size(flow));
flow_parallel=cell(NF,1);
for ii=1:NF
    flow_parallel{ii}=flow(1:ii*step);
end

% store result
result=cell(NF,55);
for ii=1:NF
    result{ii,1}=ii*step;
end

% weight of cache cost
para.alpha=5;
% weight of path cost
para.beta=10;
% weight of cache miss
para.gamma=10;
% cost of cache miss
para.miss_penalty=100;

%%%%%%%% generate simulation data structure %%%%%%%%
data.server=[data_server];
data.relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
    relay10,relay11,relay12,relay13,relay14,relay15];
data.base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];
data.access_router=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
data.router=[router1,router2,router3,router4,router5,router6,router7,router8];
data.edge_cloud=edge_cloud;
% data.server=[data_server];
% data.relay=[relay1,relay2,relay3,relay4,relay5];
% data.access_router=[AR1,AR2,AR3,AR4,AR5];
% data.router=[router1,router2,router3,router4];
% data.edge_cloud=edge_cloud;

idx=[data.access_router,data.router];
G_sub=subgraph(G_full,idx);
data.graph=G_sub;
% data.graph=G_full;
data.targets=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
% data.targets=[AR1,AR2,AR3,AR4,AR5];

%calculate the shortest path and path cost
path=cell(length(data.access_router), length(edge_cloud));
w=path;
for ii=1:length(data.access_router)
    for jj=1:length(edge_cloud)
        [path{ii,jj},w{ii,jj}]=shortestpath(data.graph,data.access_router(ii),edge_cloud(jj));
    end  
end
data.path=path;
data.cost=w;

% the maximum number of edge cloud used to cache
data.N_k=1;

% size of cache items
W_k=GenerateItemsSize(NF_TOTAL)';
data.W_k=W_k(1:flow(end));

% original utilization
% data.utilization=GenerateUtilization(edge_cloud);
data.utilization=zeros(size(edge_cloud));

% remaining cache space for each edge cloud
data.W_e=8000;
data.W_re_e=ones(size(edge_cloud))*data.W_e-3000;
data.W_re_e=data.W_re_e.*(1-data.utilization);

% remaining cache space in total
data.W_re_t=80000;

% Delay paremeter
flow_stable=1:NF_TOTAL;
[R_k,ce,mu]=GenerateDelayParameter(flow_stable,edge_cloud);
data.R_k=R_k(1:flow(end));
data.ce=ce;
data.mu=mu;

% link capacity
data.C_l=2000;

% delay tolerance: 50,100,150
% unit: Ms
% delta=[50,100,150];
% data.delta=randi(3,1,NF);
% data.delta=delta(data.delta);
mid_array=[30,30,30,100,100,10000,10000,10000,10000,10000];
data.delta=repmat(mid_array,1,10);

% mobile user movement
probability_ka=zeros(flow(end),length(data.targets));
for ii=1:flow(end)
    probability_ka(ii,:)=GetFlowProbability(ii,data.access_router,data.targets,4);
end
data.probability=probability_ka;

para.QoS_penalty=log(max(data.delta)-data.delta+50)*0.01;

%% II. optimal solution
buffer=cell(NF,9);
parfor ii=1:NF
   buffer(ii,:)=MILP(flow_parallel{ii},data,para);
end

result(:,2:10)=buffer;

%% III. Oracle solution
% data_cp=data;
% data_cp.probability=zeros(NF,length(data_cp.access_router));
% [~,I]=sort(data.probability,2,'descend');
% for ii=1:flow(end)
%     data_cp.probability(ii,I(ii))=1;
% end
% buffer=cell(NF,9);
% 
% parfor ii=1:NF
%    buffer(ii,:)=MILP(flow_parallel{ii},data_cp,para);
% end
% result(:,48:55)=buffer(:,2:9);
%% IV. heuristic solution

% Nearest Edge Cloud Caching
% buffer=cell(NF,8);
% parfor ii=1:NF
%    buffer(ii,:)=NEC(flow_parallel{ii},data,para);
% end
% 
% result(:,12:19)=buffer;

% Greedy Caching
buffer=cell(NF,8);
parfor ii=1:NF
   buffer(ii,:)=GRD(flow_parallel{ii},data,para);
end

result(:,21:28)=buffer;

% Randomized Greedy Caching
% buffer=cell(NF,8);
% parfor ii=1:NF
%    buffer(ii,:)=RGR(flow_parallel{ii},data,para);
% end
% 
% result(:,30:37)=buffer;

% Genetic Algorithm Caching
% buffer=cell(NF,8);
% traceInfo=cell(10,1);
% parfor ii=1:NF
%    [buffer(ii,:),traceInfo{ii}]=GAC(flow_parallel{ii},data,para);
% end
% 
% result(:,39:46)=buffer;

% All Caching
buffer=cell(NF,8);
parfor ii=1:NF
   buffer(ii,:)=ALC(flow_parallel{ii},data,para);
end

result(:,57:64)=buffer;

%% result comparision

% data structure of result
% 1 index; 2 No_cache cost;
%
% 3  PCDG cost; 4 PCDG penalty; 5 PCDG failed number; 6 PCDG running time; 
% 7  PCDG Monte Carlo Cost; 8 PCDG Monte Carlo failed number;
% 9  PCDG edge jam; 10 PCDG link jam 
% 11
% 12 NEC cost; 13 NEC penalty; 14 NEC failed number; 15 NEC running time; 
% 16 NEC Monte Carlo Cost; 17 NEC Monte Carlo failed number;
% 18 NEC edge jam; 19 NEC link jam
% 20
% 21 GRC cost; 22 GRC penalty; 23 GRC failed number; 24 GRC running time; 
% 25 GRC Monte Carlo Cost; 26 GRC Monte Carlo failed number;
% 27 GRC edge jam; 28 GRC link jam
% 29
% 30 RGC cost; 31 RGC penalty; 32 RGC failed number; 33 RGC running time; 
% 34 RGC Monte Carlo Cost; 35 RGC Monte Carlo failed number;
% 36 RGC edge jam; 37 RGC link jam
% 38
% 39 GAC cost; 40 GAC penalty; 41 GAC failed number; 42 GAC running time; 
% 43 GAC Monte Carlo Cost; 44 GAC Monte Carlo failed number;
% 45 GAC edge jam; 46 GAC link jam
% 47
% 48 Oracle cost; 49 Oracle penalty; 50 Oracle failed number; 51 Oracle
% running time; 52 Oracle Monte Carlo Cost; 53 Oracle Monte Carlo failed
% number; 54 Oracle edge jam; 55 Oracle link jam
% 56
% 57 AllCache cost; 58 AllCache penalty; 59 AllCache failed number; 
% 60 AllCache running time; 61 AllCache Monte Carlo Cost; 62 AllCache Monte
% Carlo failed number; 63 AllCache edge jam; 64 AllCache link jam

flow_plot=cell2mat(result(1:NF,1));

cost_Nocache=cell2mat(result(1:NF,2));
cost_MILP=cell2mat(result(1:NF,3));
% cost_NEC=cell2mat(result(1:NF,12));
cost_GRD=cell2mat(result(1:NF,21));
% cost_RGR=cell2mat(result(1:NF,30));
% cost_GA=cell2mat(result(1:NF,39));
% cost_Oracle=cell2mat(result(1:NF,48));
cost_AllCache=cell2mat(result(1:NF,57));

cost_Monte_MILP=cell2mat(result(1:NF,7));
% cost_Monte_NEC=cell2mat(result(1:NF,16));
cost_Monte_GRD=cell2mat(result(1:NF,25));
% cost_Monte_RGR=cell2mat(result(1:NF,34));
% cost_Monte_GA=cell2mat(result(1:NF,43));
% cost_Monte_Oracle=cell2mat(result(1:NF,52));

figure(1);
hold on;
plot(flow_plot,cost_Monte_MILP,'-p','Color',[0.85,0.33,0.10],'LineWidth',1.6);
% plot(flow_plot,cost_Monte_RGR,'-s','Color',[0.47,0.67,0.19],'LineWidth',1.6);
plot(flow_plot,cost_Monte_GA,'-+','Color',[0.30,0.75,0.93],'LineWidth',1.6);
plot(flow_plot,cost_Monte_Oracle,'-^','Color',[0.64,0.08,0.18],'LineWidth',1.6);
plot(flow_plot,cost_Monte_GRD,'-x','Color',[0.49,0.18,0.56],'LineWidth',1.6);
xlabel('Number of flows');
ylabel('Total cost');
lgd=legend({'PCDG','GAC','Oracle','GRD'},...
    'location','northwest');
% set(gca,'yscale','log');
lgd.FontSize=12;
hold off;
% set(gcf,'color','none'); 
% set(gca,'color','none');

figure(2);
% axis auto normal;
hold on;
plot(flow_plot,cost_Nocache,'-o','Color',[0.00,0.45,0.74],'LineWidth',3.2,'MarkerSize',10);
% plot(flow_plot,cost_Monte_NEC,'-*','Color',[0.93,0.69,0.13],'LineWidth',1.6);
plot(flow_plot,cost_Monte_GRD,'-*','Color',[0.93,0.69,0.13],'LineWidth',3.2,'MarkerSize',10);
% plot(flow_plot,cost_Monte_RGR,'-s','Color',[0.47,0.67,0.19],'LineWidth',1.6);
plot(flow_plot,cost_Monte_GA,'-s','Color',[0.47,0.67,0.19],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_Monte_MILP,'-p','Color',[0.30,0.75,0.93],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot, cost_Monte_Oracle,'-^','Color',[0.64,0.08,0.18],'LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'Nocache','GRC','GAC','PCDG','Oracle'},...
    'location','northwest');
% set(lgd,'Box','off');
set(gca,'fontsize',24);
% set(gca,'YTick',[0:50:250,500:500:2500]);
% set(gca,'yscale','log');
ylim([0,1050]);
lgd.FontSize=24;
grid on;
hold off;

figure(2);
% axis auto normal;
hold on;
plot(flow_plot,cost_Nocache/5,'-o','Color',[0.00,0.45,0.74],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_AllCache,'-s','Color',[0.49,0.18,0.56],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_Monte_GRD,'-*','Color',[0.93,0.69,0.13],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_Monte_MILP,'-p','Color',[0.30,0.75,0.93],'LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'No Cache','All Cache','GRC','PCDG'},...
    'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;

% threshold=[100,300];
% scale_k=[10,5,5/22];
% scale_b=[0,500,42500/22];
% cost_Nocache_cp=figureScale(cost_Nocache,threshold,scale_k,scale_b);
% cost_Monte_MILP_cp=figureScale(cost_Monte_MILP,threshold,scale_k,scale_b);
% cost_Monte_NEC_cp=figureScale(cost_Monte_NEC,threshold,scale_k,scale_b);
% cost_Monte_GRD_cp=figureScale(cost_Monte_GRD,threshold,scale_k,scale_b);
% cost_Monte_RGR_cp=figureScale(cost_Monte_RGR,threshold,scale_k,scale_b);
% cost_Monte_GA_cp=figureScale(cost_Monte_GA,threshold,scale_k,scale_b);
% cost_Monte_Oracle_cp=figureScale(cost_Monte_Oracle,threshold,scale_k,scale_b);
% figure(2);
% plot(flow_plot,cost_Nocache_cp,'-o',flow_plot,cost_Monte_MILP_cp,'-p',flow_plot,cost_Monte_NEC_cp,'-*',...
%     flow_plot,cost_Monte_GRD_cp,'-x',flow_plot,cost_Monte_RGR_cp,'-s',flow_plot,cost_Monte_GA_cp,'-+',...
%     flow_plot, cost_Monte_Oracle_cp,'-^','LineWidth',1.6);
% xlabel('Number of flows');
% ylabel('Monte Carlo cost');
% lgd=legend({'Nocache','PCDG','NEC','GRC','RGC','GAC','Oracle'},...
%     'location','northwest');
% yticklabels({'0','50','100','200','300','2500'});
% lgd.FontSize=12;
% grid on;

outage_MILP=result(2:2:NF,5);
outage_NEC=result(2:2:NF,12);
outage_GRD=result(2:2:NF,19);
outage_RGR=result(2:2:NF,26);
outage_GA=result(2:2:NF,33);
outage_Oracle=result(2:2:NF,40);
outage=[outage_MILP,outage_NEC,outage_GRD,outage_RGR,outage_GA,outage_Oracle];
figure(3);
bar(outage,0.6);
xlabel('Number of flows');
ylabel('Outage number');
% ylim([0,1.35]);
set(gca,'xtick',[1:10],'xticklabel',{'2','4','6','8','10','12','14','16','18','20'});
lgd=legend({'PCDG','NEC','GRC','RGC','GAC','Oracle'},'location','northwest');
lgd.FontSize=12;

% outage_Monte_MILP=result(2:2:NF,8)./result(2:2:NF,1);
% outage_Monte_NEC=result(2:2:NF,15)./result(2:2:NF,1);
% outage_Monte_GRD=result(2:2:NF,22)./result(2:2:NF,1);
% outage_Monte_RGR=result(2:2:NF,29)./result(2:2:NF,1);
% outage_Monte_GA=result(2:2:NF,36)./result(2:2:NF,1);
% outage_Monte_Oracle=result(2:2:NF,43)./result(2:2:NF,1);
% Monte_satis=[1-outage_Monte_MILP,1-outage_Monte_NEC,1-outage_Monte_GRD,...
%     1-outage_Monte_RGR,1-outage_Monte_GA,1-outage_Monte_Oracle];
% figure(4);
% bar(Monte_satis);
% xlabel('Number of flows');
% ylabel('Satisfied probability');
% ylim([0,1.5]);
% set(gca,'xtick',[1:10],'xticklabel',{'2','4','6','8','10','12','14','16','18','20'});
% lgd=legend({'PCDG','NEC','GRC','RGC','GAC','Oracle'},'location','northwest');
% lgd.FontSize=12;
% % applyhatch(gcf,'\/-x+',[]);

outage_No_Cache=ones(NF,1)*0.5;
outage_Monte_GRD=cell2mat(result(1:NF,26))./cell2mat(result(1:NF,1));
% outage_Monte_NEC=result(2:4:NF,15)./result(2:4:NF,1);
% outage_Monte_RGR=result(2:4:NF,29)./result(2:4:NF,1);
% outage_Monte_GA=result(2:2:NF,36)./result(2:2:NF,1);
outage_All_Cache=cell2mat(result(1:NF,59))./cell2mat(result(1:NF,1));
outage_Monte_MILP=cell2mat(result(1:NF,8))./cell2mat(result(1:NF,1));
% outage_Monte_Oracle=result(2:4:NF,43)./result(2:4:NF,1);
% Monte_satis=[1-outage_Monte_MILP,1-outage_Monte_NEC,1-outage_Monte_GRD,...
%     1-outage_Monte_RGR,1-outage_Monte_GA];
Monte_satis=[1-outage_No_Cache, 1-outage_All_Cache,...
    1-outage_Monte_GRD,1-outage_Monte_MILP];
figure(4);
b=bar(Monte_satis);
b(1).FaceColor=[0.00,0.45,0.74];
b(2).FaceColor=[0.49,0.18,0.56];
b(3).FaceColor=[0.93,0.69,0.13];
b(4).FaceColor=[0.30,0.75,0.93];
xlabel('Number of flows');
ylabel('Satisfied probability');
ylim([0,1.5]);
set(gca,'xtick',[1:6],'xticklabel',{'10','20','30','40','50','60'},'fontsize',24);
lgd=legend({'No Cache','All Cache','GRC','PCDG'},'location','north');
% set(lgd,'Box','off');
lgd.NumColumns=4;
lgd.FontSize=24;
applyhatch(gcf,'\/x',[]);

runtime_MILP=result(1:NF,6);
% runtime_NEC=result(1:NF,13);
runtime_GRD=result(1:NF,20);
% runtime_RGR=result(1:NF,27);
runtime_GA=result(1:NF,34);
% runtime_Oracle=result(1:NF,41);
figure(5);
hold on;
plot(flow_plot,runtime_GRD,'-x','Color',[0.93,0.69,0.13],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,runtime_GA,'-+','Color',[0.47,0.67,0.19],'LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,runtime_MILP,'-p','Color',[0.30,0.75,0.93],'LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows');
ylabel('Running time (s)');
lgd=legend({'GRC','GAC','PCDG'},...
    'location','north');
set(gca,'yscale','log','fontsize',24);
% set(lgd,'Box','off');
lgd.NumColumns=3;
ylim([0,10^3]);
lgd.FontSize=24;
hold off;

for ii=1:NF
    figure(ii+5);
    plot(traceInfo{ii}(:,1),traceInfo{ii}(:,3),'-p','LineWidth',3.2,'MarkerSize',10);
    hold on;
    plot(traceInfo{ii}(:,1),traceInfo{ii}(:,2),'-*','LineWidth',3.2,'MarkerSize',10);
    xlabel('Generation'); ylabel('Fittness');
    hold off;
    lgd=legend({'Mean','Best'},'location','north');
    set(gca,'fontsize',24);
    lgd.FontSize=24;
end
% export result as xlsx in Windows
% if ispc
%     filename='OutPut\main.xlsx';
%     xlswrite(filename,result);
% end

% probability sensitive
% not mention the specific distribution, define a function with veriation,
% represent pre-knowledge
%PCDG
pro_cost=xlsread('OutPut\3rd\pro_cost.xlsx');
cost_PCDG_1=pro_cost(1:NF,2);
cost_PCDG_2=pro_cost(1:NF,3);
cost_PCDG_3=pro_cost(1:NF,4);
cost_PCDG_4=pro_cost(1:NF,5);
figure(16);hold on;
flow_plot=pro_cost(1:NF,1);
plot(flow_plot,cost_PCDG_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_2,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_3,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_4,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'H=2.58','H=1.96','H=1.48','H=0'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;
%GRD
cost_GRD_1=pro_cost(1:NF,7);
cost_GRD_2=pro_cost(1:NF,8);
cost_GRD_3=pro_cost(1:NF,9);
cost_GRD_4=pro_cost(1:NF,10);
figure(17);hold on;
flow_plot=pro_cost(1:NF,1);
plot(flow_plot,cost_GRD_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_2,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_3,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_4,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'H=2.58','H=1.96','H=1.48','H=0'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;
%GAC
cost_GAC_1=pro_cost(1:NF,12);
cost_GAC_2=pro_cost(1:NF,13);
cost_GAC_3=pro_cost(1:NF,14);
cost_GAC_4=pro_cost(1:NF,15);
figure(18);hold on;
flow_plot=pro_cost(1:NF,1);
plot(flow_plot,cost_GAC_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_2,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_3,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_4,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'H=2.58','H=1.96','H=1.48','H=0'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;

%task sensitive
result_30_1=xlsread('OutPut\3rd\main_30_1.xlsx');
result_30_4=xlsread('OutPut\3rd\main_30_4.xlsx');
result_30_7=xlsread('OutPut\3rd\main_30_7.xlsx');
result_30_10=xlsread('OutPut\3rd\main_30_10.xlsx');
%PCDG
cost_PCDG_30_1=result_30_1(1:NF,7);
cost_PCDG_30_4=result_30_4(1:NF,7);
cost_PCDG_30_7=result_30_7(1:NF,7);
cost_PCDG_30_10=result_30_10(1:NF,7);
figure(19);hold on;
flow_plot=result_30_1(1:NF,1);
plot(flow_plot,cost_PCDG_30_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_30_4,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_30_7,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_PCDG_30_10,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'R_\tau=0.1','R_\tau=0.4','R_\tau=0.7','R_\tau=1'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;
%GRD
cost_GRD_30_1=result_30_1(1:NF,21);
cost_GRD_30_4=result_30_4(1:NF,21);
cost_GRD_30_7=result_30_7(1:NF,21);
cost_GRD_30_10=result_30_10(1:NF,21);
figure(20);hold on;
plot(flow_plot,cost_GRD_30_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_30_4,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_30_7,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GRD_30_10,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'R_\tau=0.1','R_\tau=0.4','R_\tau=0.7','R_\tau=1'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;
%GAC
cost_GAC_30_1=result_30_1(1:NF,35);
cost_GAC_30_4=result_30_4(1:NF,35);
cost_GAC_30_7=result_30_7(1:NF,35);
cost_GAC_30_10=result_30_10(1:NF,35);
figure(21);hold on;
plot(flow_plot,cost_GAC_30_1,'-*','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_30_4,'-s','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_30_7,'-p','LineWidth',3.2,'MarkerSize',10);
plot(flow_plot,cost_GAC_30_10,'-^','LineWidth',3.2,'MarkerSize',10);
xlabel('Number of flows','FontSize',24);
ylabel('Total cost','FontSize',24);
lgd=legend({'R_\tau=0.1','R_\tau=0.4','R_\tau=0.7','R_\tau=1'},'location','northwest');
set(gca,'fontsize',24);
lgd.FontSize=24;
grid on;
hold off;

ec_congestion1=xlsread('OutPut\ec_congestion.xlsx','B:B');
ec_congestion2=xlsread('OutPut\ec_congestion.xlsx','D:E');
ec_congestion=[ec_congestion1,ec_congestion2];
boxplot(ec_congestion,'Labels',{'GRC','GAC','PCDG'});
% title('Edge Cloud Congestion after Caching Assignment (flow=20)');
xlabel('Method');
ylabel('Utilization');

link_congestion1=xlsread('OutPut\link_congestion.xlsx','B:B');
link_congestion2=xlsread('OutPut\link_congestion.xlsx','D:E');
link_congestion=[link_congestion1,link_congestion2];
boxplot(link_congestion,'Labels',{'GRC','GAC','PCDG'});
% title('Link Congestion after Caching Assignment (flow=20)');
xlabel('Method');
ylabel('Utilization');