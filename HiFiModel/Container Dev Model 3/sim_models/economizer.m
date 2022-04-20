% The economizer is a plate heat exchanger used to subcool the liquid
% refrigerant supplied to the evaporator through the expansion valve. It
% has opposed flows of refrigerant 
% Side one is the "hot" side where the refrigerant going to the evaporator
% is sub-cooled. Side two is the "cold" side where refrigerant is
% evaporated. 

function xdot = economizer_ltp_simple(t,x,u,p)
global Ref

pout1 = x(1);       % Output pressure on side one [bar]
hout1 = x(2);       % Output specific enthalpy on side one [j/kg]
mdotin1 = x(3);     % Mass flow into the economizer on side one [kg/s]
hout2 = x(4);       % Output specific enthalpy on side two [j/kg]
mdotin2 = x(5);     % Mass flow into the economizer on side two [kg/s]
mdotout2 = x(6);    % Mass flow out of the economizer on side two [kg/s]
m1 = x(7);          % Internal refrigerant mass on side one [kg]
m2 = x(8);          % Internal refrigerant mass on side two [kg]
Tm =  x(9);         % Metal temperature
Tsuc  = x(10);      % Suction temperature 


pin1 = u(1);        % Input pressure on side  one [bar]
hin1 = u(2);        % Input specific enthalpy on side one [j/kg]
mdotout1 = u(3);    % Mass flow out of the economizer on side one [kg/s]
pin2 = u(4);        % Input pressure on side two [bar]
hin2 = u(5);        % Input specific enthalpy on side two [j/kg]
pout2 = u(6);       % Output pressure on side two [bar]
vexp = u(7);        % Expansion valve opening [%]  

Vi1 = 0.0005;       % Internal volume on side one (0.5 liter) [m^3]
Vi2 = 0.0005;       % Internal volume on side two (0.5 liter) [m^3]

alfa1 = 10;
alfa2 = 100;

% Get the temperature for the subcooling control volume (should use a LMTD)
T1in = Ref.THP(hin1,pin1);
T1out = Ref.THP(hout1,pout1);
% Get the evaporation temperature for the cold side control volume 
T2in = Ref.THP(hin2,pout2);
T2out = Ref.THP(hout2,pout2);

% Energy flow from subcooling volume (1) to evaporation volume (2)
dT1 = T1in-T2out;
dT2 = T1out-T2in;

% Power used in normal superheating operation 
Qsc = (hin1 - hout1)*mdotout1;
Qevap = (Ref.HDewP(pout2) - hin2)*mdotin2;
Qevap = LimitValue(Qevap, 0, Qsc);
Qnorm = Qevap + alfa1*lmtd(dT1, dT2);


% Limit the output temperatures such that they new can get higher than the
% opposite input temperature. This is necessary during LTP for T1out and 
% mass flow transients for T2out.
T2outLimiter  = LimitValue((T2out-T1in)/1, 0, 1);
T1outLimiter = LimitValue((T2in-T1out)/1, 0, 1);

% Use sqrt for a softer introduction of the limiter when it gets into
% effect
Q = Qnorm*sqrt(1-max([T2outLimiter T1outLimiter]));

if((mdotout1 <= 0.0001) ||  (mdotin2 <= 0.0001)) % Do not use input tempeatures when turned off
%   mdotout1
%   mdotin2
% T1out
% T2out
% hout2
% pout2
  Q = alfa2*(T1out-T2out);
end

%Tmdot = QLimiter2*100-Tm;
Tmdot = 0;


% Get the specific volumes for both sides
V1 = Ref.VHP(hout1,pout1);
%V2 = getRefrigSpecVol((hin2+hout2)/2, pout2);
V2 = Ref.VPX(pout2, 0.055);

% Expansion valve input
Vin_be = Ref.VHP(hin2,pin2);
% kv_evap = 0.21;
% kv_econ = 0.06;
% kv_scale = kv_econ/kv_evap;
% evap_vexp_const = 0.81e-5; % [kg/s]
% vexp_const = kv_scale*evap_vexp_const; % [kg/s]
vexp_const = 0.286e-5; % [kg/s]

if(pin2>pout2) % Check for negative pressure over the expansion valve
  mdotin2ref = vexp * sqrt(2*1/Vin_be*(pin2-pout2)) * vexp_const;
else
  mdotin2ref = 0;
end

% Subcooling side (hot)

if(m1 > 0.0001)
  if(mdotin1 > 0) % Only valid for positive mass flow
    hout1dot = ((hin1-hout1)*mdotin1-Q)/m1;
  else
    hout1dot = -Q/m1;
  end
else
  if(mdotin1 > 0)
    hout1dot = ((hin1-hout1)*mdotin1-Q)/0.0001;
  else
    hout1dot = -Q/0.0001;
  end
end
pout1dot = (pin1 - pout1 - 0.1);
% This works wery well (reference mass flow that removes the mass error in ten seconds)
% The ten seconds is needed to keep the closed loop gain of this equation
% low in order to increase the stability of the equation
% If mass is too large the mass flow in is reduced
mdotin1ref = (Vi1/V1 - m1)/10 + mdotout1;
mdotin1dot = mdotin1ref - mdotin1;
m1dot = mdotin1 - mdotout1;



% Negative mass is bad. It must be handled during startup transients and so
% on. 
if(m2 > 0.0001)
  if(mdotin2 > 0)
    hout2dot = ((hin2 - hout2)*mdotin2 + Q)/m2;
  else
    hout2dot = Q/m2;
  end
else
  if(mdotin2 > 0)
    hout2dot = ((hin2 - hout2)*mdotin2 + Q)/0.0001;
  else
    hout2dot = Q/0.0001;
  end
end

mdotin2dot = (mdotin2ref - mdotin2);
% This works wery well (reference mass flow that removes the mass error in ten seconds)
% The ten seconds is needed to keep the closed loop gain of this equation
% low in order to increase the stability of the equation
% If mass is too large the mass flow out is reduced
mdotout2ref = (m2 - Vi2/V2)/10 + mdotin2;
mdotout2dot = mdotout2ref - mdotout2;
m2dot = mdotin2 - mdotout2;

%Tmdot = (Vi1/V1 - m1)*1000 - Tm; % Mass error
Tsuc_dot = Ref.THP(hout2, pout2) - Tsuc;


xdot = [pout1dot hout1dot mdotin1dot hout2dot mdotin2dot mdotout2dot m1dot m2dot Tmdot Tsuc_dot]';

