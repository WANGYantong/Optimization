function link_delay = GetWorstLinkDelay(Cl, Rk, path)
%GetWorstLinkDelay determine the link delay by considering the worst situation.
%                  choose the path which has most links
%
%   Input variables:
%
%    Cl    : the link capacity
%    Rk    : the rate of flow k, data structure: numeric vector
%    path  : all the route from source to destination, data structure: cell array
%
%   Output variables:
%    link_delay: the biggest delay tolerance

if nargin ~= 3
        error('Error. \n Illegal input number')
end

basic = 1/(Cl-sum(Rk)); % unit ms
factornum = 0;

for ii = 1:numel(path)
    if isempty(path{ii})
        continue;
    end
    
    compare = numel(path{ii})-1;
    if factornum < compare
        factornum = compare;
    end
    
end

link_delay = basic * factornum;       

end

