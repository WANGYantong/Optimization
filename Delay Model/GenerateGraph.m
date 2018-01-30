function [G,vertice_names] = GenerateGraph()
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

rng(1);

vertice_names = {'data_server','relay1','relay2','relay3','relay4','relay5',...
    'relay6','relay7','relay8','relay9','relay10','relay11','relay12',...
        'relay13','relay14','relay15','ec1','ec2','ec3','ec4','ec5',...
        'ec6','ec7','ec8','ec9','ec10','ec11','ec12','ec13','ec14','ec15',...
        'bs1','bs2','bs3','bs4','bs5','bs6','bs7','bs8','bs9','bs10'};

N = length(vertice_names);

for v = 1:N
        eval([vertice_names{v},'=',num2str(v),';']);
end

server=[data_server];
relay=[relay1,relay2,relay3,relay4,relay5,relay6,relay7,relay8,relay9,...
    relay10,relay11,relay12,relay13,relay14,relay15];
edge_cloud=[ec1,ec2,ec3,ec4,ec5,ec6,ec7,ec8,ec9,ec10,ec11,ec12,ec13,...
    ec14,ec15];
base_station=[bs1,bs2,bs3,bs4,bs5,bs6,bs7,bs8,bs9,bs10];

%basic graph topology from nsnSim paper, for the part of backbone and access layer
s = [data_server,relay1,relay1,relay3,relay3,relay3,relay2,relay2,relay7,...
        relay7,relay6,relay5,relay5,relay4,relay14,relay11,relay11,relay11,...
        relay9,relay9,relay8,relay15,relay13,relay13,relay12,relay12,relay12,...
        relay10,ec1,ec1,ec1,ec2,ec2,ec3,ec4,ec4,ec8,ec8,ec5,ec6,ec6,ec7,...
        ec8,ec9,ec10,ec12,ec13,ec11,ec14];
t = [relay1,relay2,relay3,relay7,relay6,relay5,relay5,relay4,relay14,...
        relay11,relay11,relay11,relay9,relay8,relay15,relay15,ec2,relay13,...
        relay13,relay8,relay10,ec1,ec2,relay12,ec6,ec3,relay10,...
        ec3,ec8,ec5,ec2,ec5,ec6,ec4,ec10,ec7,ec5,ec9,ec9,ec13,ec10,ec11,...
        ec12,ec12,ec13,ec14,ec14,ec15,ec15];

mu=100;
sigma=10;
weights=round(normrnd(mu,sigma,size(s)));

G=graph(s,t,weights,vertice_names);

%some modification of graph G, to make it looks like access layer topology...
weights_mod=round(normrnd(mu,sigma,7,1));
G=addedge(G,ec5,ec12,weights_mod(1));
G=addedge(G,ec6,ec9,weights_mod(2));
G=addedge(G,ec9,ec14,weights_mod(3));
G=addedge(G,ec13,ec15,weights_mod(4));
G=addedge(G,ec10,ec11,weights_mod(5));
G=addedge(G,ec10,ec7,weights_mod(6));
G=addedge(G,ec11,ec13,weights_mod(7));
G=rmedge(G,ec9,ec8);
G=rmedge(G,ec14,ec15);
G=rmedge(G,ec15,ec11);
G=rmedge(G,ec11,ec7);  

%the link between base station and edge cloud
G=addedge(G,ec8,bs1,1);
G=addedge(G,ec8,bs2,1);
G=addedge(G,ec12,bs3,1);
G=addedge(G,ec14,bs4,1);
G=addedge(G,ec14,bs5,1);
G=addedge(G,ec15,bs6,1);
G=addedge(G,ec11,bs7,1);
G=addedge(G,ec7,bs8,1);
G=addedge(G,ec4,bs9,1);
G=addedge(G,ec4,bs10,1);

p=plot(G,'EdgeLabel',G.Edges.Weight,'NodeLabel',G.Nodes.Name);

highlight(p,server,'nodecolor','g');
highlight(p,relay,'nodecolor','b');
highlight(p,edge_cloud,'nodecolor','r');
highlight(p,base_station,'nodecolor','y');

p.XData=[7, 7,8,6,9,7,6,5,10,8,11,6,8,6,4,3,3,5,11,13,3,8,11,1,...
         5,11,9,3,8,5,7,0,1.5,3,4.5,6,7.5,9,10.5,12,13.5];
p.YData=[11,9,8,8,7,7,7,7, 6,6, 5,6,5,5,6,5,3,3, 3, 1,2,3, 1,1,...
         2, 2,1,1,2,1,1,0,  0,0,  0,0,  0,0,   0, 0,   0];

line([0,14],[10,10],'Color','k','LineStyle','--');
line([0,14],[4,4],'Color','k','LineStyle','--');
line([0,14],[0.5,0.5],'Color','k','LineStyle','--');

text(-1,11,'server','Color','k','FontSize',10);
text(-1,7,'backbone layer','Color','k','FontSize',10);
text(-1,2,'access layer','Color','k','FontSize',10);
text(-1,-1,'base station','Color','k','FontSize',10);

title('Simulation topology');

end

