clc;clear;close all;

load('HiFi_model_data_for_component_tests.mat')
ref = CoolPropPyWrapper('HEOS::R134a');

% for figures
b = 2;
width = [700*b];
height = [500*b];
%% Constants for simulations
% N_start = 10 % when mdot_COM1 is non zero..
N = size(out.tout,1);
% Beware of the sample time in simulink..
t = out.tout;
Ts_arr = [out.tout(2:N); out.tout(end)] - [0; out.tout(1:end-1)];

% %%% visualisation of sample variable sample time
% myfig(i)
% subplot(211)
% plot(t)
% xlabel('Sample number')
% ylabel('Time [s]')
% title('Simulink time array')
% subplot(212)
% 
% plot(Ts_arr)
% xlabel('Sample number')
% ylabel('Simulink time sample')

%% TESTING compressorModelV2

% Inputs for instantiation
V_1_COM1   	= 31e-5;										% 50 cm^3 - found in krestens phd. New value is used to fit it to data.
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
pin		= getData('meas_com2in'		,'p',	out)*1e5;
Tin		= getData('meas_com2in'		,'T',	out)+ 273.15;
pout	= getData('cpr_disc_line'	,'p',	out)*1e5;
omega	= getData('Fcpr'			,''	,	out);
omega_t = getTime('Fcpr', out);
omega_new = transformControllerInput(omega,omega_t,t);

% output
mdot	= getData('cpr_disc_line'	,'m',	out);

% Simulating
comp1V2out_arr = zeros(N,3);
for i=1:N
	comp1V2out_arr(i,:) = comp1V2.simulate(pin(i), pout(i), Tin(i), omega_new(i));
end


% Plotting
myfig(2, [width height])
% subplot(211)
plot(t,comp1V2out_arr(:,1))
hold on
plot(t, mdot)
legend(['compModel, Vol: ', num2str(V_1_COM2), 'Original Vol: 50e-5'], 'Krestens model')
title('Compressor flow comparison')
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')

% subplot(212)
% % plot(t, mdot./comp1V2origout_arr(:,1))
% % hold on
% plot(t, mdot./comp1V2out_arr(:,1))
% xlabel('Time [s]')
% ylabel('Ratio [\cdot]')
% % legend('Hifi model / Original model', 'Hifi model / Hacked model')
% legend('Hifi model / comprModel')
% title('Ratio between flows')


%% TESTING pjjModel

% Inputs for instantiations
Mpjjinit = 0; % inital mass inside pjj

% Instantiating object:
pjj = pjjModel(Mpjjinit);


% these inputs are taken to test whether our model and HifiModel agrees
mdotin1 	= getData('ft_exv_out_line'	,'m',	out)	% flash tank flow
hin1		= getData('ft_exv_out_line'	,'h',	out)		% enthalpy flash tank

mdotin2 	= getData('evap_out_line'	,'m',	out)	% compressor 1 flow
hin2		= getData('meas_com1out'	,'h',	out)		% enthalpy compressor 1 out

mdotout 	= getData('cpr_disc_line'	,'m',	out)		% compressor 2 flow
hout		= getData('cpr_disc_line'	,'h',	out)

% Simulating
pjj_arr = zeros(N,2);
for i=1:N
	pjj_arr(i,:) = pjj.simulate(mdotin1(i), mdotin2(i), mdotout(i), hin1(i), hin2(i), Ts_arr(i));					   
end


% Plotting
myfig(3, [width height])
subplot(211)
plot(t,pjj_arr(:,1))
hold on
plot(t,hout)

legend('PJJ model', 'Enthalpy measurement, Krestens model')
title('PJJ comparison of enthalpy with start of simulation')
xlabel('Time [s]')
ylabel('Enthalpy [J/kg]')

subplot(212)
plot(t,pjj_arr(:,2))
hold on
xlabel('Time [s]')
ylabel('Mass [kg]')
legend('M_{PJJ}')
title('Mass in PJJ with start of simulation. Initialised with M = 0')

% 122-167 

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

INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
FAN_MAX = 1;			% max value of fan	

