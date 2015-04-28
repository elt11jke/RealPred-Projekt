function gen_code_mex_FGMprimal(alg_data,opts)

fprintf('Generating C code...');

% create project folder
mkdir([opts.proj_name '_files']);
mkdir([opts.proj_name '_files/' opts.proj_name '_data']);



% generate header file
gen_header_file(opts);


% generate mex gateway file
gen_mex_gateway(alg_data,opts);


% generate code for main c-file


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


% open file to write to
fid = fopen([opts.proj_name '_files/QPgen.c'],'w');


% dereference data depends on opts.stack_usage
if opts.stack_usage == 2
    data_deref = '&';
elseif opts.stack_usage < 2
    data_deref = 'd->';
end
% dereference vars depends on opts.stack_usage
if opts.stack_usage == 0
    var_deref = 'ws->';
elseif opts.stack_usage > 0
    var_deref = '';
end



% include header files
if opts.no_math_lib == 0
    fprintf(fid,['#include <math.h>\n']);
end
fprintf(fid,['#include "QPgen.h"\n\n']);
if opts.stack_usage < 2
    fprintf(fid,'#include "data_struct.h"\n\n');
end
if opts.stack_usage == 0
    fprintf(fid,'#include "work_space_struct.h"\n\n');
end

% include function definitions
fprintf(fid,[inline_fcn_def(alg_data,opts)]);

% generate data file
if not(isfield(opts,'gen_data')) || opts.gen_data == 1
    if opts.stack_usage < 2
        gen_data_file_heap(alg_data,opts);
        % initilize data using init_data()
    elseif opts.stack_usage == 2
        gen_data_file(alg_data,opts);
        fprintf(fid,['#include "' opts.proj_name '_data/alg_data.c"\n\n']);
    end
end


% generate main_loop ---------------------------------------------------
fprintf(fid,['void qp(']);
if opts.stack_usage < 2
    fprintf(fid,'struct DATA *d, ');
end
if opts.stack_usage == 0
    fprintf(fid,'struct WORK_SPACE *ws, ');
end
fprintf(fid,[opts.precision ' *x_out, int *iter']);
if alg_data.gt == 1
    fprintf(fid,[', ' opts.precision ' *gt']);
end
if alg_data.bt == 1
    fprintf(fid,[', ' opts.precision ' *bt']);
end
fprintf(fid,[') {\n\n/* define data */\n']);


if opts.stack_usage > 0
    % inline variable definitions
    inline_var_defs(fid,alg_data,opts);
else
    var_def_heap(alg_data,opts);
end

if opts.no_math_lib == 0
    fprintf(fid,[opts.precision ' theta = 1;\n']);
    fprintf(fid,[opts.precision ' theta_old = 1;\n\n']);
end


fprintf(fid,['int jj = 0;\n\n']);
fprintf(fid,[opts.precision ' cond = -1;\n\n']);


% precompute linear term in x-update (dense)
if alg_data.gt == 1
    fprintf(fid,['mat_vec_mult_' structure(alg_data.Gg) '(' data_deref 'Gg,gt,' var_deref 'q1);\n\n']);
elseif not(isempty(alg_data.Gg))
    fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'Gg,' var_deref 'q1,' int2str(size(alg_data.Gg,1)) ');\n\n']); %q1 = Q1
end
if alg_data.bt == 1
    fprintf(fid,['mat_vec_mult_' structure(alg_data.Gb) '(' data_deref 'Gb,bt,' var_deref 'q2);\n\n']);
elseif not(isempty(alg_data.Gb))
    fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'Gb,' var_deref 'q2,' int2str(size(alg_data.Gb,1)) ');\n\n']); %q2 = Q2
end
fprintf(fid,['vec_add(' var_deref 'q1,' var_deref 'q2,' var_deref 'q,' int2str(n_x) ');\n\n']);


% define upper and lower bounds
fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'Lb,' var_deref 'l,' int2str(n_y) ');\n\n']);
fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'Ub,' var_deref 'u,' int2str(n_y) ');\n\n']);


