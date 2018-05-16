function [sol, fitnessVal] = fitness(sol, options)

global data;

fitnessVal=NEC_mod(sol,data);

end

