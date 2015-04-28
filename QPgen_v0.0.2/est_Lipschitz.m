function [b,v] = est_Lipschitz(H,A)

n = length(H);
m = size(A,1);

[L,D,P] = ldl([H A';A sparse(m,m)]);

K = inv([H A'; A sparse(m,m)]);
K11 = K(1:n,1:n);

Lest = 0;

[V,E] = eig(full(K11));
[jj,idx] = max(diag(E));
v = V(:,idx)

b = randn(n,1);

for jj = 1:n*10
    
    if mod(jj,100) == 0
        %b = v;
    end
    x = P*(L'\(D\(L\(P'*[b;zeros(m,1)]))));
    x = x(1:n);
    
    b = x/norm(x);
    
end