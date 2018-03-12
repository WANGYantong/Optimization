%%
clear
clc

%%
flow=1:1:10;
NF_TOTAL=length(flow);

%%
for ii=1:length(flow)
   fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
   mainFunction(flow(1:ii),NF_TOTAL);
   clearvars -except ii flow NF_TOTAL
end
