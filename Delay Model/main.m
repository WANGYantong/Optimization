clear
clc

rng(1);
%%%%%%%%%%%%%%%%%%%%%%% generate network topology %%%%%%%%%%%%%%%%%%%%%%%%%
% the set of flows in the netwrok
flowname={'flow1','flow2'}; %$$%
N=length(flowname);
for v=1:N
    eval([flowname{v},'=',num2str(v),';']);
end
flow=[flow1, flow2];

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
figure;
cxd=['b','k','r','g','c','m','y'];
for ii=1:length(flow)
    subplot(2,1,ii);
    LWidths{ii}=3*G{ii}.Edges.Weight/max(G{ii}.Edges.Weight);
    p(ii)=plot(G{ii},'EdgeLabel',G{ii}.Edges.Weight,'NodeLabel',...
        G{ii}.Nodes.Name,'LineWidth',LWidths{ii});
    p(ii).Marker='o';
    p(ii).MarkerSize=8;
    p(ii).EdgeColor=cxd(ii); 
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
	counter_path=counter_path+numel(path{ii});
end

Gpe=zeros(counter_path, numel(edgecloud));
index=0;
for ii=1:numel(path)
    if isempty(path{ii})
        continue;
    end
    for jj=1:numel(path{ii})
        src=find(edgecloud==path{ii}{jj}(1));
        snk=find(edgecloud==path{ii}{jj}(end));
        if ~isempty(src) && ~isempty(snk)
            index=index+1;
            Gpe(index,src)=1;
            Gpe(index,snk)=1;
        end
    end
end

% caching cost impact factor
alpha=randi(100);

% utilization for each edge cloud
% utilization(ec1)
utilization=rand(size(edgecloud));
utilization=utilization*0.8;  % CHEAT!!!!!

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

% the rate of each flow
% THINK OUT THE RELATIONSHIP WITH LAMBDA!
Rk=randi([3,8],size(flow))*100;

% link capacity
Cl=1000;

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
ec_cache_num_constr=sum(x,2)<=Nk';

ec_cache_space_constr=Wsize*x<=Rspace;

total_cache_space_constr=sum(Wsize*x,2)<=Rtotal;

path_constr=sum(y,2)==ones(size(flow))';

Gpe_Pi=repmat(Gpe',[1,1,length(flow)]);
Gpe_Pi=permute(Gpe_Pi,[3,1,2]);
ec_cross_path_constr=Pi<=Gpe_Pi;

x_Pi=repmat(x,[1,1,counter_path]);
Pi_define_constr1=Pi<=x_Pi;

y_Pi=repmat(y,[length(edgecloud),1,1]);
y_Pi=reshape(y_Pi,length(flow),length(edgecloud),counter_path);
Pi_define_constr2=Pi<=y_Pi;

Pi_define_constr3=Pi>=x_Pi+y_Pi-1;

Rk_omega=repmat(Rk,[size(link{flow1},1),1,counter_path]);
Rk_y=repmat(Rk',[1,counter_path]);
link_delay_constr=sum(sum(Rk_y.*y,2))+...
    sum(sum(Rk_omega.*omega,3),2)-Cl*z<=0;

delta_link=GetWorstLinkDelay(Cl,Rk,path);
link_slack_constr=sum(z)<=delta_link;

z_omega=repmat(z,[1,length(flow),counter_path]);
omega_define_constr1=omega<=z_omega;

[m,n]=size(y);
y_omega=reshape(y,1,m*n);
y_omega=repmat(y_omega,[size(link{flow1},1),1]);
y_omega=reshape(y_omega,size(link{flow1},1),length(flow),counter_path);
M=99999999; %sufficiently large number
omega_define_constr2=omega<=M*y_omega;

omega_define_constr3=omega>=M*(y_omega-1);

delta_edge=delta-Tpr-delta_link;
lammax=GetMaxLambda(mu,ce,delta_edge);
edge_delay_constr=sum(lambda.*x,1)<=lammax;

%%%%%%%%%%%%%% create problem and objective function %%%%%%%%%%%%%
ProCache=optimproblem;
%use E instead of S here
%S=intersect(targets,edgecloud);

objfun1=alpha./(1-utilization)*x';

w_obj=cell(size(flow));
for ii=1:numel(flow)
        counter=1;
        for jj=1:numel(w{ii})
                if isempty(w{ii}{jj})
                        continue;
                end
                for kk=1:numel(w{ii}{jj})
                        w_obj{ii}{counter}=w{ii}{jj}{kk};
                        counter=counter+1;
                end
        end
end
objfun2=zeros(size(flow));
%reshape Pi like y_omega and happy new year!


% solve the problem

