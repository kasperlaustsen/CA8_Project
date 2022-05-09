%% TESTING compressorModelV2
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


% Inputs for instantiation
V_1_COM1   	= 33e-5;										% 50 cm^3 - found in krestens phd. New value is used to fit it to data.
V_1_COM2   	= V_1_COM1/2;									% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*1e-2;								% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*1e-2;								% 5pct of pre stroke volume
kl_1       	= 1e5/2200;										% found in compressor script sent from kresten
kl_2       	= 1e5/2200;										% found in compressor script sent from kresten 
OMEGA_MAX	= 140; 
INPUT_SCALE_MAX = 100;

% Instantiating object
V1 = V_1_COM2; Vc = V_C_COM2; kl1 = kl_1; kl2 = kl_2; Ccp = 1.19; Ccv = 1;

comp1V2 = compressorModel(V1, Vc, kl1, kl2, Ccp, Ccv, OMEGA_MAX, INPUT_SCALE_MAX, ref);

% these inputs are taken to test whether our model and HifiModel agrees
% pin		= getData('meas_com2in'		,'p',	out)*1e5;
p5		= getData('meas_com2in'		,'p',	out)*1e5;			% pin
T7		= getData('meas_com2in'		,'T',	out)+ 273.15;		% Tin
p1		= getData('cpr_disc_line'	,'p',	out)*1e5;			% pout
omega	= getData('Fcpr'			,''	,	out);				
omega_t = getTime('Fcpr', out);	
omega_new = transformControllerInput(omega,omega_t,t);

% output
mdot1	= getData('cpr_disc_line'	,'m',	out);

% Simulating
comp1V2out_arr = zeros(N,3);
for i=1:N
	comp1V2out_arr(i,:) = comp1V2.simulate(p5(i), p1(i), T7(i), omega_new(i));
end


% Plotting
myfig(2, [width height])
% subplot(211)
plot(t,comp1V2out_arr(:,1))
hold on
plot(t, mdot1)
legend('compModel', 'Krestens model')
% title('Compressor flow comparison')
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')
sgtitle('Compressor flow comparison')


%% TESTING pjjModel
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


% Inputs for instantiations
Mpjjinit = 0.015; % inital mass inside pjj

% Instantiating object:
pjj = pjjModel(Mpjjinit);


% these inputs are taken to test whether our model and HifiModel agrees
mdot4 	= getData('ft_exv_out_line'	,'m',	out)		% flash tank flow			- mdotin1 					
h5		= getData('ft_exv_out_line'	,'h',	out)		% enthalpy flash tank		- hin1				
					
mdot1 	= getData('evap_out_line'	,'m',	out)		% compressor 1 flow			- mdotin2 	
h1		= getData('meas_com1out'	,'h',	out)		% enthalpy compressor 1 out	- hin2					
					
mdot2 	= getData('cpr_disc_line'	,'m',	out)		% compressor 2 flow			- mdotout 		
h2		= getData('cpr_disc_line'	,'h',	out)		% compressor 2 enthalpy		- hout

% Simulating
pjj_arr = zeros(N,2);
for i=1:N
	pjj_arr(i,:) = pjj.simulate(mdot4(i), mdot1(i), mdot2(i), h5(i), h1(i), Ts_arr(i));					   
end


% Plotting
myfig(3, [width height])
subplot(211)
plot(t,pjj_arr(:,1))
hold on
plot(t,h2)

legend('PJJ model', 'Enthalpy measurement, Krestens model')
title('Output comparison with Krestens simulation')
xlabel('Time [s]')
ylabel('Enthalpy [J/kg]')

subplot(212)
plot(t,pjj_arr(:,2))
hold on
xlabel('Time [s]')
ylabel('Mass [kg]')
legend('M_{PJJ}')
title('State: M_{PJJ}')
sgtitle('Pipe Joining Junction')


% %%% checking that the inputs make sense, at least the flows. 
% myfig(31, [width height])
% subplot(211)
% plot(t,mdotin1)
% hold on
% plot(t,mdotin2)
% plot(t,mdotout)
% plot(t,mdotin1+mdotin2+ 0.001)
% legend('mdotin1', 'mdotin2', 'mdotout', 'mdotin1 + mdotin2')
% 
% subplot(212)
% hold on
% plot(t,hin1)
% plot(t,hin2)
% plot(t,hout)
% legend('hin1', 'hin2', 'hout')
% sgtitle('PJJ: Plot of the inputs and outputs of krestens simulation')

