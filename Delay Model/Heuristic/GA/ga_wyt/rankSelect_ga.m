function [newPop] = rankSelect_ga(oldPop,~)
%rank select is based on hte roulette selection, but reassign the weight
%depends on the fitness value ranking. The weight is used as the probability to select. 
%
%function[newPop] = rankSelect_ga(oldPop,options)
%newPop  - the new population selected from the oldPop
%oldPop  - the current population
%options - options [gen]

%Get the parameters of the population
numVars = size(oldPop,2);
numSols = size(oldPop,1);

oldPop = sortrows(oldPop,2);
%Generate the relative probabilites of selection
% the weight here is set as the reverse ranking, i.e. the last one is 1,
% the second last is 2, etc.
prob = [numSols:-1:1]; 
totalFit = sum(prob);
prob=prob / totalFit; 
prob=cumsum(prob);

rNums=sort(rand(numSols,1)); 		%Generate random numbers

newPop=cell(numSols,numVars);

%Select individuals from the oldPop to the new
fitIn=1;newIn=1;
while newIn<=numSols
  if(rNums(newIn)<prob(fitIn))
    newPop(newIn,:) = oldPop(fitIn,:);
    newIn = newIn+1;
  else
    fitIn = fitIn + 1;
  end
end
end
