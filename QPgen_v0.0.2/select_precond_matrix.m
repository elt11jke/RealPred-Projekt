function M = select_precond_matrix(QP_reform,opts)


% problem dimensions
n = length(QP_reform.H);
m = size(QP_reform.A,1);
p = size(QP_reform.C,1);        


if isequal(opts.alg,'FGMprimal')
    M = QP_reform.H;
else
    if (opts.fast_gen <= 1) && isequal(opts.reform,'original') && isequal(opts.alg,'FGMdual') && isequal(opts.precond_Hess,'Hinv') && not(isinvertible(QP_reform.H))
        error(['cannot use precond_Hess = ' '''Hinv''' ' with alg = ' '''FGMdual''' ' and reform = ' '''original''' 'if H not invertible']);
    elseif isequal(opts.precond_Hess,'K11')
        % (pseudo)-inverse of [H A';A 0]
        P = [QP_reform.H QP_reform.A';QP_reform.A sparse(m,m)];
        if isinvertible(P)
            if isdiag(P)
                K = spdiags(1./diag(P),0,length(P),length(P));
            elseif issparse(P)
                K = P\speye(length(P));
            elseif not(issparse(P))
                K = P\eye(length(P));
            end
        else
            % make this more clever using LDL and other methods!
            K = pinv(full(P));
        end
        K11 = K(1:n,1:n);
        M = QP_reform.C*K11*QP_reform.C';
        M = (M+M')/2;
    elseif isequal(opts.precond_Hess,'Hinv')
        P = QP_reform.H;
        if isinvertible(P)
            if isdiag(P)
                Hinv = spdiags(1./diag(P),0,length(P),length(P));
            elseif issparse(P)
                Hinv = P\speye(length(P));
            elseif not(issparse(P))
                Hinv = P\eye(length(P));
            end
        else
            % make this more clever using LDL and other methods!'
            Hinv = pinv(full(P));
        end
        M = QP_reform.C*Hinv*QP_reform.C';
        M = (M+M')/2;
    end
end