clear
clc

rng(1);
tic;
%%%%%%%%%%%%%%%%%%%%%%% generate network topology %%%%%%%%%%%%%%%%%%%%%%%%%
% the set of flows in the network
flowname={'flow1','flow2'}; %$$%
N=length(flowname);
for v=1:N
    eval([flowname{v},'=',num2str(v),';']);
end
flow=[flow1,flow2];
NF=length(flow);

% the graph
[G_full,vertice_names,edge_cloud,p]=GenerateGraph();
N=length(vertice_names);
for v=1:N
    eval([vertice_names{v},'=',num2str(v),';']);
end
server=[data_server];
relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
    relay10,relay11,relay12,relay13,relay14,relay15];
base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];
access_router=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
router=[router1,router2,router3,router4,router5,router6,router7,router8];

%%%%%%%%%%%%%%%%%%%%% generated structure of graph%%%%%%%%%%%%%%%%%%%%%%%%%
link=G_full.Edges;

sources=AR4;
targets=[AR2,AR3,AR4,AR5,AR6];

%calculate the shortest path and path cost
path=cell(length(access_router), length(edge_cloud));
w=path;
for ii=1:length(access_router)
    for jj=1:length(edge_cloud)
        [path{ii,jj},w{ii,jj}]=shortestpath(G_full,access_router(ii),edge_cloud(jj));
    end
end

