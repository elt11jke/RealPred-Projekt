function str = inline_fcn_def(alg_data,opts)

str = [];

% include perm_fwdsolve function
str = [str '/* solves Ly=Px where P is permutation matrix defined by vector p */\n static void perm_fwdsolve(struct SPARSE_MAT *L, const int *p, ' opts.precision ' *x, ' opts.precision ' *y) {\n int iter_stop;\n int row_idx = 0;\n int jj;\n for (jj = 0; jj <= L->nr-1; jj++) {\n y[jj] = (L->data)[(L->row)[jj+1]-1]*x[p[jj]];;\n for (row_idx = (L->row)[jj] ; row_idx < (L->row)[jj+1]-1 ; row_idx++) {\n y[jj] = y[jj]-(L->data)[row_idx]*y[(L->col)[row_idx]];\n }\n }\n }\n\n'];
%str = [str '/* solves Ly=Px where P is permutation matrix defined by vector p */\n static void perm_fwdsolve(struct SPARSE_MAT *L, const int *p, ' opts.precision ' *x, ' opts.precision ' *y) {\n int iter_stop;\n int row_idx = 0;\n int jj;\n for (jj = 0; jj <= L->nr-1; jj++) {\n y[jj] = x[p[jj]];\n for (row_idx = (L->row)[jj] ; row_idx < (L->row)[jj+1] ; row_idx++) {\n y[jj] = y[jj]-(L->data)[row_idx]*y[(L->col)[row_idx]];\n }\n }\n }\n\n'];

% include backsolve_perm function
str = [str '/* solves LPy=x */\n static void backsolve_perm(struct SPARSE_MAT *L, const int *p, ' opts.precision ' *x, ' opts.precision ' *y) {\n int iter_stop;\n int row_idx = 0;\n int jj;\n for (jj = L->nr-1 ; jj >= 0 ; jj--) {\n y[p[jj]] = (L->data)[(L->row)[jj]]*x[jj];\n for (row_idx = (L->row)[jj]+1 ; row_idx < (L->row)[jj+1] ; row_idx++) {\n y[p[jj]] = y[p[jj]]-(L->data)[row_idx]*y[p[(L->col)[row_idx]]];\n }\n }\n }\n\n'];
%str = [str '/* solves LPy=x */\n static void backsolve_perm(struct SPARSE_MAT *L, const int *p, ' opts.precision ' *x, ' opts.precision ' *y) {\n int iter_stop;\n int row_idx = 0;\n int jj;\n for (jj = L->nr-1 ; jj >= 0 ; jj--) {\n y[p[jj]] = x[jj];\n for (row_idx = (L->row)[jj] ; row_idx < (L->row)[jj+1] ; row_idx++) {\n y[p[jj]] = y[p[jj]]-(L->data)[row_idx]*y[p[(L->col)[row_idx]]];\n }\n }\n }\n\n'];

% include mat_vec_mult_diag function
str = [str 'static void mat_vec_mult_diag(struct DIAG_MAT *D, ' opts.precision ' *x, ' opts.precision ' *y) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= D->n-1; jj++) {\n y[jj] = (D->data)[jj]*x[jj];\n }\n }\n\n'];
    
% include mat_vec_mult_sparse function
str = [str 'static void mat_vec_mult_sparse(struct SPARSE_MAT *L, ' opts.precision ' *x, ' opts.precision ' *y) {\n int row_idx = 0;\n int jj;\n int iter_stop;\n for (jj = 0 ; jj <= L->nr-1 ; jj++) {\n y[jj] = 0;\n for (row_idx = (L->row)[jj] ; row_idx < (L->row)[jj+1] ; row_idx++) {\n y[jj] = y[jj]+(L->data)[row_idx]*x[(L->col)[row_idx]];\n \n }\n }  \n}\n\n'];
%str = [str 'static void mat_vec_mult_sparse(struct SPARSE_MAT *L, ' opts.precision ' *x, ' opts.precision ' *y) {\n int row_idx = 0;\n int jj;\n int iter_stop;\n for (jj = 0 ; jj <= L->nr-1 ; jj++) {\n iter_stop = row_idx+(L->row)[jj];\n y[jj] = 0;\n while ((row_idx <= L->nnz) && (row_idx < iter_stop)) {\n y[jj] = y[jj]+(L->data)[row_idx]*x[(L->col)[row_idx]];\n row_idx = row_idx+1;\n }\n }  \n}\n\n'];

