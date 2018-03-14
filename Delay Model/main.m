%%
clear
clc

%%
flow=1:1:20;
NF_TOTAL=length(flow);
result=zeros(NF_TOTAL,18);

%%
for ii=1:length(flow)    
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
    result(ii,1)=ii;
    buff=mainFunction(flow(1:ii),NF_TOTAL,result);
    result(ii,3:18)=buff(ii,3:18);
end

filename='data.xlsx';
xlswrite(filename,result);
