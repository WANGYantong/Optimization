function [vector] = decoding_ga(matrix)
%DECODING_GA  binary matrix -> vector

row=size(matrix,1);

vector=zeros(row,1);

for ii=1:row
    vector(ii)=find(matrix(ii,:));
end

end

