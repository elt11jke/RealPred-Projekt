function str = free_mat_heap(M,Mstr,precision,rep)

str = [];

if nargin == 4
    % if representation specified
    if isequal(rep,'diag')
        % diagonal representation
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
    elseif isequal(rep,'sparse')
        % sparse representation
        %M = compress_row(M);
        
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr '->row);\n\n'];
        str = [str 'free(' Mstr '->col);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
        
    elseif isequal(rep,'full')
        % dense representation
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
    end
else
    % if representation not specified
    if isdiag(M)
    	% diagonal representation
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
    elseif issparse(M)
    	% sparse representation
    	M = compress_row(M);
    	
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr '->row);\n\n'];
        str = [str 'free(' Mstr '->col);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
        
    else
        % dense representation
        str = [str 'free(' Mstr '->data);\n\n'];
        str = [str 'free(' Mstr ');\n\n'];
    end
end
