function opts = select_alg_reform(QP,opts)

fprintf('Selecting remaining algorithm options....');

% REDUCE NUMBER OF TIMES ISINVERTIBLE IS CALLED!!



% data sizes
n = length(QP.H);
m = size(QP.A,1);
p = size(QP.C,1);


% M rows:   [ADMM_orig_sparse;ADMM_orig_dense;ADMM_eqelim;ADMM_ineq;
%            FGMd_orig_sparse;FGMd_orig_dense;FGMd_eqelim;
%            FGMp_orig;FGMp_eqelim;FGMp_ineq]
    
% M column: [iteration_cost] 
M = zeros(10,1);

% if some options already set. do not check other options (set to infty)
if isfield(opts,'alg')
    if isequal(opts.alg,'ADMM')
        M(5:end) = inf;
    elseif isequal(opts.alg,'FGMdual')
        M(1:4) = inf;
        M(8:10) = inf;
    elseif isequal(opts.alg,'FGMprimal')
        M(1:7) = inf;
    end
end
if isfield(opts,'reform')
   if isequal(opts.reform,'original')
       M(3:4) = inf;
       M(7) = inf;
       M(9:10) = inf;
   elseif isequal(opts.reform,'eq')
       M(1:2) = inf;
       M(4:6) = inf;
       M(8) = inf;
       M(10) = inf;
   elseif isequal(opts.reform,'ineq')
       M(1:3) = inf;
       M(5:9) = inf;
   end
end
if isfield(opts,'dense')
    if opts.dense == 1
        M(1) = inf;
        M(5) = inf;
    elseif opts.dense == 0
        M(2:4) = inf;
        M(6:10) = inf;
    end
end

        




% ADMM------------------------------------------------

% ADMM original with sparse update
if M(1) < inf
    [L,~,~] = ldl([QP.H+QP.C'*QP.C QP.A';QP.A sparse(m,m)]);
    pL = frac_zeros(L);
    pC = frac_zeros(QP.C);
    M(1) = 2*pL*(n+m)^2+2*pC*n*p;
    if isfield(opts,'dense') && opts.dense == 1
        M(1)  = inf;
    end
end
% ADMM original with dense update
if M(2) < inf
    M(2) = n*(n+m)+2*pC*n*p;
    if isfield(opts,'dense') && opts.dense == 0
        M(2) = inf;
    end
end

% ADMM eqelim
if M(3) < inf
    if not(isempty(QP.A)) && not(isempty(QP.B))
        if isfield(QP,'MPC')
            N = nullspace(QP.A,QP.MPC);
        else
            N = null(full(QP.A));
        end
        M(3) = (n-m)^2+2*frac_zeros(QP.C*N)*p*(n-m);
    else
        M(3) = inf;
    end
end

% ADMM ineq
if M(4) < inf
    if isinvertible([QP.H QP.A' QP.C';[QP.A;QP.C] sparse(m+p,m+p)]);
        M(4) = p^2+2*p;
    else
        M(4) = inf;
    end
end
%-------------------------------------------------------


%FGMdual------------------------------------------------

if M(5) < inf || M(6) < inf || M(7) < inf
    if isinvertible([QP.H QP.A';QP.A sparse(m,m)])
        % FGMdual original sparse
        if M(5) < inf
            [L,~,~] = ldl([QP.H QP.A';QP.A sparse(m,m)]);
            pL = frac_zeros(L);
            pC = frac_zeros(QP.C);
            M(5) = 2*pL*(n+m)^2+2*pC*n*p;
            if isfield(opts,'dense') && opts.dense == 1
                M(5) = inf;
            end
        end
        
        % FGMdual original with dense update
        if M(6) < inf
            M(6) = n*(n+m)+2*pC*n*p;
            if isfield(opts,'dense') && opts.dense == 0
                M(6) = inf;
            end
        end

        % FGMdual eqelim
        if M(7) < inf
            if not(isempty(QP.A)) && not(isempty(QP.B))
                if isfield(QP,'MPC')
                    N = nullspace(QP.A,QP.MPC);
                else
                    N = null(full(QP.A));
                end
                M(7) = (n-m)^2+2*frac_zeros(QP.C*N)*p*(n-m);
            else
                M(7) = inf;
            end
        end
    else
        M(5:7) = inf;
    end
end
%------------------------------------------------------


%FGMprimal---------------------------------------------

% FGMprimal original
if M(8) < inf
    if isequal(QP.C,speye(p)) && isempty(QP.A) && isempty(QP.B)
        pP = frac_zeros(QP.H);
        M(8) = pP*n^2+2*n;
    else
        M(8) = inf;
    end
end

% FGMprimal eqelim
if M(9) < inf
    if not(isempty(QP.A)) && not(isempty(QP.B))
        if isfield(QP,'MPC')
            N = nullspace(QP.A,QP.MPC);
        else
            N = null(full(QP.A));
        end
        if isequal(QP.C*N,speye(p))
            M(9) = (n-m)^2+(n-m);
        else
            M(9) = inf;
        end
    else
        M(9) = inf;
    end
end

% FGMprimal ineq
if M(10) < inf
    if isinvertible([QP.H QP.A' QP.C';[QP.A;QP.C] sparse(m+p,m+p)]);
        M(10) = p^2+2*p;
    else
        M(10) = inf;
    end
end
%------------------------------------------------------    

% find smallest iteration cost and choose algorithm reformulation and dense
[it_cost,idx] = min(M);
if it_cost < inf
    if idx == 1
        opts.alg = 'ADMM';
        opts.reform = 'original';
        opts.dense = 0;
    elseif idx == 2
        opts.alg = 'ADMM';
        opts.reform = 'original';
        opts.dense = 1;
    elseif idx == 3
        opts.alg = 'ADMM';
        opts.reform = 'eq';
        opts.dense = 1;
    elseif idx == 4
        opts.alg = 'ADMM';
        opts.reform = 'ineq';
        opts.dense = 1;
    elseif idx == 5
        opts.alg = 'FGMdual';
        opts.reform = 'original';
        opts.dense = 0;
    elseif idx == 6
        opts.alg = 'FGMdual';
        opts.reform = 'original';
        opts.dense = 1;
    elseif idx == 7
        opts.alg = 'FGMdual';
        opts.reform = 'eq';
        opts.dense = 1;
    elseif idx == 8
        opts.alg = 'FGMprimal';
        opts.reform = 'original';
        opts.dense = 1;
    elseif idx == 9
        opts.alg = 'FGMprimal';
        opts.reform = 'eq';
        opts.dense = 1;
    elseif idx == 10
        opts.alg = 'FGMprimal';
        opts.reform = 'ineq';
        opts.dense = 1;
    end
else
    error('the chosen combination opts.alg, opts.reform, and opts.dense cannot solve the specified problem');    
end

fprintf('done!\n');