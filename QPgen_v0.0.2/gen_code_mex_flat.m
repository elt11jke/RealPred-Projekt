function gen_code_mex_flat(alg_data,opts)

fprintf('Generating C code...');

% nbr of elements in gt
n_gt = size(alg_data.G,2);
% nbr of elements in bt
n_bt = size(alg_data.B,2);
% nbr of elements in output
n_x = length(alg_data.H);


% nbr of elements in original variable
if isequal(opts.reform,'original')
    n_orig_x = length(alg_data.H);
elseif isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    n_orig_x = size(alg_data.R,1);
end


% generate code for mex gateway file -----------------------------------%

file_str = '#include "mex.h"\n #include "my_mp.h"\n\n void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {\n\n /* define variables */\n double *x;\n';
if alg_data.gt == 1
file_str = [file_str 'double *gt;\n'];
end
if alg_data.bt == 1
    file_str = [file_str 'double *bt;\n\n'];
end

file_str = [file_str '/* check inputs */\n\n if (!(nrhs == '];
    
file_str = [file_str int2str(alg_data.gt+alg_data.bt) ')) {\n mexErrMsgTxt("Wrong nbr of inputs");\n} \n\n'];

if alg_data.gt == 1
    file_str = [file_str 'gt = mxGetPr(prhs[0]);\n'];
    file_str = [file_str 'if (!IS_REAL_2D_FULL_DOUBLE_VECTOR(prhs[0])  || (mxGetM(prhs[0]) != '];
    file_str = [file_str int2str(n_gt) ')){\n mexErrMsgTxt("Input 1 should be real full vector of size ('];
    file_str = [file_str int2str(n_gt) ',1)");\n}\n\n'];
end
if alg_data.bt == 1
    file_str = [file_str 'bt = mxGetPr(prhs[' int2str(alg_data.gt) ']);\n\n'];
    file_str = [file_str 'if (!IS_REAL_2D_FULL_DOUBLE_VECTOR(prhs[' int2str(alg_data.gt) '])  || (mxGetM(prhs[' int2str(alg_data.gt) ']) != '];
    file_str = [file_str int2str(n_bt) ')){\n mexErrMsgTxt("Input ' int2str(alg_data.gt+1) ' should be real full vector of size ('];
    file_str = [file_str int2str(n_bt) ',1)");\n}\n\n'];
end

file_str = [file_str '/* set output */\nplhs[0] = mxCreateDoubleMatrix(' int2str(n_orig_x) ',1,mxREAL);\n\n'];
file_str = [file_str 'x = mxGetPr(plhs[0]);\n\n /* run main loop */\n'];

if alg_data.gt + alg_data.bt == 2
    file_str = [file_str 'main_loop(x,gt,bt);\n}'];
elseif alg_data.gt == 1
    file_str = [file_str 'main_loop(x,gt);\n}'];
elseif alg_data.bt == 1
    file_str = [file_str 'main_loop(x,bt);\n}'];
end

% save to text-file
fid = fopen('my_mp_c.c','w');

fprintf(fid,file_str);



% generate code for main c-file----------------------------------------%

% clear string to be written to file
file_str = [];

file_str = '#include "my_mp.h"\n\n';

if not(isequal(opts.alg,'ADMM'))
    file_str = [file_str '#include "math.h"\n'];
end



% include main_loop
file_str = [file_str 'void main_loop(double *x_out'];
if alg_data.gt == 1
    file_str = [file_str ', double *gt'];
end
if alg_data.bt == 1
    file_str = [file_str ', double *bt'];
end
file_str = [file_str ') {\n\n'];

% define variables

% sets target code
target = 'C';



% precompute linear term in x-update (dense) and r.h.s. in .. (sparse)
if opts.dense == 1
    file_str = [file_str 'double q[' int2str(n_x) '] = {0};\n\n'];
    file_str = [file_str 'double q1[' int2str(n_x) '] = {0};\n\n'];
    file_str = [file_str 'double q2[' int2str(n_x) '] = {0};\n\n'];
    
    if alg_data.gt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.Q1,'gt','q1',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&Q1,gt,q1);\n\n'];
    elseif not(isempty(alg_data.Q1))
        file_str = [file_str 'q1 = ' exp_flat_vec(Q1,target) '\n\n\n\n'];
        %file_str = [file_str 'q1 = Q1;\n\n'];
    end
    if alg_data.bt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.Q2,'bt','q2',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&Q2,bt,q2);\n\n'];
    else
        if not(isempty(alg_data.Q2))
            file_str = [file_str 'q2 = ' exp_flat_vec(Q2,target) '\n\n\n\n'];
            %file_str = [file_str 'q2 = Q2;\n\n'];
        end
    end
    file_str = [file_str exp_flat_vec_add('q1','q2','q',n_x,target) '\n\n\n\n'];
    %file_str = [file_str 'vec_add(q1,q2,q,' int2str(n_x) ');\n\n'];
