function S = set_sparse(S,sparsity_threshold)

fields = fieldnames(S);

for i = 1:numel(fields)
    if isnumeric(S.(fields{i})) 
        if (frac_zeros(S.(fields{i})) < sparsity_threshold) && (size(S.(fields{i}),1) > 1) && (size(S.(fields{i}),2) > 1)
            S.(fields{i}) = sparse(S.(fields{i}));
        else
            S.(fields{i}) = full(S.(fields{i}));
        end
    end
end