% creates as QP problem from MPC problem data

function QP = MPC_to_QP(MPC)

% check MPC data
MPC = check_MPC_data(MPC);

% store data dimension and check compatibility
n = size(MPC.Q,1);
m = size(MPC.R,1);
px = size(MPC.Cx,1);
pu = size(MPC.Cu,1);

% store identity matrix in I
I = speye(n);

% create empty matrices that stack MPC optimization problem data
Qblk = sparse(n*MPC.N,n*MPC.N);              % Qblk = blkdiag(Q,...,Q)
Rblk = sparse(m*MPC.N,m*MPC.N);              % Rblk = blkdiag(R,...,R)
if not(isempty(MPC.q))
    qvec = zeros(n*MPC.N,1);                     % qvec = [q;...;q]
else
    qvec = [];
end
if not(isempty(MPC.r))
    rvec = zeros(m*MPC.N,1);                     % rvec = [r;...;r]
else
    rvec = [];
end
Adyn_blk = sparse(n*MPC.N,n*MPC.N);          % [Adyn_blk Bdyn_blk]*y = D_dyn*bt
Bdyn_blk = sparse(n*MPC.N,m*MPC.N);
Beq = [-MPC.Adyn;sparse(n*(MPC.N-1),n)];
if not(isempty(MPC.Cx))
    Cx_blk = sparse(px*MPC.N,n*MPC.N);
else
    Cx_blk = [];
end
if not(isempty(MPC.X.Lb))
    Lbx_vec = zeros(px*MPC.N,1);
else
    Lbx_vec = [];
end
if not(isempty(MPC.X.Ub))
    Ubx_vec = zeros(px*MPC.N,1);
else
    Ubx_vec = [];
end
if not(isempty(MPC.X.soft))
    X_soft = zeros(px*MPC.N,1);
else
    if isfield(MPC,'X')
        X_soft = inf*ones(px*MPC.N,1);
    else
        X_soft = [];
    end
end
if not(isempty(MPC.Cu))
    Cu_blk = zeros(pu*MPC.N,m*MPC.N);
else
    Cu_blk = [];
end
if not(isempty(MPC.U.Lb))
    Lbu_vec = zeros(pu*MPC.N,1);
else
    Lbu_vec = [];
end
if not(isempty(MPC.U.Ub))
    Ubu_vec = zeros(pu*MPC.N,1);
else
    Ubu_vec = [];
end
if not(isempty(MPC.U.soft))
    U_soft = zeros(pu*MPC.N,1);
else
    if isfield(MPC,'U')
        U_soft = inf*ones(pu*MPC.N,1);
    else
        U_soft = [];
    end
end

% create matrices that describe the optimization problem

for jj = 0:MPC.N-1
    idx_n_start = jj*n+1;
    idx_n_stop = (jj+1)*n;
    idx_m_start = jj*m+1;
    idx_m_stop = (jj+1)*m;
    idx_px_start = jj*px+1;
    idx_px_stop = (jj+1)*px;
    idx_pu_start = jj*pu+1;
    idx_pu_stop = (jj+1)*pu;
    
    if jj < MPC.N-1
        Qblk(idx_n_start:idx_n_stop,idx_n_start:idx_n_stop) = MPC.Q;
    end
    if jj == MPC.N-1
        Qblk(idx_n_start:idx_n_stop,idx_n_start:idx_n_stop) = MPC.Qf;
    end
    Rblk(idx_m_start:idx_m_stop,idx_m_start:idx_m_stop) = MPC.R;
    if not(isempty(MPC.q))
        qvec(idx_n_start:idx_n_stop) = MPC.q;
    end
    if not(isempty(MPC.r))
        rvec(idx_m_start:idx_m_stop) = MPC.r;
    end
    Adyn_blk(idx_n_start:idx_n_stop,idx_n_start:idx_n_stop) = -I;
    if jj ~= 0
        Adyn_blk(idx_n_start:idx_n_stop,idx_n_start-n:idx_n_stop-n) = MPC.Adyn;
    end
    Bdyn_blk(idx_n_start:idx_n_stop,idx_m_start:idx_m_stop) = MPC.Bdyn;
        
    if not(isempty(MPC.Cx))
        Cx_blk(idx_px_start:idx_px_stop,idx_n_start:idx_n_stop) = MPC.Cx;
    end
    if not(isempty(MPC.X.Lb))
        Lbx_vec(idx_px_start:idx_px_stop) = MPC.X.Lb;
    end
    if not(isempty(MPC.X.Ub))
        Ubx_vec(idx_px_start:idx_px_stop) = MPC.X.Ub;
    end
    if not(isempty(MPC.X.soft)) && isfield(MPC,'X')
        X_soft(idx_px_start:idx_px_stop) = MPC.X.soft;
    end
    
    
    if not(isempty(MPC.Cu))
        Cu_blk(idx_pu_start:idx_pu_stop,idx_m_start:idx_m_stop) = MPC.Cu;
    end
    if not(isempty(MPC.U.Lb))
        Lbu_vec(idx_pu_start:idx_pu_stop) = MPC.U.Lb;
    end
    if not(isempty(MPC.U.Ub))
        Ubu_vec(idx_pu_start:idx_pu_stop) = MPC.U.Ub;
    end
    if not(isempty(MPC.U.soft)) && isfield(MPC,'U')
        U_soft(idx_pu_start:idx_pu_stop) = MPC.U.soft;
    end
    
end

% create QP data struct

QP.H = blkdiag(Qblk,Rblk);
if MPC.gt == 0
    QP.G = [qvec;rvec];
else
    QP.G = speye(length(QP.H));
end
QP.gt = MPC.gt;
QP.A = [Adyn_blk Bdyn_blk];
QP.B = Beq;
Cx_blk_fill = sparse(pu*MPC.N,n*MPC.N);
Cu_blk_fill = sparse(px*MPC.N,m*MPC.N);
QP.C = [Cx_blk Cu_blk_fill;Cx_blk_fill Cu_blk];
%QP.C = blkdiag(Cx_blk,Cu_blk);        
QP.h.fcn = 'indicator';
QP.h.Lb = [Lbx_vec;Lbu_vec];
QP.h.Ub = [Ubx_vec;Ubu_vec];
QP.h.soft = [X_soft;U_soft];
QP.bt = 1;
