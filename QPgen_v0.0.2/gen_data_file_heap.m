% generates init data and free data files

function gen_data_file_heap(alg_data,opts)

% initialize file string
fid_init = fopen([opts.proj_name '_files/init_data.c'],'w');
fid_free = fopen([opts.proj_name '_files/free_data.c'],'w');
fid_data_struct = fopen([opts.proj_name '_files/data_struct.h'],'w');


% include functions in init_data file
fprintf(fid_init,'#include <stdlib.h>\n#include <stdio.h>\n#include "QPgen.h"\n#include "data_struct.h"\n\n');

% define read_binary_double function
fprintf(fid_init,'static void read_binary_double(double *data, size_t len, char* file_name) {\nFILE *fp = fopen(file_name,"rb");\nif (!fp) {perror("File open error");}\nfread(data, sizeof(double), len, fp);\nfclose(fp);\n}\n\n');

% define read_binary_int function
fprintf(fid_init,'static void read_binary_int(int *data, size_t len, char* file_name) {\nFILE *fp = fopen(file_name,"rb");\nif (!fp) {perror("File open error");}\nfread(data, sizeof(int), len, fp);\nfclose(fp);\n}\n\n');


% define read_binary_int function
fprintf(fid_init,'static void read_binary_float(float *data, size_t len, char* file_name) {\nFILE *fp = fopen(file_name,"rb");\nif (!fp) {perror("File open error");}\nfread(data, sizeof(float), len, fp);\nfclose(fp);\n}\n\n');


% start defining init_data
fprintf(fid_init,'void init_data(struct DATA *d) {\n\n');

% start free_data 
fprintf(fid_free,'#include <stdlib.h>\n#include "QPgen.h"\n#include "data_struct.h"\n\n void free_data(struct DATA *d) {\n\n');

% start data_struct
fprintf(fid_data_struct,'#ifndef DATA_STRUCT_H_GUARD\n#define DATA_STRUCT_H_GUARD\n\n');
fprintf(fid_data_struct,'struct DATA {\n');

% store matrices as data in generated file

