function result=mainFunction(flow,NF_TOTAL)
%%
rng(1);
result=zeros(1,18);

%% generate network topology
NF=length(flow);

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

%% generate structure of graph
link=G_full.Edges;

% sources=AR4;
targets=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];

%calculate the shortest path and path cost
path=cell(length(access_router), length(edge_cloud));
w=path;
for ii=1:length(access_router)
    for jj=1:length(edge_cloud)
        [path{ii,jj},w{ii,jj}]=shortestpath(G_full,access_router(ii),edge_cloud(jj));
    end
end

counter_path=numel(path);

%% generate parameters
% caching cost impact factor
alpha=10;

% the maximum number of edge cloud used to cache
N_k=1;

% size of cache items
% 0~5000 Mbit
W_k=GenerateItemsSize(NF_TOTAL)';
W_k=W_k(1:NF);

% original utilization
utilization=GenerateUtilization(edge_cloud);

% remaining cache space for each edge cloud
% W_e=5000+2000*floor(NF/10);
W_e=6000;
Zeta_e=ones(size(edge_cloud))*W_e;
Zeta_e=Zeta_e.*(1-utilization);

% remaining cache space in total
Zeta_t=W_e*10;

% Delay paremeter
flow_stable=1:1:NF_TOTAL;
[R_k,lambda,ce,mu]=GenerateDelayParameter(flow_stable,edge_cloud,NF);
R_k=R_k(1:NF);
lambda=lambda(1:NF,:);


% link capacity
C_l=sum(R_k)+100;

% delay tolerance
% unit: Ms
delta=15+5*NF;

% propagation delay
% unit: Ms
Tpr=10;

% mobile user movement
probability_ka=zeros(NF,length(targets));
for ii=1:NF
    probability_ka(ii,:)=GetFlowProbability(ii,access_router,targets);
end
%  probability_ka(1,:)=GetFlowProbability(ii,access_router,targets);
%  probability_ka=repmat(probability_ka(1,:),NF,1);

% define eta is the connect matrix which combine the access router and its 
% 2-hop neighbor edge clouds
eta_2hop=zeros(length(access_router),length(edge_cloud));
for ii=1:length(access_router)
    ec_index=find(edge_cloud==access_router(ii));
    if ec_index > 0
        eta_2hop(ii,ec_index)=1;
    end
    neighbor_1hop=neighbors(G_full,access_router(ii));
    for jj=1:length(neighbor_1hop)
        ec_index=find(edge_cloud==neighbor_1hop(jj));
        if ec_index > 0
            eta_2hop(ii,ec_index)=1;
        end
        neighbor_2hop=neighbors(G_full,neighbor_1hop(jj));
        for kk=1:length(neighbor_2hop)
            ec_index=find(edge_cloud==neighbor_2hop(kk));
            if ec_index > 0
                eta_2hop(ii,ec_index)=1;
            end
        end
    end
end
% eta=eta_2hop;

%% decision variable
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

%% constraints
%ec_cache_num_constr
ec_cache_num_constr1=sum(x,2)>=1;
ec_cache_num_constr2=sum(x,2)<=N_k;

%ec_cache_space_constr
ec_cache_space_constr=W_k*x<=Zeta_e;

%total_cache_space_constr
total_cache_space_constr=sum(W_k*x,2)<=Zeta_t;

%connect_ec_ar_constr
connect_ec_ar_constr1=sum(eta,2)>=1;
connect_ec_ar_constr2=eta<=eta_2hop;

%linear_denominator_constr
linear_denominator_constr=Zeta_e.*t'-W_k*y==1;

%sufficiently large number
M1=1;
M2=100000;