elseif opts.dense == 0
    % r.h.s. of equality constraint in sparse x-update
   file_str = [file_str 'double q[' int2str(n_x+size(alg_data.B,1)) ']= {0};\n\n'];
   file_str = [file_str 'double q1[' int2str(n_x) ']= {0};\n\n'];
   file_str = [file_str 'double q2[' int2str(size(alg_data.B,1)) ']= {0};\n\n'];
   if alg_data.gt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.G,'gt','q1',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&G,gt,q1);\n\n'];
   elseif not(isempty(alg_data.G))
        file_str = [file_str 'q1 = ' exp_flat_vec(alg_data.G,target) ';\n\n\n\n'];
        %file_str = [file_str 'q1 = G;\n\n'];
   end
   if alg_data.bt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.B,'bt','q2',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&B,bt,q2);\n\n'];
   elseif not(isempty(alg_data.B))
        file_str = [file_str 'q2 = ' exp_flat_vec(G,target) '\n\n\n\n'];
        %file_str = [file_str 'q2 = G;\n\n'];
   end
end


% compute new upper and lower bounds when equality constraints eliminated
file_str = [file_str 'double l[' int2str(size(alg_data.C,1)) '] = ' mat2str_c(alg_data.Lb,'num') ';\n\n'];
file_str = [file_str 'double u[' int2str(size(alg_data.C,1)) '] = ' mat2str_c(alg_data.Ub,'num') ';\n\n'];

% move all declarations to the top?
file_str = [file_str 'double tmp_var_p[' int2str(size(alg_data.C,1)) '] = {0};\n\n'];
file_str = [file_str 'double tmp_var_p2[' int2str(size(alg_data.C,1)) '] = {0};\n\n'];

if isequal(opts.reform,'eq')
    if alg_data.gt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.L1,'gt','tmp_var_p',target) '\n\n\n\n'];
    end
    if alg_data.bt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.L2,'bt','tmp_var_p2',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult' structure(alg_data.L2) '(&L2,bt,tmp_var_p2);\n\n'];
    end
    file_str = [file_str exp_flat_vec_add('tmp_var_p','tmp_var_p2','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
    file_str = [file_str exp_flat_vec_sub('l','tmp_var_p','l',size(alg_data.C,1),target) '\n\n\n\n'];
    file_str = [file_str exp_flat_vec_sub('u','tmp_var_p','u',size(alg_data.C,1),target) '\n\n\n\n'];
end


% create vector r = r1*gt+r2*bt to recover original variables 

if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    % add temporary variables to store intermediate results
    file_str = [file_str 'double tmp_var_n_orig[' int2str(n_orig_x) '] = {0};\n\n'];
    file_str = [file_str 'double tmp_var_n2_orig[' int2str(n_orig_x) '] = {0};\n\n'];

    file_str = [file_str 'double r[' int2str(n_orig_x) '] = {0};\n\n'];
    if alg_data.gt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.r1,'gt','tmp_var_n_orig',target) '\n\n\n\n'];
        %file_str = [file_str '*gt'];
    end
    if alg_data.bt == 1
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.r2,'bt','tmp_var_n2_orig',target) '\n\n\n\n'];
        %file_str = [file_str '*bt;\n\n'];
    end
    file_str = [file_str exp_flat_vec_add('tmp_var_n_orig','tmp_var_n2_orig','r',n_orig_x,target) '\n\n\n\n'];
    %file_str = [file_str 'vec_add(tmp_var_n_orig,tmp_var_n2_orig,r,' int2str(n_orig_x) ');\n\n'];
end



% initialize algorithm state (cold-starting)
file_str = [file_str 'double lambda[' int2str(size(alg_data.C,1)) '] = {0};\n'];
file_str = [file_str 'double y[' int2str(size(alg_data.C,1)) '] = {0};\n\n'];
file_str = [file_str 'double x[' int2str(n_x) '] = {0};\n\n'];
if not(isequal(opts.alg,'ADMM'))
    file_str = [file_str 'double lambda_old[' int2str(size(alg_data.C,1)) '] = {0};\n'];
    file_str = [file_str 'double v[' int2str(size(alg_data.C,1)) '] = {0};\n'];
end

% add temporary variables to store intermediate results
file_str = [file_str 'double tmp_var_n[' int2str(n_x) '] = {0};\n\n'];
file_str = [file_str 'double tmp_var_n2[' int2str(n_x) '] = {0};\n\n'];
if opts.dense == 0
    file_str = [file_str 'double tmp_var_nm[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n'];
    file_str = [file_str 'double tmp_var_nm2[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n'];
end

