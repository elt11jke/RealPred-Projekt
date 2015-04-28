function gen_data_file(alg_data,opts)

% initialize file string
fid = fopen([opts.proj_name '_files/' opts.proj_name '_data/alg_data.c'],'w');

% store matrices as data in generated file

if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
    if opts.dense == 1
        % dense representation USE DEF_MAT INSTEAD!!
        %fprintf(fid,['static const ' opts.precision ' Mdata[' int2str(size(alg_data.M,1)*size(alg_data.M,2)) '] = ' mat2str_c(alg_data.M) ';\n\n']);
        %fprintf(fid,['static struct FULL_MAT M = {' int2str(size(alg_data.M,1)) ',' int2str(size(alg_data.M,2)) ',Mdata};\n\n']);
        fprintf(fid,[def_mat(alg_data.M,'M',opts.precision)]);

        % second argument below to not represent vectors as sparse
        if alg_data.gt == 1
            fprintf(fid,[def_mat(alg_data.Q1,'Q1',opts.precision)]);
        elseif not(isempty(alg_data.Q1))
            fprintf(fid,['static const ' opts.precision ' Q1[' int2str(length(alg_data.Q1)) '] = ' mat2str_c(alg_data.Q1) ';\n\n']);
        end
        % second argument below to not represent vectors as sparse
        if alg_data.bt == 1
            fprintf(fid,[def_mat(alg_data.Q2,'Q2',opts.precision)]);
        elseif not(isempty(alg_data.Q2))
            fprintf(fid,['static const ' opts.precision ' Q2[' int2str(length(alg_data.Q2)) '] = ' mat2str_c(alg_data.Q2) ';\n\n']);
        end
    elseif opts.dense == 0
        % store ldl factorization
        % L sparse representation
        fprintf(fid,['static const ' opts.precision ' Ldata[' int2str(size(alg_data.L.val,1)) '] = ' mat2str_c(alg_data.L.val(:,2)) ';\n\n']);
        fprintf(fid,['static const int Lcols[' int2str(size(alg_data.L.val,1)) '] = ' mat2str_c(alg_data.L.val(:,1)-1) ';\n\n']);
        fprintf(fid,['static const int Lrows[' int2str(size(alg_data.L.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;alg_data.L.elem_per_row])) ';\n\n']);
        %fprintf(fid,['const int Lrows[' int2str(size(alg_data.L.elem_per_row,1)) '] = ' mat2str_c(alg_data.L.elem_per_row) ';\n\n']);
        fprintf(fid,['static struct SPARSE_MAT L = {' int2str(size(alg_data.L.val,1)) ',' int2str(length(alg_data.L.elem_per_row)) ',Lrows,Lcols,Ldata};\n\n']);
        % L' sparse representation
        fprintf(fid,['static const ' opts.precision ' LTdata[' int2str(size(alg_data.LT.val,1)) '] = ' mat2str_c(alg_data.LT.val(:,2)) ';\n\n']);
        fprintf(fid,['static const int LTcols[' int2str(size(alg_data.LT.val,1)) '] = ' mat2str_c(alg_data.LT.val(:,1)-1) ';\n\n']);
        fprintf(fid,['static const int LTrows[' int2str(size(alg_data.LT.elem_per_row,1)+1) '] = ' mat2str_c(cumsum([0;alg_data.LT.elem_per_row])) ';\n\n']);
        %fprintf(fid,['const int LTrows[' int2str(size(alg_data.LT.elem_per_row,1)) '] = ' mat2str_c(alg_data.LT.elem_per_row) ';\n\n']);
        fprintf(fid,['static struct SPARSE_MAT LT = {' int2str(size(alg_data.LT.val,1)) ',' int2str(length(alg_data.LT.elem_per_row)) ',LTrows,LTcols,LTdata};\n\n']);

        % D
        fprintf(fid,[def_mat(alg_data.D_inv,'Dinv',opts.precision)]);

        % Permutation matrix p (on vector format)
        fprintf(fid,['static const int p[' int2str(length(alg_data.p)) '] = ' mat2str_c(alg_data.p-1) ';\n\n']);

        % store B and G matrices
        if alg_data.bt == 1
            fprintf(fid,[def_mat(alg_data.B,'B',opts.precision)]);
        elseif not(isempty(alg_data.B))
            % vector representation
            fprintf(fid,['static const ' opts.precision ' B[' int2str(length(alg_data.B)) '] = ' mat2str_c(alg_data.B) ';\n\n']);
        end
        if alg_data.gt == 1
            fprintf(fid,[def_mat(alg_data.G,'G',opts.precision)]);
        elseif not(isempty(alg_data.G))
            % vector representation 
            fprintf(fid,['static const ' opts.precision ' G[' int2str(length(alg_data.G)) '] = ' mat2str_c(alg_data.G) ';\n\n']);
        end
    end
