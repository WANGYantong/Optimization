clear
clc

rng(2);
%%%%%%%%%%%%%%%%%%%%%%% generate network topology %%%%%%%%%%%%%%%%%%%%%%%%%
% the set of flows in the netwrok
flowname={'flow1','flow2','flow3'}; %$$%
N=length(flowname);
for v=1:N
    eval([flowname{v},'=',num2str(v),';']);
end
flow=[flow1, flow2, flow3];

% the nodes and edge clouds in the network 
names={'ec1','ec2','ec3','ec4','ec5',...
    'n1','n2'}; %$$%
N=length(names);
for v=1:N
    eval([names{v},'=',num2str(v),';']);
end
node=[n1,n2]; %$$%
edgecloud=[ec1,ec2,ec3,ec4,ec5]; %$$%

% generate the undirected graph
s=[ec1,ec1,n1, n1, n1, ec2,ec2,ec5]; %$$%
t=[n1, ec2,ec3,ec4,ec5,ec5,n2, n2 ]; %$$%
for ii=1:length(flow)
    weights{ii}=10*randi([1,10],size(s));
    G{ii}=graph(s,t,weights{ii},names);
end
original_ec=ec5;

% plot each flow graph
h=figure;
cxd=['b','k','r','g','c','m','y'];
for ii=1:length(flow)
    subplot(length(flow),1,ii);
    LWidths{ii}=3*G{ii}.Edges.Weight/max(G{ii}.Edges.Weight);
    p(ii)=plot(G{ii},'EdgeLabel',G{ii}.Edges.Weight,'NodeLabel',...
        G{ii}.Nodes.Name,'LineWidth',LWidths{ii});
    p(ii).Marker='o';
    p(ii).MarkerSize=8;
    p(ii).EdgeColor=cxd(1); 
    p(ii).LineStyle='--';
    highlight(p(ii),edgecloud,'nodecolor','r');
    highlight(p(ii),original_ec,'nodecolor','g'); %the original edge cloud
    p(ii).XData=[3,4,1,2,3,2,5]; 
    p(ii).YData=[3,2,1,1,1,2,1]; 
    title(['Flow',num2str(ii)]);
end
suptitle('Network Topology');

%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
% the set of links
% link{1}{1,'EndNodes'}{1}
for v=1:length(flow)
    link{v}=G{v}.Edges;
end

% the set of paths
% the paths for flow1 and flow2 are same 
% path{1,1}{1}(1)
%sources=[ec1,ec2,ec3,ec4,ec5];
sources=original_ec;
targets=[ec3,ec4,ec5,n2];
path=cell(length(sources),length(targets));
for ii=1:length(sources)
    for jj=1:length(targets)
        path{ii,jj}=GetPathBetweenNode(G{1},'undirected',sources(ii),...
            targets(jj));
    end
end

% path cost OR routing cost
w=cell(1,length(flow));
for ii=1:length(flow)
   w{ii}=GetRoutingCost(G{ii}, 'undirected', path);
end

% matrix for recording path reached edge cloud
% get the number of path
counter_path=0;
for ii=1:numel(path)
    if isempty(path{ii})
        counter_path=counter_path+1;
        continue;
    end
	counter_path=counter_path+numel(path{ii});
end

Gpe=zeros(counter_path, numel(edgecloud));
index=1;
for ii=1:numel(path)
    if isempty(path{ii})
        if find(edgecloud==sources)
            Gpe(index,sources)=1;
            index=index+1;
        end
        continue;
    end
    for jj=1:numel(path{ii})
%         src=find(edgecloud==path{ii}{jj}(1));
        snk=find(edgecloud==path{ii}{jj}(end));
%         if ~isempty(src) && ~isempty(snk)
        if ~isempty(snk)
%             Gpe(index,src)=1;
            Gpe(index,snk)=1;
            index=index+1;
        end
    end
end

% caching cost impact factor
alpha=randi(100);

% utilization for each edge cloud
% utilization(ec1)
utilization=rand(size(edgecloud));
utilization=utilization*0.8;  % CHEAT!!!!!
% utilization=utilization*0;

% mobile moving probability
probability=zeros(size(names));
probability(targets(end))=1;
for ii=1:length(targets)-1
    probability(targets(ii))=rand()/(length(targets)-1);
    probability(targets(end))=probability(targets(end))...
        -probability(targets(ii));
end

% the maximum number of edge cloud used to cache
Nk=ones(size(flow));