%y_define_constr
t_y=repmat(t',[NF,1]);
y_define_constr1=y<=t_y;
y_define_constr2=y<=M1*x;
y_define_constr3=y>=M1*(x-1)+t_y;

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
% pi_define_constr=pi<=x_pi.*eta_pi;

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

link_delay_constr=sum(sum(sum(R_komega.*pi_omega.*beta_omega,4),3),2)+...
    sum(sum(sum(R_komega.*omega.*beta_omega,2),3),4)-C_l*z<=0;

%link_slack_constr
delta_link=GetWorstLinkDelay(C_l,R_k,path);
link_slack_constr=sum(z)<=delta_link;
% link_slack_constr=sum(z)==delta_link;

%omega_define_constr
z_omega=repmat(z,[1,NF,length(access_router),length(edge_cloud)]);
omega_define_constr1=omega<=z_omega;
omega_define_constr2=omega<=M2*pi_omega;
omega_define_constr3=omega>=M2*(pi_omega-1)+z_omega;

%edge_delay_constr
% delta_edge=(delta-Tpr-delta_link)/length(edge_cloud);
delta_edge=delta-Tpr-delta_link;

if delta_edge <= 0
    return
end

lammax=GetMaxLambda(mu,ce,delta_edge);
edge_delay_constr=sum(lambda.*x,1)<=lammax;

%% create optimization problem and objective function

ProCache=optimproblem;

objfun1=sum(alpha*W_e*y,2);

probability_pi=repmat(probability_ka,[1,1,length(edge_cloud)]);
w_pi=cell2mat(w);
[m,n]=size(w_pi);
w_pi=reshape(w_pi,1,m*n);
w_pi=repmat(w_pi,[NF,1]);
w_pi=reshape(w_pi,NF,m,n);

objfun2=sum(sum(probability_pi.*w_pi.*pi,3),2);

punish=1000;
penalty=0.2;

objfun3=(1-sum(sum(probability_pi.*pi,3),2))*punish;

ProCache.Objective=sum(objfun1+objfun2+objfun3);

ProCache.Constraints.ec_cache_num_constr1=ec_cache_num_constr1;
ProCache.Constraints.ec_cache_num_constr2=ec_cache_num_constr2;
ProCache.Constraints.ec_cache_space_constr=ec_cache_space_constr;
ProCache.Constraints.total_cache_space_constr=total_cache_space_constr;
ProCache.Constraints.connect_ec_ar_constr1=connect_ec_ar_constr1;
% ProCache.Constraints.connect_ec_ar_constr2=connect_ec_ar_constr2;
ProCache.Constraints.linear_denominator_constr=linear_denominator_constr;
ProCache.Constraints.y_define_constr1=y_define_constr1;
ProCache.Constraints.y_define_constr2=y_define_constr2;
ProCache.Constraints.y_define_constr3=y_define_constr3;
ProCache.Constraints.pi_define_constr1=pi_define_constr1;
ProCache.Constraints.pi_define_constr2=pi_define_constr2;
ProCache.Constraints.pi_define_constr3=pi_define_constr3;
% ProCache.Constraints.pi_define_constr=pi_define_constr;
ProCache.Constraints.path_constr=path_constr;
ProCache.Constraints.link_delay_constr=link_delay_constr;
ProCache.Constraints.link_slack_constr=link_slack_constr;
ProCache.Constraints.omega_define_constr1=omega_define_constr1;
ProCache.Constraints.omega_define_constr2=omega_define_constr2;
ProCache.Constraints.omega_define_constr3=omega_define_constr3;
ProCache.Constraints.edge_delay_constr=edge_delay_constr;

%% solve the problem using MILP
% opts=optimoptions('intlinprog','Display','off','PlotFcn',@optimplotmilp);
opts=optimoptions('intlinprog','Display','off');
tic;
[sol,fval,exitflag,output]=solve(ProCache,'Options',opts);
MILP_time=toc;

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
% [s2,t2]=find(round(sol.eta));

hold on
for ii=1:NF
    highlight(p,edge_cloud(t1(ii)),'nodecolor','c');
    %     highlight(p,path(),'edgecolor','m');
end
hold off

%% result of MILP algorithm
fprintf("\n %%%%MILP%%%%\n");

[BB,II]=sort(s1);
t1=t1(II);

% for ii=1:NF
%     fprintf("for flow %d , cache in edgecloud %d \n", ii, edge_cloud(t1(ii)));
% end
[B,I]=sort(probability_ka,2,'descend');
ar_list=I(:,1);

total_cost=CostCalculator(t1,ar_list,W_k,probability_ka,...
    Zeta_e,W_e,Zeta_t,utilization,G_full,alpha,punish,edge_cloud,server);

delay_time = TimeCalculator(t1,path,R_k,C_l,lambda,mu,ce,Tpr,edge_cloud,server);
fprintf("delay time is %f\n",delay_time);
result(1,9)=delay_time;

if delay_time > delta
    total_cost_add=total_cost+penalty*punish*(delay_time-delta);
    fprintf("original cost is %f, penalty is %f",total_cost,...
        total_cost_add-total_cost);
else
    total_cost_add=total_cost;
end

fprintf("total cost is %f\n ",total_cost_add);
result(1,3)=total_cost_add;

display(MILP_time);
result(1,15)=MILP_time;

%% nominal algorithm
fprintf("\n %%%%nominal algorithm%%%%\n");
tic;
[nominal_cache_node, ~, nominal_total_cost]=Nominal(flow,edge_cloud,access_router,...
    W_k,probability_ka,Zeta_e,W_e,Zeta_t,utilization,G_full,alpha,punish,server);
Nominal_time=toc;
for ii=1:length(nominal_cache_node)
    if nominal_cache_node(ii)==server
        fprintf("for flow %d , cache in data server \n", ii);
        continue
    end
    fprintf("for flow %d , cache in edgecloud %d \n", ii, edge_cloud(nominal_cache_node(ii)));
end

delay_time = TimeCalculator(nominal_cache_node,path,R_k,C_l,lambda,mu,ce,Tpr,edge_cloud,server);
fprintf("delay time is %f\n",delay_time);
result(1,10)=delay_time;

if delay_time > delta
    nominal_total_cost_add=nominal_total_cost+penalty*punish*(delay_time-delta);
    fprintf("original cost is %f, penalty is %f",nominal_total_cost,...
        nominal_total_cost_add-nominal_total_cost);
else
    nominal_total_cost_add=nominal_total_cost;
end

fprintf("total cost is %f\n",nominal_total_cost_add);
result(1,4)=nominal_total_cost_add;

display(Nominal_time);
result(1,16)=Nominal_time;

%% greedy algorithm
fprintf("\n %%%%greedy algorithm%%%%\n");
tic;
[greedy_cache_node, ~, greedy_total_cost]=Greedy(flow,edge_cloud,access_router,...
    W_k,probability_ka,Zeta_e,W_e,Zeta_t,utilization,G_full,alpha,punish);
Greedy_time=toc;
for ii=1:length(greedy_cache_node)
    fprintf("for flow %d , cache in edgecloud %d \n", ii, edge_cloud(greedy_cache_node(ii)));
end

delay_time = TimeCalculator(greedy_cache_node,path,R_k,C_l,lambda,mu,ce,Tpr,edge_cloud,server);
fprintf("delay time is %f\n",delay_time);
result(1,11)=delay_time;

if delay_time > delta
    greedy_total_cost_add=greedy_total_cost+penalty*punish*(delay_time-delta);
    fprintf("original cost is %f, penalty is %f",greedy_total_cost,...
        greedy_total_cost_add-greedy_total_cost);
else
    greedy_total_cost_add=greedy_total_cost;
end

fprintf("total cost is %f\n",greedy_total_cost_add);
result(1,5)=greedy_total_cost_add;

display(Greedy_time);
result(1,17)=Greedy_time;

%% randomized greedy algorithm
fprintf("\n %%%%randomized greedy algorithm%%%%\n");
tic;

% try to use Monte Carlo
Times=1000;
randomized_total_cost_add=zeros(Times,1);
delay_time=zeros(Times,1);
correct_flag=zeros(Times,1);

parfor ii=1:Times
    [randomized_cache_node, ~, randomized_total_cost]=...
        RandomizedGreedy(flow,edge_cloud,access_router,...
        W_k,probability_ka,Zeta_e,W_e,Zeta_t,utilization,G_full,alpha,punish,...
        lambda,mu,ce,Tpr,delta,path,R_k,C_l,server);
    delay_time(ii) = TimeCalculator(randomized_cache_node,path,R_k,C_l,lambda,mu,ce,Tpr,edge_cloud,server);
    if delay_time(ii) > delta
        randomized_total_cost_add(ii)=randomized_total_cost+penalty*punish*(delay_time(ii)-delta);
        correct_flag(ii)=1;
    else
        randomized_total_cost_add(ii)=randomized_total_cost;
    end
end

randomized_time=toc;
% for ii=1:length(randomized_cache_node)
%     fprintf("for flow %d , cache in edgecloud %d \n", ii, edge_cloud(randomized_cache_node(ii)));
% end

fprintf("outage probability is %f\n",sum(correct_flag)/Times);

fprintf("delay time is %f\n",mean(delay_time));
result(1,12)=mean(delay_time);

fprintf("total cost is %f\n",mean(randomized_total_cost_add));
result(1,6)=mean(randomized_total_cost_add);

display(randomized_time/Times);
result(1,18)=randomized_time/Times;

fprintf("\ndelay tolerance is %f\n",delta);
result(1,13)=delta;

result(1,7)=punish*NF+penalty*punish*(10*NF+Tpr+delta_link-delta);

end