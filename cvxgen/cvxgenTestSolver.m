
%CVXGEN in matlab 

 params.A = [0.9708 0 0.02466 0;0 0.9689 0 0.4032 ;0 0 0.7495 0;0 0 0 0.5898 ];
 params.B= [0.1126 0.0072; 0.0108 0.1061;0 0.0482;0.0381 0 ];
 
 params.Q=[1 0 0 0;0 1 0 0; 0 0 0 0; 0 0 0 0];
 params.R=[1 0;0 1];

 params.S = 0.7231295261251562; 

 settings.verbose = 0;
 
 % Assign initial parameters intial state
params.x_0 = [0 ; 0 ; 0; 0];



% Assign initial parameters ref
params.r=[10;10;10;10];


% Exercise the high-speed solver.
for jj = 1:100
tic
[vars, status] = csolve(params,settings);  % solve, saving results.
tt = toc
end

% Check convera=struct2cell(vars);gence, and display the optimal variable value.
if ~status.converged, error 'failed to converge'; end
vars.x

a=struct2cell(vars);
hold on;
for i=1:30
    b=cell2mat(a(i));
    plot(i,b(1),'*');
end
hold off;