% csolve  Solves a custom quadratic program very rapidly.
%
% [vars, status] = csolve(params, settings)
%
% solves the convex optimization problem
%
%   minimize(quad_form(x_0 - r, Q) + quad_form(u_1 - u_0, R) + quad_form(x_1 - r, Q) + quad_form(u_2 - u_1, R) + quad_form(x_2 - r, Q) + quad_form(u_3 - u_2, R) + quad_form(x_3 - r, Q) + quad_form(u_4 - u_3, R) + quad_form(x_4 - r, Q) + quad_form(u_5 - u_4, R) + quad_form(x_5 - r, Q) + quad_form(u_6 - u_5, R) + quad_form(x_6 - r, Q) + quad_form(u_7 - u_6, R) + quad_form(x_7 - r, Q) + quad_form(u_8 - u_7, R) + quad_form(x_8 - r, Q) + quad_form(u_9 - u_8, R) + quad_form(x_9 - r, Q) + quad_form(u_10 - u_9, R) + quad_form(x_10 - r, Q) + quad_form(u_11 - u_10, R) + quad_form(x_11 - r, Q) + quad_form(u_12 - u_11, R) + quad_form(x_12 - r, Q) + quad_form(u_13 - u_12, R) + quad_form(x_13 - r, Q) + quad_form(u_14 - u_13, R) + quad_form(x_14 - r, Q) + quad_form(u_15 - u_14, R) + quad_form(x_15 - r, Q) + quad_form(u_16 - u_15, R) + quad_form(x_16 - r, Q) + quad_form(u_17 - u_16, R) + quad_form(x_17 - r, Q) + quad_form(u_18 - u_17, R) + quad_form(x_18 - r, Q) + quad_form(u_19 - u_18, R) + quad_form(x_19 - r, Q) + quad_form(u_20 - u_19, R) + quad_form(x_20 - r, Q) + quad_form(u_21 - u_20, R) + quad_form(x_21 - r, Q) + quad_form(u_22 - u_21, R) + quad_form(x_22 - r, Q) + quad_form(u_23 - u_22, R) + quad_form(x_23 - r, Q) + quad_form(u_24 - u_23, R) + quad_form(x_24 - r, Q) + quad_form(u_25 - u_24, R) + quad_form(x_25 - r, Q) + quad_form(u_26 - u_25, R) + quad_form(x_26 - r, Q) + quad_form(u_27 - u_26, R) + quad_form(x_27 - r, Q) + quad_form(u_28 - u_27, R) + quad_form(x_28 - r, Q) + quad_form(u_29 - u_28, R) + quad_form(x_29 - r, Q) + quad_form(u_30 - u_29, R))
%   subject to
%     x_1 == A*x_0 + B*u_0
%     x_2 == A*x_1 + B*u_1
%     x_3 == A*x_2 + B*u_2
%     x_4 == A*x_3 + B*u_3
%     x_5 == A*x_4 + B*u_4
%     x_6 == A*x_5 + B*u_5
%     x_7 == A*x_6 + B*u_6
%     x_8 == A*x_7 + B*u_7
%     x_9 == A*x_8 + B*u_8
%     x_10 == A*x_9 + B*u_9
%     x_11 == A*x_10 + B*u_10
%     x_12 == A*x_11 + B*u_11
%     x_13 == A*x_12 + B*u_12
%     x_14 == A*x_13 + B*u_13
%     x_15 == A*x_14 + B*u_14
%     x_16 == A*x_15 + B*u_15
%     x_17 == A*x_16 + B*u_16
%     x_18 == A*x_17 + B*u_17
%     x_19 == A*x_18 + B*u_18
%     x_20 == A*x_19 + B*u_19
%     x_21 == A*x_20 + B*u_20
%     x_22 == A*x_21 + B*u_21
%     x_23 == A*x_22 + B*u_22
%     x_24 == A*x_23 + B*u_23
%     x_25 == A*x_24 + B*u_24
%     x_26 == A*x_25 + B*u_25
%     x_27 == A*x_26 + B*u_26
%     x_28 == A*x_27 + B*u_27
%     x_29 == A*x_28 + B*u_28
%     x_30 == A*x_29 + B*u_29
%     x_31 == A*x_30 + B*u_30
%     0 <= u_0
%     0 <= u_1
%     0 <= u_2
%     0 <= u_3
%     0 <= u_4
%     0 <= u_5
%     0 <= u_6
%     0 <= u_7
%     0 <= u_8
%     0 <= u_9
%     0 <= u_10
%     0 <= u_11
%     0 <= u_12
%     0 <= u_13
%     0 <= u_14
%     0 <= u_15
%     0 <= u_16
%     0 <= u_17
%     0 <= u_18
%     0 <= u_19
%     0 <= u_20
%     0 <= u_21
%     0 <= u_22
%     0 <= u_23
%     0 <= u_24
%     0 <= u_25
%     0 <= u_26
%     0 <= u_27
%     0 <= u_28
%     0 <= u_29
%     0 <= u_30
%     u_0 <= 10
%     u_1 <= 10
%     u_2 <= 10
%     u_3 <= 10
%     u_4 <= 10
%     u_5 <= 10
%     u_6 <= 10
%     u_7 <= 10
%     u_8 <= 10
%     u_9 <= 10
%     u_10 <= 10
%     u_11 <= 10
%     u_12 <= 10
%     u_13 <= 10
%     u_14 <= 10
%     u_15 <= 10
%     u_16 <= 10
%     u_17 <= 10
%     u_18 <= 10
%     u_19 <= 10
%     u_20 <= 10
%     u_21 <= 10
%     u_22 <= 10
%     u_23 <= 10
%     u_24 <= 10
%     u_25 <= 10
%     u_26 <= 10
%     u_27 <= 10
%     u_28 <= 10
%     u_29 <= 10
%     u_30 <= 10
%     0 <= x_1
%     0 <= x_2
%     0 <= x_3
%     0 <= x_4
%     0 <= x_5
%     0 <= x_6
%     0 <= x_7
%     0 <= x_8
%     0 <= x_9
%     0 <= x_10
%     0 <= x_11
%     0 <= x_12
%     0 <= x_13
%     0 <= x_14
%     0 <= x_15
%     0 <= x_16
%     0 <= x_17
%     0 <= x_18
%     0 <= x_19
%     0 <= x_20
%     0 <= x_21
%     0 <= x_22
%     0 <= x_23
%     0 <= x_24
%     0 <= x_25
%     0 <= x_26
%     0 <= x_27
%     0 <= x_28
%     0 <= x_29
%     0 <= x_30
%     0 <= x_31
%     x_1 <= 19.8
%     x_2 <= 19.8
%     x_3 <= 19.8
%     x_4 <= 19.8
%     x_5 <= 19.8
%     x_6 <= 19.8
%     x_7 <= 19.8
%     x_8 <= 19.8
%     x_9 <= 19.8
%     x_10 <= 19.8
%     x_11 <= 19.8
%     x_12 <= 19.8
%     x_13 <= 19.8
%     x_14 <= 19.8
%     x_15 <= 19.8
%     x_16 <= 19.8
%     x_17 <= 19.8
%     x_18 <= 19.8
%     x_19 <= 19.8
%     x_20 <= 19.8
%     x_21 <= 19.8
%     x_22 <= 19.8
%     x_23 <= 19.8
%     x_24 <= 19.8
%     x_25 <= 19.8
%     x_26 <= 19.8
%     x_27 <= 19.8
%     x_28 <= 19.8
%     x_29 <= 19.8
%     x_30 <= 19.8
%     x_31 <= 19.8
%
% with variables
%      u_0   2 x 1
%      u_1   2 x 1
%      u_2   2 x 1
%      u_3   2 x 1
%      u_4   2 x 1
%      u_5   2 x 1
%      u_6   2 x 1
%      u_7   2 x 1
%      u_8   2 x 1
%      u_9   2 x 1
%     u_10   2 x 1
%     u_11   2 x 1
%     u_12   2 x 1
%     u_13   2 x 1
%     u_14   2 x 1
%     u_15   2 x 1
%     u_16   2 x 1
%     u_17   2 x 1
%     u_18   2 x 1
%     u_19   2 x 1
%     u_20   2 x 1
%     u_21   2 x 1
%     u_22   2 x 1
%     u_23   2 x 1
%     u_24   2 x 1
%     u_25   2 x 1
%     u_26   2 x 1
%     u_27   2 x 1
%     u_28   2 x 1
%     u_29   2 x 1
%     u_30   2 x 1
%      x_1   4 x 1
%      x_2   4 x 1
%      x_3   4 x 1
%      x_4   4 x 1
%      x_5   4 x 1
%      x_6   4 x 1
%      x_7   4 x 1
%      x_8   4 x 1
%      x_9   4 x 1
%     x_10   4 x 1
%     x_11   4 x 1
%     x_12   4 x 1
%     x_13   4 x 1
%     x_14   4 x 1
%     x_15   4 x 1
%     x_16   4 x 1
%     x_17   4 x 1
%     x_18   4 x 1
%     x_19   4 x 1
%     x_20   4 x 1
%     x_21   4 x 1
%     x_22   4 x 1
%     x_23   4 x 1
%     x_24   4 x 1
%     x_25   4 x 1
%     x_26   4 x 1
%     x_27   4 x 1
%     x_28   4 x 1
%     x_29   4 x 1
%     x_30   4 x 1
%     x_31   4 x 1
%
% and parameters
%        A   4 x 4
%        B   4 x 2
%        Q   4 x 4    PSD
%        R   2 x 2    PSD
%        r   4 x 1
%      x_0   4 x 1
%
% Note:
%   - Check status.converged, which will be 1 if optimization succeeded.
%   - You don't have to specify settings if you don't want to.
%   - To hide output, use settings.verbose = 0.
%   - To change iterations, use settings.max_iters = 20.
%   - You may wish to compare with cvxsolve to check the solver is correct.
%
% Specify params.A, ..., params.x_0, then run
%   [vars, status] = csolve(params, settings)
% Produced by CVXGEN, 2015-04-28 05:06:57 -0400.
% CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com.
% The code in this file is Copyright (C) 2006-2012 Jacob Mattingley.
% CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial
% applications without prior written permission from Jacob Mattingley.

% Filename: csolve.m.
% Description: Help file for the Matlab solver interface.
