Time = 100;
Ts = 0.01;
t = 0:Ts:Time-Ts;
no_samples = Time/Ts;


% ================================================================= initial conditions
state_Variables			= [M_PJJ;	M_Con;	T_m;   m_dot_air;  T_mlv;   T_mv;  M_lv;  M_v;    T_air;     T_box;     T_cargo];
init_conditions			= [0.001;	2;		302;   1;          273;     273;   2;     0.0085;  273+10;    273+10;    273+10];

Input_OP_parameters 	= [U_fan_1, U_fan_2, Theta_1, Theta_2, omega, T_ambi];
Input_OP_values			= [U_fan_1_op, U_fan_2_op, Theta_1_op, Theta_2_op, omega_op, T_ambi_op];
f						= subs(f, Input_OP_parameters, Input_OP_values);

states(:,1) = init_conditions;


for i=2:no_samples
	
	f_current = subs(f,state_Variables,states(:,i-1));
	states(:,i) = states(:,i-1) + f_current*Ts;

end
states;


titls = ["M_{PJJ}", "M_{Con}", "T_m}", "m_{dot}_{air}", "T_{mlv}", "T_{mv}", "M_{lv}", "M_v", "T_{air}", "T_{box}", "T_{cargo}"]
for j = 1:11
	figure(j)
	plot(t,states(j,:))
	title(titls(j))
end