% size of cache items
% 0~5000 Mbit
Wsize=1000*randi(5,size(flow));

% remaining cache space for each edge cloud
Rspace=ones(size(edgecloud))*10000;
Rspace=Rspace.*(1-utilization);

% remaining cache space in total
Rtotal=50000;

% link capacity
Cl=1000;

% the rate of each flow
% THINK OUT THE RELATIONSHIP WITH LAMBDA!
Rk=randi([1,floor(10/length(flow))],size(flow))*100;

% arriving rate
% unit: Mbps
lambda=poissrnd(200,length(flow),length(edgecloud));

% number of servers
ce=zeros(size(edgecloud));
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
mu=poissrnd(120,1,length(edgecloud));

% delay tolerance
% unit: Ms
delta=50;

% propagation delay
% unit: Ms
Tpr=10;

%%%%%%%%%%%%%%%%%%%%%%%% decision variable %%%%%%%%%%%%%%%%%%%%%%%%%%
x=optimvar('x',length(flow),length(edgecloud),'Type','integer',...
    'LowerBound',0,'UpperBound',1);

y=optimvar('y',length(flow),counter_path,'Type','integer',...
    'LowerBound',0,'UpperBound',1);

Pi=optimvar('Pi',length(flow),length(edgecloud),counter_path,...
    'Type','integer','LowerBound',0,'UpperBound',1);

omega=optimvar('omega',size(link{flow1},1),length(flow),counter_path,...
    'LowerBound',0);

z=optimvar('z',size(link{flow1},1),'LowerBound',0);

%%%%%%%%%%%%%%%%%%%%%%%% constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the format of w
% A=cellfun(@cell2mat, w{flow1},'UniformOutPut', false);
% cell2mat(A(1,:));
% OR
% w{flow1}{find(sources==ec5),find(targets==ec4)};

%ec_cache_num_constr
% ec_cache_num_constr=sum(x,2)<=Nk';
ec_cache_num_constr=sum(x,2)==Nk';

%ec_cache_space_constr
ec_cache_space_constr=Wsize*x<=Rspace;

%total_cache_space_constr
total_cache_space_constr=sum(Wsize*x,2)<=Rtotal;

%path_constr
path_constr=sum(y,2)==ones(size(flow))';

%ec_cross_path_constr
Gpe_Pi=repmat(Gpe',[1,1,length(flow)]);
Gpe_Pi=permute(Gpe_Pi,[3,1,2]);
ec_cross_path_constr=Pi<=Gpe_Pi;

%Pi_define_constr
x_Pi=repmat(x,[1,1,counter_path]);
Pi_define_constr1=Pi<=x_Pi;

y_Pi=repmat(y,[length(edgecloud),1,1]);
y_Pi=reshape(y_Pi,length(flow),length(edgecloud),counter_path);
Pi_define_constr2=Pi<=y_Pi;

Pi_define_constr3=Pi>=x_Pi+y_Pi-1;

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
z_omega=repmat(z,[1,length(flow),counter_path]);
omega_define_constr1=omega<=z_omega;

[m,n]=size(y);
y_omega=reshape(y,1,m*n);
y_omega=repmat(y_omega,[size(link{flow1},1),1]);
y_omega=reshape(y_omega,size(link{flow1},1),length(flow),counter_path);
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


probability_x=probability(edgecloud(1):edgecloud(end));
probability_x=repmat(probability_x,[length(flow),1]);
probability_Pi=repmat(probability_x,[1,1,counter_path]);

w_Pi=zeros(length(flow),counter_path);
for ii=1:numel(flow)
        counter=1;
        for jj=1:numel(w{ii})
                if isempty(w{ii}{jj})
                        w_Pi(ii,counter)=0;
                        counter=counter+1;
                        continue;
                end
                for kk=1:numel(w{ii}{jj})
                        w_Pi(ii,counter)=w{ii}{jj}{kk};
                        counter=counter+1;
                end
        end
end
w_Pi=repmat(w_Pi,[1,1,length(edgecloud)]);
w_Pi=permute(w_Pi,[1,3,2]);

objfun2=sum(sum(probability_Pi.*w_Pi.*Pi,3),2)';

w_max=[];
for ii=1:length(flow)
    w_max=[w_max,max(w_Pi(ii,1,:))*10];
end

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

figure(h);
hold on
for ii=1:length(flow)
    highlight(p(ii),edgecloud(t1(ii)),'nodecolor','y');
    highlight(p(ii),path_array{t2(ii)},'edgecolor','m');
end
hold off

