function opts = select_stack_usage(S,opts)


if not(isfield(opts,'stack_usage'))
    
    % count number of non-zero elements in data structure
    fields = fieldnames(S);

    nnz = 0;
    for i = 1:numel(fields)
        if isnumeric(S.(fields{i})) 
            if (size(S.(fields{i}),1) > 1) && (size(S.(fields{i}),2) > 1)
                nnz = nnz+frac_zeros(S.(fields{i}))*size(S.(fields{i}),1)*size(S.(fields{i}),2);
            end
        end
    end
    % for L and L', val, row, and col
    if isfield(S,'L')
        nnz = nnz+6*length(S.L.val);
    end
    
    % set problem size (approx 20 vars of max size)
    ps = 20*max(size(S.C,1),size(S.C,2));
    
    % if less than 300 KB data (\approx 40Kx8B), use stack only
    % if less that 300 KB vars (\approx 40Kx8B), use stack for variables
    % else use heap only
    if nnz <= 40000
        opts.stack_usage = 2;
    elseif ps <= 40000
        opts.stack_usage = 1;
    else
        opts.stack_usage = 0;
    end
end