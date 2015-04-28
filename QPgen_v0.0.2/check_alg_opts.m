function check_alg_opts(QP,opts)

fprintf('Checking algorithm options....');

% store data dimensions
n = length(QP.H);             % nbr of states
m = size(QP.A,1);          % nbr of equality constraints
p = size(QP.C,1);          % nbr of inequality constraints


% check dense inversions
if isfield(opts,'dense')
    if not(is_bool(opts.dense))
        error(['opts.dense must be either 0 or 1']);
    end
end

% check reform
if isfield(opts,'reform')
    if not(isequal(opts.reform,'original')) && not(isequal(opts.reform,'eq')) && not(isequal(opts.reform,'ineq'))
        error(['supported reformulations in opts.reform = {' '''original''' ',' '''eq''' ',' '''ineq''' '}']);
    end
    if isequal(opts.reform,'eq') && (isempty(QP.A) || isempty(QP.B))
        error(['cannot use opts.reform = ' '''eq''' ' if QP.A and/or QP.B not specified']);
    end
    if isequal(opts.reform,'ineq') && n < m+p
       error(['cannot use opts.reform = ' '''ineq''' ' if size(H,1) < size(A,1)+size(C,1)']);
    elseif isequal(opts.reform,'ineq')
        if not(isinvertible([QP.H QP.A' QP.C';[QP.A;QP.C] sparse(m+p,m+p)]))
            error(['cannot use opts.reform = ' '''ineq''' ' if [H A''' ' C''' ';A 0 0;C 0 0] is not invertible']);
        end
    end
end

if isfield(opts,'reform') && isfield(opts,'dense')
    if (isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')) && opts.dense == 0
        error(['sparse algebra not supported for opts.reform = ' '''eq''' ' or opts.reform = ' '''ineq''']);
    end
end

% check algorithm
if isfield(opts,'alg')
    if not(isequal(opts.alg,'ADMM')) && not(isequal(opts.alg,'FGMdual')) && not(isequal(opts.alg,'FGMprimal'))
        error(['supported solvers are opts.alg = {' '''ADMM''' ',' '''FGMdual''' ',' '''FGMprimal''' '}']);
    end
    if isequal(opts.alg,'FGMdual')
        if not(isinvertible([QP.H QP.A';QP.A sparse(m,m)]))
            error(['cannot use opts.alg = ' '''FGMdual''' ' with opts.reform = ' '''original''' ' or ' '''eq''' 'if [H A''' ';A 0] is not invertible']);
        end
        if isfield(opts,'reform') && isequal(opts.reform,'ineq')
           error(['cannot use  opts.alg = ' '''FGMdual''' ' with opts.reform = ' '''ineq''']);
        end
    end
    if isequal(opts.alg,'FGMprimal')
        if isfield(opts,'reform')
            if isequal(opts.reform,'original') && (not(isempty(QP.A)) || not(isempty(QP.B)))
                error(['cannot use opts.alg = ' '''FGMprimal''' ' if opts.reform = ' '''original''' ' and equality constraints are present']);
            end
            if not(isequal(QP.C,speye(p))) && isequal(opts.reform,'original')
                error(['cannot use opts.alg = ' '''FGMprimal''' ' if opts.reform = ' '''original''' ' if QP.C ~= I']);
            end
            if (not(isempty(QP.A)) && not(isempty(QP.B)))
                if isfield(QP,'MPC')
                    N = nullspace(QP.A,QP.MPC);
                else
                    N = null(full(QP.A));
                end
                if not(isequal(QP.C*N,speye(p))) && isequal(opts.reform,'eq')
                    error(['cannot use opts.alg = ' '''FGMprimal''' ' with opts.reform = ' '''eq''' ' if QP.C*null(QP.A) ~= I']);
                end
            end
        end
    end
end

fprintf('done!\n');