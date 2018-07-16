function [result] = MILP(flow,data,para)

NF=length(flow);
result=zeros(1,7);

%% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);
Qos_penalty=para.QoS_penalty(1:NF);

%% decision variable
x=optimvar('x',NF,length(data.edge_cloud),'Type','integer',...
    'LowerBound',0,'UpperBound',1);

y=optimvar('y',NF,size(data.graph.Edges,1),'Type','integer',...
    'LowerBound',0,'UpperBound',1);

z=optimvar('z',NF,size(data.graph.Edges,1),'LowerBound',0);

chi=optimvar('chi',length(data.edge_cloud),'LowerBound',0);

phi=optimvar('phi',NF,length(data.edge_cloud),'LowerBound',0);

pi=optimvar('pi',NF,length(data.access_router),length(data.edge_cloud),...
    'Type','integer','LowerBound',0,'UpperBound',1);

omega=optimvar('omega',NF,NF,size(data.graph.Edges,1),'LowerBound',0);

psi=optimvar('psi',NF,NF,size(data.graph.Edges,1),length(data.access_router),...
    length(data.edge_cloud),'Type','integer','LowerBound',0,'UpperBound',1);

%% constraints
%ec_cache_num_constr
ec_cache_num_constr=sum(x,2)<=data.N_k;

%ec_cache_space_constr
ec_cache_space_constr=data.W_k*x<=data.W_re_e;

%total_cache_space_constr
total_cache_space_constr=sum(data.W_k*x,2)<=data.W_re_t;

%sufficiently large number
M1=1;
M2=100000;

%pi_define_constr
x_pi=repmat(x,[length(data.access_router),1,1]);
x_pi=reshape(x_pi,NF,length(data.access_router),length(data.edge_cloud));
pi_define_constr1=pi<=x_pi;

probability_pi=repmat(probability_ka,[1,1,length(data.edge_cloud)]);
pi_define_constr2=pi<=M2*probability_pi;

pi_define_constr3=sum(pi,3)<=1;

%linear_denominator_constr
linear_denominator_constr=data.W_re_e.*chi'-data.W_k*phi==1;

