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
link1=G{flow1}.Edges;
link2=G{flow2}.Edges;

% the set of paths
% the paths for flow1 and flow2 are same 
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


% matrix for path cross edge cloud


%%%%%%%%%%%%%%%%%%%%%%%% decision variable %%%%%%%%%%%%%%%%%%%%%%%%%%

% constraints

% problem and objective function

% solve the problem