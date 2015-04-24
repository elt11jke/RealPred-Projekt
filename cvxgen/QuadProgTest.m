% function [sol,gt] = QuadProgTest(n)
n=4;

 Q=[1 0 0 0;0 1 0 0; 0 0 0 0; 0 0 0 0];
 R=[1 0;0 1];
 
 xref=[10 ;10 ;0 ;0];
 

 Qdiag = [];
 for i=1:n
     Qdiag = blkdiag(Qdiag,Q);
 end
 
 
 twoR =[];
 for i=1:n
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
 

 f = G1*gt';
 sol = quadprog(H,f);

 sol1 = [];
 for i=1:n
     sol1(i) = sol((size(sol,1)-2*n)+2*i-1);
 end
 sol2 = [];
 for i=1:n
     sol2(i) = sol((size(sol,1)-2*n)+2*i);
 end

plot([1:n],sol1,'*g')