%% TESTING condenserModel
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
FAN_MAX = 1;			% max value of fan	

% Inputs for instantiations
Mrinit		= 0.7;			% initial refrigerant mass inside condenser
Tminit		= 273.15 + 30;	% initial metal temperature condenser
UA_ma		= 650/3;		% found kresten PHD
UA_rm		= 1500/1;		% found kresten PHD
lambda		= 0.1;		% pressure drop constant, found in krestens sim model
Cp_m		= 387;		% evaporator and condeser metal (copper), kresten approve
M_m_Con		= 22.976;	% found in ??? (coefficient sheet?
V_i_Con		= 1.8*1e-3;	% Condenser volume


% Instantiating object:
cond = condenserModel(Mrinit, Tminit, UA_rm, UA_ma, V_i_Con, lambda, M_m_Con, Cp_m,	ref, FAN_MAX, INPUT_SCALE_MAX);


% these inputs are taken to test whether our model and HifiModel agrees
mdot2			= getData('cpr_disc_line', 'm', out); 					% mdotin	
h3				= getData('cpr_disc_line', 'h', out);					% hin		
p3				= getData('cond_out_line', 'p', out)*1e5;				% pout			
T3				= getData('cpr_disc_line', 'T', out) + 273.15; 			% T_r				
T_ambi			= getData('Tamb',			'', out); 					% T_ambi		
U_fan			= getData('cond_fan_pct',	'', out);  					% U_fan	
U_fan_t			= getTime('cond_fan_pct',		out);					% U_fan_t	
U_fan_new		= transformControllerInput(U_fan, U_fan_t, t); 			% U_fan_new		
% 
% outputs to benchmark up against
h4				= getData('cond_out_line', 'h', out);					% hout	
mdot3			= getData('cond_out_line', 'm', out);					% mout
p2				= getData('cpr_disc_line', 'p', out)*1e5;				% pin



% Simulating
Nstart = 1100; % Starting index (is at 131 seconds)

condout_arr = zeros(N-Nstart+1,3);
condvars_arr = zeros(N-Nstart+1,7);
for i = 1:(N-Nstart)
	[condvars_arr(i,:), condout_arr(i,:)] = cond.simulate(mdot2(i+Nstart), h3(i+Nstart), p3(i+Nstart), T3(i+Nstart), T_ambi(i+Nstart), U_fan_new(i+Nstart), 	Ts_arr(i+Nstart));
end

tp = t(Nstart:end);

yl1 = 1e5*[1 3.5];
yl2 = [0 0.15];
yl3 = 1e5*[7 10.5];
yl4 = [55 105];

% Plotting 1
% ----------------------
myfig(41, [width height]);
subplot(411)
plot(tp,h4(Nstart:end))
hold on
plot(tp, condout_arr(:,1))
ylim([-4e5 4e5])
legend('Enthalpy measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Enthalpy [J/kg]')
ylim(yl1)

subplot(412)
plot(tp,mdot3(Nstart:end))
hold on
plot(tp, condout_arr(:,2))
legend('Flow measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')
ylim(yl2)

subplot(413)
plot(tp,p2(Nstart:end))
hold on
plot(tp, condout_arr(:,3))
% ylim([-4e5 4e5])
legend('Pressure measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Pressure [Pa]')
ylim(yl3)

subplot(414)
plot(tp, U_fan_new(Nstart:end))
% ylim([-4e5 4e5])
legend('Ufan')
xlabel('Time [s]')
ylabel('Fan speed [%]')
ylim(yl4)
sgtitle('Condenser')


% Plotting 2
% ----------------------

% [obj.v, obj.Qrm, obj.Qma, obj.Mr, obj.Mrdiriv, obj.Tm, obj.Tmdiriv];
% myfig(42, [width height]);
% subplot(411)
% plot(tp, condvars_arr(:,1))
% % ylim([-4e5 4e5])
% legend('v')
% xlabel('Time [s]')
% ylabel('x [x]')
% 
% subplot(412)
% plot(tp, condvars_arr(:,2:3))
% legend('Q_{rm}', 'Q_{ma}')
% xlabel('Time [s]')
% ylabel('x [x]')
% 
% subplot(413)
% plot(tp, condvars_arr(:,4))
% % ylim([-4e5 4e5])
% legend('M_r')
% xlabel('Time [s]')
% ylabel('x')
% 
% subplot(414)
% plot(tp, condvars_arr(:,6))
% hold on
% plot(tp, T_r(Nstart:end))
% % ylim([-4e5 4e5])
% legend('T_m', 'T_r Kresten model input')
% xlabel('Time [s]')
% ylabel('x')

% %%% checking that the inputs make sense,  
% myfig(43, [width height])
% subplot(321)
% plot(tp,mdotin)
% hold on
% plot(tp,mdotout)
% legend('mdotin', 'mdotout')
% 
% subplot(322)
% plot(tp,hin)
% hold on
% plot(tp,hout)
% legend('hin','hout')
% 
% subplot(323)
% plot(tp,pout)
% hold on
% plot(tp,pin)
% legend('pout','pin')
% 
% subplot(324)
% plot(tp,T_r)
% legend('T_r')
% 
% subplot(325)
% plot(tp,T_ambi)
% legend('T_{ambi}')
% 
% subplot(326)
% stairs(U_fan_t,U_fan+1)
% hold on
% stairs(tp,U_fan_new)
% legend('controller sampled U_{fan}', 'variable sampled U_{fan}')
% sgtitle('Condenser: Plot of the inputs and outputs of krestens simulation')

%% TESTING condenser throttle valve model
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
THETA_MAX = 1;			% max value of valves

% Constants
C_Val   	= 0.64;											% discharge coefficient
A_Val   	= ((20/2)^2)*pi*10^-6;							% Cross sectional area
% K_Val   	= C_Val*A_Val;									% collected constant
% K_Val		= 2e-5;											% good value for equal percentage type - approximate value 1e-5from krestens phd
K_Val		= 1.235e-5;										% good value for linear type valve.
% K_Val		= 0.8e-5;										% good value for quick opening valve.

valveType = 'lin'; % Valve type: 'ep' = equal percentage, 'lin' linear, 'fo' = fast opening

% Instantiating object:
val = valveModel(valveType, THETA_MAX,INPUT_SCALE_MAX,K_Val, ref)

% these inputs are taken to test whether our model and HifiModel agrees
p3			= getData('cond_out_line', 'p', out)*1e5;						% pin						
h4			= getData('cond_out_line', 'h', out);							% hin					
mdot3		= getData('cond_out_line', 'm', out); 							% mdotin			
Theta		= getData('Vcond', '',	out);									% Theta	
Theta_t		= getTime('Vcond',		out);									% Theta_t	
Theta_new	= transformControllerInput(Theta, Theta_t, t);					% Theta_new																				
	
% output	
p1		= getData('ft_in_line', 'p', out)*1e5;							% pout



% Simulating
out_arr = zeros(N,1);
var_arr = zeros(N,4);

for i=1:N
	[var_arr(i,:), out_arr(i)] = val.simulate(p3(i), h4(i), mdot3(i), Theta_new(i));
end

yl1 = 1e5*[3.5 10]
myfig(5, [width height])


ax2 = subplot(411)
plot(t,p3)
hold on
plot(t,p1)
plot(t,out_arr)
ylim(yl1)
legend('pin','pout', 'Linear valveModel pout')
xlabel('Time [s]')
ylabel('Pressure [Pa]')
title('$P_{out} = p_{in} - \dot{m}^2 \cdot v \cdot \frac{1}{(f(\Theta)K)^2}$','interpreter','latex')

ax3 = subplot(412)
plot(t,var_arr(:,3))
% plot(t,var_arr)
% legend('v (specific volume)', 'mdotsq', '1/ThetaK', 'Theta')
legend('$\frac{1}{(f(\Theta)K)^2}$','interpreter','latex')
xlabel('Time [s]')
ylabel('[]')

ax4 = subplot(413)
% plot(t,hin)
% legend('hin')
stairs(t,var_arr(:,2))
legend('$\dot{m}^2$','interpreter','latex')
xlabel('Time [s]')
ylabel('Mass flow squared [kg^2/s^2]')

ax5 = subplot(414)
plot(t, var_arr(:,1))
legend('$v$','interpreter','latex')
xlabel('Time [s]')
ylabel('Specific Volume [m^3/kg]')
% stairs(t,Theta_new)
% hold on
% stairs(t, var_arr(:,4))
% legend('Theta', 'Theta after opening degree')

linkaxes([ax2 ax3 ax4 ax5],'x')
sgtitle('Valve model')



% %%% checking that the inputs make sense,  
% myfig(51, [width height])
% subplot(411)
% plot(t,mdotin)
% legend('mdotin')
% 
% subplot(412)
% plot(t,hin)
% legend('hin')
% 
% subplot(413)
% plot(t,pin)
% hold on
% plot(t,pout)
% legend('pin','pout')
% 
% subplot(414)
% stairs(Theta_t,Theta+1)
% hold on
% stairs(t,Theta_new)
% legend('controller sampled Theta', 'variable sampled Theta')
% sgtitle('Condenser Throttle Valve: Plot of the inputs and outputs of krestens simulation')


%% TESTING flash tank model
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


% Constants


% Instantiating object:
ft = flashtankModel(ref);

% these inputs are taken to test whether our model and HifiModel agrees
p1			= getData('ft_in_line', 'p', out)*1e5;				% pin			
h4			= getData('ft_in_line', 'h', out);					% hin		
mdot3		= getData('ft_in_line', 'm', out);					% mdotin	
														
% output
h6		= getData('ft_liq_out_line', 'h', out);				% hout1		
h5		= getData('ft_vap_out_line', 'h', out);				% hout2	
mdot5	= getData('ft_liq_out_line', 'm', out);				% mdotout1
mdot4 	= getData('ft_vap_out_line', 'm', out);				% mdotout2

% %Simulating
ft_arr = zeros(N,4);
for i=1:N
	ft_arr(i,:) = ft.simulate(p1(i), h4(i), mdot3(i));
end


myfig(6, [width height])
subplot(411)
plot(t, ft_arr(:,1))
hold on
plot(t, h6)
legend('hout1: liquid enthalpy','Krestens model')

subplot(412)
plot(t, ft_arr(:,2))
hold on
plot(t, h5)
legend('hout2: vapor enthalpy','Krestens model')

subplot(413)
plot(t, ft_arr(:,3))
hold on
plot(t, mdot5)
legend('mdotout1: liquid mass flow','Krestens model')

subplot(414)
plot(t, ft_arr(:,4))
hold on
plot(t, mdot4)
legend('mdotout2: vapor mass flow','Krestens model')
sgtitle('Flash Tank')
% %%% checking that the inputs make sense
% myfig(61, [width height])
% subplot(511)
% plot(t,mdotin)
% legend('mdotin')
% 
% subplot(512)
% plot(t,hin)
% legend('hin')
% 
% subplot(513)
% plot(t,pin)
% legend('pin')
% 
% subplot(514)
% plot(t,hout1)
% hold on
% plot(t,hout2)
% legend('hout1: liq', 'hout2: vap')
% 
% subplot(515)
% plot(t,mdotout1)
% hold on
% plot(t,mdotout2)
% legend('mdotout1: liq', 'mdotout2: vap')
% sgtitle('Flash tank: Plot of the inputs and outputs of krestens simulation')
% 

%% Testing boxModel
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


Tair	= getData('T_air',	'', out); % For init
Tambi	= getData('Tamb',	'', out); % For init but also input
Tcargo	= getData('tcargo',	'', out); % For init

% State Initial parameters
Tcargoinit	= Tcargo(1); % Set to initial value of simulation
Tairinit	= Tair(end); % Set to steady state value of simulation
Tboxinit	= (Tambi(end) + Tair(end))  / 2; % Average of air and ambient air


% Constants
Cpair		= 1003.5; % from coll comp
Cpbox		= 890; % coll comp says 447 but thats an erorr. It's 890 (aluminium)
Cpcargo		= 447; % from coll comp

UAtotal		= (0.6000 * 12*2.5*2.5); % Heat transfer from ambieant air -> box air. from sim
UAamb		= UAtotal/2; % From simulation
UAba		= UAtotal/2;
UAcargo		= 20*100; % from simulation
% UAcargo		= 500; % from kresten report
% UAcargo		= 20; % from simulation

Mair		= (13.4*2.35*2.46)*1.225; % form coll comp, rho air = 1.225;
Mbox		= 500; % coll comp says 1000. But 500 kg is prob closer???
Mcargo		= 1000; % from simulation

FAN_MAX			= 1;
INPUT_SCALE_MAX = 100;		

% Instantiating object:
box = boxModel(Tairinit, Tboxinit, Tcargoinit, Cpair, Cpbox, Cpcargo, UAamb, UAba, UAcargo, ...
				Mair, Mbox, Mcargo, FAN_MAX, INPUT_SCALE_MAX);

% these inputs are taken to test whether our model and HifiModel agrees
mdotair	= getData('m_dot_air',		'', out);
Tsup	= getData('tsup',			'', out); 
Tambi	= Tambi; % Defined further up for init

Ufan2		= getData('evap_fan_pct', '', 	out); 	
Ufan2_t		= getTime('evap_fan_pct',		out); 	
Ufan2_new	= transformControllerInput(Ufan2, Ufan2_t, t) * 1;	

														
% outputs
Tret	= getData('tret_bf_fan',	'',	out);


% Checking signals
Tair(end)-273.15
Tambi(end)-273.15
Tcargo(end)-273.15
mdotair(end) % [kg/s]
Tsup(end)-273.15
Ufan2(end)

% Qfan2 is going crazy. Lets see:
Ufan2 = Ufan2(end)
Ustarp	= ((Ufan2*FAN_MAX/INPUT_SCALE_MAX)*100 - 55.56)*0.0335
Qfan2	= 177.76 + 223.95*Ustarp + 105.85*Ustarp^2 + 16.75*Ustarp^3

% %Simulating
boxvars_arr = zeros(N,12);
boxout_arr = zeros(N,1);
for i=1:N
	[boxvars_arr(i,:), boxout_arr(i,:)] = box.simulate(Ufan2_new(i), mdotair(i), Tsup(i), Tambi(i), Ts_arr(i));
end


% Plotting
% list of inputs: mdotair, Tsup, Tambi, Ufan2
% list of outputs: Tret

% Comparison plots
myfig(71, [width height])
ax1 = subplot(211)
plot(t, boxout_arr(:))
hold on
plot(t, Tair(:))
legend('model output: Tret/Tair', 'Krestens model: Tair/tret_bf_fan')
xlabel('Time [s]')
ylabel('Temperature [C]')
title('Comparison of our model air temperature vs. Krestens model air temperature')

ax2 = subplot(212)
plot(t, boxvars_arr(:,11))
hold on
plot(t, Tcargo(:))
legend('model output: Tcargo', 'Krestens model: tcargo')
xlabel('Time [s]')
ylabel(' []')
title('Comparison of our model cargo temperature vs. Krestens model cargo temperature')

linkaxes([ax1 ax2], 'x')

% All variables plotted
% Indexes for heat flows and temperatues
Q_idx = [2,3,4,5,6];
T_idx = [7,9,11];
Tderiv_idx = [8, 10, 12]

myfig(72, [width height]);
ax1 = subplot(311);
plot(t, boxvars_arr(:,Q_idx))
legend('Qfan2', 'Qcool', 'Qamb', 'Qca', 'Qba')
xlabel('Time [s]')
ylabel('Heat flow [W]')
title('Heat flows of box')

ax2 = subplot(312);
plot(t, (boxvars_arr(:,T_idx) - 273.15)) % NOTE!: K -> C 
% hold on
% plot(t, boxvars_arr(:,Tderiv_idx)) % NOTE!: NOT K -> C
% legend('Tair', 'Tbox', 'Tcargo', 'Tairderiv',' Tboxderiv', 'Tcargoderiv')
legend('Tair', 'Tbox', 'Tcargo')
xlabel('Time [s]')
ylabel('Temperature [C]')
title('States: Temperatures')

ax3 = subplot(313);
plot(t, boxvars_arr(:,Tderiv_idx)) % NOTE!: NOT K -> C
legend('Tairderiv',' Tboxderiv', 'Tcargoderiv')
xlabel('Time [s]')
ylabel('Temperature [C]')
title('State derivatives: Temperatures')

linkaxes([ax1 ax2 ax3], 'x')



% ALL variables
% plot(t, boxvars_arr(:,:))
% legend('Ustarp', 'Qfan2', 'Qcool', 'Qamb', 'Qca', 'Qba', ...
% 		'Tair', 'Tairderiv', 'Tbox', 'Tboxderiv', 'Tcargo', 'Tcargoderiv')


%% TESTING evaporatorModel
% =========================================================================
clc; clear; close all;
ref = CoolPropPyWrapper('HEOS::R134a');
testInit


N_OP = 6000;

% these inputs are taken to test whether our model and HifiModel agrees
h6			= getData('evap_exv_out_line', 'h', 	out);					% hin				
p4			= getData('evap_exv_out_line', 'p', 	out)*1e5;				% pin				
mdot5		= getData('evap_exv_out_line', 'm', 	out); 					% mdotin	
mdot1		= getData('evap_out_line', 'm',			out); 					% mdotout	
Tv			= getData('evap_out_line', 'T',			out) + 273.15;			% Tv					 
% Tv2			= getData('tsuc', '', 	out);	% adds a bit of heat from pipe in simulation. 
Tret		= getData('tret', '', 	out);	
Ufan		= getData('evap_fan_pct', '', 	out); 	
Ufan_t		= getTime('evap_fan_pct',		out); 	
Ufan_new	= transformControllerInput(Ufan, Ufan_t, t);				
    	

% output
p5			= getData('evap_out_line', 'p',	out)*1e5;						% pout				
h7			= getData('evap_out_line', 'h', out);							% hout		
Tsup		= getData('tsup', '',  out);									% Tsup
sigma		= getData('Sigma', '', out);

% Constants
INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
FAN_MAX = 1;			% max value of fan	

% All these constants needs to be double checked. 
Mlvinit		= 0.5; 
Mvinit		= 1e-1; 
Tmlvinit	= Tv(N_OP) + 1.5; 
Tmvinit		= Tv(N_OP) + 2; 
mdotairinit = 0.1; 
poutinit    = p5(N_OP-1);

V_i_Eva		= 11.9*0.001;									% is 11.9 L  - L->m3 ; from simulink->14*1.8*6*(0.005^2)*pi; %nr_pipes*length*area
Cp_air    	= 1003.5;										% heat capacity of air, google
Cp_m		= 387;											% heat capacity of copper			
rho_air		= 1.225;										% density of air
UA_1      	= 3510;											% found in krestens phd
UA_2      	= 1930;											% found in krestens phd
UA_3      	= 50;											% found in krestens phd
M_m_Eva		= 30;											% [kg] found coeff sheet - evaporator metal mass
Xe			= 0.1;																																								
		
% Instantiating object:
evap = evaporatorModel(Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, poutinit, ...
			V_i_Eva, Cp_air, Cp_m, rho_air, UA_1, UA_2, UA_3, M_m_Eva, Xe, INPUT_SCALE_MAX, ...
			FAN_MAX, ref)

% Simulating
evap_vars_arr = zeros(N,29);
evap_outs_arr = zeros(N,3);
for i=N_OP:N
	[evap_vars_arr(i,:) evap_outs_arr(i,:)]= evap.simulate(h6(i), p4(i), mdot5(i), mdot1(i), Tv(i), Tret(i), Ufan_new(i), Ts_arr(i));

end

% N_OP_stop = N_OP + 5
% 
% evap_arr = zeros(N,29);
% for i=N_OP:N_OP_stop
% 	evap_arr(i,:) = evap.simulate(hin(i), pin(i), mdotin(i), mdotout(i), Tv(i), Tret(i), Ufan_new(i), Ts_arr(i));
% end
% legs = ["Tlv", "v1", "sigma", "Ustarp","Qfan ","Ustarmdot ","Vbardotair", ...
% 	"mbardotair","Tretfan ","Qamv", "Tretsh", "Qamlv","Qmvmlv","Qmlv", ...
% 	"mdotdew","Qmv","hv","Vlv","pout ", "Mlvdiriv","Mvdiriv","mdotairdiriv" ...
% 	,"Tmlvdiriv	","Tmvdiriv","Mlv","Mv","mdotair","Tmlv","Tmv"]
% 
% hv_idx = 17
% pout_idx = 19 
% 
% evap_arr(N_OP:N_OP_stop, 17)  =  evap_arr(N_OP:N_OP_stop, 17)*1e-5
% evap_arr(N_OP:N_OP_stop, 19)  = evap_arr(N_OP:N_OP_stop, 19)*1e-5
% 
% myfig(-1, [width height])
% for i = 1:29
% % 	subplot(6,5,i)
% 	hold on
% 	plot(evap_arr(N_OP:N_OP + 5,i))
% 	
% end
% legend(legs)



myfig(8, [width height])
ax1 = subplot(311)
plot(t, evap_outs_arr(:,1))
hold on
plot(t, p5)
legend('Evaporator output: pout', 'Krestens model')

ax2 = subplot(312)
plot(t, evap_outs_arr(:,2))
hold on
plot(t, h7)
legend('Evaporator output: hout', 'Krestens model')

ax3 = subplot(313)
plot(t, evap_outs_arr(:,3))
hold on
plot(t, Tsup)
legend('Evaporator output: Tsup', 'Krestens model')

linkaxes([ax1 ax2 ax3], 'x')





%% More thorough testing of evaporator.
% clc; clear; 
close all;
% ref = CoolPropPyWrapper('HEOS::R134a');
% testInit


N_OP = 6000;
N_OP_stop = 8000;
% All these constants needs to be double checked. 
Mlvinit		= [0.8257+0.1];		% ( 1e-3*11.8*0.8 ) / ref.VPX(1.85,0.1)  
Mvinit		= [0.0219];		% 1e-3*11.8*0.2 /ref.VDewP(1.85)
Tmlvinit 	= [Tv(N_OP) + 1.5];		
Tmvinit		= [Tv(N_OP) + 2];	
mdotairinit	= [0.1];	
poutinit    = p5(N_OP-1);

V_i_Eva		= 11.9*0.001;									% is 11.9 L  - L->m3 ; from simulink->14*1.8*6*(0.005^2)*pi; %nr_pipes*length*area
Xe			= [0.1] %*[1.1 1 0.6];																																								
Cp_air    	= 1003.5;										% heat capacity of air, google
Cp_m		= 387;											% heat capacity of copper			
rho_air		= 1.225;										% density of air
UA_1      	= [3510] * [3/4 2/3];											% found in krestens phd
UA_2      	= [1930] %*[2 1 0.5];											% found in krestens phd
UA_3      	= [50];											% found in krestens phd
M_m_Eva		= 30;											% [kg] found coeff sheet - evaporator metal mass


	
init_matrx = combvec(Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit,  poutinit,...
			V_i_Eva, Cp_air, Cp_m, rho_air, UA_1, UA_2, UA_3, M_m_Eva, Xe);

c = mat2cell(init_matrx, [ones(1,15)], [ones(1,size(init_matrx,2))]);
% Instantiating objects:

s = struct();
for i=1:size(init_matrx,2)
	s.("evap_"+ i) = evaporatorModel(c{:,i}, ...
			INPUT_SCALE_MAX, FAN_MAX, ref);
end

no_evaps = length(fieldnames(s))

evap_vars_arr_debug = zeros(N,30,no_evaps);
evap_outs_arr_debug = zeros(N,3, no_evaps);


nam = fields(s);

for ii=1:length(fieldnames(s))
	for i=N_OP:N_OP_stop
% 		['evap_', num2str(ii), '| sample no:', num2str(i)]
		[evap_vars_arr_debug(i,:,ii) evap_outs_arr_debug(i,:,ii)]= s.(nam{ii,1}).simulate(h6(i), p4(i), mdot5(i), mdot1(i), Tv(i), Tret(i), Ufan_new(i), Ts_arr(i));
	end
end

% figure out which variables that deviates:
needs_legend = [];
props = properties(s.evap_1);
for kk =1:15
	if range(init_matrx(kk,:)) ~=0
		needs_legend = [needs_legend, string(props{kk,1})];
	else
	end
end

legs = [""]
for jj = 1:size(init_matrx,2)
	legs(jj,1) = join([string(needs_legend(:))', '= [', s.(nam{jj,1}).(needs_legend(1))]);
	for ii = 2:length(needs_legend)
		legs(jj,1) = join([legs(jj,1),  s.(nam{jj,1}).(needs_legend(ii))]);
	end
	legs(jj,1) = join([legs(jj,1), ']']);
end
legs(jj+1,1) = "Krestens model";

% =========================================================================
% figure for debugging
% =========================================================================

myfig(9, [width height]);

linew = 1

ax1 = subplot(421)
for l = 1:size(init_matrx,2)
	plot(t, evap_outs_arr_debug(:,1,l),'Linewidth', linew)
	hold on
end
plot(t, p5)
legend(legs)
ylabel('Pressure [Pa]')

ax2 = subplot(422)
for l = 1:size(init_matrx,2)
	plot(t, evap_outs_arr_debug(:,2,l),'Linewidth', linew)
	hold on
end	
plot(t, h7)
legend(legs)
ylabel('Enthalpy [J/kg]')

ax3 = subplot(423)
for l = 1:size(init_matrx,2)
	plot(t, evap_outs_arr_debug(:,3,l),'Linewidth', linew)
	hold on
end
plot(t, Tsup)
legend(legs)
ylabel('Temperature [K]')

ax4 = subplot(424)
for l = 1:size(init_matrx,2)
	plot(t, evap_vars_arr_debug(:,3,l),'Linewidth', linew)
	hold on
end
plot(t, sigma)
legend(legs)
ylabel('Sigma []')

ax5 = subplot(425)
for l = 1:size(init_matrx,2)
	plot(t, evap_vars_arr_debug(:,25:26,l),'Linewidth', linew)
	hold on
end
legend(["M_{lv}: "; "M_v: "] + legs')
ylabel('Mass []')

ax6 = subplot(426)
for l = 1:size(init_matrx,2)
	plot(t, evap_vars_arr_debug(:,28:29,l),'Linewidth', linew)
	hold on
end
plot(t,Tv)
legg = ["T_{mlv}: "; "T_{mv}: "] + legs'
legg = [legg(1:4), "T_v, Krestens model"]
legend(legg)
ylabel('Temperature [K]')

ax7 = subplot(427)
for l = 1:size(init_matrx,2)
	plot(t, evap_vars_arr_debug(:,15,l),'Linewidth', linew)
	hold on
	plot(t, evap_vars_arr_debug(:,16,l),'Linewidth', linew)
end
legend(["mdotdew: "; "Q_mv: "] + legs')
ylabel("Qmv and mdotdew")

ax8 = subplot(428)
for l = 1:size(init_matrx,2)
	plot(t, evap_vars_arr_debug(:,30,l),'Linewidth', linew)
	hold on
end
plot(t,h6)
legend(legs')
ylabel('Dew point enthalpy [J/kg]')


linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7 ax8], 'x');
sgtitle('Evaporator outputs');




%%


myfig(10, [width height])
ax1 = subplot(211) % plot masses

plot(t, evap_vars_arr_debug(:,25:26,1) )
legend('Mlv', 'Mv')

ax2 = subplot(212) % plot masses
plot(t, evap_vars_arr_debug(:,15,1) )
hold on
plot(t, mdot5)
plot(t, mdot1)
legend('mdotdew', 'mdot5: in', 'mdot1: out')
linkaxes([ax1 ax2],'x')





% %%% checking that the inputs make sense
% myfig(81, [width height])
% subplot(511)
% plot(t, h6)
% hold on
% plot(t, h7)
% legend('Input: hin', 'Output: hout')
% 
% subplot(512)
% plot(t, p4)
% hold on
% plot(t, p5)
% legend('Input: pin', 'Output: pout')
% 
% subplot(513)
% plot(t, Tv)
% hold on
% % plot(t, Tv2)
% plot(t, Tret)
% plot(t, Tsup)
% % legend('Input: Tv: from evap_out_line', 'Input: Tv: from tsuc', 'Input: Tret', 'Output: Tsup')
% legend('Input: Tv: from evap_out_line', 'Input: Tret', 'Output: Tsup')
% 
% subplot(514)
% plot(t, mdot5)
% hold on
% plot(t, mdot1)
% legend('Input: mdotin', 'Input: mdotout')
% 
% subplot(515)
% stairs(Ufan_t, Ufan+1)
% hold on
% stairs(t, Ufan_new)
% legend('Input: Ufan', 'Input: Ufan_new')