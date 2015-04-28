function opts = set_opts(default_opts,opts)

% return default options
if nargin < 2 
    opts = [];
end
if isempty(opts)
    opts = default_opts;
    return
end


if not(isfield(opts,'sparsity_threshold'));
    opts.sparsity_threshold = default_opts.sparsity_threshold;
end
if not(isfield(opts,'parallelize'))
    opts.parallelize = default_opts.parallelize;
end
if not(isfield(opts,'flat'))
    opts.flat = default_opts.flat;
end
if not(isfield(opts,'alpha_relax'))
    opts.alpha_relax = default_opts.alpha_relax;
end
if not(isfield(opts,'max_iter'))
    opts.max_iter = default_opts.max_iter;
end
if not(isfield(opts,'rel_tol'))
    opts.rel_tol = default_opts.rel_tol;
end
if not(isfield(opts,'check_opt_interval'))
    opts.check_opt_interval = default_opts.check_opt_interval;
end
if not(isfield(opts,'restart'))
    opts.restart = default_opts.restart;
end
if not(isfield(opts,'precision'))
    opts.precision = default_opts.precision;
end
if not(isfield(opts,'precond_Hess'))
    opts.precond_Hess = default_opts.precond_Hess;
end
if not(isfield(opts,'rho'))
    opts.rho = default_opts.rho;
end
if not(isfield(opts,'t'))
    opts.t = default_opts.t;
end
