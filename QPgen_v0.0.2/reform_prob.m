function QP_reform = reform_prob(QP,opts)

fprintf('Reformulating problem....');

% ADD FLAG THAT SAYS IF PROBLEM STRONGLY CONVEX. ONLY INTERESTING FOR
% GRADIENT METHOD!!!

if isequal(opts.reform,'original')
    
   QP_reform = QP;
   
   % store general format data
   QP_reform.Gg = QP.G;
   QP_reform.Gb = [];
   
   % reconstruction matrices
   n = length(QP.H);
   
   % for FGMprimal since primal variables precond
   QP_reform.R = speye(n,n);
   
elseif isequal(opts.reform,'ineq')
   
    %QP_reform = QP;
    
    n = size(QP.H,1);
    m = size(QP.A,1);
    p = size(QP.C,1);
    
    % use sparse backsolve!? no, want result dense!
    K = [QP.H QP.A' QP.C';QP.A zeros(m,m+p);
        QP.C zeros(p,m+p)]\eye(n+p+m);

    K11 = K(1:n,1:n);
    K12 = K(1:n,n+1:n+m);
    K13 = K(1:n,1+n+m:end);
    
    QP_reform.H = K13'*QP.H*K13;
    QP_reform.Gg = K13'*(eye(n)-QP.H*K11)*QP.G;
    QP_reform.Gb = K13'*QP.H*K12*QP.B;
    QP_reform.C = eye(p);
    QP_reform.h.Lb = QP.h.Lb;
    %QP_reform.L2 = 0;
    QP_reform.h.Ub = QP.h.Ub;
    QP_reform.h.soft = QP.h.soft;
    QP_reform.A = [];
    QP_reform.B = [];
    QP_reform.G = QP.G;
    QP_reform.B = QP.B;
    
    QP_reform.bt = QP.bt;
    QP_reform.gt = QP.gt;
    %QP_reform.U2 = 0;
    
    % reconstruction matrices
    QP_reform.r1 = -K11*QP.G;
    QP_reform.r2 = K12*QP.B;
    QP_reform.R = K13;
    
elseif isequal(opts.reform,'eq')
    
    %QP_reform = QP;
    
    n = size(QP.H,1);
    m = size(QP.A,1);
    p = size(QP.C,1);
    

    % check if [H A';A 0] is invertible 
    % (otherwise regularize to make regularization invertible)
    if isinvertible([QP.H QP.A';QP.A zeros(m,m)]) %sum(eig([QP.H QP.A';QP.A zeros(m,m)]) > 1e-7) == m+n
        S = [QP.H QP.A';QP.A zeros(m,m)]\eye(n+m);
    else
        S = [QP.H+1e-5*eye(n) QP.A';QP.A zeros(m,m)]\eye(n+m);
    end
    
    S11 = S(1:n,1:n);
    S12 = S(1:n,1+n:end);
    if isfield(QP,'MPC')
        N = nullspace(QP.A,QP.MPC);
    else
        N = null(full(QP.A));
    end
    QP_reform.H = N'*QP.H*N;
    QP_reform.Gg = N'*(eye(n)-QP.H*S11)*QP.G;
    QP_reform.Gb = N'*QP.H*S12*QP.B;
    QP_reform.C = QP.C*N;
    QP_reform.h.Lb = QP.h.Lb;
    QP_reform.h.L1 = -QP.C*S11*QP.G;
    QP_reform.h.L2 = QP.C*S12*QP.B;
    QP_reform.h.Ub = QP.h.Ub;
    QP_reform.h.U1 = QP_reform.h.L1;
    QP_reform.h.U2 = QP_reform.h.L2;
    QP_reform.h.soft = QP.h.soft;
    QP_reform.A = [];
    QP_reform.B = [];
    QP_reform.G = QP.G;
    QP_reform.B = QP.B;
    
    QP_reform.bt = QP.bt;
    QP_reform.gt = QP.gt;
    
    % reconstruction matrices
    QP_reform.r1 = -S11*QP.G;
    QP_reform.r2 = S12*QP.B;
    QP_reform.R = N;
    
end

QP_reform = set_sparse(QP_reform,opts.sparsity_threshold);

fprintf('done!\n');