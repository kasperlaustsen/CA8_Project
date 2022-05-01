clc;clear;close all;

load('HiFi_model_data_for_component_tests.mat')
ref = CoolPropPyWrapper('HEOS::R134a');

%% Constants for simulations
% N_start = 10 % when mdot_COM1 is non zero..
N = size(out.tout,1)
% Beware of the sample time in simulink..
t = out.tout
Ts_arr = [out.tout; out.tout(end)] - [0; out.tout]

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
V_1_COM1   	= 50e-4;										% 50 cm^3 - found in krestens guestimate?
V_1_COM2   	= V_1_COM1/2;									% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*1e-2;								% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*1e-2;								% 5pct of pre stroke volume
kl_1       	= 1e5/2200;										% found in compressor script sent from kresten
kl_2       	= 1e5/2200;										% found in compressor script sent from kresten 


% Instanciating object
% V1 = 50e-6; Vc = V1*0.05; kl1 = 1e5/2200; kl2 = 1e5/2200; Ccp = 5; Ccv = 10;
V1 = V_1_COM2; Vc = V_C_COM2; kl1 = kl_1; kl2 = kl_2; Ccp = 1.19; Ccv = 1;

comp1V2 = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv, ref);

% Simulating
% pin = 1.9*1e5; pout = 1.85*1e5; Tin = 273.15+60; omega = 50; % these variables are used for initial testing

% these are variables to test whether function and HifiModel agrees
pin		= getData('meas_com2in'	,'p',	out);
Tin		= getData('meas_com2in'	,'T',	out);
pout	= getData('cpr_disc_line'	,'p',	out);
omega	= getData('Fcpr'			,''	,	out);
omega_t = getTime('Fcpr', out);
omega_new = transformControllerInput(omega,omega_t,t);

% output
mdot	= getData('cpr_disc_line'	,'m',	out);

comp1V2out_arr = zeros(N,3);



for i=1:N
	comp1V2out_arr(i,:) = comp1V2.simulate(pin(i), pout(i), Tin(i), omega_new(i));
end

myfig(-1)
subplot(211)
plot(t,comp1V2out_arr(:,1))
hold on
plot(t, mdot)
legend('output of comp1 class', 'output of logsout, mdot')
title(['V_1_{COM2}: ', num2str(V_1_COM2), '| V_C_{COM2}: ' num2str(V_C_COM2), '| kl_1: ' num2str(kl_1), '| kl_2: ' num2str(kl_2)])
subplot(212)
plot(t, mdot./comp1V2out_arr(:,1))


max(mdot)
max(comp1V2out_arr(:,1))
%% for whatever reason, out measurements of mdot and phi = 0..
% if we take krestens measurement of cpr meas out, we're good..

% for k=1:28
% 	if size(out.logsout{k}.Values.Data,2) == 5
% 		myfig(k+1)
% 		plot(out.logsout{k}.Values.Data(:,5))
% 		hold on
% 		name = out.logsout{k}.Name
% 		legend(name)
% 		k
% % 		legs = [legs, string(name)];
% 	else
% 	end
% end
% legend(legs)
%% TESTING pjjModel

% Inputs for instantiations
Ts = 1; % Simulation time in s
Mpjjinit = 1; % inital mass inside pjj

% Instanciating object:
pjj = pjjModel(Mpjjinit, Ts);

% Simulating
mdotin1 = 1; mdotin2 = 2; mdotout = 2; hin1 = 1000; hin2 = 2000;
pjj.simulate(mdotin1, mdotin2, mdotout, hin1, hin2);
pjj.M


mdotin1 = 1; mdotin2 = 1.5; mdotout = 2; hin1 = 1000; hin2 = 2000;
pjj.simulate(mdotin1, mdotin2, mdotout, hin1, hin2);
pjj.M


mdotin1 = 1; mdotin2 = 1; mdotout = 2; hin1 = 1000; hin2 = 2000;
pjj.simulate(mdotin1, mdotin2, mdotout, hin1, hin2);
pjj.M


mdotin1 = 1; mdotin2 = 1; mdotout = 2; hin1 = 1000; hin2 = 2000;
pjj.simulate(mdotin1, mdotin2, mdotout, hin1, hin2);
pjj.M



%%

% 
% function new_input = transformControllerInput(input,input_timescale,output_timescale)
% 	% this function transforms inputs to align with output_timescale
% 	% 
% 	% This is needed so that dimensions of the inputs to the simulation 
% 	% aligns. Fx, for the compressor, the input pressures are sampled with
% 	% with a variable time solver, where as the control input omega is 
% 	% sampled every second. 
% 	N = length(output_timescale)
% 	roundTargets = input_timescale;
% 	v = output_timescale;
% 	vRounded = interp1(roundTargets,roundTargets,v,'previous');
% 	
% 	for i = 1:N
% 		input_time = vRounded(i);
% 		idx = find(input_timescale == input_time,1);
% 		new_input(i) = input(idx);
% 	end
% end

% getData('meas_com1in','p',out);
% 
% function data = getData(name, measurement, out)
% % this function finds data for you so you dont have to keep track of
% % indices and measurement numbers
% % 
% % names can be : 
% %				'tcargo'	'ft_in_line'	'cond_out_line'	'ctrl_out'	
% %				'ctrl_in'	'Fcpr'	'Hevap_pct'	'VFT'	'Vcond'	'Vexp'	
% %				'cond_fan_pct'	'evap_fan_pct'	'evap_exv_out_line'	
% %				'evap_out_line'	'tret'	'tret_bf_fan'	'tsuc'	'tsup'	
% %				'ft_exv_out_line'	'ft_liq_out_line'	'ft_vap_out_line'	
% %				'Tamb'	''	''	'cpr_disc_line'	'meas_com1in'	
% %				'meas_com1out'	'meas_com2in'
% % 
% % measurements can be: 
% % 			'p'		: 	Pressure		[bar]
% % 			'h'		: 	Enthalpy		[?]
% % 			'T'		: 	Temperature		[K]
% % 			'Phi'	:	Phi				[?]
% % 			'm'		:	mdot			[?]
% 
% 	for i=1:out.logsout.numElements
% 		if string(out.logsout{i}.Name) == string(name)
% 			break
% 		end
% 	end
% 
% 	meas_arr = ["p", "h", "T", "Phi", "m"]
% 	for j =1:length(meas_arr)
% 		if meas_arr(j) == string(measurement)
% 			break
% 		end
% 	end
% 	data = out.logsout{i}.Values.Data(:,j)
% end

