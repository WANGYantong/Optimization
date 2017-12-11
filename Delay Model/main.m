clear
clc

rng(2);
%%%%%%%%%%%%%%%%%%%%%%% generate network topology %%%%%%%%%%%%%%%%%%%%%%%%%%%%
s=[1,1,2,2,3,3,5];
t=[2,3,4,5,5,6,6];
weights=10*randi([1,10],size(s));
names={'ec1','n1','ec2','ec3',...
    'ec4','n2'};
N=length(names);
for v=1:N
    eval([names{v},'=',num2str(v),';']);
end
node=[n1,n2];
edgecloud=[ec1,ec2,ec3,ec4];

hold on;
G=graph(s,t,weights,names);
LWidths=3*G.Edges.Weight/max(G.Edges.Weight);
p=plot(G,'EdgeLabel',G.Edges.Weight,'NodeLabel',...
    G.Nodes.Name,'LineWidth',LWidths);
p.Marker='o';
p.MarkerSize=8;
p.EdgeColor='b'; 
p.LineStyle='--';
highlight(p,edgecloud,'nodecolor','r');
highlight(p,ec4,'nodecolor','g'); %the original edge cloud
p.XData=[3,2,4,1,3,5];
p.YData=[3,2,2,1,1,1];
hold off;
title('Network Topology');
%%%%%%%%%%%%%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
% generate route cost matrix
% this is the shortest path between sources and targets. 
% find a way to get all the possible paths between two nodes
sources=[ec1,ec2,ec3,ec4];
targets=[ec3,ec4,n2];
wkp=distances(G,sources,targets);

K=4; % number of flows
E=4; % number of edge clouds
%P=; % number of paths
%L=; % number of links



% decision variable

% constraints

% problem and objective function

% solve the problem