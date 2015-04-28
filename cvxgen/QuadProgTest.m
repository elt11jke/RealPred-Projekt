% clear all
% clc 

n=30;

 Q =[1 0 0 0;0 1 0 0; 0 0 0 0; 0 0 0 0];
 R =[1 0;0 1];
 A = [0.9708 0 0.02466 0;0 0.9689 0 0.4032 ;0 0 0.7495 0;0 0 0 0.5898];
 B = [0.1126 0.0072; 0.0108 0.1061;0 0.0482;0.0381 0];
 
 xref=[10 ;10 ;0 ;0];
 x_0 = [0 ;0; 0; 0];

 Qdiag = [];
 for i=1:n
     Qdiag = blkdiag(Qdiag,Q);
 end
 
 
 twoR = R;
 for i=2:n
     twoR = blkdiag(twoR,2*R);
 end
 minusR = [];
 for i=1:n-1
     minusR = blkdiag(minusR,-R);
 end
 
 M1 = zeros(size(twoR));
 M1(1:end-2, 3:end) = minusR;
 
 M2 = zeros(size(twoR));
 M2(3:end, 1:end-2) = minusR;

 twoR = twoR + M1 + M2;
 twoR(end-1:end, end-1:end) = eye(2);

 H = blkdiag(Qdiag,twoR);
 
 
 % old G1 matrix and gt vector
 G1 = blkdiag(Qdiag,zeros(size(twoR)));
 
 gt = [];
 length=4*(n);
 for i=1:length
     gt(i)=10;
 
 end
 length2=length+2*n;
 for i=length+1:length2
     gt(i)=0;
 end 
 
 
 % new G1 matrix and gt vector
 G1 = [repmat(Q,n,1);repmat(zeros(size(B,2),size(Q,1)),n,1)];
 
 gt = xref';
 
 % end new G1 matrix and gt vector
 
 f = -G1*gt';
 
 % Construct diagonal identity matrix for Aeq11 
 I_init = eye(size(A));
 I = [];
 for i_ident = 1:n  
     I = blkdiag(I,I_init);
 end
 
 %------------------------------------------------------------
 % Construct off diagonal A matrix for Aeq11
 Off_diag = zeros(size(I));
 A_diag = [];
 for i_ident = 1:n-1  
     A_diag = blkdiag(A_diag,-A);
 end
 
 Off_diag(size(I_init,1)+1:end,1:end-size(I_init,1)) = A_diag;
 
 % Combine diagonal identity matrix and off diagonal 
 % matrix to form Aeq11
 Aeq11 = I + Off_diag;
 
 % Construct Aeq12
 Aeq12 = [];
 for i= 1:n  
     Aeq12 = blkdiag(Aeq12,-B);
 end
 
 % Construct the rest of Aeq matrix
 Aeq21 = zeros(size(Aeq12,2),size(Aeq11,2));
 Aeq22 = zeros(size(Aeq12,2),size(Aeq12,2));
%Aeq   = [Aeq11  Aeq12;  Aeq21 Aeq22];
  Aeq   = [Aeq11 Aeq12];
 %--------------------------------------------------------
 
 % Construct Beq
 Beq = zeros(size(Aeq,1),1);
 
 Beq(1:size(A,1)) = A*x_0; 

 % Construct upper bound and lower bound matrix
  lb = zeros(size(H,1),1);
  
  lb(4*n+1:end) = -10;
  
  ub = zeros(size(H,1),1);
  
  ub(1:4*n) = 19.8;
  
  ub(4*n+1:end) = 10;
 
 
 
 tic
 sol = quadprog(H,f,[],[],Aeq,Beq,lb,ub);
tt = toc
 
 
 sol1 = [];
 for i=1:n
     sol1(i) = sol((size(sol,1)-2*n)+2*i-1);
 end
 sol2 = [];
 for i=1:n
     sol2(i) = sol((size(sol,1)-2*n)+2*i);
 end

 %figure()
plot([1:n],sol1,'*g')



% create QPgen code
QP.H = H;
QP.G = -G1;
QP.A = Aeq;
QP.B = zeros(size(Aeq,1),1);
QP.B(1:size(A,1),1:size(A,1)) = A;
QP.C = eye(size(H,1));
QP.h.Lb = lb;
QP.h.Ub = ub;
QP.h.fcn = 'indicator';
QP.bt = 1;
QP.gt = 1;

[QP_reform,alg_data] = run_code_gen(QP);

for jj = 1:100
tic;
[qp_gen_sol,iter] = qp_mex(gt',x_0);
tt = toc
end

qp_gen_sol1 = [];

 for i=1:n
     qp_gen_sol1(i) = qp_gen_sol((size(sol,1)-2*n)+2*i-1);
 end
 qp_gen_sol2 = [];
 for i=1:n
     qp_gen_sol2(i) = qp_gen_sol((size(sol,1)-2*n)+2*i);
 end
     
 %figure()
plot([1:n],qp_gen_sol1,'*r')



