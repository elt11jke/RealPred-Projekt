% Data check.
% 
% We check,e.g., that:
%  - all necessary data is provided
%  - data dimensions are correct
%   - sparse matrices are defined as sparse
%   - dense matrices are defined as dense (threshold between sparse and
%   dense is defined in sparsity_threshold)
%  - that symmetric matrices are really symmetric
%  - rank conditions
%  - that stated problem can be solved by at least one
%  algorithm/reformulation combination

function QP = check_data(QP,opts)

fprintf('Checking data....');

% check that all necessary data is provided
if not(isfield(QP,'H'))
    error('QP.H is missing');
end
if not(isfield(QP,'G'))
    QP.G = [];
end
if not(isfield(QP,'A'))
    QP.A = [];
end
if not(isfield(QP,'B'))
    QP.B = [];
end
if isempty(QP.A)+isempty(QP.B) == 1
    error('only one of QP.A and QP.B specified');
end
if not(isfield(QP,'C'))
    error('QP.C is missing');
end
if not(isfield(QP,'h'))
    error('QP.h is missing');
end
if not(isfield(QP,'bt')) && not(isempty(QP.A)) && not(isempty(QP.B))
    error('QP.bt is missing');
elseif not(isfield(QP,'bt'))
    QP.bt = 0;
end
if not(isfield(QP,'gt'))
    error('QP.gt is missing');
end
% check function f
if not(isfield(QP.h,'fcn'))
    error('QP.h.fcn is mising');
end
if not(isequal(QP.h.fcn,'indicator')) && not(isequal(QP.h.fcn,'1norm'))
    error(['QP.h.fcn must be either ' '''indicator''' ' or ' '''1norm''' '\n']);
end

% check constraint data
if isequal(QP.h.fcn,'indicator')
    if not(isfield(QP.h,'Lb'))
        error('QP.Lb is missing');
    end
    if not(isfield(QP.h,'Ub'))
        error('QP.Ub is missing');
    end
    if not(isfield(QP.h,'soft'))
        % set hard constraints as default
        QP.h.soft = [];
    end
end


% 1-norm (write as soft-const for set 0)
if isequal(QP.h.fcn,'1norm')
    if not(isfield(QP.h,'gamma'))
        error('QP.h.gamma is not set');
    end
    if not(is_real_scalar(QP.h.gamma)) 
        error('QP.h.gamma must be a real scalar');
    end
    if not(QP.h.gamma > 0)
        error('QP.h.gamma must be positive');
    end
    % reformulate as indicator problem
    QP.h.Lb = zeros(size(QP.C,1),1);
    QP.h.Ub = zeros(size(QP.C,1),1);
    QP.h.soft = QP.h.gamma*ones(size(QP.C,1),1);
end


% check that parameter flags are 0 or 1 and that gt and or bt = 1
if QP.gt ~= 1 && QP.gt ~= 0
   error('QP.gt must be 0 or 1');
end
if QP.bt ~= 1 && QP.bt ~= 0
   error('QP.bt must be 0 or 1');
end 
if QP.bt + QP.gt == 0
   error('must set either QP.gt and/or QP.bt = 1 to get a parametric program');
end


% check that G defined if gt == 1 and B defined if bt == 1
if QP.gt == 1
    if isempty(QP.G)
        error('QP.G must be defined if QP.gt == 1');
    end
end
if QP.bt == 1
    if isempty(QP.B) || isempty(QP.A)
        error('QP.A and QP.B must be defined if QP.bt == 1');
    end
end



% check that all input data is real and numeric
if not(isnumeric(QP.H)) || not(isreal(QP.H)) || not(allfinite(QP.H))
   error('QP.H must be real and numeric');
end
if not(isnumeric(QP.G)) || not(isreal(QP.G)) || not(allfinite(QP.G))
   error('QP.G must be real and numeric');
end
if not(isnumeric(QP.A)) || not(isreal(QP.A)) || not(allfinite(QP.A))
   error('QP.A must be real and numeric');
end
if not(isnumeric(QP.B)) || not(isreal(QP.B)) || not(allfinite(QP.B))
   error('QP.B must be real and numeric');
end
if not(isnumeric(QP.C)) || not(isreal(QP.C)) || not(allfinite(QP.C))
   error('QP.C must be real and numeric');
end
if not(isnumeric(QP.h.Lb)) || not(isreal(QP.h.Lb))
   error('QP.h.Lb must be real and numeric');
end
if not(isnumeric(QP.h.Ub)) || not(isreal(QP.h.Ub))
   error('QP.h.Ub must be real and numeric');
end
if not(isnumeric(QP.h.soft)) || not(isreal(QP.h.soft))
   error('QP.h.soft must be real and numeric');
end


if isempty(QP.G)
    QP.G = zeros(length(QP.H),1);
end


% store data dimensions
n = length(QP.H);             % nbr of states
m = size(QP.A,1);          % nbr of equality constraints
p = size(QP.C,1);          % nbr of inequality constraints
n_bt = size(QP.B,2);       % size of bt
n_gt = size(QP.G,2);       % size of gt


