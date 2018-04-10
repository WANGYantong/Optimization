clear
clc

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
result=zeros(NF_TOTAL,18);

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
data.W_e=6000;
data.Zeta_e=ones(size(edge_cloud))*data.W_e;
data.Zeta_e=data.Zeta_e.*(1-data.utilization);

% remaining cache space in total
data.Zeta_t=data.W_e*10;

% Delay paremeter
flow_stable=1:1:NF_TOTAL;
[R_k,ce,mu]=GenerateDelayParameter(flow_stable,edge_cloud,NF);
data.R_k=R_k(1:NF);
data.ce=ce;
data.mu=mu;

% link capacity
data.C_l=1600;

% delay tolerance: 20,50,100,200
% unit: Ms
delta=[20,50,100,200];
data.delta=randi(4,1,NF);
data.delta=delta(data.delta);

% mobile user movement
probability_ka=zeros(NF,length(data.targets));
for ii=1:NF
    probability_ka(ii,:)=GetFlowProbability(ii,data.access_router,data.targets);
end
data.probability=probability_ka;

%% optimal solution
% for ii=1:NF
%    MILP(flow_parallel{ii},data,alpha); 
% end


%% heuristic solution



%% monte carlo simulation