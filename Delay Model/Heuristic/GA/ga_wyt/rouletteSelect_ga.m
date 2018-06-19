function [newPop] = rouletteSelect_ga(oldPop,options)
%roulette is the traditional selection function with the probability of
%surviving equal to the fittness of inv / sum(inv) of the fittness of all individuals
%
%function[newPop] = rouletteSelect_ga(oldPop,options)
%newPop  - the new population selected from the oldPop
%oldPop  - the current population
%options - options [gen]

%Get the parameters of the population
numVars = size(oldPop,2);
numSols = size(oldPop,1);

%Generate the relative probabilites of selection
totalFit = sum(1./oldPop(:,numVars));
prob=(1./oldPop(:,numVars)) / totalFit; 
prob=cumsum(prob);

rNums=sort(rand(numSols,1)); 		%Generate random numbers

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

