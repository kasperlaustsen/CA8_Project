clc;clear;close all;

load('HiFi_model_data_for_component_tests_02.mat')


% for figures
b = 2;
width = [700*b];
height = [400*b];

%%
ref = CoolPropPyWrapper('HEOS::R134a');
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



%% TESTING evaporatorModel
N_OP =  6000;

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
% Mlvinit		= 0.5; 
% Mvinit		= 1e-1; 
% Tmlvinit	= Tv(N_OP) + 1.5; 
% Tmvinit		= Tv(N_OP) + 2; 
% mdotairinit = 0.1; 
% poutinit    = pout(N_OP-1);
Mlvinit		= 0.57; 
Mvinit		= 0.04; 
Tmlvinit	= 265.9; 
Tmvinit		= 271.1; 
mdotairinit = 0.8; 
poutinit    = pout(N_OP-1);

V_i_Eva		= 11.9*0.001;	        						% is 11.9 L  - L->m3 ; from simulink->14*1.8*6*(0.005^2)*pi; %nr_pipes*length*area
Cp_air    	= 1003.5;		        						% heat capacity of air, google
Cp_m		= 387;											% heat capacity of copper			
rho_air		= 1.225;										% density of air
UA_1      	= 3510;		%std 3510							% found in krestens phd
UA_2      	= 1930;		%std 1930, 							% found in krestens phd
UA_3      	= 50;											% found in krestens phd
M_m_Eva		= 30;											% [kg] found coeff sheet - evaporator metal mass
Xe			= 0.06;      %----------------------- 0.06 is better, std 0.1																																								
		
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



myfig(8, [width height])
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
ylim([250 300])
linkaxes([ax1 ax2 ax3], 'x')

% 
% %%% checking that the inputs make sense
% myfig(81, [width height])
% subplot(511)
% plot(t, hin)
% hold on
% plot(t, hout)
% legend('Input: hin', 'Output: hout')
% 
% subplot(512)
% plot(t, pin)
% hold on
% plot(t, pout)
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
% plot(t, mdotin)
% hold on
% plot(t, mdotout)
% legend('Input: mdotin', 'Input: mdotout')
% 
% subplot(515)
% stairs(Ufan_t, Ufan+1)
% hold on
% stairs(t, Ufan_new)
% legend('Input: Ufan', 'Input: Ufan_new')

%%

% Hv_test = ref.HDewP(pout(end)) + (UA_2*(evap_arr1(end,29) - Tv(end))*(1 - evap_arr1(end,3))) /( (UA_1*(evap_arr1(end,28)  - evap_arr1(end,1))*evap_arr1(end,3)) /(ref.HDewP(pout(end)) - hin(end)))
% Hv_test = ref.HDewP(evap_arr2(end,1)) +     (UA_2*(evap_arr1(end,29) - Tv(end))*(1 - evap_arr1(end,3))) /( (UA_1*(evap_arr1(end,28)  - evap_arr1(end,1))*evap_arr1(end,3)) /(ref.HDewP(evap_arr2(end,1)) - hin(end)))
% Hv_test = ref.HDewP(evap_arr2(end,1)) +    evap_arr1(end,16)/evap_arr1(end,15)
Hv_test = ref.HDewP(pout(end)) +    (evap_arr1(end,16)/evap_arr1(end,15))

syms UA_2_test
EQ = 4.1909e+05 +     (UA_2_test*(evap_arr1(end,29) - Tv(end))*(1 - evap_arr1(end,3))) /( (UA_1*(evap_arr1(end,28)  - evap_arr1(end,1))*evap_arr1(end,3)) /(4.1909e+05 - hin(end)));
solve(EQ == 396816,UA_2_test )

