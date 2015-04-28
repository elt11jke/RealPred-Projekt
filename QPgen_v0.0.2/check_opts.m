function check_opts(opts)

% check sparsity_threshold
if not(is_real_scalar(opts.sparsity_threshold))
    error('opts.sparsity_threshold must be a real scalar');
elseif opts.sparsity_threshold < 0 || opts.sparsity_threshold > 1
    error('opts.sparsity_threshold must be between 0 and 1');
end


% check max_iter
if not(is_int(opts.max_iter))
    error('opts.max_iter must be a real integer');
elseif opts.max_iter <= 0
    error('opts.max_iter must be positive');
end


% check optimality tolerance
if not(is_real_scalar(opts.rel_tol))
    error('opts.rel_tol must be a real scalar');
elseif opts.rel_tol <= 0
    error('opts.rel_tol must be positive');
end

    
% check optimality condition check interval
if not(is_int(opts.check_opt_interval))
    error('opts.check_opt_interval must be a real integer');
elseif opts.check_opt_interval <= 0
    error('opts.check_opt_interval must be positive');
end


% check alpha_relaxation parameter for ADMM
if not(is_real_scalar(opts.alpha_relax))
    error('opts.alpha_relax must be a real integer');
elseif opts.alpha_relax <= 0 || opts.alpha_relax > 2
    error('opts.alpha_relax be between 0 and 2');
end

% check preconditioning 
if isfield(opts,'precond')
    if not(isequal(opts.precond,'no')) && not(isequal(opts.precond,'jacobi')) && not(isequal(opts.precond,'equilibration')) && not(isequal(opts.precond,'min_cond_nbr'))
        error(['opts.precond must be ' '''no''' ', ' '''jacobi''' ', ' '''equilibration''' ', or ' '''min_cond_nbr''']);
    end
end


% check relative tolerance
if not(is_real_scalar(opts.rel_tol))
    error('opts.rel_tol must be a real integer');
elseif opts.rel_tol <= 0
    error('opts.rel_tol be positive');
end

% check precision
if not(isequal(opts.precision,'double')) && not(isequal(opts.precision,'float'))
    error(['opts.precision must be ' '''double''' ' or ' '''float''']);
end

% check precond Hessian
if not(isequal(opts.precond_Hess,'K11')) && not(isequal(opts.precond_Hess,'Hinv'))
    error(['opts.precond_Hess must be ' '''K11''' ' or ' '''Hinv''']);
end

% check rho
if not(is_real_scalar(opts.rho))
    error('opts.rho must be a real scalar');
elseif opts.rho <= 0
    error('opts.rho must be positive');
end

% check t
if not(is_real_scalar(opts.t))
    error('opts.t must be a real scalar');
elseif opts.t <= 0
    error('opts.t must be positive');
elseif opts.t > 1
    warning('opts.t > 1 might result in a non converging algorithm');
end

% check precond
if isfield(opts,'precond')
    if not(isequal(opts.precond,'no')) && not(isequal(opts.precond,'jacobi')) && not(isequal(opts.precond,'equilibration')) && not(isequal(opts.precond,'min_cond_nbr'))
        error(['opts.precond must be either ' '''no''' ', ' '''jacobi''' ', ' '''equilibration''' ', or ' '''min_cond_nbr''']);
    end
end

% check min_cond_alg
if isfield(opts,'min_cond_alg')
    if not(isequal(opts.min_cond_alg,'ADMM')) && not(isequal(opts.min_cond_alg,'cvx'))
        error(['opts.min_cond_alg must be either ' '''ADMM''' ' or ' '''cvx''']);
    end
end


% check no_math_lib
if not(is_bool(opts.no_math_lib))
    error('opts.no_math_lib must be 0 or 1');
end


% check min_cond_rel_tol
if not(is_real_scalar(opts.min_cond_rel_tol))
    error('opts.min_cond_rel_tol must be a real scalar');
elseif opts.min_cond_rel_tol <= 0
    error('opts.min_cond_rel_tol must be positive');
end


% check fast_gen
if not(opts.fast_gen == 0) && not(opts.fast_gen == 1) && not(opts.fast_gen == 2) && not(opts.fast_gen == 3)
    error('opts.fast_gen must be 0, 1, 2, or 3');
end


% check stack_usage
if isfield(opts,'stack_usage')
    if not(opts.stack_usage == 0 || opts.stack_usage == 1 || opts.stack_usage == 2)
        error('opts.stack_usage must be 0, 1, or 2');
    end
end


% check proj_name
if not(ischar(opts.proj_name))
    error('opts.proj_name must be a string');
end