elseif isequal(opts.alg,'FGMprimal')
    
    % dense representation
    fprintf(fid,[def_mat(alg_data.H,'H',opts.precision)]);

    % second argument below to not represent vectors as sparse
    if alg_data.gt == 1
        fprintf(fid,[def_mat(alg_data.Gg,'Gg',opts.precision)]);
    elseif not(isempty(alg_data.Gg))
        fprintf(fid,['const ' opts.precision ' Gg[' int2str(length(alg_data.Gg)) '] = ' mat2str_c(alg_data.Gg) ';\n\n']);
    end
    % second argument below to not represent vectors as sparse
    if alg_data.bt == 1
        fprintf(fid,[def_mat(alg_data.Gb,'Gb',opts.precision)]);
    elseif not(isempty(alg_data.Gb))
        fprintf(fid,['const ' opts.precision ' Gb[' int2str(length(alg_data.Gb)) '] = ' mat2str_c(alg_data.Gb) ';\n\n']);
    end
end
    

if isequal(opts.alg,'ADMM') || isequal(opts.alg,'FGMdual')
    % store C and C'
    % remove C' if not needed!!
    fprintf(fid,[def_mat(alg_data.C,'C',opts.precision)]);
    fprintf(fid,[def_mat(alg_data.C','CT',opts.precision)]);
end

% store E, Einv, using diagonal representations
% E 
Einv = alg_data.E\speye(size(alg_data.E,1));
fprintf(fid,[def_mat(alg_data.E,'E',opts.precision)]);
fprintf(fid,[def_mat(Einv,'Einv',opts.precision)]);

% store Lb, Ub using vector representations
% Lb 
fprintf(fid,['static const ' opts.precision ' Lb[' int2str(length(alg_data.h.Lb)) '] = ' mat2str_c(alg_data.h.Lb) ';\n\n']);
% Ub 
fprintf(fid,['static const ' opts.precision ' Ub[' int2str(length(alg_data.h.Ub)) '] = ' mat2str_c(alg_data.h.Ub) ';\n\n']);
% soft (if soft constraints specified)
if max(alg_data.h.soft) > 0
    fprintf(fid,['static const ' opts.precision ' soft[' int2str(length(alg_data.h.soft)) '] = ' mat2str_c(alg_data.h.soft) ';\n\n']);
end

% L1 = U1 and L2 = U2!!
if isequal(opts.reform,'eq')
    if alg_data.gt == 1
        fprintf(fid,[def_mat(alg_data.h.L1,'L1',opts.precision)]);
    elseif not(isempty(alg_data.h.L1))
        fprintf(fid,['static const ' opts.precision ' L1[' int2str(length(alg_data.h.L1)) '] = ' mat2str_c(alg_data.h.L1) ';\n\n']);
    end
    if alg_data.bt == 1
        fprintf(fid,[def_mat(alg_data.h.L2,'L2',opts.precision)]);
    elseif not(isempty(alg_data.h.L2))
        fprintf(fid,['static const ' opts.precision ' L2[' int2str(length(alg_data.h.L2)) '] = ' mat2str_c(alg_data.h.L2) ';\n\n']);
    end
end

% skip F, always output full solution!
if 0
if not(isequal(alg_data.F,eye(n)))
    fprintf(fid,['F = ' mat2str(alg_data.F) ';\n\n']);
end
end


% add declarations of r1, r2, and R that are used to recover original
% variables
if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq')
    if alg_data.gt == 1 && not(allzeros(alg_data.r1))
        fprintf(fid,[def_mat(alg_data.r1,'r1',opts.precision)]);
    elseif not(isempty(alg_data.r1)) && not(allzeros(alg_data.r1))
        fprintf(fid,['static const ' opts.precision ' r1[' int2str(length(alg_data.r1)) '] = ' mat2str_c(alg_data.r1) ';\n\n']);
    end
    if alg_data.bt == 1 && not(allzeros(alg_data.r2))
        fprintf(fid,[def_mat(alg_data.r2,'r2',opts.precision)]);
    elseif not(isempty(alg_data.r2)) && not(allzeros(alg_data.r2))
        fprintf(fid,['static const ' opts.precision ' r2[' int2str(length(alg_data.r2)) '] = ' mat2str_c(alg_data.r2) ';\n\n']);
    end
end
if isequal(opts.reform,'eq') || isequal(opts.reform,'ineq') || (isequal(opts.reform,'original') && isequal(opts.alg,'FGMprimal'))
    fprintf(fid,[def_mat(alg_data.R,'R',opts.precision)]);
end

% close file
fclose(fid);


