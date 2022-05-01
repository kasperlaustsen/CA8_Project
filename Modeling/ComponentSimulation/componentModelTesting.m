clc;clear;close all;

load('HiFi_model_data_for_component_tests.mat')
ref = CoolPropPyWrapper('HEOS::R134a');

% for figures
b = 2;
width = [700*b];
height = [500*b];
%% Constants for simulations
% N_start = 10 % when mdot_COM1 is non zero..
N = size(out.tout,1)
% Beware of the sample time in simulink..
t = out.tout
Ts_arr = [out.tout(2:N); out.tout(end)] - [0; out.tout(1:end-1)]

myfig(1)
subplot(211)
plot(t)
xlabel('Sample number')
ylabel('Time [s]')
title('Simulink time array')
subplot(212)
plot(Ts_arr)
xlabel('Sample number')
ylabel('Simulink time sample')

%% TESTING compressorModelV2

% Inputs for instantiations

V_1_COM2_orig = 50e-6/2;
V_C_COM2_orig = V_1_COM2_orig*1e-2;

V_1_COM1   	= 50e-4;										% 50 cm^3 - found in krestens guestimate?
V_1_COM2   	= V_1_COM1/2;									% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*1e-2;								% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*1e-2;								% 5pct of pre stroke volume
kl_1       	= 1e5/2200;										% found in compressor script sent from kresten
kl_2       	= 1e5/2200;										% found in compressor script sent from kresten 

% Instantiating object
% V1 = 50e-6; Vc = V1*0.05; kl1 = 1e5/2200; kl2 = 1e5/2200; Ccp = 5; Ccv = 10;
V1 = V_1_COM2; Vc = V_C_COM2; kl1 = kl_1; kl2 = kl_2; Ccp = 1.19; Ccv = 1;

comp1V2 = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv, ref);
comp1V2orig = compressorModelV2(V_1_COM2_orig, V_C_COM2_orig, kl1, kl2, Ccp, Ccv, ref);

% pin = 1.9*1e5; pout = 1.85*1e5; Tin = 273.15+60; omega = 50; % these variables are used for initial testing

% these are variables to test whether our model and HifiModel agrees
pin		= getData('meas_com2in'	,'p',	out);
Tin		= getData('meas_com2in'	,'T',	out);
pout	= getData('cpr_disc_line'	,'p',	out);
omega	= getData('Fcpr'			,''	,	out);
omega_t = getTime('Fcpr', out);
omega_new = transformControllerInput(omega,omega_t,t);

% output
mdot	= getData('cpr_disc_line'	,'m',	out);

% Simulating
comp1V2out_arr = zeros(N,3);
comp1V2origout_arr = zeros(N,3);
for i=1:N
	comp1V2out_arr(i,:) = comp1V2.simulate(pin(i), pout(i), Tin(i), omega_new(i));
	comp1V2origout_arr(i,:) = comp1V2orig.simulate(pin(i), pout(i), Tin(i), omega_new(i));
end


% Plotting
myfig(2, [width height])
subplot(211)
plot(t,comp1V2origout_arr(:,1))
hold on
plot(t,comp1V2out_arr(:,1))
plot(t, mdot)
legend(['Orig model, Vol: ', num2str(V_1_COM2_orig)], ['Hacked model, Vol: ', num2str(V_1_COM2)], 'Compr. flow, Krestens model')
title(['V_1_{COM2}: ', num2str(V_1_COM2), '| V_C_{COM2}: ' num2str(V_C_COM2), '| kl_1: ' num2str(kl_1), '| kl_2: ' num2str(kl_2)])
xlabel('Time [s]')
ylabel('Mass flow [kg/s]')

subplot(212)
plot(t, mdot./comp1V2origout_arr(:,1))
hold on
plot(t, mdot./comp1V2out_arr(:,1))
xlabel('Time [s]')
ylabel('Ratio [\cdot]')
legend('Hifi model / Original model', 'Hifi model / Hacked model')
title('Ratio between flows')


%% TESTING pjjModel

% Inputs for instantiations
Ts = 1; % Simulation time in s
Mpjjinit = 0; % inital mass inside pjj

% Instanciating object:
pjj = pjjModel(Mpjjinit);

% Initial testing
% mdotin1 = 1; mdotin2 = 2; mdotout = 2; hin1 = 1000; hin2 = 2000;
% pjj.simulate(mdotin1, mdotin2, mdotout, hin1, hin2);
% pjj.M


% these are variables to test whether our model and HifiModel agrees
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

