% computes preconditioner and optimal parameter


function QP_reform = compute_preconditioner(QP_reform,opts)

fprintf('Computing preconditioner....');


% problem dimensions
n = length(QP_reform.H);
m = size(QP_reform.A,1);
p = size(QP_reform.C,1);        

% select preconditioning technique (if not already chosen)
if not(isfield(opts,'precond'))
    if p < 200
        opts.precond = 'min_cond_nbr';
    else
        opts.precond = 'jacobi';
    end
end


% select matrix to precondition
M = select_precond_matrix(QP_reform,opts);


% check conditions for applying equilibration
if isequal(opts.precond,'equilibration')
    if not(isempty(find(diag(M) == 0,1)))
        opts.precond = 'jacobi';
    end
end


% compute preconditioner E (make E sparse)
if isequal(opts.precond,'no')
    
    E = eye(p);
    
elseif isequal(opts.precond,'jacobi')
    
    L = diag(diag(M));
        
    % set zero entries to average of the others.
    idx0 = find(diag(L) <= 1e-6);
    Ld = diag(L);
    Ld(idx0) = sum(Ld)/(length(Ld)-length(idx0));
    
    % store E
    E = diag(1./sqrt(Ld));
    
    
elseif isequal(opts.precond,'equilibration')
    
    E = equilibrate(M,10);
    
elseif isequal(opts.precond,'min_cond_nbr')
    
    L = min_cond_nbr(M);
    
    % set zero entries to average of the others.
    idx0 = find(diag(L) <= 1e-6);
    Ld = diag(L);
    Ld(idx0) = sum(Ld)/(length(Ld)-length(idx0));
    
    % store E
    E = diag(sqrt(Ld));
    
end


% check preconditioner!
e = diag(E);
if not(isdiag(E)) || not(isempty(find(not(isfinite(E)) == 1,1))) || not(isreal(E)) || not(isnumeric(E)) || min(e) <= 0
    error('computed preconditioner cannot be used, please report error');
end





fprintf(['done! opts.precond =  ''' opts.precond ''' used\n']);