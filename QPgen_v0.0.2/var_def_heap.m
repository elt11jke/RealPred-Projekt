function var_def_heap(alg_data,opts)


% nbr of elements in gt
n_gt = size(alg_data.G,2);
% nbr of elements in bt
n_bt = size(alg_data.B,2);
% nbr of elements in x-variable
n_x = length(alg_data.H);
% nbr of elements in y and lambda varialbes
n_y = size(alg_data.C,1);

% nbr of elements in original variable
if isequal(opts.reform,'original')
    n_orig_x = length(alg_data.H);
elseif isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    n_orig_x = size(alg_data.R,1);
end

% open file streams
fid_init = fopen([opts.proj_name '_files/init_work_space.c'],'w');
fid_free = fopen([opts.proj_name '_files/free_work_space.c'],'w');
fid_work_space = fopen([opts.proj_name '_files/work_space_struct.h'],'w');

% include header files
fprintf(fid_init,'#include <stdlib.h>\n#include "work_space_struct.h"\n\n');
fprintf(fid_free,'#include <stdlib.h>\n#include "work_space_struct.h"\n\n');

% initilize functions
fprintf(fid_init,'void init_work_space(struct WORK_SPACE *ws) {\n\n');
fprintf(fid_free,'void free_work_space(struct WORK_SPACE *ws) {\n\n');
fprintf(fid_work_space,'struct WORK_SPACE {\n');


