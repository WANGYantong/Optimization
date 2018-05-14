%% I. clear memory and screen
clear all
clc

%% II. generate problem
x = 0:0.01:9;
y =  x + 10*sin(5*x)+7*cos(4*x);

figure
plot(x, y)
xlabel('axis X')
ylabel('axis Y')
title('y = x + 10*sin(5*x) + 7*cos(4*x)')


%% III. initialize population
initPop = initializega(50,[0 9],'fitness');

%% IV. call genetic algorithm
[x endPop bpop trace] = gaot_ga([0 9],'fitness',[],initPop,[1e-6 1 1],'maxGenTerm',25,...
                           'normGeomSelect',0.08,'arithXover',2,'nonUnifMutation',[2 25 3]);


%% V. 输出最优解并绘制最优点
x
hold on
plot (endPop(:,1),endPop(:,2),'ro')

%% VI. 绘制迭代进化曲线
figure(2)
plot(trace(:,1),trace(:,3),'b:')
hold on
plot(trace(:,1),trace(:,2),'r-')
xlabel('Generation'); ylabel('Fittness');
legend('Mean Fitness', 'Best Fitness')

