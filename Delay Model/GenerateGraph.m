function [G,vertice_names,edge_cloud,p] = GenerateGraph()
%GenerateGraph Generate network topology based on the paper:
%https://pdfs.semanticscholar.org/0a9a/85e48d468e7ea2a415fd661e31cec5d13ac7.pdf
%   
%   Input variables:
%
%     NULL
%
%   Output variables:
%     
%     G: undirected graph
%
%     vertice_names: the names of the verice in G, cell array

rng(2);

vertice_names = {'AR1','AR2','AR3','AR4','AR5','AR6','AR7',...
        'router1','router2','router3','router4','router5','router6',...
        'router7','router8',...
        'bs1','bs2','bs3','bs4','bs5','bs6','bs7','bs8','bs9','bs10',...
        'data_server','relay1','relay2','relay3','relay4','relay5',...
        'relay6','relay7','relay8','relay9','relay10','relay11',...
        'relay12','relay13','relay14','relay15'};

N = length(vertice_names);

for v = 1:N
        eval([vertice_names{v},'=',num2str(v),';']);
end

server=[data_server];
relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
    relay10,relay11,relay12,relay13,relay14,relay15];
base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];
access_router=[AR1,AR2,AR3,AR4,AR5,AR6,AR7];
router=[router1,router2,router3,router4,router5,router6,router7,router8];

buff_A=randperm(numel(access_router));
buff_B=randperm(numel(router))+router1-1;
edge_cloud=[buff_A(1:4),buff_B(1:6)];

%basic graph topology from nsnSim paper, for the part of backbone and access layer
s = [data_server,relay1,relay1,relay3,relay3,relay3,relay2,relay2,relay7,...
     relay7,relay6,relay5,relay5,relay4,relay14,relay11,relay11,relay11,...
     relay9,relay9,relay8,relay15,relay13,relay13,relay12,relay12,relay12,...
     relay10,router1,router1,router1,router2,router2,router4,AR7,AR7,AR1,...
     AR1,router5,router3,router3,AR6,...
     AR1,router6,router8,AR2,router7,AR5,AR3];
t = [relay1,relay2,relay3,relay7,relay6,relay5,relay5,relay4,relay14,...
     relay11,relay11,relay11,relay9,relay8,relay15,relay15,router2,relay13,...
     relay13,relay8,relay10,router1,router2,relay12,router3,router4,relay10,...
     router4,AR1,router5,router2,router5,router3,AR7,router8,AR6,router5,...
     router6,router6,router7,router8,AR5,...
     AR2,AR2,router7,AR3,AR3,AR4,AR4];

mu=100;
sigma=10;
weights=round(normrnd(mu,sigma,size(s)));

G=graph(s,t,weights,vertice_names);

%some modification of graph G, to make it looks like access layer topology...
weights_mod=round(normrnd(mu,sigma,7,1));
G=addedge(G,router5,AR2,weights_mod(1));
G=addedge(G,router3,router6,weights_mod(2));
G=addedge(G,router6,AR3,weights_mod(3));
G=addedge(G,router7,AR4,weights_mod(4));
G=addedge(G,router8,AR5,weights_mod(5));
G=addedge(G,router8,AR6,weights_mod(6));
G=addedge(G,AR5,router7,weights_mod(7));
G=rmedge(G,router6,AR1);
G=rmedge(G,AR3,AR4);
G=rmedge(G,AR4,AR5);
G=rmedge(G,AR5,AR6);  

%the link between base station and edge cloud
G=addedge(G,AR1,bs1,1);
G=addedge(G,AR1,bs2,1);
G=addedge(G,AR2,bs3,1);
G=addedge(G,AR3,bs4,1);
G=addedge(G,AR3,bs5,1);
G=addedge(G,AR4,bs6,1);
G=addedge(G,AR5,bs7,1);
G=addedge(G,AR6,bs8,1);
G=addedge(G,AR7,bs9,1);
G=addedge(G,AR7,bs10,1);

p=plot(G,'EdgeLabel',G.Edges.Weight,'NodeLabel',G.Nodes.Name);

highlight(p,server,'nodecolor','m');
highlight(p,relay,'nodecolor','b');
highlight(p,base_station,'nodecolor','y');
highlight(p,access_router,'nodecolor','r');
highlight(p,router,'nodecolor','b');
highlight(p,edge_cloud,'Marker','p','Markersize',8);

p.XData=[1,3,5,7,9,11,13,3,5,8,11,3,5,8,11,0,1.5,3,4.5,6,7.5,9,10.5,12,13.5,...
         7, 7,8,6,9,7,6,5,10,8,11,6,8,6,4,3];
p.YData=[1,1,1,1,1, 1, 1,3,3,3, 3,2,2,2, 2,0,  0,0,  0,0,  0,0,   0, 0,   0,...
         11,9,8,8,7,7,7,7, 6,6, 5,6,5,5,6,5];

line([0,14],[10,10],'Color','k','LineStyle','--');
line([0,14],[4,4],'Color','k','LineStyle','--');
line([0,14],[0.5,0.5],'Color','k','LineStyle','--');

text(-1,11,'server','Color','k','FontSize',10);
text(-1,7,'backbone layer','Color','k','FontSize',10);
text(-1,2,'access layer','Color','k','FontSize',10);
text(-1,-1,'base station','Color','k','FontSize',10);

title('Simulation topology');

end

