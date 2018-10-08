function [probability_ka] = GetFlowProbability(i,access_router, targets,opts)
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

switch opts
    
    case 1
        for ii=1:numel(targets)
            if ii==4
                continue;
            end
            probability_ka(targets(ii))=1/(numel(targets)-1);
        end
        
    case 2
        y=[0.0044,0.0540,0.2420,0.4036,0.2420,0.0540];
        index=randperm(6);
        for ii=1:numel(targets)-1
            probability_ka(targets(ii))=y(index(ii));
        end
        buffer=probability_ka(targets(end));
        probability_ka(targets(end))=probability_ka(targets(4));
        probability_ka(targets(4))=buffer;
        
        
    case 3
        y=[0.0014,0.0270,0.1420,0.6636,0.1420,0.0240];
        index=randperm(6);
        for ii=1:numel(targets)-1
            probability_ka(targets(ii))=y(index(ii));
        end
        buffer=probability_ka(targets(end));
        probability_ka(targets(end))=probability_ka(targets(4));
        probability_ka(targets(4))=buffer;
        
    otherwise
        
        probability_ka(targets(end))=1;
        for ii=1:numel(targets)-1
            probability_ka(targets(ii))=rand()/(length(targets)-1);
            probability_ka(targets(end))=probability_ka(targets(end))...
                -probability_ka(targets(ii));
        end
        
        % index = randi(length(targets));
        % buffer=probability_ka(targets(end));
        % probability_ka(targets(end))=probability_ka(targets(index));
        % probability_ka(targets(index))=buffer;
        while(1)
            index = randi(length(targets));
            if index ~= 4
                break;
            end
        end
        buffer=probability_ka(4);
        probability_ka(4)=0;
        probability_ka(targets(index))=buffer+probability_ka(targets(index));
        
        buffer=probability_ka(targets(end));
        probability_ka(targets(end))=probability_ka(targets(index));
        probability_ka(targets(index))=buffer;
        
end

end

