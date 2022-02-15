clc

global Ref

% r134aPropertyTables = twoPhaseFluidTables([74,500],[0.0005,3],25,25,60,'R134a','py.CoolProp.CoolProp.PropsSI');
% Ref = CoolPropPyWrapper('HEOS::R134a');

% refname = 'R404A'
% refname = 'R290'
refname = 'R134a'
%refname = 'R1234yf'
% refname = 'R410A'

Ref = CoolPropPyWrapper(['HEOS::' refname] )
% plot = RefrigeranthlogPClass(Ref)
% plot.Plot()
Pmin = Ref.PressureMin / 1e6 % to MPa
Pmax = Ref.PressureMax / 1e6 % to MPa
Umin = Ref.UTP(Ref.Tmin-1, 2)/1000
Umax = Ref.UTP(Ref.Tmax, 2)/1000
RefrigerantPropertyTables = twoPhaseFluidTables([Umin,Umax],[Pmin,Pmax],25,25,60, refname,'py.CoolProp.CoolProp.PropsSI');


% Load motor data
Abb11kW400V4p50Hz;
% Load EC Fan data
EC_FanData;