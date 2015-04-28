function exit_message_no_mex(QP,opts)


fprintf('-----------------------------------------------------------\n');
fprintf(['C code generated with options (in opts struct):\n\n']);
disp(opts)
fprintf('Change any of these option using the function change_opts()\n');
fprintf('-----------------------------------------------------------\n');
input_str = [];
if QP.gt == 1
    input_str = [input_str 'gt'];
end
if QP.bt == 1
    if not(isempty(input_str))
        input_str = [input_str ','];
    end
    input_str = [input_str 'bt'];
end
input_str_c = [];
if opts.stack_usage < 2
    input_str_c = [input_str_c 'd,'];
    if opts.stack_usage == 0
        input_str_c = [input_str_c 'ws,'];
    end
end

fprintf(['Generated files in folder ' opts.proj_name '_files:\n']);
fprintf('%17sQPgen.h (header file)\n','');
fprintf('%17sQPgen.c (main C file with solver qp())\n','');
fprintf('%17sqp_mex.c (mex gateway-file)\n','');
if opts.stack_usage < 2
    fprintf('%17sinit_data.c (initilize problem data)\n','');
    fprintf('%17sfree_data.c (free problem data)\n','');
    fprintf('%17sdata_struct.h (declaration of struct DATA)\n','');
end
if opts.stack_usage == 0
    fprintf('%17sinit_work_space.c (initilize work space)\n','');
    fprintf('%17sfree_work_space.c (free work space)\n','');
    fprintf('%17swork_space_struct.h (declaration of struct WORK_SPACE)\n','');
end
fprintf(['Generated mex-file in current folder:\n']);
fprintf('%17sqp_mex.mex* (compiled mex-file)\n','');
fprintf(['Generated data in folder ' opts.proj_name '_files/' opts.proj_name '_data:\n']);
if opts.stack_usage < 2
   fprintf('%17s*.bin (data files, NEEDED IN THIS PATH WHEN RUNNING MEX FILE!)\n','');
elseif opts.stack_usage == 2
    fprintf('%17salg_data.c (data file, data included in mex file)\n','');
end
fprintf('-----------------------------------------------------------\n');
fprintf(['Usage MATLAB:\n']);
if opts.stack_usage == 2
    fprintf([' - run mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/QPgen.c\n']);
elseif opts.stack_usage == 1
    fprintf([' - run mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/free_data.c\n']);
elseif opts.stack_usage == 0
    fprintf([' - run mex ' opts.proj_name '_files/qp_mex.c ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/free_data.c ' opts.proj_name '_files/init_work_space.c ' opts.proj_name '_files/free_work_space.c\n']);
end
fprintf([' - solve using function qp_mex(' input_str '):\n']);
fprintf(['       [sol,iter] = qp_mex(' input_str ');\n']);
fprintf('-----------------------------------------------------------\n');
fprintf('Usage C:\n');
if opts.stack_usage == 2
    fprintf([' - compile ' opts.proj_name '_files/QPgen.c\n']);
elseif opts.stack_usage == 1
    fprintf([' - compile ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/free_data.c\n']);
elseif opts.stack_usage == 0
    fprintf([' - compile ' opts.proj_name '_files/QPgen.c ' opts.proj_name '_files/init_data.c ' opts.proj_name '_files/free_data.c ' opts.proj_name '_files/init_work_space.c ' opts.proj_name '_files/free_work_space.c\n']);
end
input_str1 = [];
if QP.gt == 1
    input_str1 = [input_str1 opts.precision ' *gt'];
end
if QP.bt == 1
    if not(isempty(input_str1))
        input_str1 = [input_str1 ','];
    end
    input_str1 = [input_str1 opts.precision ' *bt'];
end
input_str_c1 = [];
if opts.stack_usage < 2
    input_str_c1 = [input_str_c1 'struct DATA *d,'];
    if opts.stack_usage == 0
        input_str_c1 = [input_str_c1 'struct WORK_SPACE *ws,'];
    end
end
if opts.stack_usage < 2
    fprintf([' - initialize data (ones before solving problems, input to qp()):\n       void init_data(struct DATA *d);\n']);
    fprintf([' - free data (ones after solving problems):\n       void free_data(struct DATA *d);\n']);
end
if opts.stack_usage == 0
    fprintf([' - initialize work_space (ones before solving problems, input to qp()):\n       void init_work_space(struct WORK_SPACE *ws);\n']);
    fprintf([' - free work_space (ones after solving problems):\n       void free_work_space(struct WORK_SPACE *ws);\n']);
end
fprintf([' - solve using function qp(' input_str_c 'sol,iter,' input_str '):\n       void qp(' input_str_c1 opts.precision ' *sol, int *iter, ' input_str1 ');\n']);
input_size = [];
if QP.gt == 1
    input_size = [input_size 'size(gt) = ' int2str(size(QP.G,2)) 'x1'];
end
if QP.bt == 1
    if not(isempty(input_size))
        input_size = [input_size ', '];
    end
    input_size = [input_size 'size(bt) = ' int2str(size(QP.B,2)) 'x1'];
end
fprintf('-----------------------------------------------------------\n');
fprintf(['Input dimensions: ' input_size '\n']);
fprintf('-----------------------------------------------------------\n');
fprintf(['Output dimensions: size(sol) = ' int2str(length(QP.H)) 'x1, size(iter) = 1x1\n']);
fprintf('-----------------------------------------------------------\n');