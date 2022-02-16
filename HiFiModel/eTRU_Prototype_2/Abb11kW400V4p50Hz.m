% Motor data for ABB 11 kW 400 Volt
%
% Source : p:\SimuLib\main_FC\ModelData\MotorData\Doc\Potsdam3\ABB11kW4P400V50Hz.xls
%
% Created 20/6-17 HJN

asm.nom.File='ABB11kW400V4p50Hz.m';	% File name for this file
asm.nom.Icon='ABB 11kW';		% Short name for use on simulink icons

% Nameplate  data
asm.nom.Type='3GBA 162 410-ASD';
asm.nom.Power=11000;		% [W] Rated power
asm.nom.Current=21.1;	% [Arms] Rated current
asm.nom.Voltage=400;	% [Vrms] Rated voltage
asm.nom.Frequency = 50;	% [Hz] Rated frequency
asm.nom.Speed=1477;		% [RPM] Rated speed
asm.nom.Zpp = 2;		% [-] Polepair

% Electrical one phase equivalent data
asm.nom.Rs = 0.27;		% [Ohm] Stator resistance
asm.nom.Rr = 0.19;	% [Ohm] Rotor resistance
asm.nom.Lsl= 0.66/(2*pi*asm.nom.Frequency);		% [H] Stator leakage inductance
asm.nom.Lrl= 1.55/(2*pi*asm.nom.Frequency);		% [H] Rotor leakage inductance
asm.nom.Lh = 30.0/(2*pi*asm.nom.Frequency);		% [H] Main inductance
asm.nom.J = 0.060;		% [kg m2] Rotor inertia
asm.nom.Rfe=458;			% [Ohm] Iron loss resistance

CalcParameters;			% Calculate derived motor parameters

% Define a structure with nominel (rated) and one with actual motor in order to simulate effect of motor parameter errors
asm.act = asm.nom;