% include mat_vec_mult_full function
str = [str 'static void mat_vec_mult_full(struct FULL_MAT *M, ' opts.precision ' *x, ' opts.precision ' *y) {\n int jj;\n int kk;\n #pragma omp parallel for\n for (jj = 0; jj <= (M->n)-1; jj++) {\n y[jj] = 0;\n for (kk = 0 ; kk <= (M->m)-1; kk++) {\n y[jj] = y[jj]+(M->data[kk+jj*(M->m)])*x[kk];\n }\n } \n }\n\n'];

% include stack_vec function
str = [str 'static void stack_vec(' opts.precision ' *x, ' opts.precision ' *y, ' opts.precision ' *z, int len_x, int len_y) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= len_x-1 ; jj++) {\n z[jj] = x[jj];\n }\n #pragma omp parallel for\n for (jj = 0;jj <= len_y-1 ; jj++) {\n z[jj+len_x] = y[jj];\n }\n }\n\n'];

% include vec_add function
str = [str 'static void vec_add(' opts.precision ' *x, ' opts.precision ' *y, ' opts.precision ' *z, int len) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= len-1 ; jj++) {\n z[jj] = x[jj]+y[jj];\n }\n}\n\n'];

% include vec_sub function
str = [str 'static void vec_sub(' opts.precision ' *x, ' opts.precision ' *y, ' opts.precision ' *z, int len) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= len-1 ; jj++) {\n z[jj] = x[jj]-y[jj];\n }\n }\n\n'];

% include clip function
str = [str 'static void clip(' opts.precision ' *x, ' opts.precision ' *l, ' opts.precision ' *u, int len) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= len-1; jj++) {\n x[jj] = min(max(x[jj],l[jj]),u[jj]);\n }\n }\n\n'];

% include soft clip function
str = [str 'static void clip_soft(' opts.precision ' *x, ' opts.precision ' *l, ' opts.precision ' *u, ' opts.precision ' *soft, int len) {\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj <= len-1; jj++) {\n if (soft[jj] < 0) {\n x[jj] = min(max(x[jj],l[jj]),u[jj]);\n }\n else {\n if (x[jj] <= l[jj]-soft[jj]) {\n x[jj] = x[jj]+soft[jj];\n }\n else if (x[jj] >= u[jj]+soft[jj]) {\n x[jj] = x[jj]-soft[jj];\n }\n else {\n x[jj] = min(max(x[jj],l[jj]),u[jj]);\n } \n }\n }\n }\n\n'];

% include copy_vec_part function
str = [str 'static void copy_vec_part(' opts.precision ' *x, ' opts.precision ' *y, int n){\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n y[jj] = x[jj];\n }\n }\n\n'];

% include copy_double_to_float function
str = [str 'void copy_double_to_float(double *x, float *y, int n){\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n y[jj] = (float) x[jj];\n }\n }\n\n'];

% include copy_float_to_double function
str = [str 'void copy_float_to_double(float *x, double *y, int n){\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n y[jj] = (double) x[jj];\n }\n }\n\n'];

% include copy_vec_part_negate function
str = [str 'static void copy_vec_part_negate(' opts.precision ' *x, ' opts.precision ' *y, int n){\n int jj;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n y[jj] = -x[jj];\n }\n }\n\n'];

% include scalar_mult function
str = [str 'static void scalar_mult(' opts.precision ' alpha, ' opts.precision ' *x, int n){ \n int jj;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n x[jj] = alpha*x[jj];\n }\n }\n\n'];

% include norm_sq function
str = [str 'static ' opts.precision ' norm_sq(' opts.precision ' *x, int n) { int jj;\n ' opts.precision ' norm = 0;\n #pragma omp parallel for\n for (jj = 0; jj<= n-1 ; jj++) {\n norm += pow(x[jj],2);\n }\n return norm;\n}\n\n'];

% include scalar_prod
str = [str 'static ' opts.precision ' scalar_prod(' opts.precision ' *x, ' opts.precision ' *y, int n) {\n ' opts.precision ' sum = 0;\n int jj;\n for (jj = 0 ; jj <= n-1 ; jj++) {\n sum += x[jj]*y[jj];\n }\n return sum;\n }\n\n'];

