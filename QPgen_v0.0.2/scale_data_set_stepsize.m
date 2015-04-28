function QP_reform = scale_data_set_stepsize(QP_reform,E,opts)

% store preconditioner
QP_reform.E = E;

fprintf('Scaling problem data and computing algorithm step size....');

% select step-size and scale data

if isequal(opts.alg,'ADMM')
     
    if (opts.fast_gen == 0 || opts.fast_gen == 2)
         % compute matrix used in preconditioning
         M = select_precond_matrix(QP_reform,opts);
   
        % compute optimal rho
        EMEeig = eig(full(QP_reform.E*M*QP_reform.E'));
        idx = find(EMEeig > 1e-4);
        L = max(EMEeig(idx));
        sigma = min(EMEeig(idx));
    
        % store optimal scaling factor
        QP_reform.scaling = 1/sqrt(sqrt(L*sigma));
    else
        % choose scaling 1
        QP_reform.scaling = 1;
    end
    
    % set optimal rho
    QP_reform.E = QP_reform.scaling*QP_reform.E;
    
    % scale with user defined rho
    QP_reform.E = sqrt(opts.rho)*QP_reform.E;
    
    % invert E
    %Einv = QP_reform.E\speye(length(QP_reform.E));
    Einv = spdiags(1./diag(QP_reform.E),0,length(QP_reform.E),length(QP_reform.E));
    
    % create h_{E^-1}(v) = h(E^{-1}v) (for prox with h_{E^-1} in alg)
    QP_reform.h.Lb = QP_reform.E*QP_reform.h.Lb;
    QP_reform.h.Ub = QP_reform.E*QP_reform.h.Ub;
    QP_reform.h.soft = Einv*QP_reform.h.soft;
    
    if isequal(opts.reform,'eq')
       %QP_reform.h.L1 = E*QP_reform.h.L1;
       %QP_reform.h.L2 = E*QP_reform.h.L2;
       %QP_reform.h.U1 = E*QP_reform.h.U1;
       %QP_reform.h.U2 = E*QP_reform.h.U2;
    end

    
    % precondition problem data
    QP_reform.C = QP_reform.E*QP_reform.C;
    
elseif isequal(opts.alg,'FGMdual')
    % select correct matrix to compute step-size
    tmp_opts.precond_Hess = 'K11';
    tmp_opts.alg = 'FGMdual';
    tmp_opts.reform = opts.reform;
    tmp_opts.fast_gen = opts.fast_gen;
    
    M = select_precond_matrix(QP_reform,tmp_opts);
    
    % 1/sqrt(L) for FGMdual (sqrt since mult. from two sides)
    L = max(eigs(QP_reform.E*M*QP_reform.E'));
    if L == 0
        L = norm(full(QP_reform.E*M*QP_reform.E'));
    end
    
    % store scaling factor
    QP_reform.scaling = 1/sqrt(L);
    
    % set optimal step-size
    QP_reform.E = QP_reform.scaling*QP_reform.E;
    
    % scale with user defined step-size
    QP_reform.E = sqrt(opts.t)*QP_reform.E;
    
    % invert E
    %Einv = QP_reform.E\speye(length(QP_reform.E));
    Einv = spdiags(1./diag(QP_reform.E),0,length(QP_reform.E),length(QP_reform.E));
    
    % create h_{E^-1}(v) = h(E^{-1}v) (for prox with h_{E^-1} in alg)
    QP_reform.h.Lb = QP_reform.E*QP_reform.h.Lb;
    QP_reform.h.Ub = QP_reform.E*QP_reform.h.Ub;
    QP_reform.h.soft = Einv*QP_reform.h.soft;
    
    if isequal(opts.reform,'eq')
       %QP_reform.h.L1 = E*QP_reform.h.L1;
       %QP_reform.h.L2 = E*QP_reform.h.L2;
       %QP_reform.h.U1 = E*QP_reform.h.U1;
       %QP_reform.h.U2 = E*QP_reform.h.U2;
    end
    
    % precondition problem data
    QP_reform.C = QP_reform.E*QP_reform.C;
    
elseif isequal(opts.alg,'FGMprimal')
    % 1/sqrt(L) for FGMprimal (sqrt since mult. from two sides)
    L = max(eigs(QP_reform.E'*QP_reform.H*QP_reform.E));
    if L == 0
        L = norm(full(QP_reform.E*M*QP_reform.E'));
    end
    
    % store scaling factor
    QP_reform.scaling = 1/sqrt(L);
    
    % set optimal step-size
    QP_reform.E = QP_reform.scaling*QP_reform.E;
    
    % scale with user defined step-size
    QP_reform.E = sqrt(opts.t)*QP_reform.E;
    
    % invert E
    %Einv = QP_reform.E\speye(length(QP_reform.E));
    Einv = spdiags(1./diag(QP_reform.E),0,length(QP_reform.E),length(QP_reform.E));
    
    % precondition problem data
    QP_reform.H = QP_reform.E'*QP_reform.H*QP_reform.E;
    if not(isempty(QP_reform.Gg));
        QP_reform.Gg = QP_reform.E'*QP_reform.Gg;
    end
    if not(isempty(QP_reform.Gb))
        QP_reform.Gb = QP_reform.E'*QP_reform.Gb;
    end
    % create h_{E}(v) = h(Ev) (for prox with h_E in alg)
    QP_reform.h.Lb = Einv*QP_reform.h.Lb;
    QP_reform.h.Ub = Einv*QP_reform.h.Ub;
    QP_reform.h.soft = QP_reform.E*QP_reform.h.soft;
    
    if isequal(opts.reform,'eq')
       QP_reform.h.L1 = Einv*QP_reform.h.L1;
       QP_reform.h.L2 = Einv*QP_reform.h.L2;
       QP_reform.h.U1 = Einv*QP_reform.h.U1;
       QP_reform.h.U2 = Einv*QP_reform.h.U2;
    end
    QP_reform.R = QP_reform.R*QP_reform.E;
end


% set data sparse if sparisty under threshold
QP_reform = set_sparse(QP_reform,opts.sparsity_threshold);


fprintf(['done!\n']);