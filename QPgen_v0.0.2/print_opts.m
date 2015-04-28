function print_opts(desc)

if nargin < 1 || not(is_bool(desc))
    desc = 0;
end

fprintf('Possible options to send to run_code_gen or change_opts in opts struct:\n\n');

opts = default_opts();

% opts.alg
if desc == 1
    fprintf('Select algorithm:\n');
end
if isfield(opts,'alg')
    str = ['(Default: ''' opts.alg ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n'],'alg',['{''ADMM'',''FGMdual'',''FGMprimal''}'],str);
fprintf(['%20s : %-40s %26s\n'],'',['''ADMM'': ADMM'],'');
fprintf(['%20s : %-40s %26s\n'],'',['''FGMdual'': Fast dual grad method'],'');
fprintf(['%20s : %-40s %26s\n\n'],'',['''FGMprimal'': Fast primal grad method'],'');

% opts.reform
if desc == 1
    fprintf('Select problem formulation:\n');
end
if isfield(opts,'reform')
    str = ['(Default: ''' opts.reform ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n'],'reform',['{''original'',''ineq'',''eq''}'],str);
fprintf(['%20s : %-40s %26s\n'],'',['''original'': Solve original problem formulation'],'');
fprintf(['%20s : %-40s %26s\n'],'',['''ineq'': Reformulate problem in y=Cx'],'');
fprintf(['%20s : %-40s %26s\n\n'],'',['''eq'': Eliminate equality constraints'],'');

% opts.dense
if desc == 1
    fprintf('Select if dense linear algebra or not:\n');
end
if isfield(opts,'dense')
    str = ['(Default: ''' int2str(opts.dense) ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'dense',['{0,1}'],str);

% opts.precond
if desc == 1
    fprintf('Select method to compute preconditioner:\n');
end
if isfield(opts,'precond')
    str = ['(Default: ''' opts.precond ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n'],'precond',['{''min_cond_nbr'',''jacobi'',''equilibration'',''no''}'],str);
fprintf(['%20s : %-40s %26s\n'],'',['''min_cond_nbr'': Minimize condition number'],'');
fprintf(['%20s : %-40s %26s\n'],'',['''jacobi'': Jacobi scaling (= infty-norm equilibration)'],'');
fprintf(['%20s : %-40s %26s\n'],'',['''equilibration'': 1-norm equilibration'],'');
fprintf(['%20s : %-40s %26s\n\n'],'',['''no'': No preconditioning'],'');

% opts.precision_Hess
if desc == 1
    fprintf('Select Hessian matrix to precondition (only for FGMdual, ADMM):\n');
end
if isfield(opts,'precond_Hess')
    str = ['(Default: ''' opts.precond_Hess ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n'],'precond_Hess',['{''K11'',''Hinv''}'],str);
fprintf(['%20s : %-40s %26s\n'],'',['''K11'': use K11 where [K11 K12'';K12 K22] = inv([H A'';A 0])'],'');
fprintf(['%20s : %-40s %26s\n\n'],'',['''Hinv'': use inv(H)'],'');

% opts.min_cond_alg
if desc == 1
    fprintf('Select algorithm to perform pseudo condition number minimization:\n');
end
if isfield(opts,'min_cond_alg')
    str = ['(Default: ''' opts.min_cond_alg ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n'],'min_cond_alg',['{''cvx'',''ADMM''}'],str);
fprintf(['%20s : %-40s %26s\n'],'',['''cvx'': Use CVX (need CVX installed)'],'');
fprintf(['%20s : %-40s %26s\n\n'],'',['''ADMM'': at beta-stage, not always fully functional'],'');

% opts.min_cond_rel_tol
if desc == 1
    fprintf('Select relative tolerance for ADMM-alg that minimizes pseudo condition number:\n');
end
if isfield(opts,'min_cond_rel_tol')
    str = ['(Default: ' num2str(opts.min_cond_rel_tol) ')'];
else
    str = '(Default: Chosen by logic)';
end
fprintf(['%20s : %-40s %26s\n\n'],'min_cond_rel_tol','> 0 ',str);

% opts.precision
if desc == 1
    fprintf('Select data precision:\n');
end
if isfield(opts,'precision')
    str = ['(Default: ''' opts.precision ''')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'precision',['{''double'',''float''}'],str);

% opts.no_math_lib
if desc == 1
    fprintf('Select if no math library should be use (only for FGM*, ADMM does not use math.h):\n');
end
if isfield(opts,'no_math_lib')
    str = ['(Default: ' int2str(opts.no_math_lib) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'no_math_lib',['{0,1}'],str);


% opts.fast_gen
if desc == 1
    fprintf('Fast generation: 0: normal gen, 1: faster param. sel., 2: no data checks, 3: 1 and 2 \n(if using fast_gen == 2 and fast_gen == 3, make sure data and opts can be used to solve alg):\n');
end
if isfield(opts,'fast_gen')
    str = ['(Default: ' int2str(opts.fast_gen) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'fast_gen','{0,1,2,3}',str);



% opts.stack_usage
if desc == 1
    fprintf('Selects how much to use stack (0: data, vars on heap, 1: data on heap, 2: data, vars on stack)\nMake sure there is enough space on stack if stack_usage > 0:\n');
end
if isfield(opts,'stack_usage')
    str = ['(Default: ' int2str(opts.stack_usage) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'stack_usage','{0,1,2}',str);



% opts.sparsity_threshold
if desc == 1
    fprintf('Selects the threshold for sparse matrices:\n');
end
if isfield(opts,'sparsity_threshold')
    str = ['(Default: ' num2str(opts.sparsity_threshold) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'sparsity_threshold','(0,1)',str);


% opts.rel_tol
if desc == 1
    fprintf('Select relative tolerance:\n');
end
if isfield(opts,'rel_tol')
    str = ['(Default: ' num2str(opts.rel_tol) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'rel_tol','> 0 ',str);


% opts.max_iter
if desc == 1
    fprintf('Select max number of iterations:\n');
end
if isfield(opts,'max_iter')
    str = ['(Default: ' num2str(opts.max_iter) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'max_iter','(int) > 0 ',str);


% opts.check_opt_interval
if desc == 1
    fprintf('Select with what interval optimality conditions are checked:\n');
end
if isfield(opts,'check_opt_interval')
    str = ['(Default: ' num2str(opts.check_opt_interval) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'check_opt_interval','(int) > 0 ',str);



% opts.proj_name
if desc == 1
    fprintf('Select proj_name (generated files end up in folder "proj_name"_files):\n');
end
if isfield(opts,'proj_name')
    str = ['(Default: ' opts.proj_name ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'proj_name','(string) ',str);



% opts.restart
if desc == 1
    fprintf('Select if adaptive restart is used (only for FGM*):\n');
end
if isfield(opts,'restart')
    str = ['(Default: ' num2str(opts.restart) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'restart','{0,1}',str);


% opts.alpha_relax
if desc == 1
    fprintf('Select relaxation parameter in ADMM:\n');
end
if isfield(opts,'alpha_relax')
    str = ['(Default: ' num2str(opts.alpha_relax) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'alpha_relax','(0,2]',str);


% opts.rho
if desc == 1
    fprintf('Select step-size parameter (rho) in ADMM:\n');
end
if isfield(opts,'rho')
    str = ['(Default: ' num2str(opts.rho) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'rho','> 0',str);


% opts.t
if desc == 1
    fprintf('Select step-size parameter (t) in FGM*:\n');
end
if isfield(opts,'t')
    str = ['(Default: ' num2str(opts.t) ')'];
else
    str = '(Default: Data dependent)';
end
fprintf(['%20s : %-40s %26s\n\n'],'t','> 0 (> 1 might cause unstable algorithm)',str);



% defaults options
fprintf('Default options can be changed in ''default_opts.m''\n');