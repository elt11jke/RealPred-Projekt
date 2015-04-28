function opts = select_precond_method(M,opts)

n = length(M);

% size of SDP (if small enough)
if length(M) <= 500
    q = rank(full(M));
else
    q = inf;
end

% select preconditioning technique (if not already chosen)
if not(isfield(opts,'precond'))
    if q <= 100 && q/n > 0.35
        opts.precond = 'min_cond_nbr';
    else
        opts.precond = 'jacobi';
    end
end

% select precond alg if min_cond_nbr
 if not(isfield(opts,'min_cond_alg'))
     if q <= 100 && exist('cvx_version.m') == 2
          opts.min_cond_alg = 'cvx';
     else
          opts.min_cond_alg = 'ADMM';
     end
end