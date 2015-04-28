function str = structure(M,upper_case)

if nargin < 2
    upper_case = 0;
end

% return str = '_diag' if M diagonal
% return str = '_sparse' if M sparse
% return str = '' if M full

str = [];

if isdiag(M)
    str = 'diag';
elseif issparse(M)
    str = 'sparse';
else
    str = 'full';
end

if upper_case == 1
    str = upper(str);
end