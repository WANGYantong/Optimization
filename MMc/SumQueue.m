function [f] = SumQueue(lambda, c, mu)

f=0;

for n=0:(c-1)
    f=f+lambda.^n/(factorial(n)*mu^n);

end