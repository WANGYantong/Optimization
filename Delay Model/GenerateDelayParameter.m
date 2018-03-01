function [R_k,lambda,ce,mu] = GenerateDelayParameter(flow,edge_cloud)

rng(1);

NF=length(flow);

% the rate of each flow
R_k=randi([1,floor(10/NF)],size(flow))*100;

% arriving rate
% unit: Mbps
lambda=poissrnd(200,NF,length(edge_cloud));

% number of servers
ce=zeros(size(edge_cloud));
for ii=1:length(ce)
    if rand()>0.5
        ce(ii)=2;
    else
        ce(ii)=3;
    end
end

% each server service rate
% assuming service rates for different flows are same
% unit: Mbps
mu=poissrnd(120,1,length(edge_cloud));
end