% store as sparse if frac_zeros < opts.sparsity_threshold
if opts.fast_gen >= 2
    QP = set_sparse(QP,opts.sparsity_threshold); 
end


% check that data sizes are compatible
if n ~= size(QP.H,1) || n ~= size(QP.H,2)
    error('incompatible dimensions in QP.H');
end

if not(isempty(QP.G)) && n ~= size(QP.G,1)
    error('incompatible dimensions in QP.G');
end

if n ~= size(QP.C,2)
    error('incompatible dimensions in QP.C');
end

if not(isempty(QP.A)) && n ~= size(QP.A,2)
    error('incompatible dimensions in QP.A');
end 

if not(isempty(QP.A)) && m >= n
    error('QP.A must have more columns that rows');
end

if not(isempty(QP.B)) && m ~= size(QP.B,1)
    error('incompatible dimensions in QP.B');
end 

if p ~= size(QP.h.Lb,1) || 1 ~= size(QP.h.Lb,2)
    error('incompatible dimensions in QP.h.Lb');
end 

if p ~= size(QP.h.Ub,1) || 1 ~= size(QP.h.Ub,2)
    error('incompatible dimensions in QP.h.Ub');
end 

if not(isempty(QP.h.soft))
    if p ~= size(QP.h.soft,1) || 1 ~= size(QP.h.soft,2)
        error('incompatible dimensions in QP.h.soft');
    end
end

if QP.gt == 0 && not(isempty(QP.G)) && n_gt ~= 1
    error('incompatible dimensions, if QP.gt = 0 then nbr_cols(QP.G)=1');
end

if QP.bt == 0 && not(isempty(QP.B)) && n_bt ~= 1
    error('incompatible dimensions, if QP.bt = 0 then dim(QP.B)=n x 1');
end




% check that QP.h.soft is positive and set inf values to -1 (to avoid
% inf-values in c)
if not(isempty(QP.h.soft))
    if not(isempty(find(QP.h.soft <= 0,1)))
        error('QP.h.soft must be positive in all elements');
    end
    % set inf values to -1
    idx = isinf(QP.h.soft);
    QP.h.soft(idx) = -1;
else
    QP.h.soft = -1*ones(p,1);
end


% check that not both Lb and Ub infinite as same location
if not(isempty(QP.h.Lb)) && not(isempty(QP.h.Ub))
    idx_Lb = isinf(QP.h.Lb);
    idx_Ub = isinf(QP.h.Ub);
    if sum(idx_Lb.*idx_Ub) > 0
        error('both QP.h.Lb and QP.h.Ub inf at same index, remove constraint');
    end
end



% to avoid inf values in C code, set Lb that are -inf to large negative value
if not(isempty(QP.h.Lb))
    idx = isinf(QP.h.Lb);
    QP.h.Lb(idx) = -1e10;
end

% to avoid inf values in C code, set Ub that are inf to large positive value
if not(isempty(QP.h.Ub))
    idx = isinf(QP.h.Ub);
    QP.h.Ub(idx) = 1e10;
end


if opts.fast_gen <= 1
    % check that QP.H not 0
    if max(max(abs(QP.H))) < 1e-12
        error('QP.H may not be 0');
    end

    % check symmetry of QP.H, if slight non-symmetry, make symmetric
    if norm(QP.H-QP.H',1) >= 5e-15*n
        error('QP.H not symmetric'\n);
    else
        QP.H = 1/2*(QP.H+QP.H');
    end

    % check positive semi-definiteness of QP.H
    [~,psd_flag] = chol(QP.H+1e-9*speye(n));
    if psd_flag > 0
        error('QP.H not positive semi-definite'\n);
    end


    % check rank condition on A
    if not(isempty(QP.A))
        [~,psd_flag] = chol(QP.A*QP.A');
        if psd_flag > 0
            error('A does not have full row rank'\n);
        end
    end

    % check that lower bounds are smaller than upper bounds
    if isequal(QP.h.fcn,'indicator')
        if not(isempty(find(QP.h.Lb >= QP.h.Ub,1)))
            error('Lower bound must be (strictly) smaller than upper bound');
        end
    end

    % check that QP.C does not contain any zero rows
    if not(isempty(find(sum(abs(QP.C),2) == 0,1)))
        error('There are row that are all 0 in QP.C. This is not allowed.');
    end

    % check if [H+C'C A';A 0] is invertible. If not, no algorithm is guaranteed
    % to converge
    if not(isinvertible([QP.H+QP.C'*QP.C QP.A';QP.A sparse(m,m)]))
        if isempty(QP.A)
            error(['the matrix H+C''' 'C is not invertible, must hold for algorithms to converge']);
        else
            error(['the matrix [H+C''' 'C A''' ';A 0] is not invertible, must hold for algorithms to converge']);
        end
    end
end

fprintf('done!\n')