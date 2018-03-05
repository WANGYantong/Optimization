function [probability_ka] = GetFlowProbability(i,access_router, targets)
%GETFLOWPROBABILITY return the probability of mobile users movement
%
%   Input variables:
%
%       access_router: set of all access_router
%
%       targets: the potential base_stations mobile users will move towards
%
%   Output variables:
%       probability_ka: the probability of mobile users moving to which
%                       access_router
rng(i);

probability_ka=zeros(size(access_router));
probability_ka(targets(end))=1;
for ii=1:numel(targets)-1
    probability_ka(targets(ii))=rand()/(length(targets)-1);
    probability_ka(targets(end))=probability_ka(targets(end))...
        -probability_ka(targets(ii));
end

index = randi(length(targets));
buffer=probability_ka(targets(end));
probability_ka(targets(end))=probability_ka(targets(index));
probability_ka(targets(index))=buffer;

end

