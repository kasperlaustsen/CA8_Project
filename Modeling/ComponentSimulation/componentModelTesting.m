clc;clear;close all;


% TESTING compressorModelV2

% Inputs for instanciations
V_1_COM1   	= 50e-6;										% 50 cm^3 - found in krestens guestimate?
V_1_COM2   	= V_1_COM1/2;									% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*0.05;								% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*0.05;								% 5pct of pre stroke volume
kl_1       	= 1e5/2200;										% found in compressor script sent from kresten
kl_2       	= 1e5/2200;										% found in compressor script sent from kresten 

% Instanciating object


% Simulating
V1 = 50e-6; Vc = V1*0.05; kl1 = 1e5/2200; kl2 = 1e5/2200; Ccp = 5; Ccv = 10;
pin = 1.9*1e5; pout = 1.85*1e5; Tin = 273.15+60; omega = 50;
comp1V2 = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv);
comp1V2out = comp1V2.simulate(pin, pout, Tin, omega)



% TESTING pjjModel

% Inputs for instanciations
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


% TESTING evaporatorModel
Ts = 1; Mlvinit = 0.2; Mvinit = 1/1000; Tmlvinit = -10+273.15; Tmvinit = -10+273.15;
mdotairinit = 0.2; Vi = 50/10000; Cpair = 1000; rhoair = 1000; UA1 = 50; UA2 = 50;
UA3 = 50; Mm = 30; Tvinit = -15 + 273.15;


Vi = 50e-6; 
evap = evaporatorModel(Ts, Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, ...
			Vi, Cpair, rhoair, UA1, UA2, UA3, Mm, Tvinit)

hin = 3000; pin = 1.9*1e5; mdotin = 0.15; mdotout = 0.14; Tret = 30+273.15;
Ufan = 0.5;
evap.simulate(hin, pin, mdotin, mdotout, Tret, Ufan)	