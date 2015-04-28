function gen_mex_gateway(alg_data,opts)

% nbr of elements in gt
n_gt = size(alg_data.G,2);
% nbr of elements in bt
n_bt = size(alg_data.B,2);
% nbr of elements in x-variable
n_x = length(alg_data.H);

% nbr of elements in original variable
if isequal(opts.reform,'original')
    n_orig_x = length(alg_data.H);
elseif isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    n_orig_x = size(alg_data.R,1);
end


% open file to write to
fid = fopen([opts.proj_name '_files/qp_mex.c'],'w');


% generate code for mex gateway file -----------------------------------%

fprintf(fid,'#include "mex.h"\n');

fprintf(fid,'#include "QPgen.h"\n');

if opts.stack_usage < 2
    fprintf(fid,'#include "data_struct.h"\n');
end
if opts.stack_usage == 0
    fprintf(fid,'#include "work_space_struct.h"\n');
end

fprintf(fid,['\n\n void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {\n\n /* define variables */\n double *x;\n int *iter;']);
if alg_data.gt == 1
    fprintf(fid,['double *gt;\n']);
end
if alg_data.bt == 1
    fprintf(fid,['double *bt;\n\n']);
end


if isequal(opts.precision,'float')
    fprintf(fid,['float xf[' int2str(n_orig_x) '] = {0};\n']);
    if alg_data.gt == 1
        fprintf(fid,['float gtf[' int2str(n_gt) '] = {0};\n']);
    end
    if alg_data.bt == 1
       fprintf(fid,['float btf[' int2str(n_bt) '] = {0};\n']);
    end
end

fprintf(fid,['/* check inputs */\n\n if (!(nrhs == ']);
    
fprintf(fid,[int2str(alg_data.gt+alg_data.bt) ')) {\n mexErrMsgTxt("Wrong nbr of inputs");\n} \n\n']);

if alg_data.gt == 1
    fprintf(fid,['gt = mxGetPr(prhs[0]);\n']);
    fprintf(fid,['if (!IS_REAL_2D_FULL_DOUBLE_VECTOR(prhs[0])  || (mxGetM(prhs[0]) != ']);
    fprintf(fid,[int2str(n_gt) ')){\n mexErrMsgTxt("Input 1 should be real full vector of size (']);
    fprintf(fid,[int2str(n_gt) ',1)");\n}\n\n']);

    if isequal(opts.precision,'float')
       fprintf(fid,['copy_double_to_float(gt,gtf,' int2str(n_gt) ');\n\n']); 
    end
end

if alg_data.bt == 1
    fprintf(fid,['bt = mxGetPr(prhs[' int2str(alg_data.gt) ']);\n\n']);
    fprintf(fid,['if (!IS_REAL_2D_FULL_DOUBLE_VECTOR(prhs[' int2str(alg_data.gt) '])  || (mxGetM(prhs[' int2str(alg_data.gt) ']) != ']);
    fprintf(fid,[int2str(n_bt) ')){\n mexErrMsgTxt("Input ' int2str(alg_data.gt+1) ' should be real full vector of size (']);
    fprintf(fid,[int2str(n_bt) ',1)");\n}\n\n']);
    
    if isequal(opts.precision,'float')
        fprintf(fid,['copy_double_to_float(bt,btf,' int2str(n_bt) ');\n\n']);
    end
end

fprintf(fid,['/* set output */\n plhs[0] = mxCreateDoubleMatrix(' int2str(n_orig_x) ',1,mxREAL);\n\n']);
fprintf(fid,['x = mxGetPr(plhs[0]);\n\n /* run main loop */\n']);

fprintf(fid,['plhs[1] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);\n\n']);
fprintf(fid,['iter = (int *) mxGetData(plhs[1]);\n\n']);

% intialize data
if opts.stack_usage < 2
    fprintf(fid,'struct DATA *d = malloc(sizeof(struct DATA));\n\n');
    fprintf(fid,'init_data(d);\n\n');
end
if opts.stack_usage == 0
    fprintf(fid,'struct WORK_SPACE *ws = malloc(sizeof(struct WORK_SPACE));\n\n');
    fprintf(fid,'init_work_space(ws);\n\n');
end



% help strings for argument list
if opts.stack_usage < 2
    arg_str = 'd,';
    if opts.stack_usage == 0
        arg_str = [arg_str 'ws,'];
    end
elseif opts.stack_usage == 2
    arg_str = '';
end
if isequal(opts.precision,'float')
    suffix = 'f';
elseif isequal(opts.precision,'double')
    suffix = '';
end

% run qp solver
if alg_data.gt + alg_data.bt == 2
    fprintf(fid,['qp(' arg_str 'x' suffix ',iter,gt' suffix ',bt' suffix ');\n\n']);
elseif alg_data.gt == 1
    fprintf(fid,['qp(' arg_str 'x' suffix ',iter,gt' suffix ');\n\n']);
elseif alg_data.bt == 1
    fprintf(fid,['qp(' arg_str 'x' suffix ',iter,bt' suffix ');\n\n']);
end

if 0
if isequal(opts.precision,'float')
    if alg_data.gt + alg_data.bt == 2
        fprintf(fid,['qp(' d 'xf,iter,gtf,btf);\n\n']);
    elseif alg_data.gt == 1
        fprintf(fid,['qp(' d 'xf,iter,gtf);\n\n']);
    elseif alg_data.bt == 1
        fprintf(fid,['qp(' d 'xf,iter,btf);\n\n']);
    end
    
else
    if alg_data.gt + alg_data.bt == 2
        fprintf(fid,['qp(' d 'x,iter,gt,bt);\n\n']);
    elseif alg_data.gt == 1
        fprintf(fid,['qp(' d 'x,iter,gt);\n\n']);
    elseif alg_data.bt == 1
        fprintf(fid,['qp(' d 'x,iter,bt);\n\n']);
    end
end
end

if isequal(opts.precision,'float')
    fprintf(fid,['copy_float_to_double(xf,x,' int2str(n_orig_x) ');\n\n']);
end

% free malloc:ed data
if opts.stack_usage < 2
    fprintf(fid,'free_data(d);\n\n');
end

if opts.stack_usage == 0
    fprintf(fid,'free_work_space(ws);\n\n');
end

fprintf(fid,['}']);

% close file
fclose(fid);

