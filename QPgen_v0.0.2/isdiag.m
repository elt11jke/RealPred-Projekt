function b = isdiag(A)

b = (size(A,1) == size(A,2)) && isequal(diag(diag(A)),A);