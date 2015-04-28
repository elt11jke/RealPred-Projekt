function bool = isinvertible(M)

% checks if M is invertible
% assumes that M is symmetric and square

n = length(M);

%Mfull = full(M);

bool = 1;

if n <= 300
    bool = (min(abs(eig(full(M)))) > 1e-9);
else
    [~,D,p] = ldl(M,'vector');
    [ri,ci] = find(D ~= 0);
    
    idx_iter = 1;
    while idx_iter <= length(ci)-1 && bool == 1
        if ri(idx_iter) < ri(idx_iter+1) && ci(idx_iter) < ci(idx_iter+1)
            bool = full(min(abs(D(ci(idx_iter),ci(idx_iter)))) > 1e-9);
            idx_iter = idx_iter+1;
        else
            Dblk = D(ci(idx_iter):ci(idx_iter)+1,ci(idx_iter):ci(idx_iter)+1);
            bool = full(min(abs(eig(Dblk))) > 1e-9);
            
            % move forward as many index as non-zeros in block
            idx_iter = idx_iter+length(find(Dblk));
        end
    end
    if idx_iter == length(ci)
        bool = full((min(abs(D(ci(idx_iter),ci(idx_iter)))) > 1e-9));
    end
end