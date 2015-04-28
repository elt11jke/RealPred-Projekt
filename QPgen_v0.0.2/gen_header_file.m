function gen_header_file(opts)


% generate header file-----------------------------%

if opts.stack_usage == 2
    const = 'const ';
elseif opts.stack_usage < 2
    const = '';
end

% open file to write to
fid = fopen([opts.proj_name '_files/QPgen.h'],'w');


fprintf(fid,['#ifndef MYMP_H_GUARD\n']);
fprintf(fid,['#define MYMP_H_GUARD\n\n']);

% input check 
fprintf(fid,['#define IS_REAL_2D_FULL_DOUBLE_VECTOR(z) (!mxIsComplex(z) && mxGetNumberOfDimensions(z) == 2 && !mxIsSparse(z) && mxIsDouble(z) && (mxGetN(z) == 1))\n']);
fprintf(fid,['#define min(a,b) (((a) < (b)) ? (a) : (b))\n']);
fprintf(fid,['#define max(a,b) (((a) > (b)) ? (a) : (b))\n']);
fprintf(fid,['#define mod(a,b) (a-(b*(a/b)))\n']);
fprintf(fid,['#define pow2(a) (a*a)\n\n']);


% sparse matrix struct (row-compressed) 
fprintf(fid,['struct SPARSE_MAT {\n']);
% problem data 
fprintf(fid,[const 'int nnz;\n']);
fprintf(fid,[const 'int nr;\n']);
fprintf(fid,[const 'int *row;\n']);
fprintf(fid,[const 'int *col;\n']);
fprintf(fid,[const opts.precision ' *data;\n};\n\n']);

% diagonal matrix struct
fprintf(fid,['struct DIAG_MAT {\n']);
fprintf(fid,[const 'int n;\n']);
fprintf(fid,[const opts.precision ' *data;\n};\n\n']);

% full matrix struct
fprintf(fid,['struct FULL_MAT {\n']);
fprintf(fid,[const 'int n;\n']);
fprintf(fid,[const 'int m;\n']);
fprintf(fid,[const opts.precision ' *data;\n};\n\n']);

fprintf(fid,['#endif']);


% close file
fclose(fid);


