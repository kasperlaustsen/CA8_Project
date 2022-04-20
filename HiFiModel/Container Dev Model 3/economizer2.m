% The economizer is a plate heat exchanger used to subcool the liquid
% refrigerant supplied to the evaporator through the expansion valve. It
% has opposed flows of refrigerant
% Side one is the "hot" side where the refrigerant going to the evaporator
% is sub-cooled. Side two is the "cold" side where refrigerant is
% evaporated.

function xdot = economizer2(t,x,u,p)

pout1 = x(1);       % Output pressure on side one [bar]
hout1 = x(2);       % Output specific enthalpy on side one [j/kg]
mdotin1 = x(3);     % Mass flow into the economizer on side one [kg/s]
hout2 = x(4);       % Output specific enthalpy on side two [j/kg]
mdotin2 = x(5);     % Mass flow into the economizer on side two [kg/s]
mdotout2 = x(6);    % Mass flow out of the economizer on side two [kg/s]
m1 = x(7);          % Internal refrigerant mass on side one [kg]
m2 = x(8);          % Internal refrigerant mass on side two [kg]
Tm =  x(9);         % Metal temperature

pin1 = u(1);        % Input pressure on side one [bar]
hin1 = u(2);        % Input specific enthalpy on side one [j/kg]
mdotout1 = u(3);    % Mass flow out of the economizer on side one [kg/s]
pin2 = u(4);        % Input pressure on side two [bar]
hin2 = u(5);        % Input specific enthalpy on side two [j/kg]
pout2 = u(6);       % Output pressure on side two [bar]
vexp = u(7);        % Expansion valve opening [%]

Vi1 = 0.0005;       % Internal volume on side one (0.5 liter) [m^3]
Vi2 = 0.0005;       % Internal volume on side two (0.5 liter) [m^3]
Cpm = 500;          % Heat capacity of metal [J/(kg*K)]
Mm  = 2;            % Mass of the metal [kg]
alfa1 = 1000;
alfa2 = 300;
alfa3 = 1000;
alfa4 = 100; % Test alfa for calculating sigma_econ

% Get the output temperature for the subcooling control volume
Tout1 = getRefrigTemp(hout1,pout1);
% Get the input temperature for the subcooling control volume (approximately TC)
Tin1 = getRefrigTemp(hin1,pin1);
T1 = (Tin1+Tout1)/2;

% Get the output temperature for the evaporation side control volume
Tout2 = getRefrigTemp(hout2,pout2);
%Get the input temperature or the evaporation side control volume, after the expansion valve
Tin2 = getRefrigTemp(hin2,pout2);
T2 = (Tin2+Tout2)/2;


% Get the specific volumes for both sides
V1 = getRefrigSpecVol(hout1,pout1);
V2 = getRefrigSpecVol((hin2+hout2)/2,pin2+0.1);
[T X2] = TXPH(pin2+0.1,(hin2+hout2)/2);
sigma = LimitValue((1-X2), 0, 1);

Q1 = (hin1-hout1)*mdotout1
% Power of evaporation for cold side 2
Qevap = (HDewP(pin2) - hin2)*mdotout2
% Find the equivalent temperature drop on the hot liquid side 1
dT1Evap = Qevap/(CpBubT(Tin1)*mdotout1)
% Calculate the LMTD for the evaporating volume
dT1 = Tout1 + dT1Evap - Tin2
dT2 = Tout1 - Tin2
Tlmtd_evap = lmtd(dT1,dT2)
% Find sigma
sigma_econ = LimitValue(Qevap/(Tlmtd_evap*alfa1),0,1)


% Power of the superheating
Qsh = (hout2 - HDewP(pin2))*mdotout2
% Find the equivalent temperature increase on the hot liquid side 1
dT1sh = Qsh/(CpBubT(Tin1)*mdotout1)






q1 = (hin1-hout1)*mdotout1
q2 = (hin2-hout2)*mdotout2

% Liquid carry over
% Not all of the refrigerant is evaporated so it must be calculated
% what the void fraction is on the evaporation output and what the
% temperature drop is on the liquid side.
if(sigma_econ >= 1)
  
  
else % Normal superheat
  % Calculate 
  
  
  
end





%sigma = sigma2;





alfa1 = 1000;
alfa2 = 300;
alfa3 = 500;

% Calculate the energy flow from the metal to the liquid volume
Qml = alfa1*(Tm-T2)*sigma;
% Calculate the energy flow from the metal to the vapor volume
Qmv = alfa2*(Tm-T2)*(1-sigma);
% Calculate the amount of energy flowing from the subcooled refrigerant to
% the metal
Qscm = alfa3*((T1+273.15)-(Tm+273.15));

Tmdot = (Qscm-Qml-Qmv)/(Mm*Cpm);

m1dot = mdotin1 - mdotout1;
pout1dot = 0.1 * (pin1 - pout1 - 0.1);
hout1dot = ((hin1-hout1)*mdotin1-Qscm)/m1;
mdotin1dot = -((m1dot*V1)/Vi1 + (m1*V1 - Vi1));

m2dot = mdotin2 - mdotout2;
hout2dot = ((hin2 - hout2)*mdotin2 + (Qmv+Qml))/m2;

% Expansion valve/mass flow
Vin_be = getRefrigSpecVol(hin2,pin2);
kv_evap = 0.21;
kv_econ = 0.06;
kv_scale = kv_econ/kv_evap;
vexp_const = kv_scale*1.0e-5; % [kg/s]
if(pin2>pout2) % Check for negative pressure over the expansion valve
  mdotref = vexp * sqrt(2*1/Vin_be*(pin2-pout2)) * vexp_const;
else
  mdotref = 0;
end
mdotin2dot = (mdotref - mdotin2);

mdotout2dot = (m2dot*V2)/Vi2 + (m2*V2 - Vi2);

xdot = [pout1dot hout1dot mdotin1dot hout2dot mdotin2dot mdotout2dot m1dot m2dot Tmdot]';
