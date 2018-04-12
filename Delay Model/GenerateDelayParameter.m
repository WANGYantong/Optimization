function [R_k,ce,mu] = GenerateDelayParameter(flow_stable,edge_cloud)

rng(1);

% the rate of each flow
% R_k=randi([1,2],size(flow_stable))*100;
R_k=ones(size(flow_stable))*0.05;

% number of servers
ce=zeros(size(edge_cloud));
ce(1:8)=2;
ce(9:10)=3;

% each server service rate
% assuming service rates for different flows are same
mu=poissrnd(0.5,1,length(edge_cloud))+1;

end