if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
    if opts.dense == 1
        % dense representation USE DEF_MAT INSTEAD!!
        %fprintf(fid_init,['static const ' opts.precision ' Mdata[' int2str(size(alg_data.M,1)*size(alg_data.M,2)) '] = ' mat2str_c(alg_data.M) ';\n\n']);
        %fprintf(fid_init,['static struct FULL_MAT M = {' int2str(size(alg_data.M,1)) ',' int2str(size(alg_data.M,2)) ',Mdata};\n\n']);
        fprintf(fid_init,[def_mat_heap(alg_data.M,'M',opts)]);
        fprintf(fid_init,'d->M = M;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.M,'d->M')]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.M,1) '_MAT *M;\n']);
        % second argument below to not represent vectors as sparse
        if alg_data.gt == 1
            fprintf(fid_init,[def_mat_heap(alg_data.Q1,'Q1',opts)]);
            fprintf(fid_init,'d->Q1 = Q1;\n\n');
            fprintf(fid_free,[free_mat_heap(alg_data.Q1,'d->Q1',opts.precision)]);
            fprintf(fid_data_struct,['struct ' structure(alg_data.Q1,1) '_MAT *Q1;\n']);
        elseif not(isempty(alg_data.Q1))
            fprintf(fid_init,[def_vec_heap(alg_data.Q1,'Q1',opts)]);
            fprintf(fid_init,'d->Q1 = Q1;\n\n');
            fprintf(fid_free,[free_vec_heap(alg_data.Q1,'d->Q1',opts.precision)]);
            fprintf(fid_data_struct,[opts.precision ' *Q1;\n']);
            %fprintf(fid_init,['static const ' opts.precision ' Q1[' int2str(length(alg_data.Q1)) '] = ' mat2str_c(alg_data.Q1) ';\n\n']);
        end
        % second argument below to not represent vectors as sparse
        if alg_data.bt == 1
            fprintf(fid_init,[def_mat_heap(alg_data.Q2,'Q2',opts)]);
            fprintf(fid_init,'d->Q2 = Q2;\n\n');
            fprintf(fid_free,[free_mat_heap(alg_data.Q2,'d->Q2',opts.precision)]);
            fprintf(fid_data_struct,['struct ' structure(alg_data.Q2,1) '_MAT *Q2;\n']);
        elseif not(isempty(alg_data.Q2))
            fprintf(fid_init,[def_vec_heap(alg_data.Q2,'Q2',opts)]);
            fprintf(fid_init,'d->Q2 = Q2;\n\n');
            fprintf(fid_free,[free_vec_heap(alg_data.Q2,'d->Q2',opts.precision)]);
            fprintf(fid_data_struct,[opts.precision ' *Q2;\n']);
            %fprintf(fid_init,['static const ' opts.precision ' Q2[' int2str(length(alg_data.Q2)) '] = ' mat2str_c(alg_data.Q2) ';\n\n']);
        end
    elseif opts.dense == 0
        % store ldl factorization
        % L sparse representation
        fprintf(fid_init,[def_mat_heap(alg_data.L,'L',opts,'sparse')]);
        fprintf(fid_init,'d->L = L;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.L,'d->L',opts.precision,'sparse')]);
        fprintf(fid_data_struct,['struct SPARSE_MAT *L;\n']);
        %fprintf(fid_init,['static const ' opts.precision ' Ldata[' int2str(size(alg_data.L.val,1)) '] = ' mat2str_c(alg_data.L.val(:,2)) ';\n\n']);
        %fprintf(fid_init,['static const int Lcols[' int2str(size(alg_data.L.val,1)) '] = ' mat2str_c(alg_data.L.val(:,1)-1) ';\n\n']);
        %fprintf(fid_init,['static const int Lrows[' int2str(size(alg_data.L.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;alg_data.L.elem_per_row])) ';\n\n']);
        %fprintf(fid_init,['const int Lrows[' int2str(size(alg_data.L.elem_per_row,1)) '] = ' mat2str_c(alg_data.L.elem_per_row) ';\n\n']);
        %fprintf(fid_init,['static struct SPARSE_MAT L = {' int2str(size(alg_data.L.val,1)) ',' int2str(length(alg_data.L.elem_per_row)) ',Lrows,Lcols,Ldata};\n\n']);
        % L' sparse representation
        fprintf(fid_init,[def_mat_heap(alg_data.LT,'LT',opts,'sparse')]);
        fprintf(fid_init,'d->LT = LT;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.LT,'d->LT',opts.precision,'sparse')]);
        fprintf(fid_data_struct,['struct SPARSE_MAT *LT;\n']);
        
        %fprintf(fid_init,['static const ' opts.precision ' LTdata[' int2str(size(alg_data.LT.val,1)) '] = ' mat2str_c(alg_data.LT.val(:,2)) ';\n\n']);
        %fprintf(fid_init,['static const int LTcols[' int2str(size(alg_data.LT.val,1)) '] = ' mat2str_c(alg_data.LT.val(:,1)-1) ';\n\n']);
        %fprintf(fid_init,['static const int LTrows[' int2str(size(alg_data.LT.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;alg_data.LT.elem_per_row])) ';\n\n']);
        %fprintf(fid_init,['const int LTrows[' int2str(size(alg_data.LT.elem_per_row,1)) '] = ' mat2str_c(alg_data.LT.elem_per_row) ';\n\n']);
        %fprintf(fid_init,['static struct SPARSE_MAT LT = {' int2str(size(alg_data.LT.val,1)) ',' int2str(length(alg_data.LT.elem_per_row)) ',LTrows,LTcols,LTdata};\n\n']);

        % D
        fprintf(fid_init,[def_mat_heap(alg_data.D_inv,'Dinv',opts)]);
        fprintf(fid_init,'d->Dinv = Dinv;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.D_inv,'d->Dinv',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.D_inv,1) '_MAT *Dinv;\n']);
        
        % Permutation matrix p (on vector format)
        tmp_opts.precision = 'int';
        tmp_opts.proj_name = opts.proj_name;
        fprintf(fid_init,[def_vec_heap(alg_data.p-1,'p',tmp_opts)]);
        fprintf(fid_init,'d->p = p;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.p-1,'d->p','int')]);
        fprintf(fid_data_struct,['int *p;\n']);
         
        % fprintf(fid_init,['static const int p[' int2str(length(alg_data.p)) '] = ' mat2str_c(alg_data.p-1) ';\n\n']);

        % store B and G matrices
        if (alg_data.bt == 1)
            fprintf(fid_init,[def_mat_heap(alg_data.B,'B',opts)]);
            fprintf(fid_init,'d->B = B;\n\n');
            fprintf(fid_free,[free_mat_heap(alg_data.B,'d->B',opts.precision)]);
            fprintf(fid_data_struct,['struct ' structure(alg_data.B,1) '_MAT *B;\n']);
        elseif not(isempty(alg_data.B))
            % vector representation
            fprintf(fid_init,[def_vec_heap(alg_data.B,'B',opts)]);
            fprintf(fid_init,'d->B = B;\n\n');
            fprintf(fid_free,[free_vec_heap(alg_data.B,'d->B',opts.precision)]);
            fprintf(fid_data_struct,[opts.precision ' *B;\n']);
            %fprintf(fid_init,['static const ' opts.precision ' B[' int2str(length(alg_data.B)) '] = ' mat2str_c(alg_data.B) ';\n\n']);
        end
        if alg_data.gt == 1
            fprintf(fid_init,[def_mat_heap(alg_data.G,'G',opts)]);
            fprintf(fid_init,'d->G = G;\n\n');
            fprintf(fid_free,[free_mat_heap(alg_data.G,'d->G',opts.precision)]);
            fprintf(fid_data_struct,['struct ' structure(alg_data.G,1) '_MAT *G;\n']);
        elseif not(isempty(alg_data.G))
            % vector representation 
            fprintf(fid_init,[def_vec_heap(alg_data.G,'G',opts)]);
            fprintf(fid_init,'d->G = G;\n\n');
            fprintf(fid_free,[free_vec_heap(alg_data.G,'d->G',opts.precision)]);
            fprintf(fid_data_struct,[opts.precision ' *G;\n']);
            %fprintf(fid_init,['static const ' opts.precision ' G[' int2str(length(alg_data.G)) '] = ' mat2str_c(alg_data.G) ';\n\n']);
        end
    end
elseif isequal(opts.alg,'FGMprimal')
    
    % dense representation
    fprintf(fid_init,[def_mat_heap(alg_data.H,'H',opts)]);
    fprintf(fid_init,'d->H = H;\n\n');
    fprintf(fid_free,[free_mat_heap(alg_data.H,'d->H',opts.precision)]);
    fprintf(fid_data_struct,['struct ' structure(alg_data.H,1) '_MAT *H;\n']);

    % second argument below to not represent vectors as sparse
    if alg_data.gt == 1
        fprintf(fid_init,[def_mat_heap(alg_data.Gg,'Gg',opts)]);
        fprintf(fid_init,'d->Gg = Gg;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.Gg,'d->Gg',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.Gg,1) '_MAT *Gg;\n']);
    elseif not(isempty(alg_data.Gg))
        fprintf(fid_init,[def_vec_heap(alg_data.Gg,'Gg',opts)]);
        fprintf(fid_init,'d->Gg = Gg;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.Gg,'d->Gg',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *Gg;\n']);
        %fprintf(fid_init,['const ' opts.precision ' Gg[' int2str(length(alg_data.Gg)) '] = ' mat2str_c(alg_data.Gg) ';\n\n']);
    end
    % second argument below to not represent vectors as sparse
    if alg_data.bt == 1
        fprintf(fid_init,[def_mat_heap(alg_data.Gb,'Gb',opts)]);
        fprintf(fid_init,'d->Gb = Gb;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.Gb,'d->Gb',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.Gb,1) '_MAT *Gb;\n']);
    elseif not(isempty(alg_data.Gb))
        fprintf(fid_init,[def_vec_heap(alg_data.Gb,'Gb',opts)]);
        fprintf(fid_init,'d->Gb = Gb;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.Gb,'d->Gb',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *Gb;\n']);
        %fprintf(fid_init,['const ' opts.precision ' Gb[' int2str(length(alg_data.Gb)) '] = ' mat2str_c(alg_data.Gb) ';\n\n']);
    end
end
    

if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
    % store C and C'
    % remove C' if not needed!!
    fprintf(fid_init,[def_mat_heap(alg_data.C,'C',opts)]);
    fprintf(fid_init,'d->C = C;\n\n');
    fprintf(fid_free,[free_mat_heap(alg_data.C,'d->C',opts.precision)]);
    fprintf(fid_data_struct,['struct ' structure(alg_data.C,1) '_MAT *C;\n']);
    
    fprintf(fid_init,[def_mat_heap(alg_data.C','CT',opts)]);
    fprintf(fid_init,'d->CT = CT;\n\n');
    fprintf(fid_free,[free_mat_heap(alg_data.C','d->CT',opts.precision)]);
    fprintf(fid_data_struct,['struct ' structure(alg_data.C',1) '_MAT *CT;\n']);
end

% store E, Einv, using diagonal representations
% E 
%Einv = alg_data.E\speye(size(alg_data.E,1));
Einv = spdiags(1./diag(alg_data.E),0,length(alg_data.E),length(alg_data.E));
fprintf(fid_init,[def_mat_heap(alg_data.E,'E',opts)]);
fprintf(fid_init,'d->E = E;\n\n');
fprintf(fid_free,[free_mat_heap(alg_data.E,'d->E',opts.precision)]);
fprintf(fid_data_struct,['struct ' structure(alg_data.E,1) '_MAT *E;\n']);

fprintf(fid_init,[def_mat_heap(Einv,'Einv',opts)]);
fprintf(fid_init,'d->Einv = Einv;\n\n');
fprintf(fid_free,[free_mat_heap(Einv,'d->Einv',opts.precision)]);
fprintf(fid_data_struct,['struct ' structure(Einv,1) '_MAT *Einv;\n']);

% store Lb, Ub using vector representations
% Lb 
fprintf(fid_init,[def_vec_heap(alg_data.h.Lb,'Lb',opts)]);
fprintf(fid_init,'d->Lb = Lb;\n\n');
fprintf(fid_free,[free_vec_heap(alg_data.h.Lb,'d->Lb',opts.precision)]);
fprintf(fid_data_struct,[opts.precision ' *Lb;\n']);
%fprintf(fid_init,['static const ' opts.precision ' Lb[' int2str(length(alg_data.h.Lb)) '] = ' mat2str_c(alg_data.h.Lb) ';\n\n']);
% Ub 
fprintf(fid_init,[def_vec_heap(alg_data.h.Ub,'Ub',opts)]);
fprintf(fid_init,'d->Ub = Ub;\n\n');
fprintf(fid_free,[free_vec_heap(alg_data.h.Ub,'d->Ub',opts.precision)]);
fprintf(fid_data_struct,[opts.precision ' *Ub;\n']);
%fprintf(fid_init,['static const ' opts.precision ' Ub[' int2str(length(alg_data.h.Ub)) '] = ' mat2str_c(alg_data.h.Ub) ';\n\n']);
% soft (if soft constraints specified)
if max(alg_data.h.soft) > 0
    fprintf(fid_init,[def_vec_heap(alg_data.h.soft,'soft',opts)]);
    fprintf(fid_init,'d->soft = soft;\n\n');
    fprintf(fid_free,[free_vec_heap(alg_data.h.soft,'d->soft',opts.precision)]);
    fprintf(fid_data_struct,[opts.precision ' *soft;\n']);
    %fprintf(fid_init,['static const ' opts.precision ' soft[' int2str(length(alg_data.h.soft)) '] = ' mat2str_c(alg_data.h.soft) ';\n\n']);
end

% L1 = U1 and L2 = U2!!
if isequal(opts.reform,'eq')
    if alg_data.gt == 1
        fprintf(fid_init,[def_mat_heap(alg_data.h.L1,'L1',opts)]);
        fprintf(fid_init,'d->L1 = L1;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.h.L1,'d->L1',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.h.L1,1) '_MAT *L1;\n']);
    elseif not(isempty(alg_data.h.L1))
        fprintf(fid_init,[def_vec_heap(alg_data.h.L1,'L1',opts)]);
        fprintf(fid_init,'d->L1 = L1;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.h.L1,'d->L1',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *L1;\n']);
        %fprintf(fid_init,['static const ' opts.precision ' L1[' int2str(length(alg_data.h.L1)) '] = ' mat2str_c(alg_data.h.L1) ';\n\n']);
    end
    if alg_data.bt == 1
        fprintf(fid_init,[def_mat_heap(alg_data.h.L2,'L2',opts)]);
        fprintf(fid_init,'d->L2 = L2;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.h.L2,'d->L2',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.h.L2,1) '_MAT *L2;\n']);
    elseif not(isempty(alg_data.h.L2))
        fprintf(fid_init,[def_vec_heap(alg_data.h.L2,'L2',opts)]);
        fprintf(fid_init,'d->L2 = L2;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.h.L2,'d->L2',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *L2;\n']);
        %fprintf(fid_init,['static const ' opts.precision ' L2[' int2str(length(alg_data.h.L2)) '] = ' mat2str_c(alg_data.h.L2) ';\n\n']);
    end
end

% skip F, always output full solution!
if 0
if not(isequal(alg_data.F,eye(n)))
    fprintf(fid_init,['F = ' mat2str(alg_data.F) ';\n\n']);
    fprintf(fid_free,['F = ' mat2str(alg_data.F) ';\n\n']);
end
end


% add declarations of r1, r2, and R that are used to recover original
% variables
if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    if alg_data.gt == 1 && not(allzeros(alg_data.r1))
        fprintf(fid_init,[def_mat_heap(alg_data.r1,'r1',opts)]);
        fprintf(fid_init,'d->r1 = r1;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.r1,'d->r1',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.r1,1) '_MAT *r1;\n']);
    elseif not(isempty(alg_data.r1)) && not(allzeros(alg_data.r1))
        fprintf(fid_init,[def_vec_heap(alg_data.r1,'r1',opts)]);
        fprintf(fid_init,'d->r1 = r1;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.r1,'d->r1',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *r1;\n']);
        %fprintf(fid_init,['static const ' opts.precision ' r1[' int2str(length(alg_data.r1)) '] = ' mat2str_c(alg_data.r1) ';\n\n']);
    end
    if alg_data.bt == 1 && not(allzeros(alg_data.r2))
        fprintf(fid_init,[def_mat_heap(alg_data.r2,'r2',opts)]);
        fprintf(fid_init,'d->r2 = r2;\n\n');
        fprintf(fid_free,[free_mat_heap(alg_data.r2,'d->r2',opts.precision)]);
        fprintf(fid_data_struct,['struct ' structure(alg_data.r2,1) '_MAT *r2;\n']);
    elseif not(isempty(alg_data.r2)) && not(allzeros(alg_data.r2))
        fprintf(fid_init,[def_vec_heap(alg_data.r2,'r2',opts)]);
        fprintf(fid_init,'d->r2 = r2;\n\n');
        fprintf(fid_free,[free_vec_heap(alg_data.r2,'d->r2',opts.precision)]);
        fprintf(fid_data_struct,[opts.precision ' *r2;\n']);
        %fprintf(fid_init,['static const ' opts.precision ' r2[' int2str(length(alg_data.r2)) '] = ' mat2str_c(alg_data.r2) ';\n\n']);
    end
end
if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq') || (isequal(opts.reform,'original') && isequal(opts.alg,'FGMprimal'))
    fprintf(fid_init,[def_mat_heap(alg_data.R,'R',opts)]);
    fprintf(fid_init,'d->R = R;\n\n');
    fprintf(fid_free,[free_mat_heap(alg_data.R,'d->R',opts.precision)]);
    fprintf(fid_data_struct,['struct ' structure(alg_data.R,1) '_MAT *R;\n']);
end

% return/free data struct
%fprintf(fid_init,'return(d);\n\n');
fprintf(fid_free,'free(d);\n\n');

% closing parenthesis
fprintf(fid_init,'}\n\n');
fprintf(fid_free,'}\n\n');
fprintf(fid_data_struct,'};\n\n#endif\n\n');

% close file
fclose(fid_init);
fclose(fid_free);
fclose(fid_data_struct);
