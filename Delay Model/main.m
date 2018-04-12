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
flow=1:1:6;
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
buffer=zeros(NF,6);
parfor ii=1:NF
   buffer(ii,:)=MILP(flow_parallel{ii},data,alpha,penalty);
end

result(1:NF,3:8)=buffer;

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
cost_MILP=result(1:1:NF,3);
cost_Nominal=result(1:1:NF,4);
cost_Greedy=result(1:1:NF,5);
cost_Random=result(1:1:NF,6);
cost_Nocache=result(1:1:NF,7);
figure(1);
plot(flow,cost_MILP,'-.o',flow,cost_Nominal,'-.^',...
    flow,cost_Greedy,'-.s',flow,cost_Random,'-.d');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend({'MILP','NEC','Greedy','Randomized'},'location','northwest');

delay_MILP=result(1:1:NF,9);
delay_Nominal=result(1:1:NF,10);
delay_Greedy=result(1:1:NF,11);
delay_Random=result(1:1:NF,12);
delay_Tolerance=result(1:1:NF,13);
figure(2);
plot(flow,delay_MILP,'-.o',flow,delay_Nominal,'-.^',...
    flow,delay_Greedy,'-.s',flow,delay_Random,'-.d',flow,delay_Tolerance,'-r');
title('delay time');
xlabel('number of flows');
ylabel('delay time(ms)');
legend({'MILP','NEC','Greedy','Randomized','Delay Tolerance'},'location','northwest');

filename='data.xlsx';
xlswrite(filename,result);

%MILP can always find the optimal solution
satisfied_MILP=1:1:15; 
%when it comes to 10 flows, there is an network servicing rate upgrade
satisfied_NEC=[1,1,1,2,3,4,5,5,6,7,7,7,8,8,8];
satisfied_Greedy=[1,1,2,3,4,5,6,6,7,9,10,10,11,12,12];
%for Randomized, this is a mean number of 1000 monte carlo simulations,
%so there are some fractional numbers
satisfied_Randomized=[1,2,3,4,5,6,7,8,9,9.999,10.907,10.876,11.258,12.018,12];

outage_NEC=(satisfied_MILP-satisfied_NEC)./satisfied_MILP;
outage_Greedy=(satisfied_MILP-satisfied_Greedy)./satisfied_MILP;
outage_Randomized=(satisfied_MILP-satisfied_Randomized)./satisfied_MILP;
outage=[outage_NEC;outage_Greedy;outage_Randomized]';
figure(3);
bar(outage,0.6);
title('Outage Probability');
xlabel('number of flows');
ylim([0,1]);
legend({'NEC','Greedy','Randomized'},'location','north');

satisfied_NEC=satisfied_NEC./satisfied_MILP;
satisfied_Greedy=satisfied_Greedy./satisfied_MILP;
satisfied_Randomized=satisfied_Randomized./satisfied_MILP;
satisfied_MILP=satisfied_MILP./satisfied_MILP;
satisfied=[satisfied_MILP;satisfied_NEC;satisfied_Greedy;satisfied_Randomized]';
figure(4);
bar(satisfied,0.6);
title('Satisfied Probability');
xlabel('number of flows');
ylim([0 1.6]);
legend({'MILP','NEC','Greedy','Randomized'},'location','north');