function opts = default_opts()

% return default options

opts.sparsity_threshold = 0.65;
opts.alpha_relax = 1.85;
opts.max_iter = 2000;
opts.rel_tol = 1e-3;
opts.check_opt_interval = 10;
opts.restart = 1;
opts.precision = 'double';
opts.precond_Hess = 'K11';
opts.rho = 1;
opts.t = 1;
opts.no_math_lib = 0;
opts.min_cond_rel_tol = 2e-5;
opts.fast_gen = 0;
opts.proj_name = 'qp';