counter_path=numel(path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caching cost impact factor
alpha=1;

% the maximum number of edge cloud used to cache
N_k=1;

% size of cache items
% 0~5000 Mbit
W_k=1000*randi(5,size(flow));

% original utilization
utilization=rand(size(edge_cloud))*0.8;

% remaining cache space for each edge cloud
W_e=10000;
Zeta_e=ones(size(edge_cloud))*W_e;
Zeta_e=Zeta_e.*(1-utilization);

% remaining cache space in total
Zeta_t=50000;

% link capacity
C_l=1000;

% the rate of each flow
R_k=randi([1,floor(10/NF)],size(flow))*100;

% arriving rate
% unit: Mbps
lambda=poissrnd(200,NF,length(edge_cloud));

% number of servers
ce=zeros(size(edge_cloud));
for ii=1:length(ce)
    if rand()>0.5
        ce(ii)=2;
    else
        ce(ii)=3;
    end
end

% each server service rate
% assuming service rates for different flows are same
% unit: Mbps
mu=poissrnd(120,1,length(edge_cloud));

% delay tolerance
% unit: Ms
delta=100;

% propagation delay
% unit: Ms
Tpr=10;

% mobile user movement
probability_ka=zeros(size(access_router));
probability_ka(targets(end))=1;
for ii=1:numel(targets)-1
    probability_ka(targets(ii))=rand()/(length(targets)-1);
    probability_ka(targets(end))=probability_ka(targets(end))...
        -probability_ka(targets(ii));
end

%%%%%%%%%%%%%%%%%%%%%%%% decision variable %%%%%%%%%%%%%%%%%%%%%%%%%%
x=optimvar('x',NF,length(edge_cloud),'Type','integer',...
    'LowerBound',0,'UpperBound',1);

eta=optimvar('eta',length(access_router),length(edge_cloud),'Type',...
    'integer','LowerBound',0,'UpperBound',1);

pi=optimvar('pi',NF,length(access_router),length(edge_cloud),...
    'Type','integer','LowerBound',0,'UpperBound',1);

t=optimvar('t',length(edge_cloud),'LowerBound',0);

y=optimvar('y',NF,length(edge_cloud),'LowerBound',0);

z=optimvar('z',size(link,1),'LowerBound',0);

omega=optimvar('omega',size(link,1),NF,length(access_router),...
    length(edge_cloud),'LowerBound',0);

%%%%%%%%%%%%%%%%%%%%%%%% constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ec_cache_num_constr
ec_cache_num_constr1=sum(x,2)>=1;
ec_cache_num_constr2=sum(x,2)<=N_k;

%ec_cache_space_constr
ec_cache_space_constr=W_k*x<=Zeta_e;

%total_cache_space_constr
total_cache_space_constr=sum(W_k*x,2)<=Zeta_t;

%connect_ec_ar_constr
connect_ec_ar_constr1=sum(eta,2)>=1;
connect_ec_ar_constr2=sum(eta,2)<=N_k;

%linear_denominator_constr
linear_denominator_constr=Zeta_e.*t'-W_k*y==1;

%sufficiently large number
M=1000000;

%y_define_constr
t_y=repmat(t',[2,1]);
y_define_constr1=y<=t_y;
y_define_constr2=y<=M*x;
y_define_constr3=y>=M*(x-1)+t_y;

%pi_define_constr
x_pi=repmat(x,[length(access_router),1,1]);
x_pi=reshape(x_pi,NF,length(access_router),length(edge_cloud));
pi_define_constr1=pi<=x_pi;

[m,n]=size(eta);
eta_pi=reshape(eta,1,m*n);
eta_pi=repmat(eta_pi,[NF,1]);
eta_pi=reshape(eta_pi,NF,length(access_router),length(edge_cloud));
pi_define_constr2=pi<=eta_pi;

pi_define_constr3=pi>=x_pi+eta_pi-1;

%path_constr
path_constr=sum(sum(pi,3),2)==1;

%link_delay_constr
R_komega=repmat(R_k,[size(link,1),1,length(access_router),length(edge_cloud)]);

[m,n,l]=size(pi);
pi_omega=reshape(pi,1,m*n*l);
pi_omega=repmat(pi_omega,[size(link,1),1]);
pi_omega=reshape(pi_omega,size(link,1),m,n,l);

beta=GetPathLinkRel(G_full,"undirected",path,length(access_router),...
    length(edge_cloud));
[m,n,l]=size(beta);
beta_omega=reshape(beta,1,m*n*l);
beta_omega=repmat(beta_omega,[NF,1]);
beta_omega=reshape(beta_omega,NF,m,n,l);
beta_omega=permute(beta_omega,[2,1,3,4]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%link_delay_constr
Rk_omega=repmat(Rk,[size(link{flow1},1),1,counter_path]);
Rk_y=repmat(Rk',[1,counter_path]);
beta=GetPathLinkRel(G{1},"undirected",path,counter_path);

omega_link=squeeze(sum(Rk_omega.*omega,2));
omega_link=omega_link*beta';
omega_link_vec=optimexpr(length(omega_link));
for ii=1:length(omega_link_vec)
    omega_link_vec(ii)=omega_link(ii,ii);
end

link_delay_constr=(sum(Rk_y.*y,1)*beta')'+...
    omega_link_vec-Cl*z<=0;

%link_slack_constr
delta_link=GetWorstLinkDelay(Cl,Rk,path);
link_slack_constr=sum(z)<=delta_link;

%omega_define_constr
z_omega=repmat(z,[1,NF,counter_path]);
omega_define_constr1=omega<=z_omega;

[m,n]=size(y);
y_omega=reshape(y,1,m*n);
y_omega=repmat(y_omega,[size(link{flow1},1),1]);
y_omega=reshape(y_omega,size(link{flow1},1),NF,counter_path);
M=1000000; %sufficiently large number
omega_define_constr2=omega<=M*y_omega;

omega_define_constr3=omega>=M*(y_omega-1)+z_omega;

%edge_delay_constr
delta_edge=delta-Tpr-delta_link;
lammax=GetMaxLambda(mu,ce,delta_edge);
edge_delay_constr=sum(lambda.*x,1)<=lammax;

%%%%%%%%%%%%%% create problem and objective function %%%%%%%%%%%%%
ProCache=optimproblem;
%use E instead of S here
%S=intersect(targets,edgecloud);

objfun1=alpha./(1-utilization)*x';

% probability_x=probability_ec(edge_cloud(1):edge_cloud(end));
% probability_x=repmat(probability_x,[NF,1]);
% probability_x = [];
% for ii = 1:NF
%    probability_x=[probability_x;...
%        GetFlowProbability( base_station, targets, edge_cloud, G)];
% end
probability_x=GetFlowProbability(base_station,targets,access_router,G);
probability_x=repmat(probability_x,NF);
probability_Pi=repmat(probability_x,[1,1,counter_path]);

% w_Pi=zeros(length(flow),counter_path);
% for ii=1:numel(flow)
w_Pi=zeros(HARDCORDED_N,counter_path);
% for ii=1:HARDCORDED_N
%         counter=1;
%         for jj=1:numel(w{ii})
%                 if isempty(w{ii}{jj})
%                         w_Pi(ii,counter)=0;
%                         counter=counter+1;
%                         continue;
%                 end
%                 for kk=1:numel(w{ii}{jj})
%                         w_Pi(ii,counter)=w{ii}{jj}{kk};
%                         counter=counter+1;
%                 end
%         end
% end
w_Pi=cell2mat(w(:));
w_Pi=repmat(w_Pi,[1,1,length(edge_cloud)]);
w_Pi=permute(w_Pi,[1,3,2]);

objfun2=sum(sum(probability_Pi.*w_Pi.*Pi,3),2)';

% w_max=[];
% for ii=1:length(flow)
%     w_max=[w_max,shortestpath(G_full{1},sources,data_server)];
% end
w_max=1200;

objfun3=(1-sum(probability_x.*x,2))'.*w_max;


ProCache.Objective=sum(objfun1+objfun2+objfun3);

ProCache.Constraints.ec_cache_num_constr=ec_cache_num_constr;
ProCache.Constraints.ec_cache_space_constr=ec_cache_space_constr;
ProCache.Constraints.total_cache_space_constr=total_cache_space_constr;
ProCache.Constraints.path_constr=path_constr;
ProCache.Constraints.ec_cross_path_constr=ec_cross_path_constr;
ProCache.Constraints.Pi_define_constr1=Pi_define_constr1;
ProCache.Constraints.Pi_define_constr2=Pi_define_constr2;
ProCache.Constraints.Pi_define_constr3=Pi_define_constr3;
ProCache.Constraints.link_delay_constr=link_delay_constr;
ProCache.Constraints.link_slack_constr=link_slack_constr;
ProCache.Constraints.omega_define_constr1=omega_define_constr1;
ProCache.Constraints.omega_define_constr2=omega_define_constr2;
ProCache.Constraints.omega_define_constr3=omega_define_constr3;
ProCache.Constraints.edge_delay_constr=edge_delay_constr;

%%%%%%%%%%%%%%%%%%% solve the problem %%%%%%%%%%%%%%%%%%%%
% opts=optimoptions('intlinprog','Display','off','PlotFcn',@optimplotmilp);
opts=optimoptions('intlinprog','Display','off');
[sol,fval,exitflag,output]=solve(ProCache,opts);

if isempty(sol)
    disp('The solver did not return a solution.')
    return
end

%caculate the number of constrains
buff=struct2cell(ProCache.Constraints);
counter_constraints=0;
for ii=1:numel(buff)
    counter_constraints=counter_constraints+numel(buff{ii});
end
fprintf('The total number of constraints are %d.\n', counter_constraints);

%examine the sol
bool_buff=zeros(numel(buff),1);
for ii=1:numel(buff)
    if max(infeasibility(buff{ii},sol))<=output.constrviolation
        bool_buff(ii)=1;
    end
end
if (exitflag=="OptimalSolution")&&(all(bool_buff==1))
    disp('the solution is feasible')
else
    disp('the solution is not feasible')
end

%draw the result of MILP
[s1,t1]=find(round(sol.x));
[s2,t2]=find(round(sol.y));

path_array=cell(counter_path,1);
index=1;
for ii=1:numel(path)
    if isempty(path{ii})
        index=index+1;
        continue;
    end
    for jj=1:numel(path{ii})
        path_array{index}=path{ii}{jj};
        index=index+1;
    end
end

hold on
for ii=1:NF
    highlight(p,edge_cloud(t1(ii)),'nodecolor','c');
    highlight(p,path_array{t2(ii)},'edgecolor','m');
end
hold off

all_time=toc;
display(all_time);


%%%%%%%%%%%%%%%%%%% greedy algorithm %%%%%%%%%%%%%%%%%%%%
[greedy_cache_node, greedy_total_cost]=Greedy(probability_x,utilization,...
    Wsize, Rspace, Fullspace, Rtotal, G{1}, alpha, sources, w_max);
for ii=1:length(greedy_cache_node)
   fprintf("for flow %d , cache in edgecloud %d \n", ii, greedy_cache_node(ii)); 
end
fprintf("total cost is %f\n",greedy_total_cost);
    
