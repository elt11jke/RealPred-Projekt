function str = def_mat(M,Mstr,precision,rep)

str = [];

if nargin == 4
    % if representation specified
    if isequal(rep,'diag')
        % diagonal representation
        str = [str 'static const ' precision ' ' Mstr 'data[' int2str(length(M)) '] = ' mat2str_c(diag(M)) ';\n\n'];
        str = [str 'static struct DIAG_MAT ' Mstr ' = {' int2str(length(M)) ',' Mstr 'data};\n\n'];
    elseif isequal(rep,'sparse')
        % sparse representation
        % M = compress_row(M);
        str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,2)) ';\n\n'];
        str = [str 'static const int ' Mstr 'cols[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,1)-1) ';\n\n'];
        str = [str 'static const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
        %str = [str 'const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)) '] = ' mat2str_c(M.elem_per_row,'int') ';\n\n'];
        str = [str 'static struct SPARSE_MAT ' Mstr ' = {' int2str(size(M.val,1)) ',' int2str(length(M.elem_per_row)) ',' Mstr 'rows,' Mstr 'cols,' Mstr 'data};\n\n'];
    elseif isequal(rep,'full')
        % dense representation
        str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M,1)*size(M,2)) '] = ' mat2str_c(M) ';\n\n'];
        str = [str 'static struct FULL_MAT ' Mstr ' = {' int2str(size(M,1)) ',' int2str(size(M,2)) ',' Mstr 'data};\n\n'];
    end
else
    % if representation not specified
    if isdiag(M)
    	% diagonal representation
        str = [str 'static const ' precision ' ' Mstr 'data[' int2str(length(M)) '] = ' mat2str_c(diag(M)) ';\n\n'];
        str = [str 'static struct DIAG_MAT ' Mstr ' = {' int2str(length(M)) ',' Mstr 'data};\n\n'];
    elseif issparse(M)
    	% sparse representation
    	M = compress_row(M);
    	str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,2)) ';\n\n'];
        str = [str 'static const int ' Mstr 'cols[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,1)-1) ';\n\n'];
    	str = [str 'static const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
        %str = [str 'const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)) '] = ' mat2str_c(M.elem_per_row,'int') ';\n\n'];
        str = [str 'static struct SPARSE_MAT ' Mstr ' = {' int2str(size(M.val,1)) ',' int2str(length(M.elem_per_row)) ',' Mstr 'rows,' Mstr 'cols,' Mstr 'data};\n\n'];
    else
        % dense representation
        str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M,1)*size(M,2)) '] = ' mat2str_c(M) ';\n\n'];
        str = [str 'static struct FULL_MAT ' Mstr ' = {' int2str(size(M,1)) ',' int2str(size(M,2)) ',' Mstr 'data};\n\n'];
    end
end