% Inputs for instantiations
Mrinit = 0.5;			% initial refrigerant mass inside condenser
Tminit = 273.15 + 30;	% initial metal temperature condenser
UA_ma		= 650;		% found kresten PHD
UA_rm		= 1500;		% found kresten PHD
lambda		= 0.1;		% pressure drop constant, found in krestens sim model
Cp_m		= 387;		% evaporator and condeser metal (copper), kresten approve
M_m_Con		= 22.976;	% found in ??? (coefficient sheet?
V_i_Con		= 1.8*1e-3;	% Condenser volume


% Instantiating object:
cond = condenserModel(Mrinit, Tminit, UA_rm, UA_ma, V_i_Con, lambda, M_m_Con, Cp_m,	ref, FAN_MAX, INPUT_SCALE_MAX)


% these inputs are taken to test whether our model and HifiModel agrees
mdotin			= getData('cpr_disc_line', 'm', out); 
hin				= getData('cpr_disc_line', 'h', out);
pout			= getData('cond_out_line', 'p', out)*1e5;	
T_r				= getData('cpr_disc_line', 'T', out) + 273.15;  
T_ambi			= getData('Tamb',			'', out); 	
U_fan			= getData('cond_fan_pct',	'', out);  
U_fan_t			= getTime('cond_fan_pct',		out);
U_fan_new		= transformControllerInput(U_fan, U_fan_t, t); 

% outputs to benchmark up against
hout			= getData('cond_out_line', 'h', out);
mdotout			= getData('cond_out_line', 'm', out);
pin				= getData('cpr_disc_line', 'p', out)*1e5;	



% Simulating
cond_arr = zeros(N,5);
for i = 1:N
	cond_arr(i,:) = cond.simulate(mdotin(i), hin(i), pout(i), T_r(i), T_ambi(i), U_fan_new(i), 	Ts_arr(i));
end

myfig(4, [width height])
subplot(311)
plot(t,hout)
hold on
plot(t, cond_arr(:,1))
ylim([-4e5 4e5])
legend('Enthalpy measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Enthalpy [J/kg]')

subplot(312)
plot(t,mdotout)
hold on
plot(t, cond_arr(:,2))
legend('Flow measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')

subplot(313)
plot(t,pin)
hold on
plot(t, cond_arr(:,3))
% ylim([-4e5 4e5])
legend('Pressure measurement, Krestens model', 'CondenserModel')
xlabel('Time [s]')
ylabel('Pressure [Pa]')

% %%% checking that the inputs make sense,  
% myfig(41, [width height])
% subplot(321)
% plot(t,mdotin)
% hold on
% plot(t,mdotout)
% legend('mdotin', 'mdotout')
% 
% subplot(322)
% plot(t,hin)
% hold on
% plot(t,hout)
% legend('hin','hout')
% 
% subplot(323)
% plot(t,pout)
% hold on
% plot(t,pin)
% legend('pout','pin')
% 
% subplot(324)
% plot(t,T_r)
% legend('T_r')
% 
% subplot(325)
% plot(t,T_ambi)
% legend('T_{ambi}')
% 
% subplot(326)
% stairs(U_fan_t,U_fan+1)
% hold on
% stairs(t,U_fan_new)
% legend('controller sampled U_{fan}', 'variable sampled U_{fan}')
% sgtitle('Condenser: Plot of the inputs and outputs of krestens simulation')

%% TESTING condenser throttle valve model

INPUT_SCALE_MAX = 1;	% Inputs are scaled between 0 and this value
THETA_MAX = 100;			% max value of valves

% Constants
C_Val   	= 0.64;											% discharge coefficient
A_Val   	= ((20/2)^2)*pi*10^-6;							% Cross sectional area
% K_Val   	= C_Val*A_Val;									% collected constant
K_Val		= 2e-8;											% approximate value 1e-5from krestens phd
K_Val		= 1.4e-9;										% good value for linear type valve.

% Instantiating object:
val = valveModel(THETA_MAX,INPUT_SCALE_MAX,K_Val, ref)

% these inputs are taken to test whether our model and HifiModel agrees
pin			= getData('cond_out_line', 'p', out)*1e5;	
hin			= getData('cond_out_line', 'h', out);
mdotin		= getData('cond_out_line', 'm', out); 
Theta		= getData('Vcond', '',	out);
Theta_t		= getTime('Vcond',		out);
Theta_new	= transformControllerInput(Theta, Theta_t, t); 																

% output
pout		= getData('ft_in_line', 'p', out)*1e5;	



% Simulating
out_arr = zeros(N,1);
var_arr = zeros(N,3);
for i=1:N
	[var_arr(i,:), out_arr(i)] = val.simulate(pin(i), hin(i), mdotin(i), Theta_new(i));
end


myfig(5, [width height])
ax1 = subplot(511)
plot(t,mdotin)
legend('mdotin')

ax2 = subplot(512)
plot(t,pin)
hold on
plot(t,pout)
plot(t,out_arr)
legend('pin','pout', 'valveModel pout')

% ax3 = subplot(313)

ax3 = subplot(513)
plot(t,var_arr)
legend('v (specific volume)', 'mdotsq', '1/ThetaK')


ax4 = subplot(514)
% plot(t,hin)
% legend('hin')
stairs(t,var_arr(:,1:2))
legend('v', 'mdotsq')

ax5 = subplot(515)
% plot(t,hin)
% legend('hin')
stairs(t,Theta_new)
legend('Theta')

linkaxes([ax1 ax2 ax3 ax4 ax5],'x')




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
% Constants


% Instantiating object:
ft = flashtankModel(ref);

% these inputs are taken to test whether our model and HifiModel agrees
pin			= getData('ft_in_line', 'p', out)*1e5;	
hin			= getData('ft_in_line', 'h', out);
mdotin		= getData('ft_in_line', 'm', out); 
														
% output
hout1		= getData('ft_liq_out_line', 'h', out);	
hout2		= getData('ft_vap_out_line', 'h', out);
mdotout1	= getData('ft_liq_out_line', 'm', out);
mdotout2 	= getData('ft_vap_out_line', 'm', out);

% %Simulating
ft_arr = zeros(N,4);
for i=1:N
	ft_arr(i,:) = ft.simulate(pin(i), hin(i), mdotin(i));
end


myfig(6, [width height])
subplot(411)
plot(t, ft_arr(:,1))
hold on
plot(t, hout1)
legend('hout1: liquid enthalpy','Krestens model')

subplot(412)
plot(t, ft_arr(:,2))
hold on
plot(t, hout2)
legend('hout2: vapor enthalpy','Krestens model')

subplot(413)
plot(t, ft_arr(:,3))
hold on
plot(t, mdotout1)
legend('mdotout1: liquid mass flow','Krestens model')

subplot(414)
plot(t, ft_arr(:,4))
hold on
plot(t, mdotout2)
legend('mdotout2: vapor mass flow','Krestens model')

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


%% TESTING evaporatorModel
N_OP = 6000;

% these inputs are taken to test whether our model and HifiModel agrees
hin			= getData('evap_exv_out_line', 'h', 	out);
pin			= getData('evap_exv_out_line', 'p', 	out)*1e5;	
mdotin		= getData('evap_exv_out_line', 'm', 	out); 
mdotout		= getData('evap_out_line', 'm', 	out); 
Tv			= getData('evap_out_line', 'T', 	out) + 273.15;	
% Tv2			= getData('tsuc', '', 	out);	% adds a bit of heat from pipe in simulation. 
Tret		= getData('tret', '', 	out);	
Ufan		= getData('evap_fan_pct', '', 	out); 	
Ufan_t		= getTime('evap_fan_pct',		out); 	
Ufan_new	= transformControllerInput(Ufan, Ufan_t, t);				
    	

% output
pout		= getData('evap_out_line', 'p',					out)*1e5;	
hout		= getData('evap_out_line', 'h', out);
Tsup		= getData('tsup', '',  out);


% Constants
INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
FAN_MAX = 1;			% max value of fan	

% All these constants needs to be double checked. 
Mlvinit		= 0.5; 
Mvinit		= 1e-1; 
Tmlvinit	= Tv(N_OP) + 1.5; 
Tmvinit		= Tv(N_OP) + 2; 
mdotairinit = 0.1; 
poutinit    = pout(N_OP-1);

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
evap = evaporatorModel(Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, ...
			V_i_Eva, Xe, Cp_air, Cp_m, rho_air, UA_1, UA_2, UA_3, M_m_Eva, INPUT_SCALE_MAX, ...
			FAN_MAX, poutinit, ref)


% Simulating
evap_arr1 = zeros(N,29);
evap_arr2 = zeros(N,3);
for i=N_OP:N
	[evap_arr1(i,:) evap_arr2(i,:)]= evap.simulate(hin(i), pin(i), mdotin(i), mdotout(i), Tv(i), Tret(i), Ufan_new(i), Ts_arr(i));
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



myfig(7, [width height])
ax1 = subplot(311)
plot(t, evap_arr2(:,1))
hold on
plot(t, pout)
legend('Evaporator output: pout', 'Krestens model')

ax2 = subplot(312)
plot(t, evap_arr2(:,2))
hold on
plot(t, hout)
legend('Evaporator output: hout', 'Krestens model')

ax3 = subplot(313)
plot(t, evap_arr2(:,3))
hold on
plot(t, Tsup)
legend('Evaporator output: Tsup', 'Krestens model')

linkaxes([ax1 ax2 ax3], 'x')


%%% checking that the inputs make sense
myfig(71, [width height])
subplot(511)
plot(t, hin)
hold on
plot(t, hout)
legend('Input: hin', 'Output: hout')

subplot(512)
plot(t, pin)
hold on
plot(t, pout)
legend('Input: pin', 'Output: pout')

subplot(513)
plot(t, Tv)
hold on
% plot(t, Tv2)
plot(t, Tret)
plot(t, Tsup)
% legend('Input: Tv: from evap_out_line', 'Input: Tv: from tsuc', 'Input: Tret', 'Output: Tsup')
legend('Input: Tv: from evap_out_line', 'Input: Tret', 'Output: Tsup')

subplot(514)
plot(t, mdotin)
hold on
plot(t, mdotout)
legend('Input: mdotin', 'Input: mdotout')

subplot(515)
stairs(Ufan_t, Ufan+1)
hold on
stairs(t, Ufan_new)
legend('Input: Ufan', 'Input: Ufan_new')
