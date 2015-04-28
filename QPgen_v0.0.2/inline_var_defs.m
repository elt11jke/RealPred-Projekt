function inline_var_defs(fid,alg_data,opts)


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



% precompute linear term in x-update (dense) and r.h.s. in .. (sparse)
if opts.dense == 1 || isequal(opts.alg,'FGMprimal')
    fprintf(fid,[opts.precision ' q[' int2str(n_x) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' q1[' int2str(n_x) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' q2[' int2str(n_x) '] = {0};\n\n']);
elseif opts.dense == 0
    % r.h.s. of equality constraint in sparse x-update
   fprintf(fid,[opts.precision ' q[' int2str(n_x+size(alg_data.B,1)) ']= {0};\n\n']);
   fprintf(fid,[opts.precision ' q1[' int2str(n_x) ']= {0};\n\n']);
   if not(isempty(alg_data.B))
        fprintf(fid,[opts.precision ' q2[' int2str(size(alg_data.B,1)) ']= {0};\n\n']);
   end
end


% define upper and lower bounds
fprintf(fid,[opts.precision ' l[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid,[opts.precision ' u[' int2str(n_y) '] = {0};\n\n']);

% init shift prox argument when reform = 'eq'
if isequal(opts.reform,'eq')
    fprintf(fid,[opts.precision ' shift_arg[' int2str(n_y) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' Eshift_arg[' int2str(n_y) '] = {0};\n\n']);
end


% temporary variables
fprintf(fid,[opts.precision ' tmp_var_p[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid,[opts.precision ' tmp_var_p2[' int2str(n_y) '] = {0};\n\n']);
if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM')
    fprintf(fid,[opts.precision ' arg_prox_h[' int2str(n_y) '] = {0};\n\n']);
end

% create vector r = r1*gt+r2*bt to recover original variables 

if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq') || isequal(opts.alg,'FGMprimal')
    % add temporary variables to store intermediate results
    fprintf(fid,[opts.precision ' tmp_var_n_orig[' int2str(n_orig_x) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' tmp_var_n2_orig[' int2str(n_orig_x) '] = {0};\n\n']);

    fprintf(fid,[opts.precision ' r[' int2str(n_orig_x) '] = {0};\n\n']);
end


% initialize algorithm state (cold-starting)
if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM')
    fprintf(fid,[opts.precision ' lambda[' int2str(n_y) '] = {0};\n']);
end
fprintf(fid,[opts.precision ' y[' int2str(n_y) '] = {0};\n\n']);
fprintf(fid,[opts.precision ' x[' int2str(n_x) '] = {0};\n\n']);
if isequal(opts.alg,'FGMdual') || isequal(opts.alg,'FGMprimal')
    if isequal(opts.alg,'FGMdual')
        fprintf(fid,[opts.precision ' lambda_old[' int2str(n_y) '] = {0};\n']);
    end
    fprintf(fid,[opts.precision ' v[' int2str(n_y) '] = {0};\n']);
    if opts.restart == 1
        fprintf(fid,[opts.precision ' v_old[' int2str(n_y) '] = {0};\n']);
    end
end
if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMprimal')
    fprintf(fid,[opts.precision ' y_old[' int2str(n_y) '] = {0};\n\n']);
    if isequal(opts.alg,'ADMM')
        fprintf(fid,[opts.precision ' Cx[' int2str(n_y) '] = {0};\n\n']);
    end
end


% add temporary variables to store intermediate results
fprintf(fid,[opts.precision ' tmp_var_n[' int2str(n_x) '] = {0};\n\n']);
fprintf(fid,[opts.precision ' tmp_var_n2[' int2str(n_x) '] = {0};\n\n']);

% add temporary variables to store intermediate results
if opts.dense == 0 && (isequal(opts.alg,'FGMdual') || isequal(opts.alg,'ADMM'))
    fprintf(fid,[opts.precision ' tmp_var_nm[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' tmp_var_nm2[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
    fprintf(fid,[opts.precision ' rhs[' int2str(n_x+size(alg_data.B,1)) '] = {0};\n\n']);
end

