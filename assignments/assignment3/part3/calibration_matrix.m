%% Vanishing Points from previous question
vp_1 = [-202 215 1]';
vp_2 = [1371 230 1]';
vp_3 = [503 4867 1]';

%% Solve for matrix K

% First compute inv(K')
% Compute v_i' * inv(K') * K * v_j
% Use three vanishing point to compute constraints

syms u v f;

eqns = [-u * (vp_2(1) + vp_3(1)) + vp_2(1) * vp_3(1) - v * (vp_2(2) + vp_3(2)) + vp_2(2) * vp_3(2) == ...
        -u * (vp_3(1) + vp_1(1)) + vp_3(1) * vp_1(1) - v * (vp_3(2) + vp_1(2)) + vp_3(2) * vp_1(2), ...
        -u * (vp_1(1) + vp_2(1)) + vp_1(1) * vp_2(1) - v * (vp_1(2) + vp_2(2)) + vp_1(2) * vp_2(2) == ...
        -u * (vp_3(1) + vp_1(1)) + vp_3(1) * vp_1(1) - v * (vp_3(2) + vp_1(2)) + vp_3(2) * vp_1(2)];

% eqns = [vp_2(1) * (vp_1(1) - u * vp_1(1)) + vp_2(2) * (vp_1(2) - v * (vp_1(2))) +  vp_2(3) * (vp_1(3) + u * (1/f * vp_1(1) - u/f * vp_1(1)) + v * (1/f * vp_1(2) - v/f * vp_1(2))) == 0, ...    
%         vp_3(1) * (vp_1(1) - u * vp_1(1)) + vp_3(2) * (vp_1(2) - v * (vp_1(2))) +  vp_3(3) * (vp_1(3) + u * (1/f * vp_1(1) - u/f * vp_1(1)) + v * (1/f * vp_1(2) - v/f * vp_1(2))) == 0, ...
%         vp_3(1) * (vp_2(1) - u * vp_2(1)) + vp_3(2) * (vp_2(2) - v * (vp_2(2))) +  vp_3(3) * (vp_2(3) + u * (1/f * vp_2(1) - u/f * vp_2(1)) + v * (1/f * vp_2(2) - v/f * vp_2(2))) == 0];

vars = [u v f];

[sol_u, sol_v, sol_f] = solve(eqns, vars);

%% Solution to u v f 
f = double(sol_f);
f = f(1);
u = double(sol_u);
v = double(sol_v);

%% Calibration matrix
K = [f, 0, u(1);
     0, f, v(1);
     0, 0, 1]

%%  
% K= [-774.3358 0 546.0258; 0 -774.3358 355.0230; 0 0 1.0000]; 

%% Rotation matrix                

r_z = K \ vp_1;
r_x = K \ vp_2;
r_y = K \ vp_3;

r_x = r_x / norm(r_x);
r_y = r_y / norm(r_y);
r_z = r_z / norm(r_z);

R = [r_x r_y r_z]