% never used?
%file_str = [file_str 'double tmp_var_m[' int2str(size(alg_data.B,1)) '] = {0};\n\n'];
file_str = [file_str 'double rhs[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n'];

if not(isequal(opts.alg,'ADMM'))
    file_str = [file_str 'double theta = 1;\n'];
    file_str = [file_str 'double theta_old = 1;\n'];
    file_str = [file_str 'double alpha = 1;\n\n'];
end


file_str = [file_str 'int jj;'];
% add for-loop from 1 to max_iter
file_str = [file_str 'for (jj = 1; jj <= ' int2str(opts.max_iter) '; jj++ ) {\n\n'];


% x variable update
if opts.dense == 1
    
    % implements dense x-update x = M*(lambda-E*y)+q for ADMM
    % implements dense x-update x = M*(v)+q for FGM
     if isequal(opts.alg,'ADMM')
        % implements dense x-update x = M*(lambda-E*y)+q
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.E,'y','tmp_var_p',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&E,y,tmp_var_p);\n\n'];

        file_str = [file_str exp_flat_vec_sub('lambda','tmp_var_p','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
        %file_str = [file_str 'vec_sub(lambda,tmp_var_p,tmp_var_p,' int2str(size(alg_data.C,1)) ');\n\n'];

        file_str = [file_str exp_flat_mat_vec_mult(alg_data.M,'tmp_var_p','tmp_var_n',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&M,tmp_var_p,tmp_var_n);\n\n'];
    else
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.M,'v','tmp_var_n',target) '\n\n'];
        %file_str = [file_str 'mat_vec_mult(&M,v,tmp_var_n);\n\n'];
    end

    file_str = [file_str exp_flat_vec_add('tmp_var_n','q','x',n_x,target) '\n\n\n\n'];
    %file_str = [file_str 'vec_add(tmp_var_n,q,x,' int2str(n_x) ');\n\n'];
    
elseif opts.dense == 0
    % compute r.h.s. rhs = [CT*(E*y-lambda)-q1;q2]; for ADMM
    % compute r.h.s. rhs = [CT*(-v)-q1;q2]; for FGM
    
    if isequal(opts.alg,'ADMM')
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.E,'y','tmp_var_p',target) '\n\n\n\n'];
        %file_str = [file_str 'mat_vec_mult_xxx(&E,y,tmp_var_p);\n\n'];
        
        file_str = [file_str exp_flat_vec_sub('tmp_var_p','lambda','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
        %file_str = [file_str 'vec_sub(tmp_var_p,lambda,tmp_var_p,' int2str(size(alg_data.C,1)) ');\n\n'];
    else
        file_str = [file_str exp_flat_copy_vec_part_negate('v','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
        %file_str = [file_str 'copy_vec_part_negate(v,tmp_var_p,' int2str(size(alg_data.C,1)) ');\n\n'];
    end

    file_str = [file_str exp_flat_mat_vec_mult(alg_data.C','tmp_var_p','tmp_var_n',target) '\n\n\n\n'];        
    %file_str = [file_str 'mat_vec_mult' structure(alg_data.C) '(&CT,tmp_var_p,tmp_var_n);\n\n'];
    
    file_str = [file_str exp_flat_vec_sub('tmp_var_n','q1','tmp_var_n',n_x,target) '\n\n\n\n'];
    %file_str = [file_str 'vec_sub(tmp_var_n,q1,tmp_var_n,' int2str(n_x) ');\n\n'];
    
    file_str = [file_str exp_flat_stack_vec('tmp_var_n','q2','rhs',n_x,size(alg_data.B,1),target) '\n\n\n\n'];
    %file_str = [file_str 'stack_vec(tmp_var_n,q2,rhs,' int2str(n_x) ',' int2str(size(alg_data.B,1)) ');\n\n'];
    
    % LDL solve: P'LDL'Px = rhs
    file_str = [file_str exp_flat_perm_fwdsolve(alg_data.L,alg_data.p,'rhs','tmp_var_nm',target) '\n\n\n\n'];
    %file_str = [file_str 'perm_fwdsolve(&L,p,rhs,tmp_var_nm);\n\n'];
 
   % diagonal D inverse or sparse or full!
   file_str = [file_str exp_flat_mat_vec_mult(alg_data.D_inv,'tmp_var_nm','tmp_var_nm2',target) '\n\n\n\n'];    
   %file_str = [file_str 'mat_vec_mult_xxx(&Dinv,tmp_var_nm,tmp_var_nm2);\n\n'];    
   
    file_str = [file_str exp_flat_backsolve_perm(alg_data.LT,alg_data.p,'tmp_var_nm2','tmp_var_nm',target) '\n\n\n\n'];
    %file_str = [file_str 'backsolve_perm(&LT,p,tmp_var_nm2,tmp_var_nm);\n\n'];
    
    file_str = [file_str exp_flat_copy_vec_part('tmp_var_nm','x',n_x,target) '\n\n\n\n'];
    %file_str = [file_str 'copy_vec_part(tmp_var_nm,x,' int2str(n_x) ');\n\n'];
end


% y variable update: y = clip(Einv*(Cx+lambda),l,u)
file_str = [file_str exp_flat_mat_vec_mult(alg_data.C,'x','tmp_var_p',target) '\n\n\n\n'];
%file_str = [file_str 'mat_vec_mult_xxx(&C,x,tmp_var_p);\n\n'];

if isequal(opts.alg,'ADMM')
    file_str = [file_str exp_flat_vec_add('lambda','tmp_var_p','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
    %file_str = [file_str 'vec_add(lambda,tmp_var_p,tmp_var_p,' int2str(size(alg_data.C,1)) ');\n\n'];
else
    file_str = [file_str exp_flat_vec_add('v','tmp_var_p','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
    %file_str = [file_str 'vec_add(v,tmp_var_p,tmp_var_p,' int2str(size(alg_data.C,1)) ');\n\n'];
end

file_str = [file_str exp_flat_mat_vec_mult(alg_data.E\speye(length(alg_data.E)),'tmp_var_p','y',target) '\n\n\n\n'];
%file_str = [file_str 'mat_vec_mult_xxx(&Einv,tmp_var_p,y);\n\n'];

file_str = [file_str exp_flat_clip_symb('y','l','u',size(alg_data.C,1),target) '\n\n\n\n'];
%file_str = [file_str exp_flat_clip('y',alg_data.Lb,alg_data.Ub,size(alg_data.C,1),target) '\n\n\n\n'];
%file_str = [file_str 'clip(y,l,u,' int2str(size(alg_data.C,1)) ');\n\n'];

% tmp_var_p contains Cx+lambda
% lambda variable update lambda = lambda+Cx-Ey
file_str = [file_str exp_flat_mat_vec_mult(alg_data.E,'y','tmp_var_p2',target) '\n\n\n\n'];
%file_str = [file_str 'mat_vec_mult_diag(&E,y,tmp_var_p2);\n\n'];

if not(isequal(opts.alg,'ADMM'))
    file_str = [file_str exp_flat_copy_vec_part('lambda','lambda_old',size(alg_data.C,1),target) '\n\n\n\n'];
end

file_str = [file_str exp_flat_vec_sub('tmp_var_p','tmp_var_p2','lambda',size(alg_data.C,1),target) '\n\n\n\n'];
%file_str = [file_str 'vec_sub(tmp_var_p,tmp_var_p2,lambda,' int2str(size(alg_data.C,1)) ');\n\n'];

% acceleration term in FGM
if not(isequal(opts.alg,'ADMM'))
    file_str = [file_str exp_flat_vec_sub('lambda','lambda_old','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
    file_str = [file_str 'theta_old = theta;\n\n'];
    file_str = [file_str 'theta = (1+sqrt(1+4*pow(theta_old,2)))/2;\n\n'];
    file_str = [file_str 'alpha = (theta_old-1)/theta;\n\n'];
    file_str = [file_str exp_flat_scalar_mult('alpha','tmp_var_p',size(alg_data.C,1),target) '\n\n\n\n'];
    file_str = [file_str exp_flat_vec_add('tmp_var_p','lambda','v',size(alg_data.C,1),target) '\n\n\n\n'];
end

% end for loop
file_str = [file_str '}\n\n'];

% reconstruction of original variables
if isequal(opts.reform,'eq') ||  isequal(opts.reform,'ineq')
    %if isequal(alg_data.F,eye(n))
        file_str = [file_str exp_flat_mat_vec_mult(alg_data.R,'x','tmp_var_n_orig',target) '\n\n\n\n'];
        file_str = [file_str exp_flat_vec_add('tmp_var_n_orig','r','x_out',n_orig_x,target) '\n\n\n\n'];
        %file_str = [file_str 'x_out = R*x+r;\n\n'];
    %else
        %file_str = [file_str 'x_out = F*(R*x+r);\n\n'];
    %end
elseif isequal(opts.reform,'original')
    %if isequal(alg_data.F,eye(n))
        file_str = [file_str exp_flat_copy_vec_part('x','x_out',n_orig_x,target) '\n\n\n\n'];
        %file_str = [file_str 'copy_vec_part(x,x_out,' int2str(n_orig_x) ');\n\n'];
        %file_str = [file_str 'x_out = x;\n\n'];
    %else
    %    file_str = [file_str 'x_out = F*x;\n\n'];
    %end
end

file_str = [file_str '}'];
% save to text-file
fid = fopen('my_loop_flat.c','w');

fprintf(fid,file_str);

fprintf('done!\n');