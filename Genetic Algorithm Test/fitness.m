function [sol, fitnessVal] = fitness(sol, options)

x = sol(1);
y = sol(2);

fitnessVal =-(20+x.^2+y.^2-10*(cos(2*pi*x)+cos(2*pi*y)));

end

