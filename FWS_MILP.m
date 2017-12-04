clear
clc

% generate the facility locations
rng(1); % for reproducibility
N=20;   
N2=N*N;
f=0.05; % density of factories
w=0.05; % density of warehouses
s=0.1;  % density of sales outlets
F=floor(f*N2); % number of factories
W=floor(w*N2); % number of warehouses
S=floor(s*N2); % number of sales outlets

xyloc=randperm(N2,F+W+S); %locations of the facilities
[xloc,yloc]=ind2sub([N N],xyloc);

h=figure;
plot(xloc(1:F),yloc(1:F),'rs',xloc(F+1:F+W),yloc(F+1:F+W),'k*',...
    xloc(F+W+1:F+W+S),yloc(F+W+1:F+W+S),'bo');
lgnd=legend('Factory','Warehouse','Sales outlet','Location','EastOutside');
lgnd.AutoUpdate='off';
xlim([0 N+1]);ylim([0 N+1])

% generate random capacities, costs and demands
P=20;
pcost=80*rand(F,P)+20;
pcap=1000*rand(F,P)+500;
wcap=P*400*rand(W,1)+P*400;
turn=2*rand(1,P)+1;
tcost=5*rand(1,P)+5;
d=300*rand(S,P)+200;

% generate the distance arrays
% allocate matrix for factory-warehouse distances
distfw=zeros(F,W); 
for ii=1:F
    for jj=1:W
        distfw(ii,jj)=abs(xloc(ii)-xloc(F+jj))+abs(yloc(ii)-yloc(F+jj));
    end
end
% allocate matrix for sales out-warehouse distances
distsw=zeros(S,W);
for ii=1:S
    for jj=1:W
        distsw(ii,jj)=abs(xloc(F+W+ii)-xloc(F+jj))+abs(yloc(F+W+ii)-yloc(F+jj));
    end
end

% desicion variable
x=optimvar('x',P,F,W,'LowerBound',0);
y=optimvar('y',S,W,'Type','integer','LowerBound',0,'UpperBound',1);

% constraints
capconstr=sum(x,3)<=pcap';
demconstr=squeeze(sum(x,2))==d'*y;
warecap=sum(diag(1./turn)*(d'*y),1)<=wcap';
salesware=sum(y,2)==ones(S,1);

% create problem and objective function
factoryprob=optimproblem;
objfun1=sum(sum(sum(x,3).*(pcost'),2),1);

objfun2=0;
for p=1:P
    objfun2=objfun2+tcost(p)*sum(sum(squeeze(x(p,:,:)).*distfw));
end

r=sum(distsw.*y,2);
v=d*(tcost(:));
objfun3=sum(v.*r);

factoryprob.Objective=objfun1+objfun2+objfun3;
factoryprob.Constraints.capconstr=capconstr;
factoryprob.Constraints.demconstr=demconstr;
factoryprob.Constraints.warecap=warecap;
factoryprob.Constraints.salesware=salesware;

% solve the problem
opts=optimoptions('intlinprog','Display','off','PlotFcn',@optimplotmilp);
[sol,fval,exitflag,output]=solve(factoryprob,opts);

if isempty(sol)
    disp('The solver did not return a solution.')
    return
end

sol.y = round(sol.y);
outlets=sum(sol.y,1);

figure(h);
hold on
for ii = 1:S
    jj = find(sol.y(ii,:)); % Index of warehouse associated with ii
    xsales = xloc(F+W+ii); ysales = yloc(F+W+ii);
    xwarehouse = xloc(F+jj); ywarehouse = yloc(F+jj);
    if rand(1) < .5 % Draw y direction first half the time
        plot([xsales,xsales,xwarehouse],[ysales,ywarehouse,ywarehouse],'g--')
    else % Draw x direction first the rest of the time
        plot([xsales,xwarehouse,xwarehouse],[ysales,ysales,ywarehouse],'g--')
    end
end
hold off

title('Mapping of sales outlets to warehouses')

