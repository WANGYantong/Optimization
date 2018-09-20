function [R_k,ce,mu] = GenerateDelayParameter(flow_stable,edge_cloud)

rng(1);

% the rate of each flow
% R_k=randi([1,2],size(flow_stable))*100;
R_k=randi([1,10],size(flow_stable));

% number of servers
% ce=zeros(size(edge_cloud));
% ce(1:4)=4;
% ce(5:6)=6;
% ce(9)=6;
% ce(7:8)=8;
ce=ones(size(edge_cloud))*4;

% each server service rate
% assuming service rates for different flows are same
% mu=poissrnd(1,1,length(edge_cloud))+1;
% mu=[1.5,1,1,1,1,1,1.5,1.5,1,1]+0.5;
% mu=[1.5,1,1,1,1,1,1.5,1.5,1,1];
mu=[2,2,2,2,3,3,4,4,3]+0.5;

end

