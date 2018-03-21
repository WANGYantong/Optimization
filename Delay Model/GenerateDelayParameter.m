function [R_k,lambda,ce,mu] = GenerateDelayParameter(flow_stable,edge_cloud,NF)

rng(1);

NF_stable=length(flow_stable);

% the rate of each flow
% R_k=randi([1,2],size(flow_stable))*100;
R_k=ones(size(flow_stable))*100;

% arriving rate
% unit: Mbps
lambda=poissrnd(200,NF_stable,length(edge_cloud));

% number of servers
ce=zeros(size(edge_cloud));
ce(1:8)=2+floor(NF/10);
ce(9:10)=4+2*floor(NF/10);
% for ii=1:length(ce)
%     if rand()>0.8
%         ce(ii)=2;
%     else
%         ce(ii)=4+2*floor(NF/10);
%     end
% end

% each server service rate
% assuming service rates for different flows are same
% unit: Mbps
mu=poissrnd(120,1,length(edge_cloud));
end

