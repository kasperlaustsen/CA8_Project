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
comp1V2 = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv);

% Simulating
V1 = 50e-6; Vc = V1*0.05; kl1 = 1e5/2200; kl2 = 1e5/2200; Ccp = 5; Ccv = 10;
pin = 1.9*1e5; pout = 1.85*1e5; Tin = 273.15+60; omega = 50;

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

