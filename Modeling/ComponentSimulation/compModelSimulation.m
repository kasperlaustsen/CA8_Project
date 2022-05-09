clc; clear; close all;

% Import CoolPropWrapper
ref = CoolPropPyWrapper('HEOS::R134a');

% Initialize data and other stuff
testInit

% Non component specific variables
INPUT_SCALE_MAX = 100;	% Inputs are scaled between 0 and this value
FAN_MAX = 1;			% max value of fan
THETA_MAX = 1;
OMEGA_MAX = 140;


% Compressor
% ---------------------
% Inputs for instantiation
V_1_COM1   	= 33e-5;			% 50 cm^3 - found in krestens phd. New value is used to fit it to data.
V_1_COM2   	= V_1_COM1/2;		% 2nd stage is half the first
V_C_COM1   	= V_1_COM1*1e-2;	% 5pct of pre stroke volume
V_C_COM2   	= V_1_COM2*1e-2;	% 5pct of pre stroke volume
kl_1       	= 1e5/2200;			% found in compressor script sent from kresten
kl_2       	= 1e5/2200;			% found in compressor script sent from kresten 

V1 = V_1_COM2; Vc = V_C_COM2; kl1 = kl_1; kl2 = kl_2; Ccp = 1.19; Ccv = 1;

% Instantiating object
compressor = compressorModel(V1, Vc, kl1, kl2, Ccp, Ccv, OMEGA_MAX, INPUT_SCALE_MAX, ref);

% PJJ
% ---------------------

% Inputs for instantiations
Mpjjinit = 0.015; % inital mass inside pjj

% Instantiating object:
pjj = pjjModel(Mpjjinit);


% Condenser
% ---------------------

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


% Valve(s)
% ---------------------
% Constants
C_Val   	= 0.64;											% discharge coefficient
A_Val   	= ((20/2)^2)*pi*10^-6;							% Cross sectional area
% K_Val   	= C_Val*A_Val;									% collected constant
% K_Val		= 2e-5;											% good value for equal percentage type - approximate value 1e-5from krestens phd
K_Val		= 1.235e-5;										% good value for linear type valve.
% K_Val		= 0.8e-5;										% good value for quick opening valve.

valveType = 'lin'; % Valve type: 'ep' = equal percentage, 'lin' linear, 'fo' = fast opening

% Instantiating object:

valveExp = valveModel(valveType, THETA_MAX,INPUT_SCALE_MAX,K_Val, ref);
valveCTV = valveModel(valveType, THETA_MAX,INPUT_SCALE_MAX,K_Val, ref);


% Flash Tank
% ---------------------

% Constants


% Instantiating object:
flashTank = flashtankModel(ref);


% Box
% ---------------------

% Constants
Tair	= getData('T_air',	'', out); % For init
Tambi	= getData('Tamb',	'', out); % For init but also input
Tcargo	= getData('tcargo',	'', out); % For init

% State Initial parameters
Tcargoinit	= Tcargo(1); % Set to initial value of simulation
Tairinit	= Tair(end); % Set to steady state value of simulation
Tboxinit	= (Tambi(end) + Tair(end))  / 2; % Average of air and ambient air

Cpair		= 1003.5; % from coll comp
Cpbox		= 890; % coll comp says 447 but thats an erorr. It's 890 (aluminium)
Cpcargo		= 447; % from coll comp

UAtotal		= (0.6000 * 12*2.5*2.5); % Heat transfer from ambieant air -> box air. from sim
UAamb		= UAtotal/2; % From simulation
UAba		= UAtotal/2;
UAcargo		= 20*100; % from simulation

Mair		= (13.4*2.35*2.46)*1.225; % form coll comp, rho air = 1.225;
Mbox		= 500; % coll comp says 1000. But 500 kg is prob closer???
Mcargo		= 1000; % from simulation	

% Instantiating object:
box = boxModel(Tairinit, Tboxinit, Tcargoinit, Cpair, Cpbox, Cpcargo, UAamb, UAba, UAcargo, ...
				Mair, Mbox, Mcargo, FAN_MAX, INPUT_SCALE_MAX);

% Evaporator
% ---------------------

% Constants
Mlvinit		= 0.5; % OLD VALUE
Mvinit		= 0.1; % OLD VALUE
Tmlvinit	= Tv(N_OP) + 1.5; % OLD VALUE
Tmvinit		= Tv(N_OP) + 2; % OLD VALUE
mdotairinit = 0.1; 
poutinit    = p5(N_OP-1); % OLD VALUE

V_i_Eva		= 11.9*0.001;	% is 11.9 L  - L->m3 ; from simulink->14*1.8*6*(0.005^2)*pi; %nr_pipes*length*area
Cp_air    	= 1003.5;		% heat capacity of air, google
Cp_m		= 387;			% heat capacity of copper			
rho_air		= 1.225;		% density of air
UA_1      	= 3510;			% found in krestens phd
UA_2      	= 1930;			% found in krestens phd
UA_3      	= 50;			% found in krestens phd
M_m_Eva		= 30;			% [kg] found coeff sheet - evaporator metal mass
Xe			= 0.1;																																								

% Instansiation
% Instantiating object:
evap = evaporatorModel(Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, poutinit, ...
			V_i_Eva, Cp_air, Cp_m, rho_air, UA_1, UA_2, UA_3, M_m_Eva, Xe, INPUT_SCALE_MAX, ...
			FAN_MAX, ref)


% ---------------------
