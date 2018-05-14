%% I. clear memory and screen
clear all
clc

%% II. generate problem
x = -5:0.01:5;
y = -5:0.01:5;
z = 20+x.^2+y.^2-10*(cos(2*pi*x)+cos(2*pi*y));

%% III. initialize population
initPop = initializega(50,[-5,5;-5,5],'fitness');

%% IV. call genetic algorithm
[x endPop bpop trace] = gaot_ga([-5,5;-5,5],'fitness',[],initPop,[1e-6 1 1],'maxGenTerm',25,...
                           'normGeomSelect',0.08,'arithXover',2,'nonUnifMutation',[2 25 3]);


%% V. output the optimal solution found by gaot_ga
x

%% VI. convergence figure
plot(trace(:,1),trace(:,3),'b:')
hold on
plot(trace(:,1),trace(:,2),'r-')
xlabel('Generation'); ylabel('Fittness');
legend('Mean Fitness', 'Best Fitness')

