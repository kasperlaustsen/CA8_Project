function x = cpr1a(u)

global Ref

pin = u(1);
pout = u(2);
hin = u(3);
w = u(4);         % Speed [rotations per second]
FaultMode = u(5); %

%Rhos = 5;         % Specific density for R134a gas [kg/(m^3*bar)]
vls = (w/110);    % Valve loss scale factor

Vs1 = 2.1929e-4;  % Stage one volume [m^3]  (58E-3/2)^2*pi*41.5E-3*2
if (FaultMode > 0 && FaultMode < 1)
  Vhs1 = FaultMode*Vs1;  % Stage one harmful volume [m^3]
else
  Vhs1 = 0.05*Vs1;  % Stage one harmful volume (5%) [m^3]
end
sls1 = 0.05*vls;     % Stage one suction loss [bar]
pls1 = 0.05*vls;     % Stage one purge loss [bar]

% Get the state variables for stage one
Ps11 = LimitSignal(pin - sls1, [0.01 20]);
Ps12 = pout + pls1;
%[Tin vin] = TVHP(hin, pin);
%vin = getRefrigSpecVol(hin, pin);
%[Tout vout] = TVHP(hout, pout); 
Tin = Ref.THP(hin,Ps11);
vs11 = Ref.VHP(hin, Ps11);
vs11dry = Ref.VDewP(Ps11);         %[m^3/kg]
% Cpin = Ref.CpMassTP(Tin,Ps11);
% Cvin = Ref.CvMassTV(Tin,vs11);
% gam = Cpin/Cvin
%gam = Ref.CpRatioHP(hin, Ps11);
gam = Ref.CpRatioHP(Ref.HDewP(Ps11), Ps11);

% Liquid slugging impacts volume pumping performance because the liquid
% refrigerant evaporates on its way into the compressor stage. This means
% that the resulting volume flow on the suction port for the compressor is
% greatly reduced. The adiabatic assumption does not cover this and must be
% enhanced to capture this bahviour 
if(vs11 < vs11dry)  
  %Q = LimitValue(Ref.QHP(hin, pin), 0, 1.0);
  vs11 = vs11dry + (vs11dry  -vs11);
end

% Calculate the mass flow for stage one
vs12 = ((Ps12/Ps11)^(-1/gam))*vs11;
% mdots1 = (Vs1/vs1dry - Vhs1/vs12)*w/2;
mdots1 = (Vs1/vs11 - Vhs1/vs12)*w/2;
% Calculate the the change in enthalpy for stage two
% During an adiabatic process, the quantity TV^(gamma-1) is a constant
%T12 = ((Tin+273.15)*vin^(gam-1))/vs12^(gam-1) - 273.15;
% http://en.wikipedia.org/wiki/Adiabatic_process
T12 = ((Tin+273.15)*(pout/Ps11)^((gam-1)/gam) - 273.15)*1.06;

if(T12 < -100)
  Ps11
  gam
  pout
  Tin
end

if(pin < 0.01)
  mdots1 = pin*0.06;
end

hout = LimitSignal(Ref.HTP(T12,pout), [Ref.HDewP(pout) 540000]);
% if(hout == 130000)
%   pin
%   pout
%   Tin
%   Ps11
% end

if(pin > 0.01)
  if(pout > pin)    
    mdot = mdots1;    
  else
    mdot = (1/vs11)*Vs1*w;
  end
else
  mdot = 0;
end

mdot = LimitSignal(mdot, [0 0.5]);

x = [hout mdot];