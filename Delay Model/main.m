clear
clc

rng(1);
%% construct network topology
[G_full,vertice_names,edge_cloud,p]=GenerateGraph();
N=length(vertice_names);
for v=1:N
    eval([vertice_names{v},'=',num2str(v),';']);
end

%% generate analysis variables

% each flow reprerents a mobile user
flow=1:1:15;
NF=length(flow);
% for stable, like rng
NF_TOTAL=20;
flow_parallel=cell(size(flow));
for ii=1:NF
    flow_parallel{ii}=flow(1:ii);
end

% store result
result=zeros(NF_TOTAL,30);
for ii=1:NF
    result(ii,1)=ii;
end

% weight of cache cost
alpha=10;
% weight of QoS penalty
penalty=10;

%% generate simulation data structure
data.server=[data_server];
data.relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
    relay10,relay11,relay12,relay13,relay14,relay15];
data.base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];
data.access_router=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
data.router=[router1,router2,router3,router4,router5,router6,router7,router8];
data.edge_cloud=edge_cloud;

data.graph=G_full;
data.targets=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];

%calculate the shortest path and path cost
path=cell(length(data.access_router), length(edge_cloud));
w=path;
for ii=1:length(data.access_router)
    for jj=1:length(edge_cloud)
        [path{ii,jj},w{ii,jj}]=shortestpath(G_full,data.access_router(ii),edge_cloud(jj));
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
data.W_e=5000;
data.Zeta_e=ones(size(edge_cloud))*data.W_e;
data.Zeta_e=data.Zeta_e.*(1-data.utilization);

% remaining cache space in total
data.Zeta_t=data.W_e*10;

% Delay paremeter
flow_stable=1:1:NF_TOTAL;
[R_k,ce,mu]=GenerateDelayParameter(flow_stable,edge_cloud);
data.R_k=R_k(1:NF);
data.ce=ce;
data.mu=mu;

% link capacity
data.C_l=1;

% delay tolerance: 50,150,250
% unit: Ms
delta=[50,150,250];
data.delta=randi(3,1,NF);
data.delta=delta(data.delta);

% mobile user movement
probability_ka=zeros(NF,length(data.targets));
for ii=1:NF
    probability_ka(ii,:)=GetFlowProbability(ii,data.access_router,data.targets);
end
data.probability=probability_ka;

%% optimal solution
buffer=zeros(NF,7);
parfor ii=1:NF
   buffer(ii,:)=MILP(flow_parallel{ii},data,alpha,penalty);
end

result(1:NF,2:8)=buffer;

%% heuristic solution

% Nearest Edge Cloud Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=NEC(flow_parallel{ii},data,alpha,penalty);
end

result(1:NF,10:15)=buffer;

% Greedy Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=GRD(flow_parallel{ii},data,alpha,penalty);
end

result(1:NF,17:22)=buffer;

% Randomized Greedy Caching
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=RGR(flow_parallel{ii},data,alpha,penalty);
end

result(1:NF,24:29)=buffer;

%% result comparision
cost_Nocache=result(1:NF,2);
cost_MILP=result(1:NF,3);
cost_NEC=result(1:NF,10);
cost_GRD=result(1:NF,17);
cost_RGR=result(1:NF,24);
cost_Monte_MILP=result(1:NF,7);
cost_Monte_NEC=result(1:NF,14);
cost_Monte_GRD=result(1:NF,21);
cost_Monte_RGR=result(1:NF,28);

figure(1);
plot(flow,cost_Nocache,'-o',flow,cost_MILP,'-+',flow,cost_NEC,'-*',...
    flow,cost_GRD,'-x',flow,cost_RGR,'-s');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend({'Nocache','MILP','NEC','GRD','RGR'},'location','northwest');

figure(2);
plot(flow,cost_Nocache,'-o',flow,cost_Monte_MILP,':+',...
    flow,cost_Monte_NEC,':*',flow,cost_Monte_GRD,':x',flow,cost_Monte_RGR,':s');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend({'Nocache','Monte MILP','Monte NEC','Monte GRD','Monte RGR'},...
    'location','northwest');

figure(3);
plot(flow,cost_MILP./cost_Nocache,'-+',flow,cost_NEC./cost_Nocache,'-*',...
    flow,cost_GRD./cost_Nocache,'-x',flow,cost_RGR./cost_Nocache,'-s');
title('cost gain');
xlabel('number of flows');
ylabel('cost gain');
legend({'MILP VS Nocache','NEC VS Nocache','GRD VS Nocache','RGR VS Nocache'},...
    'location','northwest');

figure(4);
plot(flow,cost_Monte_MILP./cost_Nocache,':+',flow,cost_Monte_NEC./cost_Nocache,':*',...
    flow,cost_Monte_GRD./cost_Nocache,':x',flow,cost_Monte_RGR./cost_Nocache,':s');
title('cost gain');
xlabel('number of flows');
ylabel('cost gain');
legend({'Monte_MILP VS Nocache','Monte_NEC VS Nocache','Monte_GRD VS Nocache',...
    'Monte_RGR VS Nocache'},'location','northwest');

outage_MILP=result(1:NF,5);
outage_NEC=result(1:NF,12);
outage_GRD=result(1:NF,19);
outage_RGR=result(1:NF,26);
outage=[outage_MILP,outage_NEC,outage_GRD,outage_RGR];
figure(5);
bar(outage,0.6);
title('Outage');
xlabel('number of flows');
ylim([0,1]);
legend({'MILP','NEC','GRD','RGR'},'location','north');

outage_Monte_MILP=result(1:NF,8);
outage_Monte_NEC=result(1:NF,15);
outage_Monte_GRD=result(1:NF,22);
outage_Monte_RGR=result(1:NF,29);
Monte_outage=[outage_Monte_MILP,outage_Monte_NEC,outage_Monte_GRD,outage_Monte_RGR];
figure(6);
bar(Monte_outage,0.6);
title('Outage');
xlabel('number of flows');
ylim([0,1]);
legend({'Monte MILP','Monte NEC','Monte GRD','Monte RGR'},'location','north');

% export result as xlsx in Windows
if ispc
    filename='main.xlsx';
    xlswrite(filename,result);
end