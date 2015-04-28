function E = equilibrate(M,nbrSteps)


% diagonal of scaling matrix
c = rand(length(M),1);

B = abs(M);

% sinkhorn-knopp
for jj = 1:nbrSteps

  r = 1./(B*c);
  c = 1./(B*r);

end


%D = sqrt(r(1,1)/c(1,1))*spdiags(c,0,length(c),length(c));
e = sqrt(r(1,1)/c(1,1))*c;

E = spdiags(e,0,length(M),length(M));