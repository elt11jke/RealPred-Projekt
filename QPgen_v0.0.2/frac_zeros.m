function p = frac_zeros(A)

p = length(find(A~=0))/(size(A,1)*size(A,2));