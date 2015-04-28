function str = def_vec_heap(M,Mstr,opts)

precision = opts.precision;

data_folder = [opts.proj_name '_files/' opts.proj_name '_data/'];

str = [];

% vector representation
if isequal(precision,'int')
    array_to_binary_int(M,[data_folder Mstr '.bin']);
else
    eval(['array_to_binary_' precision '(M,''' data_folder Mstr '.bin'')']);
end
str = [str precision ' *' Mstr ' = malloc(' int2str(length(M)) '*sizeof(' precision '));\n\n']; 
if isequal(precision,'int')
    str = [str 'read_binary_int(' Mstr ',' int2str(length(M)) ',"' data_folder Mstr '.bin");\n\n'];
else
    str = [str 'read_binary_' precision '(' Mstr ',' int2str(length(M)) ',"' data_folder Mstr '.bin");\n\n'];
end

%str = [str '*' Mstr ' = ' mat2str_c(M) ';\n\n'];