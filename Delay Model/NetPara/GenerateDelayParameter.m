function [R_k,ce,mu] = GenerateDelayParameter(flow_stable,edge_cloud)

rng(1);

% the rate of each flow
% R_k=randi([1,2],size(flow_stable))*100;
R_k=ones(size(flow_stable))*0.03;

% number of servers
ce=zeros(size(edge_cloud));
ce(1:4)=2;
ce(5:6)=3;
ce(9:10)=3;
ce(7:8)=2*2;

% each server service rate
% assuming service rates for different flows are same
% mu=poissrnd(1,1,length(edge_cloud))+1;
% mu=[1.5,1,1,1,1,1,1.5,1.5,1,1]+0.5;
% mu=[1.5,1,1,1,1,1,1.5,1.5,1,1];
mu=[0.6,0.6,0.6,0.6,1,1,1.5,1.5,1,1];

end

