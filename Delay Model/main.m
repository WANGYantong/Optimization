clear
clc

flowname={'flow1','flow2','flow3','flow4','flow5'}; %$$%
N=length(flowname);
for v=1:N
    eval([flowname{v},'=',num2str(v),';']);
end
flow=[flow1,flow2,flow3,flow4,flow5];

for ii=1:length(flow)
   fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
   mainFunction(flow(1:ii));
   clearvars -except ii flow
end
