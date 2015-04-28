function Ac = compress_row(A)

% store general sparse matrix A in row compressed format 

% Lc = zeros(length(find(L ~= 0))-size(L,1),3);

% remove else clause, since slower!

if 1
At = A';
[col,~,val] = find(At);
Ac.val = [col val];
row = full(sum(At ~= 0))';
Ac.elem_per_row = row;

else
[n,m] = size(A);
nbr_el = length(find(A ~= 0));

Ac.elem_per_row = zeros(n,1);
Ac.val = zeros(nbr_el,2);

counter = 1;
for jj = 1:n
    idx = find(A(jj,:) ~= 0);
    Ac.elem_per_row(jj) = length(idx);
    for kk = 1:length(idx)
        Ac.val(counter,1) = idx(kk);
        Ac.val(counter,2) = A(jj,idx(kk));
        counter = counter+1;
    end
end
end