% precompute linear term in x-update (dense) and r.h.s. in .. (sparse)
if opts.dense == 1 || isequal(opts.alg,'FGMprimal')
    fprintf(fid_init,[opts.precision ' *q = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' q[' int2str(n_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->q = q;\n\n');
    fprintf(fid_free,'free(ws->q);\n\n');
    fprintf(fid_work_space,[opts.precision ' *q;\n\n']);
    
    fprintf(fid_init,[opts.precision ' *q1 = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' q1[' int2str(n_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->q1 = q1;\n\n');
    fprintf(fid_free,'free(ws->q1);\n\n');
    fprintf(fid_work_space,[opts.precision ' *q1;\n\n']);
    
    fprintf(fid_init,[opts.precision ' *q2 = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' q2[' int2str(n_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->q2 = q2;\n\n');
    fprintf(fid_free,'free(ws->q2);\n\n');
    fprintf(fid_work_space,[opts.precision ' *q2;\n\n']);
elseif opts.dense == 0
    % r.h.s. of equality constraint in sparse x-update
    fprintf(fid_init,[opts.precision ' *q = calloc(' int2str(n_x+size(alg_data.B,1)) ',sizeof(' opts.precision '));\n\n']);
   %fprintf(fid_init,[opts.precision ' q[' int2str(n_x+size(alg_data.B,1)) ']= {0};\n\n']);
   fprintf(fid_init,'ws->q = q;\n\n');
   fprintf(fid_free,'free(ws->q);\n\n');
   fprintf(fid_work_space,[opts.precision ' *q;\n\n']);
   
   fprintf(fid_init,[opts.precision ' *q1 = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
   %fprintf(fid_init,[opts.precision ' q1[' int2str(n_x) ']= {0};\n\n']);
   fprintf(fid_init,'ws->q1 = q1;\n\n');
   fprintf(fid_free,'free(ws->q1);\n\n');
   fprintf(fid_work_space,[opts.precision ' *q1;\n\n']);
   
   if not(isempty(alg_data.B))
        fprintf(fid_init,[opts.precision ' *q2 = calloc(' int2str(size(alg_data.B,1)) ',sizeof(' opts.precision '));\n\n']);
        %fprintf(fid_init,[opts.precision ' q2[' int2str(size(alg_data.B,1)) ']= {0};\n\n']);
        fprintf(fid_init,'ws->q2 = q2;\n\n');
        fprintf(fid_free,'free(ws->q2);\n\n');
        fprintf(fid_work_space,[opts.precision ' *q2;\n\n']);
   end
end


% define upper and lower bounds
fprintf(fid_init,[opts.precision ' *l = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' l[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid_init,'ws->l = l;\n\n');
fprintf(fid_free,'free(ws->l);\n\n');
fprintf(fid_work_space,[opts.precision ' *l;\n\n']);

fprintf(fid_init,[opts.precision ' *u = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' u[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid_init,'ws->u = u;\n\n');
fprintf(fid_free,'free(ws->u);\n\n');
fprintf(fid_work_space,[opts.precision ' *u;\n\n']);


% init shift prox argument when reform = 'eq'
if isequal(opts.reform,'eq')
    fprintf(fid_init,[opts.precision ' *shift_arg = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid,[opts.precision ' shift_arg[' int2str(n_y) '] = {0};\n\n']);
    fprintf(fid_init,'ws->shift_arg = shift_arg;\n\n');
    fprintf(fid_free,'free(ws->shift_arg);\n\n');
    fprintf(fid_work_space,[opts.precision ' *shift_arg;\n\n']);
    
    fprintf(fid_init,[opts.precision ' *Eshift_arg = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid,[opts.precision ' Eshift_arg[' int2str(n_y) '] = {0};\n\n']);
    fprintf(fid_init,'ws->Eshift_arg = Eshift_arg;\n\n');
    fprintf(fid_free,'free(ws->Eshift_arg);\n\n');
    fprintf(fid_work_space,[opts.precision ' *Eshift_arg;\n\n']);
end





fprintf(fid_init,[opts.precision ' *tmp_var_p = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' tmp_var_p[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid_init,'ws->tmp_var_p = tmp_var_p;\n\n');
fprintf(fid_free,'free(ws->tmp_var_p);\n\n');
fprintf(fid_work_space,[opts.precision ' *tmp_var_p;\n\n']);

fprintf(fid_init,[opts.precision ' *tmp_var_p2 = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' tmp_var_p2[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid_init,'ws->tmp_var_p2 = tmp_var_p2;\n\n');
fprintf(fid_free,'free(ws->tmp_var_p2);\n\n');
fprintf(fid_work_space,[opts.precision ' *tmp_var_p2;\n\n']);

if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM')
    fprintf(fid_init,[opts.precision ' *arg_prox_h = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' arg_prox_h[' int2str(n_y) '] = {0};\n\n']);
    fprintf(fid_init,'ws->arg_prox_h = arg_prox_h;\n\n');
    fprintf(fid_free,'free(ws->arg_prox_h);\n\n');
    fprintf(fid_work_space,[opts.precision ' *arg_prox_h;\n\n']);
end

% create vector r = r1*gt+r2*bt to recover original variables 

if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq') || isequal(opts.alg,'FGMprimal')
    % add temporary variables to store intermediate results
    fprintf(fid_init,[opts.precision ' *tmp_var_n_orig = calloc(' int2str(n_orig_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' tmp_var_n_orig[' int2str(n_orig_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->tmp_var_n_orig = tmp_var_n_orig;\n\n');
    fprintf(fid_free,'free(ws->tmp_var_n_orig);\n\n');
    fprintf(fid_work_space,[opts.precision ' *tmp_var_n_orig;\n\n']);

    fprintf(fid_init,[opts.precision ' *tmp_var_n2_orig = calloc(' int2str(n_orig_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' tmp_var_n2_orig[' int2str(n_orig_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->tmp_var_n2_orig = tmp_var_n2_orig;\n\n');
    fprintf(fid_free,'free(ws->tmp_var_n2_orig);\n\n');
    fprintf(fid_work_space,[opts.precision ' *tmp_var_n2_orig;\n\n']);

    fprintf(fid_init,[opts.precision ' *r = calloc(' int2str(n_orig_x) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' r[' int2str(n_orig_x) '] = {0};\n\n']);
    fprintf(fid_init,'ws->r = r;\n\n');
    fprintf(fid_free,'free(ws->r);\n\n');
    fprintf(fid_work_space,[opts.precision ' *r;\n\n']);

end


% initialize algorithm state (cold-starting)
if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM')
    fprintf(fid_init,[opts.precision ' *lambda = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' lambda[' int2str(n_y) '] = {0};\n']);
    fprintf(fid_init,'ws->lambda = lambda;\n\n');
    fprintf(fid_free,'free(ws->lambda);\n\n');
    fprintf(fid_work_space,[opts.precision ' *lambda;\n\n']);
end
fprintf(fid_init,[opts.precision ' *y = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' y[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid_init,'ws->y = y;\n\n');
fprintf(fid_free,'free(ws->y);\n\n');
fprintf(fid_work_space,[opts.precision ' *y;\n\n']);

fprintf(fid_init,[opts.precision ' *x = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' x[' int2str(n_x) '] = {0};\n\n']);
fprintf(fid_init,'ws->x = x;\n\n');
fprintf(fid_free,'free(ws->x);\n\n');
fprintf(fid_work_space,[opts.precision ' *x;\n\n']);

if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'FGMprimal')
    if isequal(opts.alg,'FGMdual')
        fprintf(fid_init,[opts.precision ' *lambda_old = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
        %fprintf(fid_init,[opts.precision ' lambda_old[' int2str(n_y) '] = {0};\n']);
        fprintf(fid_init,'ws->lambda_old = lambda_old;\n\n');
        fprintf(fid_free,'free(ws->lambda_old);\n\n');
        fprintf(fid_work_space,[opts.precision ' *lambda_old;\n\n']);
    end
    fprintf(fid_init,[opts.precision ' *v = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' v[' int2str(n_y) '] = {0};\n']);
    fprintf(fid_init,'ws->v = v;\n\n');
    fprintf(fid_free,'free(ws->v);\n\n');
    fprintf(fid_work_space,[opts.precision ' *v;\n\n']);
    
    if opts.restart == 1
        fprintf(fid_init,[opts.precision ' *v_old = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
        %fprintf(fid_init,[opts.precision ' v_old[' int2str(n_y) '] = {0};\n']);
        fprintf(fid_init,'ws->v_old = v_old;\n\n');
        fprintf(fid_free,'free(ws->v_old);\n\n');
        fprintf(fid_work_space,[opts.precision ' *v_old;\n\n']);
    end
end
if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMprimal')
    fprintf(fid_init,[opts.precision ' *y_old = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' y_old[' int2str(n_y) '] = {0};\n\n']);
    fprintf(fid_init,'ws->y_old = y_old;\n\n');
    fprintf(fid_free,'free(ws->y_old);\n\n');
    fprintf(fid_work_space,[opts.precision ' *y_old;\n\n']);
    
    if isequal(opts.alg,'ADMM')
        fprintf(fid_init,[opts.precision ' *Cx = calloc(' int2str(n_y) ',sizeof(' opts.precision '));\n\n']);
        %fprintf(fid_init,[opts.precision ' Cx[' int2str(n_y) '] = {0};\n\n']);
        fprintf(fid_init,'ws->Cx = Cx;\n\n');
        fprintf(fid_free,'free(ws->Cx);\n\n');
        fprintf(fid_work_space,[opts.precision ' *Cx;\n\n']);
    end
end


% add temporary variables to store intermediate results
fprintf(fid_init,[opts.precision ' *tmp_var_n = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' tmp_var_n[' int2str(n_x) '] = {0};\n\n']);
fprintf(fid_init,'ws->tmp_var_n = tmp_var_n;\n\n');
fprintf(fid_free,'free(ws->tmp_var_n);\n\n');
fprintf(fid_work_space,[opts.precision ' *tmp_var_n;\n\n']);

fprintf(fid_init,[opts.precision ' *tmp_var_n2 = calloc(' int2str(n_x) ',sizeof(' opts.precision '));\n\n']);
%fprintf(fid_init,[opts.precision ' tmp_var_n2[' int2str(n_x) '] = {0};\n\n']);
fprintf(fid_init,'ws->tmp_var_n2 = tmp_var_n2;\n\n');
fprintf(fid_free,'free(ws->tmp_var_n2);\n\n');
fprintf(fid_work_space,[opts.precision ' *tmp_var_n2;\n\n']);

% add temporary variables to store intermediate results
if opts.dense == 0 && (isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM'))
    fprintf(fid_init,[opts.precision ' *tmp_var_nm = calloc(' int2str(n_x+size(alg_data.B,1)) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' tmp_var_nm[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
    fprintf(fid_init,'ws->tmp_var_nm = tmp_var_nm;\n\n');
    fprintf(fid_free,'free(ws->tmp_var_nm);\n\n');
    fprintf(fid_work_space,[opts.precision ' *tmp_var_nm;\n\n']);
    
    fprintf(fid_init,[opts.precision ' *tmp_var_nm2 = calloc(' int2str(n_x+size(alg_data.B,1)) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' tmp_var_nm2[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
    fprintf(fid_init,'ws->tmp_var_nm2 = tmp_var_nm2;\n\n');
    fprintf(fid_free,'free(ws->tmp_var_nm2);\n\n');
    fprintf(fid_work_space,[opts.precision ' *tmp_var_nm2;\n\n']);
    
    fprintf(fid_init,[opts.precision ' *rhs = calloc(' int2str(n_x+size(alg_data.B,1)) ',sizeof(' opts.precision '));\n\n']);
    %fprintf(fid_init,[opts.precision ' rhs[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
    fprintf(fid_init,'ws->rhs = rhs;\n\n');
    fprintf(fid_free,'free(ws->rhs);\n\n');
    fprintf(fid_work_space,[opts.precision ' *rhs;\n\n']);
end

% free ws
fprintf(fid_free,'free(ws);\n\n');

% closing bracket
fprintf(fid_init,'}\n\n');
fprintf(fid_free,'}\n\n');
fprintf(fid_work_space,'};\n\n');



% close files
fclose(fid_init);
fclose(fid_free);
fclose(fid_work_space);