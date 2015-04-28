% -------------------------------------------------------
% [QP_reform,alg_data] = run_code_gen(QP,opts)
% -------------------------------------------------------
% Generate C code to solve parametric QP:s of the form
%
%           minimize     1/2 x'Hx + g'x + h(Cx)
%           subject to   Ax = b
%
% where:
% - H, C, and A are fixed matrices
% - h is a soft constraint function:
%
%           \          /
%   h(y) =   \        /
%             \______/
%
%   with potentially infinite slopes
% - g and/or b are parameters that may change for each solve
% 
%   if g parametric, then g = G*gt where gt is parameter, else g = G
%   if b parametric, then b = B*bt where bt is parameter, else b = B
% -------------------------------------------------------
% INPUTS: QP (required), opts (optional)
% -------------------------------------------------------
%
% INPUT QP: (required)
%
% ====INDICATORS====
% QP.gt = {0,1}  :  indicates if g is parametric or not
% QP.bt = {0,1}  :  indicates if b is parametric or not
%
% ====DATA====
% QP.H : Hessian H (required)
% QP.G : linear cost matrix G (column vector if QP.gt == 0)
% QP.A : equality constraint matrix A
% QP.B : equality constraint r.h.s. matrix B (column vector if QP.bt == 0)
% QP.C : matrix C (required)
% QP.h.fcn : 'indicator' or '1norm' (required)
% if QP.h.fcn == 'indicator'
%     QP.h.Lb : lower bounds to Cx (required)
%     QP.h.Ub : upper bounds to Cx (required)
%     QP.h.soft : slope for soft constraints for Cx (may be inf)
% if QP.h.fcn == '1norm'
%     QP.h.gamma : scalar uniform soft penalty (required)
%     
%     this is translated to
%         QP.h.fcn == 'indicator'
%         QP.h.Lb = 0
%         QP.h.Ub = 0
%         QP.h.soft = QP.h.gamma
%
%
% INPUT opts: (optional)
%
% - run print_opts(desc) to see available options
%   desc : {0,1} where 1 gives more information, and 0 gives less
% -------------------------------------------------------
% OUTPUTS: QP_reform, alg_data
% -------------------------------------------------------
% QP_reform: 
%  - contains data for reformulated QP
%  - contains original problem in QP_reform.QP
%  - contains chosen options in QP_reform.opts
%
% alg_data:
%  - contains algorithm data
% -------------------------------------------------------
% File generation: QPgen.h (header file)
%                  QPgen.c (main c file with solver qp())
%                  qp_mex.c (mex gateway file)
%                  qp_mex.mex* (compiled mex-file, if mex-compilation works)
% -------------------------------------------------------
% MATLAB usage: [sol,iter] = qp_mex(gt,bt);   (if MPC.gt == 1 and MPC.bt == 1)
%               [sol,iter] = qp_mex(bt);      (if MPC.gt == 0 and MPC.bt == 1)
%               [sol,iter] = qp_mex(gt);      (if MPC.gt == 1 and QP.bt == 0)
% 
% INPUT SIZES: gt = size(QP.G,2)x1, bt = size(QP.B,2)x1
% -------------------------------------------------------
function [QP_reform,alg_data] = run_code_gen(QP,opts)

% checks if 1 or two input arguments
if nargin < 1
    error('not enough input arguments to function');
elseif nargin == 1
    opts = struct;
end

% set default options
opts = set_opts(default_opts(),opts);

% check options
check_opts(opts);

% check data (and manipulate, possibly change this??)
QP = check_data(QP,opts);

% check if algorithm options are compatible with data
if not(opts.fast_gen)
    check_alg_opts(QP,opts);
end

% select algorithm and reformulation (if not already set and if possible)
if not(isfield(opts,'reform')) || not(isfield(opts,'alg')) || not(isfield(opts,'dense'))
    opts = select_alg_reform(QP,opts);
end

% reformulate problem data to equivalent formulation
QP_reform = reform_prob(QP,opts);

% compute preconditioner matrix and select precond method
[E,opts] = compute_preconditioner(QP_reform,opts);

% scale data with preconditioner and set stepsize
QP_reform = scale_data_set_stepsize(QP_reform,E,opts);

% generate data struct needed for chosen algorithm
alg_data = gen_alg_data(QP_reform,opts);

% select stack usage
opts = select_stack_usage(alg_data,opts);


% store original QP formulation and options used to generate QP_reform
QP_reform.QP = QP;
QP_reform.opts = opts;

% generate C code
if isequal(opts.alg,'FGMprimal')
    gen_code_mex_FGMprimal(alg_data,opts)
else
    gen_code_mex(alg_data,opts)
end

% compile source (if mex available)
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