% upper and lower bound shifted if reform='eq'
if isequal(opts.reform,'eq')
    if alg_data.gt == 1
        fprintf(fid,['mat_vec_mult_' structure(alg_data.h.L1) '(' data_deref 'L1,gt,' var_deref 'tmp_var_p);\n\n']);
    elseif not(isempty(alg_data.h.L1))
        fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'L1,' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
    end
    if alg_data.bt == 1
        fprintf(fid,['mat_vec_mult_' structure(alg_data.h.L2) '(' data_deref 'L2,bt,' var_deref 'tmp_var_p2);\n\n']);
    elseif not(isempty(alg_data.h.L2))
        fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'L2,' var_deref 'tmp_var_p2,' int2str(n_y) ');\n\n']);
    end
    fprintf(fid,['vec_add(' var_deref 'tmp_var_p,' var_deref 'tmp_var_p2,' var_deref 'shift_arg,' int2str(n_y) ');\n\n']);
    %fprintf(fid,['mat_vec_mult_' structure(alg_data.E) '(' data_deref 'E,' var_deref 'shift_arg,' var_deref 'Eshift_arg);\n\n']);
    
    %fprintf(fid,['vec_add(' var_deref 'tmp_var_p,' var_deref 'tmp_var_p2,' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
    %fprintf(fid,['vec_sub(' var_deref 'l,' var_deref 'tmp_var_p,' var_deref 'l,' int2str(n_y) ');\n\n']);
    %fprintf(fid,['vec_sub(' var_deref 'u,' var_deref 'tmp_var_p,' var_deref 'u,' int2str(n_y) ');\n\n']);
end



% create vector r = r1*gt+r2*bt to recover original variables 

% add temporary variables to store intermediate results
if isequal(opts.reform,'ineq') || isequal(opts.reform,'eq')
    if alg_data.gt == 1 && not(allzeros(alg_data.r1))
        fprintf(fid,['mat_vec_mult_' structure(alg_data.r1) '(' data_deref 'r1,gt,' var_deref 'tmp_var_n_orig);\n\n']);
        %fprintf(fid,['*gt']);
    elseif not(isempty(alg_data.r1)) && not(allzeros(alg_data.r1))
        fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'r1,' var_deref 'tmp_var_n_orig,' int2str(n_orig_x) ');\n\n']);
    end
    if alg_data.bt == 1 && not(allzeros(alg_data.r2))
        fprintf(fid,['mat_vec_mult_' structure(alg_data.r2) '(' data_deref 'r2,bt,' var_deref 'tmp_var_n2_orig);\n\n']);
        %fprintf(fid,['*bt;\n\n']);
    elseif not(isempty(alg_data.r2)) && not(allzeros(alg_data.r2))
        fprintf(fid,['copy_vec_part((' opts.precision ' *) ' data_deref 'r2,' var_deref 'tmp_var_n2_orig,' int2str(n_orig_x) ');\n\n']);
    end
    fprintf(fid,['vec_add(' var_deref 'tmp_var_n_orig,' var_deref 'tmp_var_n2_orig,' var_deref 'r,' int2str(n_orig_x) ');\n\n']);
end


% add for-loop from 1 to max_iter
%fprintf(fid,['for (jj = 1; jj <= ' int2str(opts.max_iter) '; jj++ ) {\n\n']);

% add while-loop from 1 to max_iter or cond
fprintf(fid,['while ((jj < ' int2str(opts.max_iter) ') && (cond < 0)) {\n\n']);


% increase variable counter
fprintf(fid,['jj++;\n\n']);

% x variable update
    
% implements gradient step x^+ = v-1/L(Hv+q)

fprintf(fid,['mat_vec_mult_' structure(alg_data.H) '(' data_deref 'H,' var_deref 'v,' var_deref 'tmp_var_n);\n\n']);
fprintf(fid,['vec_add(' var_deref 'tmp_var_n,' var_deref 'q,' var_deref 'tmp_var_n2,' int2str(n_x) ');\n\n']);
%fprintf(fid,['scalar_mult(' num2str(1/alg_data.L,15) ',tmp_var_n2,' int2str(n_x) ');\n\n']);
fprintf(fid,['vec_sub(' var_deref 'v,' var_deref 'tmp_var_n2,' var_deref 'x,' int2str(n_x) ');\n\n']);    


