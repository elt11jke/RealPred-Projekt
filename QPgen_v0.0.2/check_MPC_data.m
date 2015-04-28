function MPC = check_MPC_data(MPC)


% check that all MPC input data is specified
if not(isfield(MPC,'Q'))
  error('MPC.Q empty');
end
if not(isfield(MPC,'Qf'))
    MPC.Qf = MPC.Q;
end
if not(isfield(MPC,'R'))
  error('MPC.R empty');
end
if not(isfield(MPC,'q'))
    MPC.q = [];
end
if not(isfield(MPC,'r'))
    MPC.r = [];
end
if not(isfield(MPC,'gt'))
   MPC.gt = 0; 
end
if not(isfield(MPC,'Adyn'))
  error('MPC.Adyn empty');
end
if not(isfield(MPC,'Bdyn'))
  error('MPC.Bdyn empty');
end
if (not(isfield(MPC,'X')) || not(isfield(MPC,'Cx'))) && (not(isfield(MPC,'U')) || not(isfield(MPC,'Cu')))
  error('no state or control constraints specified, either X and Cx or U and Cu must be specified');
end
if xor(isfield(MPC,'X'),isfield(MPC,'Cx'))
   error('must specify both Cx and X to specify state constraints (or none if no state constraints)');
end
if xor(isfield(MPC,'U'),isfield(MPC,'Cu'))
   error('must specify both Cu and U to specify input constraints (or none if no input constraints)');
end
if isfield(MPC,'X') 
    if (not(isfield(MPC.X,'Lb')) || not(isfield(MPC.X,'Ub')))
        error('MPC.X must contain both MPC.X.Lb and MPC.X.Ub');
    end
end
if isfield(MPC,'U')
    if (not(isfield(MPC.U,'Lb')) || not(isfield(MPC.U,'Ub')))
        error('MPC.U must contain both MPC.U.Lb and MPC.U.Ub');
    end
end
if isfield(MPC,'X')
    if not(isfield(MPC.X,'soft'))
        MPC.X.soft = [];
    end
end
if isfield(MPC,'U')
    if not(isfield(MPC.U,'soft'))
        MPC.U.soft = [];
    end
end
if not(isfield(MPC,'Cx')) || not(isfield(MPC,'X'))
    MPC.Cx = [];
    MPC.X.Lb = [];
    MPC.X.Ub = [];
    MPC.X.soft = [];
elseif not(isfield(MPC,'Cu')) || not(isfield(MPC,'U'))
    MPC.Cu = [];
    MPC.U.Lb = [];
    MPC.U.Ub = [];
    MPC.U.soft = [];
end
if not(isfield(MPC,'N'))
    error('no control horizon specified');
end


% check that all input data is real and numeric
if not(isnumeric(MPC.Q)) || not(isreal(MPC.Q))
   error('MPC.Q must be real and numeric');
end
if not(isnumeric(MPC.Qf)) || not(isreal(MPC.Qf))
   error('MPC.Qf must be real and numeric');
end 
if not(isnumeric(MPC.R)) || not(isreal(MPC.R))
   error('MPC.R must be real and numeric');
end
if not(isnumeric(MPC.q)) || not(isreal(MPC.q))
   error('MPC.q must be real and numeric');
end
if not(isnumeric(MPC.r)) || not(isreal(MPC.r))
   error('MPC.r must be real and numeric');
end
if not(isnumeric(MPC.Adyn)) || not(isreal(MPC.Adyn))
   error('MPC.Adyn must be real and numeric');
end
if not(isnumeric(MPC.Bdyn)) || not(isreal(MPC.Bdyn))
   error('MPC.Bdyn must be real and numeric');
end
if not(isnumeric(MPC.Cx)) || not(isreal(MPC.Cx))
   error('MPC.Cx must be real and numeric');
end
if not(isnumeric(MPC.X.Lb)) || not(isreal(MPC.X.Lb))
   error('MPC.X.Lb must be real and numeric');
end
if not(isnumeric(MPC.X.Ub)) || not(isreal(MPC.X.Ub))
   error('MPC.X.Ub must be real and numeric');
end
if not(isnumeric(MPC.X.soft)) || not(isreal(MPC.X.soft))
   error('MPC.X.soft must be real and numeric');
end 
if not(isnumeric(MPC.Cu)) || not(isreal(MPC.Cu))
   error('MPC.Cu must be real and numeric');
end
if not(isnumeric(MPC.U.Lb)) || not(isreal(MPC.U.Lb))
   error('MPC.U.Lb must be real and numeric');
end
if not(isnumeric(MPC.U.Ub)) || not(isreal(MPC.U.Ub))
   error('MPC.U.Ub must be real and numeric');
end
if not(isnumeric(MPC.U.soft)) || not(isreal(MPC.U.soft))
   error('MPC.U.soft must be real and numeric');
end 
if not(isnumeric(MPC.N)) || not(isreal(MPC.N))
    error('MPC.N must be real and numeric');
end
if not(isnumeric(MPC.gt)) || not(isreal(MPC.gt))
   error('MPC.gt must be real and numeric');
end


% store data dimension and check compatibility
n = size(MPC.Q,1);
m = size(MPC.R,1);
px = size(MPC.Cx,1);
pu = size(MPC.Cu,1);

if n ~= size(MPC.Q,2)
    error('MPC.Q not square');
end
if n ~= size(MPC.Qf,1) || n ~= size(MPC.Qf,2)
    error('MPC.Qf not square or compatible with MPC.Q');
end
if m ~= size(MPC.R,2)
   error('MPC.R not square');
end 
if MPC.gt == 1 && (not(isempty(MPC.q)) || not(isempty(MPC.r)))
   error('cannot have MPC.gt = 1 and MPC.q and/or MPC.r specified. choose either parametric or fixed linear term');
