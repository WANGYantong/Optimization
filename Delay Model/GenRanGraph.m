clear;

size = 55;

%generate random matrix
randomMatrix = randi([0 1], size,size);
%make it symmetric
randomMatrix = triu(randomMatrix) + triu(randomMatrix,1)';
%make digonal of the matrix zero
randomMatrix = randomMatrix & xor(diag(ones(1,size)),ones(size,size));

G = graph(randomMatrix);
plot(G);
i=1;