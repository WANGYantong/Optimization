clear
clc

rng(2);

%%%%%%%%%%%%%%%%%%%%%%% generate network topology %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the set of flows in the netwrok
flow={'flow1','flow2'}; %$$%
N=length(flow);
for v=1:N
    eval([flow{v},'=',num2str(v),';']);
end

% the nodes and edge clouds in the network 
names={'ec1','n1','ec2','ec3',...
    'ec4','n2'}; %$$%
N=length(names);
for v=1:N
    eval([names{v},'=',num2str(v),';']);
end
node=[n1,n2]; %$$%
edgecloud=[ec1,ec2,ec3,ec4]; %$$%

% generate the undirected graph
s=[1,1,2,2,3,3,5]; %$$%
t=[2,3,4,5,5,6,6]; %$$%
for ii=1:length(flow)
    weights{ii}=10*randi([1,10],size(s));
    G{ii}=graph(s,t,weights{ii},names);
end

% plot each flow graph
figure;
cxd=['r','b','g','c','y','m','k'];
for ii=1:length(flow)
    subplot(2,1,ii);
    LWidths{ii}=3*G{ii}.Edges.Weight/max(G{ii}.Edges.Weight);
    p(ii)=plot(G{ii},'EdgeLabel',G{ii}.Edges.Weight,'NodeLabel',...
        G{ii}.Nodes.Name,'LineWidth',LWidths{ii});
    p(ii).Marker='o';
    p(ii).MarkerSize=8;
    p(ii).EdgeColor=cxd(randi(length(cxd))); 
    p(ii).LineStyle='--';
    highlight(p(ii),edgecloud,'nodecolor','r');
    highlight(p(ii),ec4,'nodecolor','g'); %the original edge cloud
    p(ii).XData=[3,2,4,1,3,5]; 
    p(ii).YData=[3,2,2,1,1,1]; 
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
sources=[ec1,ec2,ec3,ec4];
targets=[ec3,ec4,n2];
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
Gpe=zeros(numel(path), numel(edgecloud));
for ii=1:size(Gpe,1)
    if isempty(path{ii})
        continue;
    end
    % considering path{ii} may has more than one posiible route, but their 
    % source and destination are same. So here use path{ii}{1} to replace
    % the others.
    src=find(edgecloud==path{ii}{1}(1));
    snk=find(edgecloud==path{ii}{1}(end));
    if ~isempty(src) && ~isempty(snk)
        Gpe(ii,src)=1;
        Gpe(ii,snk)=1;
    end
end
Gpe=sparse(Gpe);

% caching cost impact factor

% utilization for each edge cloud

% mobile moving probability

% the maximum number of edge cloud used to cache

% size of cache items

% remaining cache space for each edge cloud

% remaining cache space in total

% the rate of each flow

% link capacity

% arriving rate

% number of servers

% each server service rate

% delay tolerance

% propagation delay


%%%%%%%%%%%%%%%%%%%%%%%% decision variable %%%%%%%%%%%%%%%%%%%%%%%%%%

% constraints

% problem and objective function

% solve the problem
