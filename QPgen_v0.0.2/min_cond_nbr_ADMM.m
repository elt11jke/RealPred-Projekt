% minimize condition number of M using ADMM

% if input M is symmetric and positive semi definite, then minimize
% condition number of M
% otherwise minimize condition number of M'M



function E = min_cond_nbr_ADMM(M,rel_tol)



% initially work with full matrices, then go to sparse!
% IMPLEMENT: SWITCH TO HANDLE SPARSE MATRICES EFFICIENTLY
% IMPLEMENT: ADAPTIVE RHO-SELECTION
% IMPLEMENT: ADAPTIVE SCALING OF E-MATRIX
% CLEAN UP CODE!
% USE BISECTION ON GRADIENT!

cond = 1;

% check that input matrix is wide
if size(M,1) > size(M,2)
  error('input matrix must be square or wide')
end


% check if M positive semi definite
psd = 0;
if size(M,1) == size(M,2) && max(max(M-M')) < 1e-14
  % input is square and symmetric
    M = 1/2*(M+M');
  
  % compute matrix C such that C'C = M
  
  [~,pd] = chol(M+1e-9*eye(length(M)));
  
  if pd == 0
      psd = 1;
  else
      psd = 0;
  end
end

% if M PSD, compute full rank C s.t. M = C'C
% else set C = M
% then minimize (pseudo condition number of C'C)
if psd == 1

    [V,D] = eig(full(M));
    Ddiag = diag(D);
    idx = find(abs(Ddiag) > 1e-8);
    D = D(idx,idx);
    V = V(:,idx);
    
    Dsqrt = diag(sqrt(diag(D)));
    
    C = Dsqrt'*V';
    
    % scale C to solve problem faster
    scale_factor = min(sqrt(diag(D)));
    C = C/scale_factor;
else
    C = M;
    scale_factor = min(eig(C*C'));
    C = C/scale_factor;
end


% store problem dimensions n is size(M) q is rank(M)
n = size(C,2);
q = size(C,1);


% algorithm parameters
rho = 1;

% bisection center starting point
c = 1; 

% compute matrix that multiplies e in E=diag(e)
% this is used in first subproblem in algorithm
CC = [];
for jj = 1:size(C,2)
  CC = [CC kron(C(:,jj),C(:,jj))];
end

CCT = CC';

% compute cholesky factorization of CC'*CC
CCmat = 2*CC'*CC+eye(n);

R_CC = chol(CCmat);

% decision variables E = diag(e)
X = zeros(q,q);
Y = zeros(q,q);
f = zeros(n,1);
s = 0;
lambda = 0;
LambdaX = zeros(q,q);
LambdaY = zeros(q,q);
LambdaF = zeros(n,1);

fprintf('\n-----------------------------------------------------------------\n');
fprintf('iter  | rel prim-res | rel prim-tol | rel dual-res | rel dual-tol\n');
fprintf('-----------------------------------------------------------------\n');

% run ADMM loop
%for jj = 1:10000
jj = 0;
while cond > 0

    jj = jj+1;
  % first subproblem update
  t = s-lambda-1/rho;
 
  e = R_CC\(R_CC'\(CCT*(reshape(X-LambdaX,q^2,1)+reshape(Y-LambdaY,q^2,1))+f-LambdaF));
  
  % store old updates
  fold = f;
  sold = s;
  Xold = X;
  Yold = Y;
  
  % second subproblem update  
  % project onto F>=0
  f = max(0,e+LambdaF);

  
  % project onto Y>=I
  CeC = C*spdiags(e,0,length(e),length(e))*C';

  rhs_mat = CeC+LambdaY;
  rhs_mat = 1/2*(rhs_mat+rhs_mat');
  
  [U,S] = eig(rhs_mat);
  Y = eye(length(S))+U*max(0,S-eye(length(S)))*U';
  % make symmetric
  Y = 1/2*(Y+Y');
  
  
  % project onto X<=sI
  
  rhs_mat = CeC+LambdaX;
  % make symmetric
  rhs_mat = 1/2*(rhs_mat+rhs_mat');

  [U,S] = eig(rhs_mat);

  Sd = diag(S);
  
  s = bisection(Sd,t,lambda,rho,c);
  
  sI = s*eye(length(S));
  X = sI-U*max(0,sI-S)*U';
  % make symmetric
  X = 1/2*(X+X');

  % update dual variables
  LambdaX = LambdaX+(CeC-X);
  LambdaX = 1/2*(LambdaX+LambdaX');
  LambdaY = LambdaY+(CeC-Y);
  LambdaY = 1/2*(LambdaY+LambdaY');
  LambdaF = LambdaF+(e-f);
  lambda = lambda+(t-s);
  
  % make condition relative to problem size
  if mod(jj,50) == 0
      
      % compute residuals
    % primal residual
    res_p1_n = norm(CeC-X,'fro')^2;
    res_p2_n = norm(CeC-Y,'fro')^2;
    res_p3_n = norm(e-f)^2;
    res_p4_n = norm(t-s)^2;
    res_p_n = sqrt(res_p1_n+res_p2_n+res_p3_n+res_p4_n);
    
    res_p_d = max(max(sqrt(norm(2*CeC,'fro')^2+norm(e)^2+norm(t)^2),sqrt(norm(X,'fro')^2+norm(Y,'fro')^2+norm(f)^2+norm(s)^2)),1e-6);
    
    rel_res_p = res_p_n/res_p_d;
  
    % dual residual
    res_d1_n = rho*norm(CeC'*(X-Xold),'fro')^2;
    res_d2_n = rho*norm(CeC'*(Y-Yold),'fro')^2;
    res_d3_n = rho*norm(f-fold)^2;
    res_d4_n = rho*norm(s-sold)^2;
    res_d_n = sqrt(res_d1_n+res_d2_n+res_d3_n+res_d4_n);
  
    res_d_d = sqrt(norm(CCT*reshape(LambdaX+LambdaY,q^2,1),'fro')^2+norm(LambdaF)^2+norm(lambda)^2);
    
    rel_res_d = res_d_n/res_d_d;
    
    cond = max(rel_res_d-rel_tol,rel_res_p-rel_tol);
    
    fprintf('%6d| %9.7e|      %4.2e| %9.7e|     %4.2e\n',jj,rel_res_p,rel_tol,rel_res_d,rel_tol);
    %if 0
    if rel_res_p < 0.05*rel_res_d
        rho_old = rho;
        rho = max(rho/2,1e-3);
        rho_old/rho;
        LambdaX = rho_old/rho*LambdaX;
        LambdaY = rho_old/rho*LambdaY;
        LambdaF = rho_old/rho*LambdaF;
        lambda = rho_old/rho*lambda;
        
    elseif rel_res_d < 0.05*rel_res_p
        rho_old = rho;
        rho = min(rho*2,1000);
        rho_old/rho;
        LambdaX = rho_old/rho*LambdaX;
        LambdaY = rho_old/rho*LambdaY;
        LambdaF = rho_old/rho*LambdaF;
        lambda = rho_old/rho*lambda;
        
    end
    %end
  end
  
end


%E = diag(sqrt(max(0,e)));
E = spdiags(sqrt(max(0,e)),0,length(M),length(M));

% unscale E
E = E/scale_factor;

% Scale E to set lambda_max(E) = 1/lambda_min(E) (optimal rho selection)
E = 1/sqrt(sqrt(s))*E;

function s = bisection(Sd,t,lambda,rho,c)

  % left, center, and right starting points in bisection algorithm
  
  l = c-0.1;
  r = c+1;
  c = (l+r)/2;
  
  
  grad_l = f_grad(Sd,t,lambda,rho,l);
  grad_c = f_grad(Sd,t,lambda,rho,c);
  grad_r = f_grad(Sd,t,lambda,rho,r);

  
  iter = 0;


  while (r-l) > 1e-6
    
    iter = iter+1;
    
    if grad_l > 0
      
      lOld = l;
      cOld = c;
      l = l-2*(c-l);
      c = lOld;
      r = cOld;
  
      grad_lOld = grad_l;
      grad_cOld = grad_c;
      grad_l = f_grad(Sd,t,lambda,rho,l);
      grad_c = grad_lOld;
      grad_r = grad_cOld;
      
      
    elseif grad_r < 0
      
      rOld = r;
      cOld = c;
      r = r+2*(r-c);
      c = rOld;
      l = cOld;

      grad_rOld = grad_r;
      grad_cOld = grad_c;
      grad_r = f_grad(Sd,t,lambda,rho,r);
      grad_c = grad_rOld;
      grad_l = grad_cOld;
      
    elseif grad_c > 0
      
      r = c;
      c = (c+l)/2;
      grad_r = grad_c;
      grad_c = f_grad(Sd,t,lambda,rho,c);
    
    elseif grad_c <= 0
      
      l = c;
      c = (c+r)/2;
      grad_l = grad_c;
      grad_c = f_grad(Sd,t,lambda,rho,c);
    
  end
  end
  % set optimal value after bisection
  s = c;
    


% evaluate gradient in gradient bisection method   
function f_grad_val = f_grad(Sd,t,lambda,rho,s)
   
% gradient for function in paper
f_grad_val = rho*(sum(-max(Sd-s,0))+s-t-lambda);

% gradient when s is minimized linearly instead of t
%f_grad_val = rho*(sum(-max(Sd-s,0))+s-t-lambda+1/rho);