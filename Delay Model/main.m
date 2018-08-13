clear
clc

addpath(genpath(pwd));
rng(1);

%% I. establish parameter

%%%%%%%% construct network topology %%%%%%%%
[G_full,vertice_names,edge_cloud,p]=GenerateGraph2();
N=length(vertice_names);
for v=1:N
    eval([vertice_names{v},'=',num2str(v),';']);
end

%%%%%%%% generate analysis variables %%%%%%%%

% each flow reprerents a mobile user
flow=1:1:20;
NF=length(flow);
% for stable, like rng
NF_TOTAL=20;
flow_parallel=cell(size(flow));
for ii=1:NF
    flow_parallel{ii}=flow(1:ii);
end

% store result
result=zeros(NF_TOTAL,43);
for ii=1:NF
    result(ii,1)=ii;
end

% weight of cache cost
para.alpha=10;
% weight of path cost
para.beta=10;
% weight of cache miss
para.gamma=10;
% cost of cache miss
para.miss_penalty=100;

%%%%%%%% generate simulation data structure %%%%%%%%
% data.server=[data_server];
% data.relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
%     relay10,relay11,relay12,relay13,relay14,relay15];
% data.base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];
% data.access_router=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
% data.router=[router1,router2,router3,router4,router5,router6,router7,router8];
% data.edge_cloud=edge_cloud;
data.server=[data_server];
data.relay=[relay1,relay2,relay3,relay4,relay5];
data.access_router=[AR1,AR2,AR3,AR4,AR5];
data.router=[router1,router2,router3,router4];
data.edge_cloud=edge_cloud;

idx=[data.router,data.access_router];
G_sub=subgraph(G_full,idx);
% data.graph=G_sub;
data.graph=G_full;
%data.targets=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
data.targets=[AR1,AR2,AR3,AR4,AR5];

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
data.W_k=W_k(1:NF);

% original utilization
data.utilization=GenerateUtilization(edge_cloud);

% remaining cache space for each edge cloud
data.W_e=8500;
data.W_re_e=ones(size(edge_cloud))*data.W_e;
data.W_re_e=data.W_re_e.*(1-data.utilization);

% remaining cache space in total
data.W_re_t=data.W_e*10;

% Delay paremeter
flow_stable=1:1:NF_TOTAL;
[R_k,ce,mu]=GenerateDelayParameter(flow_stable,edge_cloud);
data.R_k=R_k(1:NF);
data.ce=ce;
data.mu=mu;

% link capacity
data.C_l=1;

% delay tolerance: 50,100,150
% unit: Ms
% delta=[50,100,150];
% data.delta=randi(3,1,NF);
% data.delta=delta(data.delta);
mid_array=[50,50,50,100,100,100,100,150,150,150];
data.delta=repmat(mid_array,1,2);

% mobile user movement
probability_ka=zeros(NF,length(data.targets));
for ii=1:NF
    probability_ka(ii,:)=GetFlowProbability(ii,data.access_router,data.targets);
end
data.probability=probability_ka;

para.QoS_penalty=log(max(data.delta)+50-data.delta)*0.1;

%% II. optimal solution
buffer=zeros(NF,7);
% parfor ii=1:NF
parfor ii=1:NF
   buffer(ii,:)=MILP(flow_parallel{ii},data,para);
end

result(1:NF,2:8)=buffer;

%% III. Oracle solution
data_cp=data;
data_cp.probability=zeros(NF,length(data_cp.access_router));
[~,I]=sort(data.probability,2,'descend');
for ii=1:NF
    data_cp.probability(ii,I(ii))=1;
end
buffer=zeros(NF,7);

parfor ii=1:NF
   buffer(ii,:)=MILP(flow_parallel{ii},data_cp,para);
end
result(1:NF,38:43)=buffer(1:NF,2:7);
%% IV. heuristic solution

% Nearest Edge Cloud Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=NEC(flow_parallel{ii},data,para);
end

result(1:NF,10:15)=buffer;

% Greedy Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=GRD(flow_parallel{ii},data,para);
end

result(1:NF,17:22)=buffer;

% Randomized Greedy Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=RGR(flow_parallel{ii},data,para);
end

