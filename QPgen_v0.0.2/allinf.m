function bool = allinf(M)

bool = (sum(sum(isinf(M))) == size(M,1)*size(M,2));