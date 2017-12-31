lb=[0];
ub=[360];
x0=[0];
c=[3];
delay=[0.01]
options=optimoptions(@fmincon,'Algorithm','sqp');
[x,fval]=...
fmincon(@objfun,x0,[],[],[],[],lb,ub,@(x) confun(x,c,delay),options)

function f = objfun(x)
f=-x;
end


function [c, ceq] = confun(x,c, delay)
%c = [x^2/(120*(240^2-x^2))-0.001];
c=[x^c/(120*(6*120^c+40*x+x^c)*(360-x))-delay];
ceq = [];
end