result(1:NF,24:29)=buffer;

% Genetic Algorithm Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=GAC(flow_parallel{ii},data,para);
end

result(1:NF,31:36)=buffer;

%% result comparision

% data structure of result
% 1 index; 2 No_cache cost;
%
% 3  PCDG cost; 4 PCDG penalty; 5 PCDG failed number; 6 PCDG running time; 
% 7  PCDG Monte Carlo Cost; 8 PCDG Monte Carlo failed number;
% 9 
% 10 NEC cost; 11 NEC penalty; 12 NEC failed number; 13 NEC running time; 
% 14 NEC Monte Carlo Cost; 15 NEC Monte Carlo failed number;
% 16 
% 17 GRC cost; 18 GRC penalty; 19 GRC failed number; 20 GRC running time; 
% 21 GRC Monte Carlo Cost; 22 GRC Monte Carlo failed number;
% 23
% 24 RGC cost; 25 RGC penalty; 26 RGC failed number; 27 RGC running time; 
% 28 RGC Monte Carlo Cost; 29 RGC Monte Carlo failed number;
% 30
% 31 GAC cost; 32 GAC penalty; 33 GAC failed number; 34 GAC running time; 
% 35 GAC Monte Carlo Cost; 36 GAC Monte Carlo failed number;
% 37
% 38 Oracle cost; 39 Oracle penalty; 40 Oracle failed number; 41 Oracle
% running time; 42 Oracle Monte Carlo Cost; 43 Oracle Monte Carlo failed
% number

cost_Nocache=result(1:NF,2);
cost_MILP=result(1:NF,3);
cost_NEC=result(1:NF,10);
cost_GRD=result(1:NF,17);
cost_RGR=result(1:NF,24);
cost_GA=result(1:NF,31);
cost_Oracle=result(1:NF,38);
cost_Monte_MILP=result(1:NF,7);
cost_Monte_NEC=result(1:NF,14);
cost_Monte_GRD=result(1:NF,21);
cost_Monte_RGR=result(1:NF,28);
cost_Monte_GA=result(1:NF,35);
cost_Monte_Oracle=result(1:NF,42);

% figure(1);
% plot(flow,cost_Nocache,':o',flow,cost_MILP,'-p',flow,cost_NEC,'-*',...
%     flow,cost_GRD,'-x',flow,cost_RGR,'-s',flow,cost_GA,'-+',...
%     'LineWidth',1.6);
% xlabel('number of flows');
% ylabel('total cost');
% lgd=legend({'Nocache','PCDG','NEC','GRC','RGC','GAC'},...
%     'location','northwest');
% lgd.FontSize=12;

figure(1);
plot(flow,cost_Monte_MILP,'-p', flow,cost_Monte_RGR,'-s',flow,cost_Monte_GA,'-+',...
    flow,cost_Monte_Oracle,'-^','LineWidth',1.6);
xlabel('Number of flows');
ylabel('Total cost');
lgd=legend({'PCDG','RGC','GAC','Oracle'},...
    'location','northwest');
% set(gca,'yscale','log');
lgd.FontSize=12;

% figure(2);
% % axis auto normal;
% plot(flow,cost_Nocache,'-o',flow,cost_Monte_MILP,'-p',flow,cost_Monte_NEC,'-*',...
%     flow,cost_Monte_GRD,'-x',flow,cost_Monte_RGR,'-s',flow,cost_Monte_GA,'-+',...
%     flow, cost_Monte_Oracle,'-^','LineWidth',1.6);
% xlabel('Number of flows');
% ylabel('Monte Carlo cost');
% lgd=legend({'Nocache','PCDG','NEC','GRC','RGC','GAC','Oracle'},...
%     'location','northwest');
% % set(gca,'YTick',[0:50:250,500:500:2500]);
% %set(gca,'yscale','log');
% % xlim([1,20]);
% lgd.FontSize=12;
% grid on;

