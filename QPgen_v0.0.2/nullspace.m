function N = nullspace(M,MPC)

% compute nullspace, either orthonormal nullspace of MPC-nullspace

if nargin < 2
    % compute orthonormal nullspace
    N = null(full(M));
elseif max(abs(eig(MPC.Adyn))) <= 1
    n = size(MPC.Adyn,1);
    m = size(MPC.Bdyn,2);
    
    N1 = sparse(n*MPC.N,m*MPC.N);
    N1_blk_col = zeros(n*MPC.N,m);
    N1_el = MPC.Bdyn;
    for jj = 1:MPC.N
        
       N1_blk_col((jj-1)*n+1:jj*n,:) = N1_el;
       N1_el = MPC.Adyn*N1_el;
       
    end
    N1 = N1_blk_col;
    for jj = 2:m*MPC.N
        N1(:,(jj-1)*m+1:jj*m) = shift(N1(:,(jj-2)*m+1:(jj-1)*m),n);
    end
    
    N2 = speye(m*MPC.N);
    N = [N1;N2];
    
else
    N = null(full(M));
end


function A = shift(A,n,m)
% shifts column vector n steps down and inserts zeros on top
A = [A(1:end-n,:);sparse(n,size(A,2))];
A = circshift(A,n);