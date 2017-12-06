clear
clc

rng(2);
% generate network topology
s=[1,1,2,2,3,3,5];
t=[2,3,4,5,5,6,6];
weights=10*randi([1,10],size(s));
names={'ec1','n1','ec2','ec3',...
    'ec4','n2'};

hold on;
G=graph(s,t,weights,names);
LWidths=3*G.Edges.Weight/max(G.Edges.Weight);
p=plot(G,'EdgeLabel',G.Edges.Weight,'NodeLabel',...
    G.Nodes.Name,'LineWidth',LWidths);
p.Marker='o';
p.NodeColor='r';
p.MarkerSize=8;
p.EdgeColor='b'; 
p.LineStyle='--';
p.XData=[3,2,4,1,3,5];
p.YData=[3,2,2,1,1,1];
plot(3,1,'black*');
hold off;
title('Network Topology');


% parameters

% decision variable

% constraints

% problem and objective function

% solve the problem