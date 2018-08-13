function  [G,vertice_name,edge_cloud,p]=GenerateGraph2()

vertice_name={'AR1','AR2','AR3','AR4','AR5',...
    'router1','router2','router3','router4',...
    'relay1','relay2','relay3','relay4','relay5',...
    'data_server'};

N=length(vertice_name);

for v=1:N
    eval([vertice_name{v},'=',num2str(v),';']);
end

server=[data_server];
relay=[relay1,relay2,relay3,relay4,relay5];
router=[router1,router2,router3,router4];
access_router=[AR1,AR2,AR3,AR4,AR5];

edge_cloud=[access_router,router];

s=[data_server,data_server,relay1,relay1,relay2,relay2,...
    relay3,relay3,relay4,relay4,relay5,relay5,...
    router1,router1,router2,router2,router3,router3,router4,router4];

t=[relay1,relay2,relay3,relay4,relay4,relay5,...
    router1,router2,router2,router3,router3,router4,...
    AR1,AR2,AR2,AR3,AR3,AR4,AR4,AR5];

weights=10;

G=graph(s,t,weights,vertice_name);

p=plot(G,'EdgeLabel',G.Edges.Weight,'NodeLabel',G.Nodes.Name,'layout','force');

highlight(p,server,'nodecolor','m');
highlight(p,relay,'nodecolor','b');
highlight(p,access_router,'nodecolor','r');
highlight(p,router,'nodecolor','b');
highlight(p,edge_cloud,'Marker','p','Markersize',8);

p.XData=[1,3,5,7,9,2,4,6,8,4,6,3,5,7,5];
p.YData=[1,1,1,1,1,2,2,2,2,4,4,3,3,3,5];

title('Simulation topology');


end

