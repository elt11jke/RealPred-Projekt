function bool = allzeros(M)

bool = (sum(sum(find(M))) == 0);