% y variable update: x = clip(x,l,u) (prox-step)
fprintf(fid,['copy_vec_part(' var_deref 'y,' var_deref 'y_old,' int2str(n_x) ');\n\n']);
fprintf(fid,['copy_vec_part(' var_deref 'x,' var_deref 'y,' int2str(n_x) ');\n\n']);
if isequal(opts.reform,'eq')
   fprintf(fid,['vec_add(' var_deref 'y,' var_deref 'shift_arg,' var_deref 'y,' int2str(n_x) ');\n\n']); 
end
if max(alg_data.h.soft) > 0
   % soft constraints 
   fprintf(fid,['clip_soft(' var_deref 'y,' var_deref 'l,' var_deref 'u,(' opts.precision ' *) ' data_deref 'soft,' int2str(n_x) ');\n\n']);
else
    % hard constraints
    fprintf(fid,['clip(' var_deref 'y,' var_deref 'l,' var_deref 'u,' int2str(n_x) ');\n\n']);
end
if isequal(opts.reform,'eq')
    fprintf(fid,['vec_sub(' var_deref 'y,' var_deref 'shift_arg,' var_deref 'y,' int2str(n_x) ');\n\n']);
end


% acceleration term in FGM
fprintf(fid,['vec_sub(' var_deref 'y,' var_deref 'y_old,' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
if alg_data.str_conv > 0
    fprintf(fid,['scalar_mult(' num2str(alg_data.str_conv,15) ',' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
else
    if opts.no_math_lib == 0
        fprintf(fid,['theta_old = theta;\n\n']);
        fprintf(fid,['theta = (1+sqrt(1+4*pow(theta_old,2)))/2;\n\n']);
        fprintf(fid,['scalar_mult((theta_old-1)/theta,' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
    else
        fprintf(fid,['scalar_mult((jj-1)/(jj+2),' var_deref 'tmp_var_p,' int2str(n_y) ');\n\n']);
    end
end
if opts.restart == 1
   fprintf(fid,['copy_vec_part(' var_deref 'v,' var_deref 'v_old,' int2str(n_y) ');\n\n']); 
end

fprintf(fid,['vec_add(' var_deref 'tmp_var_p,' var_deref 'y,' var_deref 'v,' int2str(n_y) ');\n\n']);

% check stopping condition
fprintf(fid,['if (mod(jj,' int2str(opts.check_opt_interval) ') == 0) {\n cond = check_stop_cond_FGM(' data_deref 'Einv,' var_deref 'y,' var_deref 'y_old,' var_deref 'tmp_var_p,' var_deref 'tmp_var_p2,' int2str(n_y) ',' num2str(opts.rel_tol) ');\n }\n\n']);

% add adaptive restart
if opts.restart == 1
   fprintf(fid,['restart(' var_deref 'y,' var_deref 'y_old,' var_deref 'v,' var_deref 'v_old,' var_deref 'tmp_var_p,' var_deref 'tmp_var_p2,' int2str(n_y) ');\n\n']);
end



% end for loop
fprintf(fid,['}\n\n']);



%if isequal(alg_data.F,eye(n))
    fprintf(fid,['mat_vec_mult_' structure(alg_data.R) '(' data_deref 'R,' var_deref 'y,' var_deref 'tmp_var_n_orig);\n\n']);
    fprintf(fid,['vec_add(' var_deref 'tmp_var_n_orig,' var_deref 'r,x_out,' int2str(n_orig_x) ');\n\n']);
    %fprintf(fid,['x_out = R*x+r;\n\n']);
%else
    %fprintf(fid,['x_out = F*(R*x+r);\n\n']);
%end


fprintf(fid,['*iter = jj;\n\n']);


fprintf(fid,['}']);

% close file
fclose(fid);

fprintf('done!\n');