end
if n ~= size(MPC.Adyn,1) || n ~= size(MPC.Adyn,2)
    error('MPC.Adyn not square or does not match size of MPC.Q');
end
if n ~= size(MPC.Bdyn,1) || m ~= size(MPC.Bdyn,2)
   error('MPC.Bdyn does not match sizes of MPC.Adyn and MPC.R');
end

if not(isempty(MPC.Cx))
    if n ~= size(MPC.Cx,2)
       error('MPC.Cx does not match size of MPC.Q');
    end
end
if not(isempty(MPC.X.Lb))
    if 1 ~= size(MPC.X.Lb,2)
       error('MPC.X.Lb must be a column vector');
    end
    if px ~= size(MPC.X.Lb,1)
       error('MPC.X.Lb does not match the size of MPC.Cx');
    end
    if 1 ~= size(MPC.X.Ub,2)
       error('MPC.X.Ub must be a column vector');
    end
    if px ~= size(MPC.X.Ub,1)
       error('MPC.X.Ub does not match the size of MPC.Cx');
    end
    if not(isempty(MPC.X.soft))
       if 1 ~= size(MPC.X.soft,2) 
            error('MPC.X.soft must be a column vector');
       end
       if px ~= size(MPC.X.soft,1)
            error('MPC.X.soft does not match the size of MPC.Cx');
       end
    end
end
if not(isempty(MPC.Cu))
    if m ~= size(MPC.Cu,2)
       error('MPC.Cu does not match size of MPC.R');
    end
end
if not(isempty(MPC.U.Lb))
    if 1 ~= size(MPC.U.Lb,2)
       error('MPC.U.Lb must be a column vector');
    end
    if pu ~= size(MPC.U.Lb,1)
       error('MPC.U.Lb does not match the size of MPC.Cu');
    end
    if 1 ~= size(MPC.U.Ub,2)
       error('MPC.U.Ub must be a column vector');
    end
    if pu ~= size(MPC.U.Ub,1)
       error('MPC.U.Ub does not match the size of MPC.Cu');
    end
    if not(isempty(MPC.U.soft))
       if 1 ~= size(MPC.U.soft,2) 
            error('MPC.U.soft must be a column vector');
       end
       if pu ~= size(MPC.U.soft,1)
            error('MPC.U.soft does not match the size of MPC.Cu');
       end
    end 
end
if 1 ~= size(MPC.N,1) || 1 ~= size(MPC.N,2)
   error('MPC.N must be an integer');
end 
if not(isempty(MPC.q))
    if n ~= size(MPC.q,1) || 1 ~= size(MPC.q,2)
        error('size of MPC.q does not match size of MPC.Q');
    end
end
if not(isempty(MPC.r))
    if m ~= size(MPC.r,1) || 1 ~= size(MPC.r,2)
        error('size of MPC.r does not match size of MPC.R');
    end
end

if MPC.gt ~= 0 && MPC.gt ~= 1
   error('MPC.gt must be either 0 or 1');
end

if MPC.gt == 1 && (not(isempty(MPC.q)) || not(isempty(MPC.r)))
   error('MPC.gt == 1 and nonempty MPC.q or MPC.r not supported. either use parametric or fixed linear term'); 
end


% check data validity 
% positive semi-definiteness and symmetry of Q and R
if norm(MPC.Q-MPC.Q',1) >= 5e-15*n
    error('MPC.Q not symmetric');
else
    MPC.Q = 1/2*(MPC.Q+MPC.Q');
end
[~,psd_flag] = chol(MPC.Q+1e-8*speye(n));
if psd_flag > 0
    error('MPC.Q not positive semi-definite');
end
if norm(MPC.Qf-MPC.Qf',1) >= 5e-15*n
    error('MPC.Qf not symmetric');
else
    MPC.Qf = 1/2*(MPC.Qf+MPC.Qf');
end
[~,psd_flag] = chol(MPC.Qf+1e-8*speye(n));
if psd_flag > 0
    error('MPC.Qf not positive semi-definite');
end
if norm(MPC.R-MPC.R',1) >= 5e-15*n
    error('MPC.R not symmetric');
else
    MPC.R = 1/2*(MPC.R+MPC.R');
end
[~,psd_flag] = chol(MPC.R+1e-8*speye(m));
if psd_flag > 0
    error('MPC.R not positive semi-definite');
end

% check controllability of (Adyn,Bdyn)
CB = ctrb(MPC.Adyn,MPC.Bdyn);
if not(rank(CB)) == n
    error('MPC.Adyn and MPC.Bdyn specify a non-controllable system');
end

% check for zero rows in Cx and Cu
if not(isempty(find(sum(MPC.Cx,2) == 0,1)))
    error('MPC.Cx contains a row with only zeros');
end
if not(isempty(find(sum(MPC.Cu,2) == 0,1)))
    error('MPC.Cu contains a row with only zeros');
end
% check if any Lbx > Ubx
if isfield(MPC,'Lbx') || isfield(MPC,'Ubx')
    if not(isempty(find(MPC.X.Lb >= MPC.X.Ub,1)))
        error('MPC.X.Lb greater than or equal to MPC.X.Ub in some entry(entries)');
    end
end
% check if any Lbu > Ubu
if isfield(MPC,'Lbu') || isfield(MPC,'Ubu')
    if not(isempty(find(MPC.U.Lb >= MPC.U.Ub,1)))
        error('MPC.U.Lb greater than or equal to MPC.U.Ub in some entry(entries)');
    end
end
% check that N is an integer
if not(MPC.N == round(MPC.N)) || not(MPC.N > 0)
   error('MPC.N must be a positive integer');
end