threshold=[100,300];
scale_k=[10,5,5/22];
scale_b=[0,500,42500/22];
cost_Nocache_cp=figureScale(cost_Nocache,threshold,scale_k,scale_b);
cost_Monte_MILP_cp=figureScale(cost_Monte_MILP,threshold,scale_k,scale_b);
cost_Monte_NEC_cp=figureScale(cost_Monte_NEC,threshold,scale_k,scale_b);
cost_Monte_GRD_cp=figureScale(cost_Monte_GRD,threshold,scale_k,scale_b);
cost_Monte_RGR_cp=figureScale(cost_Monte_RGR,threshold,scale_k,scale_b);
cost_Monte_GA_cp=figureScale(cost_Monte_GA,threshold,scale_k,scale_b);
cost_Monte_Oracle_cp=figureScale(cost_Monte_Oracle,threshold,scale_k,scale_b);
figure(2);
plot(flow,cost_Nocache_cp,'-o',flow,cost_Monte_MILP_cp,'-p',flow,cost_Monte_NEC_cp,'-*',...
    flow,cost_Monte_GRD_cp,'-x',flow,cost_Monte_RGR_cp,'-s',flow,cost_Monte_GA_cp,'-+',...
    flow, cost_Monte_Oracle_cp,'-^','LineWidth',1.6);
xlabel('Number of flows');
ylabel('Monte Carlo cost');
lgd=legend({'Nocache','PCDG','NEC','GRC','RGC','GAC','Oracle'},...
    'location','northwest');
yticklabels({'0','50','100','200','300','2500'});
lgd.FontSize=12;
grid on;

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

outage_Monte_MILP=result(5:5:NF,8)./result(5:5:NF,1);
outage_Monte_NEC=result(5:5:NF,15)./result(5:5:NF,1);
outage_Monte_GRD=result(5:5:NF,22)./result(5:5:NF,1);
outage_Monte_RGR=result(5:5:NF,29)./result(5:5:NF,1);
outage_Monte_GA=result(5:5:NF,36)./result(5:5:NF,1);
outage_Monte_Oracle=result(5:5:NF,43)./result(5:5:NF,1);
Monte_satis=[1-outage_Monte_MILP,1-outage_Monte_NEC,1-outage_Monte_GRD,...
    1-outage_Monte_RGR,1-outage_Monte_GA,1-outage_Monte_Oracle];
figure(4);
bar(Monte_satis);
xlabel('Number of flows');
ylabel('Satisfied probability');
ylim([0,1.5]);
set(gca,'xtick',[1:4],'xticklabel',{'5','10','15','20'});
lgd=legend({'PCDG','NEC','GRC','RGC','GAC','Oracle'},'location','northwest');
lgd.FontSize=12;
applyhatch(gcf,'\/-x+|',[]);

runtime_MILP=result(1:NF,6);
runtime_NEC=result(1:NF,13);
runtime_GRD=result(1:NF,20);
runtime_RGR=result(1:NF,27);
runtime_GA=result(1:NF,34);
runtime_Oracle=result(1:NF,41);
figure(5);
plot(flow,runtime_MILP,'-p',flow,runtime_NEC,'-*',...
    flow,runtime_GRD,'-x',flow,runtime_RGR,'-s',flow,runtime_GA,'-+',...
    flow,runtime_Oracle,'-^','LineWidth',1.6);
xlabel('Number of flows');
ylabel('Running time');
lgd=legend({'PCDG','NEC','GRC','RGC','GAC','Oracle'},...
    'location','northwest');
set(gca,'yscale','log');
lgd.FontSize=12;

% export result as xlsx in Windows
% if ispc
%     filename='OutPut\main.xlsx';
%     xlswrite(filename,result);
% end

% ec_congestion=xlsread('OutPut\ec_congestion.xlsx');
% boxplot(ec_congestion,'Labels',{'NEC','GRC','RGC','GAC','PCDG'});
% title('Edge Cloud Congestion after Caching Assignment (flow=20)');
% xlabel('Method');
% ylabel('Utilization');
% link_congestion=xlsread('OutPut\link_congestion.xlsx');
% boxplot(link_congestion,'Labels',{'NEC','GRC','RGC','GAC','PCDG'});
% title('Link Congestion after Caching Assignment (flow=20)');
% xlabel('Method');
% ylabel('Utilization');