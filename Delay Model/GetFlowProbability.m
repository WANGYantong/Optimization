function [probability_ec] = GetFlowProbability( base_station, targets, edge_cloud, G)
%GETFLOWPROBABILITY return the probability of mobile users movement
%
%   Input variables:
%
%       base_station: set of all base_stations
%
%       targets: the potential base_stations mobile users will move towards
%
%       edge_cloud: set of all edge_cloud
%
%       G: the network topology
%
%   Output variables:
%       probability_ec: the probability of mobile users moving to which
%       edge cloud
% rng(1);

probability_bc=zeros(size(base_station));
probability_bc(targets(end))=1;
for ii=1:length(targets)-1
    probability_bc(targets(ii))=rand()/(length(targets)-1);
    probability_bc(targets(end))=probability_bc(targets(end))...
        -probability_bc(targets(ii));
end
% calculate the probability of corresponding ec of these bs in targets
probability_ec=zeros(size(edge_cloud));
for ii=1:numel(targets)
    index=neighbors(G{1},targets(ii));
    probability_ec(index)=probability_ec(index)+...
        probability_bc(targets(ii));
end

end

