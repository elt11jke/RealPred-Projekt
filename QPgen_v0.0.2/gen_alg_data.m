function alg_data = gen_alg_data(QP_reform,opts)

fprintf('Generating algorithm data....');

% move fields that are the same to outside if clause?

alg_data.H = QP_reform.H;

% used in primal FGM
%if isequal(opts.alg,'FGMprimal')
    alg_data.G = QP_reform.G;
    alg_data.B = QP_reform.B;
    alg_data.Gb = QP_reform.Gb;
    alg_data.Gg = QP_reform.Gg;
%end

alg_data.str_conv = 0;

% needed???
if isfield(QP_reform,'L')
    alg_data.L = QP_reform.L;
end

if isequal(opts.reform,'original')
    
    
    n = length(QP_reform.H);
    m = size(QP_reform.A,1);
    p = size(QP_reform.C,1);
    
    if not(isequal(opts.alg,'FGMprimal'))
        % selects if ADMM or fast dual grad method is used
        if isequal(opts.alg,'ADMM')
            regul = 1;
        elseif isequal(opts.alg,'FGMdual')
            regul = 0;
        end

    
        if opts.dense == 1

            % PERFORM INVERSION WITH SPEYE IF SPARSE!
            M = [QP_reform.H+regul*QP_reform.C'*QP_reform.C QP_reform.A';QP_reform.A zeros(m,m)]\eye(n+m);

            M11 = M(1:n,1:n);
            M12 = M(1:n,1+n:end);

            alg_data.M = -M11*QP_reform.C';
            if not(isempty(QP_reform.Gg))
                alg_data.Q1 = -M11*QP_reform.Gg;
            else
                alg_data.Q1 = [];
            end
            alg_data.Q2 = M12*QP_reform.B;


        elseif opts.dense == 0

            % take care of sparsity of H, C, and A!
            % solve by ldl of [H A';A 0]
            [L,D,p] = ldl([QP_reform.H+regul*QP_reform.C'*QP_reform.C QP_reform.A';QP_reform.A zeros(m,m)],'vector');
            
            alg_data.L = compress_row(L);
            % CHANGE THIS LATER? IS NOT COMPATIBLE WITH FLAT GENERATION! NO
            % INSTEAD UPDATE FLAT GENERATION CODE!
            alg_data.LT = compress_row(L');
            %alg_data.LT = compress_row_LT(L);
            alg_data.D_inv = D\speye(length(D)); 
            alg_data.D_inv = sparse(alg_data.D_inv);
            alg_data.p = p';

        end
    end
    alg_data.C = QP_reform.C;
    alg_data.h.Lb = QP_reform.h.Lb;
    alg_data.h.Ub = QP_reform.h.Ub;
    alg_data.h.soft = QP_reform.h.soft;
    
    alg_data.E = QP_reform.E;
    
    alg_data.gt = QP_reform.gt;
    alg_data.bt = QP_reform.bt;
    
    if isequal(opts.alg,'FGMprimal')
        alg_data.R = QP_reform.R;
        alg_data.r1 = [];
        alg_data.r2 = [];
    end
    if 0
    alg_data.F = QP_reform.F;
    end
    
    % check strong convexity
    if (opts.fast_gen == 0) || (opts.fast_gen == 2)
        if isinvertible([QP_reform.H QP_reform.A';QP_reform.A zeros(m,m)])
            M = [QP_reform.H QP_reform.A';QP_reform.A zeros(m,m)]\eye(n+m);
            M11 = M(1:n,1:n);
            M = QP_reform.C*M11*QP_reform.C';
            if isinvertible(M)
                eigM = eig(M);
                sigma = min(eigM);
                L = max(eigM);
                if sigma/L > 1e-4
                    alg_data.str_conv = (sqrt(L)-sqrt(sigma))/(sqrt(L)+sqrt(sigma));
                end
            end
        end
    end
    
elseif isequal(opts.reform,'ineq')
    
    n = length(QP_reform.H);
    
    % selects if ADMM or fast grad method is used
    if isequal(opts.alg,'ADMM')
        regul = 1;
    else
        regul = 0;
    end
    
    % PERFORM INVERSION WITH SPEYE IS SPARSE!
    if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
        M = (QP_reform.H+regul*QP_reform.C'*QP_reform.C)\eye(n);
        alg_data.M = -M*QP_reform.C';
        alg_data.Q1 = -M*QP_reform.Gg;
        alg_data.Q2 = -M*QP_reform.Gb;
    end
    alg_data.C = QP_reform.C;
    alg_data.h.Lb = QP_reform.h.Lb;
    alg_data.h.Ub = QP_reform.h.Ub;
    alg_data.h.soft = QP_reform.h.soft;
    alg_data.E = QP_reform.E;
    
    alg_data.gt = QP_reform.gt;
    alg_data.bt = QP_reform.bt;
    
    alg_data.R = QP_reform.R;
    alg_data.r1 = QP_reform.r1;
    alg_data.r2 = QP_reform.r2;
    if 0
    alg_data.F = QP_reform.F;
    end
    
    % check strong convexity
    if (opts.fast_gen == 0) || (opts.fast_gen == 2)
        if isinvertible(QP_reform.H)
            eigH = eig(QP_reform.H);
            sigma = min(eigH);       
            L = max(eigH);
            if sigma/L > 1e-4
                alg_data.str_conv = (sqrt(L)-sqrt(sigma))/(sqrt(L)+sqrt(sigma));
            end
        end
    end
    
elseif isequal(opts.reform,'eq')

    
    n = length(QP_reform.H);
    p = size(QP_reform.C,1);
    
    % selects if ADMM or fast grad method is used
    if isequal(opts.alg,'ADMM')
        regul = 1;
    else
        regul = 0;
    end
    
    % PERFORM INVERSION WITH SPEYE IS SPARSE!
    
    if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
        M = (QP_reform.H+regul*QP_reform.C'*QP_reform.C)\eye(n);
        alg_data.M = -M*QP_reform.C';
        alg_data.Q1 = -M*QP_reform.Gg;
        alg_data.Q2 = -M*QP_reform.Gb;
    end
    alg_data.C = QP_reform.C;
    alg_data.h.Lb = QP_reform.h.Lb;
    alg_data.h.L1 = QP_reform.h.L1;
    alg_data.h.L2 = QP_reform.h.L2;
    alg_data.h.Ub = QP_reform.h.Ub;
    alg_data.h.U1 = QP_reform.h.U1;
    alg_data.h.U2 = QP_reform.h.U2;
    alg_data.h.soft = QP_reform.h.soft;
    
    alg_data.E = QP_reform.E;
    
    alg_data.gt = QP_reform.gt;
    alg_data.bt = QP_reform.bt;
    
    alg_data.R = QP_reform.R;
    alg_data.r1 = QP_reform.r1;
    alg_data.r2 = QP_reform.r2;
    if 0
    alg_data.F = QP_reform.F;
    end
    
    % check strong convexity
    if (opts.fast_gen == 0) || (opts.fast_gen == 2)
        if isinvertible(QP_reform.H)
            M = QP_reform.C*(QP_reform.H\QP_reform.C');
            if isinvertible(M)
                eigM = eig(M);
                sigma = min(eigM);       
                L = max(eigM);
                if sigma/L > 1e-4
                    alg_data.str_conv = (sqrt(L)-sqrt(sigma))/(sqrt(L)+sqrt(sigma));
                end
            end
        end
    end
end

% make data sparse if under sparsity threshold
alg_data = set_sparse(alg_data,opts.sparsity_threshold);

fprintf('done!\n');