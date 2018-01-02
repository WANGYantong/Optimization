function lammax = GetMaxLambda(mu,ce,delay)
%GETMAXLAMBDA calculate the max lambda which satisfies the MMc model
%
%   
%   Input variables:
%
%     mu  : unit servicing rate for each edge cloud service each flow
%   
%     ce  : number of servers for each edge cloud
%
%    delay: tolerance time for edge delay
%
%   Output variables:
%
%   lammax : the max lambda for each edge cloud

if nargin ~= 3
        error('Error. \n Illegal input number')
end

lb = zeros(size(mu));
ub = mu .* ce;
x0 = lb;
options = optimoptions(@fmincon, 'Algorithm', 'sqp','Display','off');
lammax = x0;

for ii = 1:length(lammax)
        lammax(ii) = fmincon(@objfun, x0(ii), [], [], [], [], lb(ii), ub(ii),...
                @(lambda) MMC(lambda, mu(ii), ce(ii), delay), options);
end

end

function f = objfun(x)
        f = -x;
end
               
function [c, ceq] = MMC(lambda, mu, c, delay)

f1 = lambda^c/(factorial(c)*mu^c);
f2 = (1-lambda/(c*mu))*SumQueue(lambda,mu,c)+f1;
f3 = c*mu-lambda;
f4 = 1/mu;

c = f1/(f2*f3)+f4-delay;
ceq = [];

end

function f = SumQueue(lambda, mu, c)

f=0;

for n=0:(c-1)
    f=f+lambda^n/(factorial(n)*mu^n);
end

end
