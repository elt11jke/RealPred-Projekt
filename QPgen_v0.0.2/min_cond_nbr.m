% minimize pseudo condition number of M

function E = min_cond_nbr(M)

% make symmetric and set dimension
p = length(M);
M = 1/2*(M+M');

% compute Q such that M = Q'Q
[V,D] = eig(full(M));
Ddiag = diag(D);
idx = find(abs(Ddiag) > 1e-8);
D = D(idx,idx);
V = V(:,idx);

Dsqrt = diag(sqrt(diag(D)));

Q = Dsqrt'*V';
v = length(Q(:,1));

cvx_begin sdp
    %cvx_solver scs
    variable L(p,p) diagonal
    variable Linv(p,p) diagonal
    variable s(1)
    minimize s
    subject to
        Q*L*Q' <= s*eye(v)
        Q*L*Q' >= eye(v)
        L >= 0*eye(p);
cvx_end

E = spdiags(sqrt(max(0,diag(L))),0,length(M),length(M));

% Scale E to set lambda_max(E) = 1/lambda_min(E) (optimal rho selection)
E = 1/sqrt(sqrt(s))*E;