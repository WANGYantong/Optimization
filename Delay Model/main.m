%%
clear
clc

%%
flow=1:1:15;
NF=length(flow);
% NF_TOTAL=length(flow);
NF_TOTAL=20;
result=zeros(NF_TOTAL,18);

%%
flow_parallel=cell(size(flow));
for ii=1:NF
    flow_parallel{ii}=flow(1:ii);
end

for ii=1:NF
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
    result(ii,:)=mainFunction(flow_parallel{ii},NF_TOTAL);
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
end
result(:,1)=1:1:NF_TOTAL;

%%
cost_MILP=result(1:1:NF,3);
cost_Nominal=result(1:1:NF,4);
cost_Greedy=result(1:1:NF,5);
cost_Random=result(1:1:NF,6);
cost_Nocache=result(1:1:NF,7);
figure(1);
plot(flow,cost_MILP,'-.o',flow,cost_Nominal,'-.^',...
    flow,cost_Greedy,'-.s',flow,cost_Random,'-.d');
title('cost');
xlabel('number of flows');
ylabel('total cost');
legend({'MILP','NEC','Greedy','Randomized'},'location','northwest');

delay_MILP=result(1:1:NF,9);
delay_Nominal=result(1:1:NF,10);
delay_Greedy=result(1:1:NF,11);
delay_Random=result(1:1:NF,12);
delay_Tolerance=result(1:1:NF,13);
figure(2);
plot(flow,delay_MILP,'-.o',flow,delay_Nominal,'-.^',...
    flow,delay_Greedy,'-.s',flow,delay_Random,'-.d',flow,delay_Tolerance,'-r');
title('delay time');
xlabel('number of flows');
ylabel('delay time(ms)');
legend({'MILP','NEC','Greedy','Randomized','Delay Tolerance'},'location','northwest');

filename='data.xlsx';
xlswrite(filename,result);

%MILP can always find the optimal solution
satisfied_MILP=1:1:15; 
%when it comes to 10 flows, there is an network servicing rate upgrade
satisfied_NEC=[1,1,1,2,3,4,5,5,6,7,7,7,8,8,8];
satisfied_Greedy=[1,1,2,3,4,5,6,6,7,9,10,10,11,12,12];
%for Randomized, this is a mean number of 1000 monte carlo simulations,
%so there are some fractional numbers
satisfied_Randomized=[1,2,3,4,5,6,7,8,9,9.999,10.907,10.876,11.258,12.018,12];

outage_NEC=(satisfied_MILP-satisfied_NEC)./satisfied_MILP;
outage_Greedy=(satisfied_MILP-satisfied_Greedy)./satisfied_MILP;
outage_Randomized=(satisfied_MILP-satisfied_Randomized)./satisfied_MILP;
outage=[outage_NEC;outage_Greedy;outage_Randomized]';
figure(3);
bar(outage,0.6);
title('Outage Probability');
xlabel('number of flows');
ylim([0,1]);
legend({'NEC','Greedy','Randomized'},'location','north');

satisfied_NEC=satisfied_NEC./satisfied_MILP;
satisfied_Greedy=satisfied_Greedy./satisfied_MILP;
satisfied_Randomized=satisfied_Randomized./satisfied_MILP;
satisfied_MILP=satisfied_MILP./satisfied_MILP;
satisfied=[satisfied_MILP;satisfied_NEC;satisfied_Greedy;satisfied_Randomized]';
figure(4);
bar(satisfied,0.6);
title('Satisfied Probability');
xlabel('number of flows');
ylim([0 1.6]);
legend({'MILP','NEC','Greedy','Randomized'},'location','north');

