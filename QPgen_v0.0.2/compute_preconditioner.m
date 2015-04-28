% computes preconditioner and optimal parameter


function [E,opts] = compute_preconditioner(QP_reform,opts)


% problem dimensions
n = length(QP_reform.H);
m = size(QP_reform.A,1);
p = size(QP_reform.C,1);


% if no preconditioning, return E=I
if isfield(opts,'precond') && isequal(opts.precond,'no')
    E=speye(p);
    opts.min_cond_alg = 'ADMM';
    return
end


fprintf('Computing preconditioner....');


% select matrix to precondition
M = select_precond_matrix(QP_reform,opts);

% select precond method
opts = select_precond_method(M,opts);


% check conditions for applying equilibration
if isequal(opts.precond,'equilibration')
    if not(isempty(find(diag(M) == 0,1)))
        error('cannot use equilibration if diagonal elements are 0 in preconditioned matrix');
    end
end


% compute preconditioner E
if isequal(opts.precond,'jacobi')
    
    L = spdiags(diag(M),0,length(M),length(M));
       
    % set zero entries to average of the others.
    Ld = diag(L);
    idx0 = find(Ld <= 1e-6*max(Ld));
    Ld(idx0) = sum(Ld)/(length(Ld)-length(idx0));
        
    % store E
    E = spdiags(1./sqrt(Ld),0,length(M),length(M));
    
    
elseif isequal(opts.precond,'equilibration')
    
    E = equilibrate(M,10);
    
elseif isequal(opts.precond,'min_cond_nbr')
    
    if isequal(opts.min_cond_alg,'cvx')
        E = min_cond_nbr(M);
    elseif isequal(opts.min_cond_alg,'ADMM')
        E = min_cond_nbr_ADMM(M,opts.min_cond_rel_tol);
    end
    % set zero entries to average of the others.
    Ed = diag(E);
    idx0 = find(Ed <= 1e-3*max(Ed));
    Ed(idx0) = sum(Ed)/(length(Ed)-length(idx0));
    
    E = spdiags(Ed,0,length(Ed),length(Ed));
    
    if length(idx0) > 0
        fprintf('WARNING: optimal precond has entries that are 0, this might cause bad performance\nif bad performance is observed, try preconditioners jacobi or equilibration instead\n->push any button to continue code generation<-\n');
        pause
    end
end

% check preconditioner!
e = diag(E);
if not(isdiag(E)) || not(isempty(find(not(isfinite(e)) == 1,1))) || not(isreal(e)) || not(isnumeric(e)) || min(e) <= 0
    error('computed preconditioner cannot be used, please report error and use other preconditioning method');
end


fprintf(['done!\n']);