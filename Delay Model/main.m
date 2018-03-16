%%
clear
clc

%%
flow=1:1:10;
NF_TOTAL=length(flow)*2;
result=zeros(NF_TOTAL,18);

%%
for ii=1:length(flow)
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
    result(ii,1)=ii;
    buff=mainFunction(flow(1:ii),NF_TOTAL,result);
    result(ii,3:18)=buff(ii,3:18);
end

%%
cost_MILP=result(1:1:10,3);
cost_Nominal=result(1:1:10,4);
cost_Greedy=result(1:1:10,5);
cost_Random=result(1:1:10,6);
cost_Nocache=result(1:1:10,7);
figure(1);
plot(flow,cost_MILP,'-o',flow,cost_Nominal,'-+',...
    flow,cost_Greedy,'-*',flow,cost_Random,'-d',flow,cost_Nocache,'-x');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend('MILP','Nominal','Greedy','Randomized','No Cache');

delay_MILP=result(1:1:10,9);
delay_Nominal=result(1:1:10,10);
delay_Greedy=result(1:1:10,11);
delay_Random=result(1:1:10,12);
delay_Tolerance=result(1:1:10,13);
figure(2);
plot(flow,delay_MILP,'-o',flow,delay_Nominal,'-+',...
    flow,delay_Greedy,'-*',flow,delay_Random,'-d',flow,delay_Tolerance,'-x');
title('delay time');
xlabel('number of flows');
ylabel('delay time(ms)');
legend('MILP','Nominal','Greedy','Randomized','Delay Tolerance');

% filename='data.xlsx';
% xlswrite(filename,result);
