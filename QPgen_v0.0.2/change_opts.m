% -------------------------------------------------------
% [QP_reform,alg_data] = change_opts(QP_reform,alg_data,opts)
%  - regenerate code with new options specified in opts
% -------------------------------------------------------
% 
% INPUTS: QP_reform, alg_data, opts
%
%  - QP_reform: output from run_code_gen or run_code_gen_MPC
%  - alg_data: output from run_code_gen or run_code_gen_MPC
%  - opts: struct with options (see print_opts() for available options)
%
% -------------------------------------------------------
%
% ACTION:
%
%  performs, using the new options specified in opts, a cheaper way to rerun:
%
%       [QP_reform,alg_data] = run_code_gen(QP,opts)
%
%  or 
%
%       [QP_reform,alg_data] = run_code_gen_MPC(MPC,opts)
%
%  where QP or MPC are the structs used to generate QP_reform and alg_data
%
%  (for fields in opts that are missing, the original options are used)
%
% -------------------------------------------------------
% 
% OUTPUTS: QP_reform, alg_data
%
%  - QP_reform: can be used to again update generated code using change_opts
%  - alg_data: can be used to again update generated code using change_opts
%
% -------------------------------------------------------
function [QP_reform,alg_data] = change_opts(QP_reform,alg_data,opts)

% store original QP formulation
QP = QP_reform.QP;

% store previous options
prev_opts = QP_reform.opts;

% store previous preconditioner
Eprev = QP_reform.E;

% compare options in opts and in QP_reform.opts
opts = set_opts(prev_opts,opts);

% checking that options OK
check_opts(opts);


% compare and set remaining options...!!!
if isfield(opts,'alg') && not(isequal(opts.alg,prev_opts.alg))
    new_alg = 1;
else
    opts.alg = prev_opts.alg;
    new_alg = 0;
end
if isfield(opts,'reform') && not(isequal(opts.reform,prev_opts.reform))
    new_reform = 1;
else
    opts.reform = prev_opts.reform;
    new_reform = 0;
end
if isfield(opts,'dense') && not(isequal(opts.dense,prev_opts.dense))
    new_dense = 1;
else
    opts.dense = prev_opts.dense;
    new_dense = 0;
end
if isfield(opts,'min_cond_alg') && not(isequal(opts.min_cond_alg,prev_opts.min_cond_alg))
    new_min_cond_alg = 1;
else
    opts.min_cond_alg = prev_opts.min_cond_alg;
    new_min_cond_alg = 0;
end
if isfield(opts,'min_cond_rel_tol') && not(isequal(opts.min_cond_rel_tol,prev_opts.min_cond_rel_tol))
    new_min_cond_rel_tol = 1;
else
    opts.min_cond_rel_tol = prev_opts.min_cond_rel_tol;
    new_min_cond_rel_tol = 0;
end
if isfield(opts,'precond') && not(isequal(opts.precond,prev_opts.precond))
    new_precond = 1;
else
    opts.precond = prev_opts.precond;
    new_precond = 0;
end
if isequal(opts.precond_Hess,prev_opts.precond_Hess)
    new_precond_Hess = 0;
else
    new_precond_Hess = 1;
end
if isfield(opts,'stack_usage') && not(isequal(opts.stack_usage,prev_opts.stack_usage))
    new_stack_usage = 1;
else
    opts.stack_usage = prev_opts.stack_usage;
    new_stack_usage = 0;
end

% check algorithm options
if new_alg || new_reform || new_dense
    % check if algorithm options are compatible with data
    check_alg_opts(QP,opts);
end

if new_reform || new_alg || new_dense || new_precond || new_precond_Hess || new_min_cond_alg || (new_min_cond_rel_tol && isequal(opts.min_cond_alg,'ADMM'))
    
    % recompute reformulation from original problem
    QP_reform = reform_prob(QP,opts);

    % different logic that desides if a new preconditioner must be computed
    % (to save computation)

    % we only have three different preconditioners WRITE SOMEWHERE!
    % check if change to or from two implies we do not have to test third
    
    if isequal(opts.precond,'min_cond_nbr')
        % a test for new preconditioning
        test_precond = @(opts) (isequal(opts.reform,'original') && isequal(opts.precond_Hess,'Hinv'));
        if new_precond || new_precond_Hess || new_min_cond_alg || (new_min_cond_rel_tol && isequal(opts.min_cond_alg,'ADMM'))
            E = compute_preconditioner(QP_reform,opts);
        elseif new_reform && ((isequal(opts.reform,'ineq') && not(isequal(prev_opts.reform,'ineq'))) || (not(isequal(opts.reform,'ineq')) && isequal(prev_opts.reform,'ineq')))
            E = compute_preconditioner(QP_reform,opts);
        elseif (test_precond(opts) && not(test_precond(prev_opts)) || (not(test_precond(opts)) && test_precond(prev_opts)))
            E = compute_preconditioner(QP_reform,opts);
        else
            E = Eprev;
        end
    else
        E = compute_preconditioner(QP_reform,opts);
    end

    % invert preconditioner if changing from or to FGMprimal
    if new_alg && (isequal(opts.alg,'FGMprimal') || isequal(prev_opts.alg,'FGMprimal'))
        %E = E\eye(length(E));
        E = spdiags(1./diag(E),0,length(E),length(E));
    end

    % scale data in QP_reform (also fixes poential updated step-sizes)
    QP_reform = scale_data_set_stepsize(QP_reform,E,opts);

    % restore original QP and opts
    QP_reform.QP = QP;
    QP_reform.opts = opts;
    
    % generate data struct needed for chosen algorithm
    alg_data = gen_alg_data(QP_reform,opts);
    opts.gen_data = 1;
    
elseif (not(isequal(opts.rho,prev_opts.rho)) && isequal(opts.alg,'ADMM')) || (not(isequal(opts.t,prev_opts.t)) && (isequal(opts.alg,'FGMdual') || isequal(opts.alg,'FGMprimal')))
    
    % scale matrices with new step-size (the
    % correct E must be stored and reinserted into QP_reform, multiplied the new step-size)
    E = QP_reform.E;
    QP_reform = scale_data_set_stepsize(QP_reform,eye(size(QP_reform.E)),opts);
    if isequal(opts.alg,'ADMM')
        QP_reform.E = sqrt(opts.rho)*QP_reform.scaling*E;
    elseif isequal(opts.alg,'FGMdual') || isequal(opts.alg,'FGMprimal')
        QP_reform.E = sqrt(opts.t)*QP_reform.scaling*E;
    end
    
    % restore original QP and opts
    QP_reform.QP = QP;
    QP_reform.opts = opts;
    
    % generate data struct needed for chosen algorithm
    alg_data = gen_alg_data(QP_reform,opts);
    opts.gen_data = 1;
elseif not(isequal(opts.precision,prev_opts.precision)) || not(isequal(opts.stack_usage,prev_opts.stack_usage)) || not(isequal(opts.proj_name,prev_opts.proj_name))
    opts.gen_data = 1;
else
    opts.gen_data = 0;
end

% generate C code
if isequal(opts.alg,'FGMprimal')
    gen_code_mex_FGMprimal(alg_data,opts)
else
    gen_code_mex(alg_data,opts)
end

% compile generated code
try
    if opts.stack_usage == 2
        eval(['mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/QPgen.c']);
    elseif opts.stack_usage == 1
        eval(['mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/free_data.c']);
    elseif opts.stack_usage == 0
        eval(['mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/init_work_space.c ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/free_data.c ' opts.proj_name '_files/free_work_space.c']);
    end
    exit_message(QP,opts);
catch me
    exit_message_no_mex(QP,opts);
end
