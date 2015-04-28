function bool = allfinite(M)

bool = (sum(sum(isinf(M))) == 0);