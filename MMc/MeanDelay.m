function [f]=MeanDelay(lambda, c, mu)

f1 = lambda.^c/(factorial(c)*mu^c);
f2 = (1-lambda./(c*mu)).*SumQueue(lambda, c, mu)+ f1;
f3 = c*mu-lambda;

f = f1./(f2.*f3);

end
