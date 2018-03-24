%%
clear
clc

%%
flow=1:1:20;
NF=length(flow);
% NF_TOTAL=length(flow);
NF_TOTAL=20;
result=zeros(NF_TOTAL,18);

%%
for ii=1:NF
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
    result(ii,1)=ii;
    buff=mainFunction(flow(1:ii),NF_TOTAL,result);
    result(ii,3:18)=buff(ii,3:18);
end

%%
cost_MILP=result(1:1:NF,3);
cost_Nominal=result(1:1:NF,4);
cost_Greedy=result(1:1:NF,5);
cost_Random=result(1:1:NF,6);
cost_Nocache=result(1:1:NF,7);
figure(1);
plot(flow,cost_MILP,'-.o',flow,cost_Nominal,'-.^',...
    flow,cost_Greedy,'-.s',flow,cost_Random,'-.d',flow,cost_Nocache,'-.p');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend({'MILP','Nominal','Greedy','Randomized','No Cache'},'location','northwest');

figure(2);
plot(flow,cost_MILP./cost_Nominal,'-.^', flow,cost_MILP./cost_Greedy,'-.s',...
    flow,cost_MILP./cost_Random,'-.d',flow,cost_MILP./cost_Nocache,'-.p');
xlabel('number of flows');
ylabel('cost gain');
legend({'MILP VS Nominal','MILP VS Greedy','MILP VS Randomized',...
    'MILP VS No_cache'},'location','northwest');

delay_MILP=result(1:1:NF,9);
delay_Nominal=result(1:1:NF,10);
delay_Greedy=result(1:1:NF,11);
delay_Random=result(1:1:NF,12);
delay_Tolerance=result(1:1:NF,13);
figure(3);
plot(flow,delay_MILP,'-.o',flow,delay_Nominal,'-.^',...
    flow,delay_Greedy,'-.s',flow,delay_Random,'-.d',flow,delay_Tolerance,'-.p');
title('delay time');
xlabel('number of flows');
ylabel('delay time(ms)');
legend({'MILP','Nominal','Greedy','Randomized','Delay Tolerance'},'location','northwest');

% filename='data.xlsx';
% xlswrite(filename,result);
