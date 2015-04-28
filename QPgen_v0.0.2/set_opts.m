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
if not(isfield(opts,'no_math_lib'))
    opts.no_math_lib = default_opts.no_math_lib;
end
if not(isfield(opts,'min_cond_rel_tol'))
    opts.min_cond_rel_tol = default_opts.min_cond_rel_tol;
end
if not(isfield(opts,'fast_gen'))
    opts.fast_gen = default_opts.fast_gen;
end
if not(isfield(opts,'proj_name'))
    opts.proj_name = default_opts.proj_name;
end