% include adaptive restart
str = [str 'static void restart(' opts.precision ' *x, ' opts.precision ' *x_old, ' opts.precision ' *y, ' opts.precision ' *y_old, ' opts.precision ' *tmp_var_p, ' opts.precision ' *tmp_var_p2, int n){\n ' opts.precision ' test;\n vec_sub(y_old,x,tmp_var_p,n);\n vec_sub(x,x_old,tmp_var_p2,n);\n test = scalar_prod(tmp_var_p,tmp_var_p2,n);\n if (test > 0) {\n copy_vec_part(x_old,y,n);\n copy_vec_part(x_old,x,n);\n }\n }\n\n'];

% include check_stop_cond_FGM
str = [str 'static ' opts.precision ' check_stop_cond_FGM('];
str = [str 'struct ' structure(alg_data.E,1) '_MAT *Einv, ' opts.precision ' *y, ' opts.precision ' *v, ' opts.precision ' *tmp_var_p, ' opts.precision ' *tmp_var_p2, int p, ' opts.precision ' tol) {\n ' opts.precision ' cond_num;\n ' opts.precision ' cond_den;\n ' opts.precision ' cond;\n vec_sub(y,v,tmp_var_p,p);\n'];
str = [str 'mat_vec_mult_' structure(alg_data.E) '(Einv,tmp_var_p,tmp_var_p2);\n'];
str = [str 'cond_num = norm_sq(tmp_var_p2,p);\n'];
str = [str 'mat_vec_mult_' structure(alg_data.E) '(Einv,y,tmp_var_p);\n'];
str = [str 'cond_den = norm_sq(tmp_var_p,p);\n'];
str = [str 'mat_vec_mult_' structure(alg_data.E) '(Einv,v,tmp_var_p);\n'];
str = [str 'cond_den = max(max(norm_sq(tmp_var_p,p),cond_den),1e-8);\n cond = pow2(tol)-cond_num/cond_den;\n return cond;\n }\n\n'];

% include check_stop_cond_ADMM
%Einv = alg_data.E\eye(size(alg_data.E,1));
Einv = spdiags(1./diag(alg_data.E),0,length(alg_data.E),length(alg_data.E));
str = [str 'static ' opts.precision ' check_stop_cond_ADMM('];
str = [str 'struct ' structure(alg_data.C,1) '_MAT *CT, '];
str = [str 'struct ' structure(Einv,1) '_MAT *Einv, ' opts.precision ' *Cx, ' opts.precision ' *y, ' opts.precision ' *y_old, ' opts.precision ' *lambda, ' opts.precision ' *tmp_var_p, ' opts.precision ' *tmp_var_p2, ' opts.precision ' *tmp_var_n, int n, int p, ' opts.precision ' tol) {\n ' opts.precision ' cond_num_p;\n ' opts.precision ' cond_den_p;\n ' opts.precision ' cond_p;\n ' opts.precision ' cond_num_d;\n ' opts.precision ' cond_den_d;\n ' opts.precision ' cond_d;\n\n'];
str = [str 'mat_vec_mult_' structure(Einv) '(Einv,Cx,tmp_var_p);\n'];
str = [str 'cond_den_p = norm_sq(tmp_var_p2,p);\n cond_den_p = max(max(norm_sq(y,n),cond_den_p),1e-8);\n vec_sub(tmp_var_p,y,tmp_var_p,p);\n cond_num_p = norm_sq(tmp_var_p,p);\n cond_p = pow2(tol)/4-cond_num_p/cond_den_p;\n\n'];
str = [str 'mat_vec_mult_' structure(alg_data.C') '(CT,lambda,tmp_var_n);\n'];
str = [str 'cond_den_d = max(norm_sq(tmp_var_n,n),1e-8);\n vec_sub(y,y_old,tmp_var_p,p);\n'];
str = [str 'mat_vec_mult_' structure(Einv) '(Einv,tmp_var_p,tmp_var_p2);\n'];
str = [str 'mat_vec_mult_' structure(alg_data.C') '(CT,tmp_var_p2,tmp_var_n);\n'];
str = [str 'cond_num_d = norm_sq(tmp_var_n,n);\n cond_d = pow2(tol)/4-cond_num_d/cond_den_d;\n return min(cond_p,cond_d);\n }\n\n'];
