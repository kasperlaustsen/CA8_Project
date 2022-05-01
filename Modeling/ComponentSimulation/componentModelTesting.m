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
% plot(Ts_arr)
% xlabel('Sample number')
% ylabel('Simulink time sample')

%% TESTING compressorModelV2

% Inputs for instantiation
V_1_COM1   	= 50e-6;										% 50 cm^3 - found in krestens guestimate?
V_1_COM2   	= V_1_COM1/2;									% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*1e-2;								% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*1e-2;								% 5pct of pre stroke volume
kl_1       	= 1e5/2200;										% found in compressor script sent from kresten
kl_2       	= 1e5/2200;										% found in compressor script sent from kresten 
OMEGA_MAX	= 140; 
INPUT_SCALE_MAX = 100;

% Instantiating object
V1 = V_1_COM2; Vc = V_C_COM2; kl1 = kl_1; kl2 = kl_2; Ccp = 1.19; Ccv = 1;

comp1V2 = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv, OMEGA_MAX, INPUT_SCALE_MAX, ref);

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
subplot(211)
plot(t,comp1V2out_arr(:,1))
hold on
plot(t, mdot)
legend(['compModel, Vol: ', num2str(V_1_COM2)], 'Compr. flow, Krestens model')
title('Compressor flow comparison')
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')

subplot(212)
% plot(t, mdot./comp1V2origout_arr(:,1))
% hold on
plot(t, mdot./comp1V2out_arr(:,1))
xlabel('Time [s]')
ylabel('Ratio [\cdot]')
% legend('Hifi model / Original model', 'Hifi model / Hacked model')
legend('Hifi model / comprModel')

title('Ratio between flows')


%% TESTING pjjModel

% Inputs for instantiations
Mpjjinit = 0; % inital mass inside pjj

% Instanciating object:
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
% myfig(2, [width height])
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


% Operating point
v_Con		= 0.0008;										% pure guess. needs to be table look up later


% Instanciating object:
cond = condenserModel(Mrinit, Tminit, UA_rm, UA_ma, V_i_Con, lambda, M_m_Con, Cp_m)


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



cond_arr = zeros(N,5);

% Simulating
for i = 1:N
	cond_arr(i,:) = cond.simulate(mdotin(i), hin(i), pout(i), T_r(i), T_ambi(i), U_fan_new(i), FAN_MAX, INPUT_SCALE_MAX,	Ts_arr(i),	ref);
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
ylabel('Pressure []')

% %%% checking that the inputs make sense,  
% myfig(4, [width height])
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

%% TESTING condenser throttle valve model


%% TESTING evaporatorModel
Ts = 1; Mlvinit = 0.2; Mvinit = 1/1000; Tmlvinit = -10+273.15; Tmvinit = -10+273.15;
mdotairinit = 0.2; Vi = 50/10000; Cpair = 1000; rhoair = 1000; UA1 = 50; UA2 = 50;
UA3 = 50; Mm = 30; Tvinit = -15 + 273.15;


Vi = 50e-6; 
evap = evaporatorModel(Ts, Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, ...
			Vi, Cpair, rhoair, UA1, UA2, UA3, Mm, Tvinit)

hin = 3000; pin = 1.9*1e5; mdotin = 0.15; mdotout = 0.14; Tret = 30+273.15;
Ufan = 0.5;
evap.simulate(hin, pin, mdotin, mdotout, Tret, Ufan)	


