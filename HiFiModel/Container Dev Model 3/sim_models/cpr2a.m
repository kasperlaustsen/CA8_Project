function x = cpr2a(u)
global Ref

pin = u(1);
pout = u(2);
hin = u(3);
w = u(4);         % Speed [rotations per second]
FaultMode = u(5); % 

%Rhos = 5;         % Specific density for R134a gas [kg/(m^3*bar)]
vls = (w/110);    % Valve loss scale factor

Vs2 = 1.3739e-4;  % Stage two volume [m^3]  (58E-3/2)^2*pi*26E-3*2
if (FaultMode > 1)
  Vhs2 = (FaultMode-1)*Vs2;  % Stage two harmful volume (50%) [m^3]
else
  Vhs2 = 0.05*Vs2;  % Stage two harmful volume (5%) [m^3]
end
sls2 = 0.5*vls;   % Stage two suction loss [bar]
pls2 = 0.5*vls;   % Stage two purge loss [bar]

% Calculate the heat transfered from the frequency converter to the refrigerent
% [Tin vin] = TVHP(hin, pin)
Tin = Ref.THP(hin,pin);
% Qfcr = (Tfc-Tin)*20
% hinc = Qfcr/mdot
% %hin = hin+hinc

% Get the state variables for stage two
Ps21 = pin - sls2;
Ps22 = pout + pls2;
%[Tin vin] = TVHP(hin, pin);
%vin = getRefrigSpecVol(hin, pin);

% vs21 = VTP(Tin, Ps21); %[m^3/kg]
vs21 = Ref.VHP(hin, Ps21);

% Cpin = Ref.CpMassTP(Tin,Ps21);
% Cvin = Ref.CvMassTV(Tin,vs21);
% gam = Cpin/Cvin;
gam = Ref.CpRatioHP(hin, Ps21);

% Calculate the mass flow for stage two
vs22 = ((Ps22/Ps21)^(-1/gam))*vs21;
mdots2 = (Vs2/vs21 - Vhs2/vs22)*w/2;
% Calculate the the change in enthalpy for stage two
% During an adiabatic process, the quantity TV^(gamma-1) is a constant
%T22 = ((Tin+273.15)*vin^(gam-1))/vs22^(gam-1) - 273.15;
T22 = ((Tin+273.15)*(pout/pin)^((gam-1)/gam) - 273.15)*1.06;

hout = LimitSignal(Ref.HTP(T22,pout), [130000 540000]);

if(hout  < 200000)
  Tin
  FaultMode
  vs21
  gam
  vs22
  T22
  pout
end


if(pin > 0.01)
  if(pout > pin)    
    mdot = mdots2;    
  else
    mdot = 1/vs21*Vs2*w;    
  end
else
  mdot = 0;
end

mdot = LimitSignal(mdot, [0 0.5]);

x = [hout mdot]';