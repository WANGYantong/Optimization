clear
clc

% combine variables into one vector
variables={'I1','I2','HE1','HE2','LE1','LE2','C','BF1',...
    'BF2','HPS','MPS','LPS','P1','P2','PP','EP'};
N=length(variables);
for v=1:N
    eval([variables{v},'=',num2str(v),';']);
end

%[x fval]=linprog(f,A,b,Aeq,beq,lb,ub)

% objective function
%  0.002614 HPS + 0.0239 PP + 0.009825 EP
f=zeros(size(variables));
f([HPS,PP,EP])=[0.002614,0.0239,0.009825];

% inequality constraints
% I1 - HE1 ¡Ü 132,000 
% -EP - PP ¡Ü -12,000
% -P1 - P2 - PP ¡Ü -24,550.
A=zeros(3,N);
A(1,[I1,HE1])=[1,-1];
A(2,[EP,PP])=[-1,-1];
A(3,[P1,P2,PP])=[-1,-1,-1];
b=[132000,-12000,-24550];

% equality constraints
% LE2 + HE2 - I2 = 0
% LE1 + LE2 + BF2 - LPS = 0
% I1 + I2 + BF1 - HPS = 0
% C + MPS + LPS - HPS = 0
% LE1 + HE1 + C - I1 = 0
% HE1 + HE2 + BF1 - BF2 - MPS = 0
% 1267.8 HE1 + 1251.4 LE1 + 192 C + 3413 P1 - 1359.8 I1 = 0
% 1267.8 HE2 + 1251.4 LE2 + 3413 P2 - 1359.8 I2 = 0.
Aeq=zeros(8,N);
Aeq(1,[LE2,HE2,I2])=[1,1,-1];
Aeq(2,[LE1,LE2,BF2,LPS])=[1,1,1,-1];
Aeq(3,[I1,I2,BF1,HPS])=[1,1,1,-1];
Aeq(4,[C,MPS,LPS,HPS])=[1,1,1,-1];
Aeq(5,[LE1,HE1,C,I1])=[1,1,1,-1];
Aeq(6,[HE1,HE2,BF1,BF2,MPS])=[1,1,1,-1,-1];
Aeq(7,[HE1,LE1,C,P1,I1])=[1267.8,1251.4,192,3413,-1359.8];
Aeq(8,[HE2,LE2,P2,I2])=[1267.8,1251.4,3413,-1359.8];
beq=zeros(1,8);

% lower bound
% P1 ¡Ý 2500
% P2 ¡Ý 3000
% MPS ¡Ý 271,536
% LPS ¡Ý 100,623.
lb=zeros(size(variables));
lb([P1,P2,MPS,LPS])=[2500,3000,271536,100623];

% upper bound
% P1 ¡Ü 6250
% P2 ¡Ü 9000
% I1 ¡Ü 192,000
% I2 ¡Ü 244,000
% C ¡Ü 62,000
% LE2 ¡Ü 142000.
ub=inf(size(variables));
ub([P1,P2,I1,I2,C,LE2])=[6250,9000,192000,244000,62000,142000];

options=optimoptions('linprog','Algorithm','dual-simplex');
[x,fval]=linprog(f,A,b,Aeq,beq,lb,ub,options);

for d=1:N
    fprintf('%12.2f \t%s\n',x(d), variables{d})
end

fval

