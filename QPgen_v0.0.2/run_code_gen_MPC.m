% -------------------------------------------------------
% [QP_reform,alg_data] = run_code_gen_MPC(MPC,opts)
% Actions:
%  - reformulates MPC problem in struct MPC to QP problem in struct QP
%  - runs: run_code_gen(QP,opts)
% -------------------------------------------------------
% Generate C code to solve parametric MPC problems of the form
%
%                N - 1
%              1  --                                         1  
%  minimize    -  \  (x(t)'Qx(t)+u(t)'Ru(t)+q'x(t)+r'u(t)) + - x(N)'Qfx(N)
%              2  /                                          2
%                 --
%                t = 0
%
%  subject to  x(t+1) = Adyn*x(t) + Bdyn*u(t)      t = 0,...,N-1
%              Cx*x(t) in X                        t = 0,...,N
%              Cu*u(t) in U                        t = 0,...,N-1
%              x(0) = bt
% 
%  ===Reformulate as QP===
%
%           minimize     1/2 x'Hx + g'x + h(Cx)
%           subject to   Ax = bt
%
%   where x = [x(1);...;x(N);u(0);...;u(N-1)];
%
%   if g parametric, g = gt, else g = [q;...;q;r;...;r]
%   bt is always parametric
% -------------------------------------------------------
% INPUTS: MPC (required), opts (optional)
% -------------------------------------------------------
%
% INPUT MPC: (required)
%
% ====INDICATORS====
% MPC.gt = {0,1}  :  indicates if linear cost is parametric or not
%
% ====DATA====
% MPC.Q : quadratic state cost matrix
% MPC.Qf : terminal cost matrix (set to MPC.Q if abscent)
% MPC.q : linear state cost (vector if MPC.gt == 0, else abscent)
% MPC.R : quadratic input cost matrix
% MPC.r : linear input cost (vector if MPC.gt == 0, else abscent)
% MPC.Adyn : dynamics matrix
% MPC.Bdyn : input matrix
% MPC.Cx : matrix defining state constraints
% MPC.Cu : matrix defining input constraints
% MPC.X : specification of constraints for Cx*x(t), i.e., Cx*x(t)\in X
% MPC.X.Lb : lower bounds on Cx*x(t)
% MPC.X.Ub : upper bounds on Cx*x(t)
% MPC.X.soft : linear penalty for soft constraints on Cx*x(t) (may be inf)
% MPC.U : specification of constraints fo Cu*u(t), i.e., Cu*u(t)\in U
% MPC.U.Lb : lower bounds on Cu*u(t)
% MPC.U.Ub : upper bounds on Cu*u(t)
% MPC.U.soft : linear penalty for soft constraints on Cu*u(t) (may be inf)
% MPC.N : control and prediction horizion
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
% MATLAB usage: [sol,iter] = qp_mex(gt,bt);     (if MPC.gt == 1)
%               [sol,iter] = qp_mex(bt);        (if MPC.gt == 0)
% 
% INPUT SIZES: gt : N*(length(MPC.Q)+length(MPC.R))x1
%              bt : length(Adyn)x1
% -------------------------------------------------------
function [QP_reform,alg_data] = run_code_gen_MPC(MPC,opts)


% checks if 1 or two input arguments
if nargin < 1
    error('not enough input arguments to function');
elseif nargin == 1
    opts = struct;
end

% form QP from MPC data
QP = MPC_to_QP(MPC);
QP

QP.MPC = MPC;

% run code generator
[QP_reform,alg_data] = run_code_gen(QP,opts);