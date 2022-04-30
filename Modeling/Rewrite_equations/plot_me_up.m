Time = 500;
Ts = 0.1;
no_samples = Time/Ts;
Time_vector = 0:Ts:Time-Ts;


% convert f to function handle with specific input variable order (inputs states)
f_func = matlabFunction(f, 'vars', [U_fan_1, U_fan_2, Theta_1, Theta_2, omega, T_ambi, ...
	M_PJJ, M_Con, T_m, m_dot_air, T_mlv, T_mv, M_lv, M_v, T_air,  T_box,  T_cargo]);


% initial conditions
% -------------------------------
debug_idx = [1 2 3] % 4 5 6 7 8 9 10 11]


% States
state_variables =	[M_PJJ; M_Con; T_m; m_dot_air; T_mlv; T_mv; M_lv; M_v; T_air; T_box; T_cargo];
state_init =		[M_PJJ_OP; M_Con_OP; T_m_OP; m_dot_air_OP; T_mlv_OP; T_mv_OP; M_lv_OP; M_v_OP; T_air_OP; T_box_OP; T_cargo_OP];

% Inputs + disturbance
input_variables = [U_fan_1, U_fan_2, Theta_1, Theta_2, omega, T_ambi];
input_OP_values = [U_fan_1_op, U_fan_2_op, Theta_1_op, Theta_2_op, omega_op, T_ambi_op];


clear states state_derivatives
states(:,1) = state_init;		% initialize states at first sample


% Convert [input, states] to cell array for input to f function
f_func_input = num2cell([input_OP_values, states(:,1)']);

% Generate new state derivatives
state_derivatives(:,1) = f_func(f_func_input{:});


% Simulation
% -------------------------------

for i=2:no_samples
	
    states(debug_idx,i) = states(debug_idx,i-1) + double(state_derivatives(debug_idx,i-1)) * Ts;
	
	f_func_input = num2cell([input_OP_values, states(:,i)']);			% Convert [input states] to cell array for input to f function
	state_derivatives(:,i) = f_func(f_func_input{:});					% Generate new state derivatives

end

% -------------------------------

%Plotting of simulation results
close all
% indexes for plotting
plt_idx  = [1:11];
mass_idx = [1 2 7 8];
temp_idx = [3 5 6 9 10];
flow_idx = [4];

legs = ["1: M_{PJJ}", "2: M_{Con}", "3: T_m", "4: m_{dot}_{air}", "5: T_{mlv}",...
	"6: T_{mv}", "7: M_{lv}", "8: M_{v}", "9: T_{air}",  "10: T_{box}",  "11: T_{cargo}"];


% limits
yl1 = [-5 500];
yl2 = [-10 10];


ax1 = [];
myfig(1);
set(gcf,'Visible','on')
ax1(1) = subplot(2,1,1);
plot(Time_vector,states(plt_idx ,:)')
legend(legs(plt_idx ), 'Location', 'southeast')
grid on
title('States')
% ylim(yl1)

ax1(2) = subplot(2,1,2);
plot(Time_vector,state_derivatives(plt_idx ,:)')
legend(legs(plt_idx ), 'Location', 'southeast')
grid on
title('State derivatives')
ylim(yl2)
linkaxes(ax1,'x')


% ===========================================================================================
%									Figure 2 - masses
yl21 = [-5 5];
yl22 = [-10 10];

ax1 = [];
myfig(2);
set(gcf,'Visible','on')
ax1(1) = subplot(2,1,1);
plot(Time_vector,states(mass_idx ,:)')
legend(legs(mass_idx ), 'Location', 'southeast')
grid on
title('States')
ylim(yl21)

ax1(2) = subplot(2,1,2);
plot(Time_vector,state_derivatives(mass_idx ,:)')
legend(legs(mass_idx ), 'Location', 'southeast')
grid on
title('State derivatives')
ylim(yl22)
linkaxes(ax1,'x')

% ===========================================================================================
%									Figure 3 - Temperatures
yl31 = [-5 500];
yl32 = [-10 10];

ax1 = [];
myfig(3);
set(gcf,'Visible','on')
ax1(1) = subplot(2,1,1);
plot(Time_vector,states(temp_idx ,:)')
legend(legs(temp_idx ), 'Location', 'southeast')
grid on
title('States')
% ylim(yl21)

ax1(2) = subplot(2,1,2);
plot(Time_vector,state_derivatives(temp_idx ,:)')
legend(legs(temp_idx ), 'Location', 'southeast')
grid on
title('State derivatives')
ylim(yl22)
linkaxes(ax1,'x')