%phi_define_constr
chi_phi=repmat(chi',[NF,1]);
phi_define_constr1=phi<=chi_phi;
phi_define_constr2=phi<=M1*x;
phi_define_constr3=phi>=M1*(x-1)+chi_phi;

BETA=GetPathLinkRel(data.graph,"undirected",data.path,length(data.access_router),...
    length(data.edge_cloud));
%y_define_constr
[m,n,l]=size(BETA);
BETA_y=reshape(BETA,1,m*n*l);
BETA_y=repmat(BETA_y,[NF,1]);
BETA_y=reshape(BETA_y,NF,m,n,l);

pi_y=repmat(pi,[size(BETA,1),1,1,1]);
pi_y=reshape(pi_y,NF,size(BETA,1),length(data.access_router),length(data.edge_cloud));

y_define_constr1=y<=sum(sum(BETA_y.*pi_y,4),3);
y_define_constr2=M2*y>=sum(sum(BETA_y.*pi_y,4),3);

%link_slack_constr
delta_link=GetWorstLinkDelay(data.C_l,data.R_k,data.path);
% delta_link=data.delta*2/3;
link_slack_constr=sum(z,2)<=delta_link;

%link_delay_constr
[m,n,l]=size(BETA);
BETA_psi=reshape(BETA,1,m*n*l);
BETA_psi=repmat(BETA_psi,[NF,1]);
BETA_psi=reshape(BETA_psi,NF,m,n,l);
[l,g,b,t]=size(BETA_psi);
BETA_psi=reshape(BETA_psi,1,l*g*b*t);
BETA_psi=repmat(BETA_psi,[NF,1]);
BETA_psi=reshape(BETA_psi,NF,l,g,b,t);
% test
% buffeerrr=cell(NF,NF);
% for ii=1:20
%     for jj=1:20
%         a=zeros(size(BETA));
%         a(:,:,:)=BETA_psi(ii,jj,:,:,:);
%         buffeerrr{ii,jj}=a;
%         check=(buffeerrr{ii,jj}==BETA);
%         all(check)
%     end
% end
R_psi=repmat(data.R_k,[l,1,g,b,t]);
z_psi_d=repmat(z,[1,1,b]);
R_psi_d=repmat(data.R_k,[l,1,g,b]);
omega_psi_d=repmat(omega,[1,1,1,b]);

link_delay_constr=squeeze(sum(sum(BETA_psi.*R_psi.*psi,5),1))...
    <=data.C_l*z_psi_d-squeeze(sum(R_psi_d.*omega_psi_d,1));

%psi_define_constr

%manual generator
%how to expand the optimvar like \pi_{k,d,e} to \pi_{k',k,l,d,e}? permute
%could not be used for optimvar in version 2018a. 
psi_define_constr1=optimconstr(l,l,g,b,t);
psi_define_constr2=optimconstr(l,l,g,b,t);
psi_define_constr3=optimconstr(l,l,g,b,t);
for ii=1:l
    for jj=1:l
        for kk=1:g
            for ll=1:b
                for mm=1:t
                    psi_define_constr1(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)<=pi(jj,ll,mm);
                    psi_define_constr2(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)<=y(ii,kk);
                    psi_define_constr3(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)>=pi(jj,ll,mm)+y(ii,kk)-1;
                end
            end
        end
    end
end

%omega_define_constr
[m,n]=size(z);
z_omega=reshape(z,1,m*n);
z_omega=repmat(z_omega,[NF,1]);
z_omega=reshape(z_omega,NF,m,n);

y_omega=reshape(y,1,m*n);
y_omega=repmat(y_omega,[NF,1]);
y_omega=reshape(y_omega,m,NF,n);
%%%%%%%%%%%%%CONSTRUCT SITE%%%%%%%%%%%%%

%link_delay_constr
R_komega=repmat(data.R_k,[size(data.graph.Edges,1),1,...
    length(data.access_router),length(data.edge_cloud)]);

[m,n,l]=size(pi);
pi_omega=reshape(pi,1,m*n*l);
pi_omega=repmat(pi_omega,[size(data.graph.Edges,1),1]);
pi_omega=reshape(pi_omega,size(data.graph.Edges,1),m,n,l);

beta=GetPathLinkRel(data.graph,"undirected",data.path,length(data.access_router),...
    length(data.edge_cloud));
[m,n,l]=size(beta);
beta_omega=reshape(beta,1,m*n*l);
beta_omega=repmat(beta_omega,[NF,1]);
beta_omega=reshape(beta_omega,NF,m,n,l);
beta_omega=permute(beta_omega,[2,1,3,4]);

C_lomega=data.C_l;
C_lomega=repmat(C_lomega,[m,NF,n,l]);

red_buff=sum(sum(sum(R_komega.*omega.*beta_omega,2),3),4);
red_buff=repmat(red_buff,[1,NF,n,l]);

link_delay_constr=C_lomega.*beta_omega.*omega-red_buff>=beta_omega.*pi_omega;



%omega_define_constr
z_omega=repmat(z,[1,NF,length(data.access_router),length(data.edge_cloud)]);
omega_define_constr1=omega<=z_omega;
omega_define_constr2=omega<=M2*pi_omega;
omega_define_constr3=omega>=M2*(pi_omega-1)+z_omega;

%edge_delay_constr
% in practice, use min() to replace the delta_edge not effect the result
% delta_edge=min(data.delta*1/3);
delta_edge=min(data.delta-delta_link);
lammax=GetMaxLambda(data.mu,data.ce,delta_edge);
edge_delay_constr=sum(x,1)<=lammax;

%% create optimization problem and objective function

ProCache=optimproblem;

objfun1=sum(alpha*data.W_e*y,2);

probability_pi=repmat(data.probability,[1,1,length(data.edge_cloud)]);
w_pi=cell2mat(data.cost);
[m,n]=size(w_pi);
w_pi=reshape(w_pi,1,m*n);
w_pi=repmat(w_pi,[NF,1]);
w_pi=reshape(w_pi,NF,m,n);

objfun2=sum(sum(probability_pi.*w_pi.*pi,3),2);

objfun3=(1-sum(sum(probability_pi.*pi,3),2)).*punish';

ProCache.Objective=sum(objfun1+objfun2+objfun3);

ProCache.Constraints.ec_cache_num_constr1=ec_cache_num_constr;
ProCache.Constraints.ec_cache_space_constr=ec_cache_space_constr;
ProCache.Constraints.total_cache_space_constr=total_cache_space_constr;
ProCache.Constraints.linear_denominator_constr=linear_denominator_constr;
ProCache.Constraints.y_define_constr1=y_define_constr1;
ProCache.Constraints.y_define_constr2=y_define_constr2;
ProCache.Constraints.y_define_constr3=y_define_constr3;
ProCache.Constraints.pi_define_constr1=pi_define_constr1;
ProCache.Constraints.pi_define_constr2=pi_define_constr2;
% ProCache.Constraints.link_delay_constr=link_delay_constr;
ProCache.Constraints.link_slack_constr=link_slack_constr;
ProCache.Constraints.omega_define_constr1=omega_define_constr1;
ProCache.Constraints.omega_define_constr2=omega_define_constr2;
ProCache.Constraints.omega_define_constr3=omega_define_constr3;
ProCache.Constraints.edge_delay_constr=edge_delay_constr;

%% solve the problem using MILP

opts=optimoptions('intlinprog','Display','off','MaxTime',36000);

% timer for MILP
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

%% return of MILP

[s1,t1]=find(round(sol.x));

[~,II]=sort(s1);
t1=t1(II);

[~,I]=sort(data.probability,2,'descend');
ar_list=I(:,1);

solution.allocation=t1;
solution.ar_list=ar_list;

total_cost=CostCalculator(solution,data,alpha,punish);

delay_time = TimeCalculator(solution,data);

failed_number=0;
total_cost_add=total_cost;
for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        total_cost_add=total_cost_add+(1/penalty)*punish(ii)*(delay_time(ii)-data.delta(ii));
        failed_number=failed_number+1;
    end
end

midterm=zeros(1,NF);
for ii=1:NF
    if 100 > data.delta(ii)
        midterm(ii)=(1/penalty)*punish(ii)*(100-data.delta(ii))+punish(ii);
    else
        midterm(ii)=punish(ii);
    end
end

result(1,1)=sum(midterm);
result(1,2)=total_cost_add;
result(1,3)=total_cost_add-total_cost;
result(1,4)=failed_number;
result(1,5)=MILP_time;

%% Monte Carlo test

buff=MonteCarlo(flow,solution,data,punish,alpha,penalty);
result(1,6:7)=buff;

end

