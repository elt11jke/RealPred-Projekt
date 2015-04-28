function bool = is_real_scalar(a)

bool = (isnumeric(a) && isreal(a) && (length(a) == 1) && isfinite(a));