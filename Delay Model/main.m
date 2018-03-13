%%
clear
clc

%%
flow=1:1:100;
NF_TOTAL=length(flow);
result=zeros(NF_TOTAL,18);

%%
for ii=1:length(flow)    
    fprintf("\n %%%%%%%%%%%%for %d flow%%%%%%%%%%%%\n",ii);
    result(ii,1)=ii;
    result=result+mainFunction(flow(1:ii),NF_TOTAL,result);
end

filename='data.xlsx';
xlswrite(filename,result);
