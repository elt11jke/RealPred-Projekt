function str = def_mat_heap(M,Mstr,opts,rep)

str = [];

precision = opts.precision;

data_folder = [opts.proj_name '_files/' opts.proj_name '_data/'];

if nargin == 4
    % if representation specified
    if isequal(rep,'diag')
        % diagonal representation
        eval(['array_to_binary_' precision '(diag(M),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(length(M)) '*sizeof(' precision '));\n\n'];
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(length(M)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '' Mstr 'data = (' precision '[' int2str(length(M)) ']) ' mat2str_c(diag(M)) ';\n\n'];
        
        str = [str 'struct DIAG_MAT *' Mstr ' = malloc(sizeof(struct DIAG_MAT));\n\n'];
        str = [str Mstr '->n = ' int2str(length(M)) ';\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];
        
        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(length(M)) '] = ' mat2str_c(diag(M)) ';\n\n'];
        %str = [str 'static struct DIAG_MAT ' Mstr ' = {' int2str(length(M)) ',' Mstr 'data};\n\n'];
    elseif isequal(rep,'sparse')
        % sparse representation
        %M = compress_row(M);
        
        eval(['array_to_binary_' precision '(M.val(:,2),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(size(M.val,1)) '*sizeof(' precision '));\n\n']; 
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(size(M.val,1)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '' Mstr 'data = (' precision '[' int2str(size(M.val,1)) ']) ' mat2str_c(M.val(:,2)) ';\n\n'];
        
        array_to_binary_int(M.val(:,1)-1,[data_folder Mstr 'cols.bin']);
        str = [str 'int *' Mstr 'cols = malloc(' int2str(size(M.val,1)) '*sizeof(int));\n\n']; 
        str = [str 'read_binary_int(' Mstr 'cols,' int2str(size(M.val,1)) ',"' data_folder Mstr 'cols.bin");\n\n'];
        %str = [str '*' Mstr 'cols = (int[' int2str(size(M.val,1)) ']) ' mat2str_c(M.val(:,1)-1) ';\n\n'];
        
        array_to_binary_int(cumsum([0;M.elem_per_row]),[data_folder Mstr 'rows.bin']);
        str = [str 'int *' Mstr 'rows = malloc(' int2str(length(M.elem_per_row)+1) '*sizeof(int));\n\n']; 
        str = [str 'read_binary_int(' Mstr 'rows,' int2str(length(M.elem_per_row)+1) ',"' data_folder Mstr 'rows.bin");\n\n'];
        %str = [str '*' Mstr 'rows = (int[' int2str(length(M.elem_per_row)+1) ']) ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
                
        str = [str 'struct SPARSE_MAT *' Mstr ' = malloc(sizeof(struct SPARSE_MAT));\n\n'];
        str = [str Mstr '->nnz = ' int2str(size(M.val,1)) ';\n\n'];
        str = [str Mstr '->nr = ' int2str(length(M.elem_per_row)) ';\n\n'];
        str = [str Mstr '->row = ' Mstr 'rows;\n\n'];
        str = [str Mstr '->col = ' Mstr 'cols;\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];
        
        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,2)) ';\n\n'];
        %str = [str 'static const int ' Mstr 'cols[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,1)-1) ';\n\n'];
        %str = [str 'static const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
        %str = [str 'static struct SPARSE_MAT ' Mstr ' = {' int2str(size(M.val,1)) ',' int2str(length(M.elem_per_row)) ',' Mstr 'rows,' Mstr 'cols,' Mstr 'data};\n\n'];
    elseif isequal(rep,'full')
        % dense representation
        eval(['array_to_binary_' precision '(reshape(M'',size(M,1)*size(M,2),1),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(size(M,1)*size(M,2)) '*sizeof(' precision '));\n\n']; 
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(size(M,1)*size(M,2)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '*' Mstr 'data = (' precision '[' int2str(length(M)) ']) ' mat2str_c(M) ';\n\n'];
  
        str = [str 'struct FULL_MAT *' Mstr ' = malloc(sizeof(struct FULL_MAT));\n\n'];
        str = [str Mstr '->n = ' int2str(size(M,1)) ';\n\n'];
        str = [str Mstr '->m = ' int2str(size(M,2)) ';\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];
        
        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M,1)*size(M,2)) '] = ' mat2str_c(M) ';\n\n'];
        %str = [str 'static struct FULL_MAT ' Mstr ' = {' int2str(size(M,1)) ',' int2str(size(M,2)) ',' Mstr 'data};\n\n'];
    end
else
    % if representation not specified
    if isdiag(M)
    	% diagonal representation
        eval(['array_to_binary_' precision '(diag(M),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(length(M)) '*sizeof(' precision '));\n\n']; 
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(length(M)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '*' Mstr 'data = (' precision '[' int2str(length(M)) ']) ' mat2str_c(diag(M)) ';\n\n'];
        
        str = [str 'struct DIAG_MAT *' Mstr ' = malloc(sizeof(struct DIAG_MAT));\n\n'];
        str = [str Mstr '->n = ' int2str(length(M)) ';\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];

        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(length(M)) '] = ' mat2str_c(diag(M)) ';\n\n'];
        %str = [str 'static struct DIAG_MAT ' Mstr ' = {' int2str(length(M)) ',' Mstr 'data};\n\n'];
    elseif issparse(M)
    	% sparse representation
    	M = compress_row(M);
        eval(['array_to_binary_' precision '(M.val(:,2),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(size(M.val,1)) '*sizeof(' precision '));\n\n']; 
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(size(M.val,1)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '*' Mstr 'data = (' precision '[' int2str(size(M.val,1)) ']) ' mat2str_c(M.val(:,2)) ';\n\n'];
        
        array_to_binary_int(M.val(:,1)-1,[data_folder Mstr 'cols.bin']);
        str = [str 'int *' Mstr 'cols = malloc(' int2str(size(M.val,1)) '*sizeof(int));\n\n']; 
        str = [str 'read_binary_int(' Mstr 'cols,' int2str(size(M.val,1)) ',"' data_folder Mstr 'cols.bin");\n\n'];
        %str = [str '*' Mstr 'cols = (int[' int2str(size(M.val,1)) ']) ' mat2str_c(M.val(:,1)-1) ';\n\n'];
        
        array_to_binary_int(cumsum([0;M.elem_per_row]),[data_folder Mstr 'rows.bin']);
        str = [str 'int *' Mstr 'rows = malloc(' int2str(length(M.elem_per_row)+1) '*sizeof(int));\n\n']; 
        str = [str 'read_binary_int(' Mstr 'rows,' int2str(length(M.elem_per_row)+1) ',"' data_folder Mstr 'rows.bin");\n\n'];
        %str = [str '*' Mstr 'rows = (int[' int2str(length(M.elem_per_row)+1) ']) ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
                
        str = [str 'struct SPARSE_MAT *' Mstr ' = malloc(sizeof(struct SPARSE_MAT));\n\n'];
        str = [str Mstr '->nnz = ' int2str(size(M.val,1)) ';\n\n'];
        str = [str Mstr '->nr = ' int2str(length(M.elem_per_row)) ';\n\n'];
        str = [str Mstr '->row = ' Mstr 'rows;\n\n'];
        str = [str Mstr '->col = ' Mstr 'cols;\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];
        
        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,2)) ';\n\n'];
        %str = [str 'static const int ' Mstr 'cols[' int2str(size(M.val,1)) '] = ' mat2str_c(M.val(:,1)-1) ';\n\n'];
    	%str = [str 'static const int ' Mstr 'rows[' int2str(size(M.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;M.elem_per_row])) ';\n\n'];
        %str = [str 'static struct SPARSE_MAT ' Mstr ' = {' int2str(size(M.val,1)) ',' int2str(length(M.elem_per_row)) ',' Mstr 'rows,' Mstr 'cols,' Mstr 'data};\n\n'];
    else
        % dense representation
        eval(['array_to_binary_' precision '(reshape(M'',size(M,1)*size(M,2),1),''' data_folder Mstr 'data.bin'');']);
        str = [str precision ' *' Mstr 'data = malloc(' int2str(size(M,1)*size(M,2)) '*sizeof(' precision '));\n\n']; 
        str = [str 'read_binary_' precision '(' Mstr 'data,' int2str(size(M,1)*size(M,2)) ',"' data_folder Mstr 'data.bin");\n\n'];
        %str = [str '*' Mstr 'data = (' precision '[' int2str(length(M)) ']) ' mat2str_c(M) ';\n\n'];
  
        str = [str 'struct FULL_MAT *' Mstr ' = malloc(sizeof(struct FULL_MAT));\n\n'];
        str = [str Mstr '->n = ' int2str(size(M,1)) ';\n\n'];
        str = [str Mstr '->m = ' int2str(size(M,2)) ';\n\n'];
        str = [str Mstr '->data = ' Mstr 'data;\n\n'];
        
        
        %str = [str 'static const ' precision ' ' Mstr 'data[' int2str(size(M,1)*size(M,2)) '] = ' mat2str_c(M) ';\n\n'];
        %str = [str 'static struct FULL_MAT ' Mstr ' = {' int2str(size(M,1)) ',' int2str(size(M,2)) ',' Mstr 'data};\n\n'];
    end
end

