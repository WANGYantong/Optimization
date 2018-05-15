function [matrix] = encoding_ga(vector,size_mat)
%ENCODING  vector -> binary matrix
row=size_mat(1);
column=size_mat(2);

matrix=zeros(row,column);

for ii=1:row
    matrix(ii,vector(ii))=1;
end

end

