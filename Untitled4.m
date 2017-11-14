lb=[0];
ub=[360];
x0=[0];
options=optimoptions(@fmincon,'Algorithm','sqp');
[x,fval]=...
fmincon(@objfun,x0,[],[],[],[],lb,ub,@confun,options)