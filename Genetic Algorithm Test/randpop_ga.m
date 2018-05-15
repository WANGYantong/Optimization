function [matrix] = randpop_ga(size_mat)
%RANDPOP_GA generate a random binary matrix where only one bit in each row
%           has value 1, the size of matrix is determined by size_mat

m=size_mat(1);
n=size_mat(2);

matrix=zeros(m,n);
for ii=1:m
    rand_pos = randi([1, n]);
    matrix(ii,rand_pos)=1;
end

end

