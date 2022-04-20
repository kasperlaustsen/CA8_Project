function xdot = evaporator_ltp(t,x,u,p)
global Ref
%clc
%%
%x = [.8 390000 .003 0.8 160000 1 0.05 -10 -5];
%u = [9 200000 .003 -3 2 60];
%t = 1;

% Notes:
%  This model is made for simulating liquid run through and because it is
%  two very different situations it is also two different sets of
%  equations. Run-through is determined by Sigma >= 1, where sigma is
%  the point where all the refrigerant has evaporated. 



%Thus when it is
%  larger than one it is outside the evaporator and the magnitude of run
%  through is defined by Xout = 1/sigma.
%  It is assumed that the quality of
%  the refrigerant over the first control volume decrease linearily with
%  distance and therefore the average quality of this control volume is
%  fixed at X1. Because the enthalpy in the mixed zone is tied to the
%  quality it is therefore given by h1 = HPX(p1,X1).


% Control volume one will only be empty when the expansion valve has been
% closed while the compressor is running. Size of control volume one is
% given by it's mass and a fixed X value. Mass flow out of the volume is
% given by Q1 and it will therefore be zero when the is no more mass left.
% If Q1 is allowed to be negative mdot12 can also be negative and thereby
% correct mass below zero. During run-through X can no longer be fixed and 
% h1 must be given by a normal energy balance. 

% Control volume two is tricky. During normal operation with sigma < 1 the
% volume has a normal mass and energy balance, but when sigme >= 1 the mass
% of this volume is zero and the energy balance is changed to reflect the
% output enthalpy from volume one.  

% Variable X1 with a lower limit? 


% Situations: 
% Sigma < 1:

% Definitions for inputs and outputs
pout = x(1);   % Output pressure
h2 = x(2);     % Specific enthalpy of superheated gas (hout)
mdotin = x(3); % Input mass flow
sigma = x(4);  % Boundary between liquid/gas mix and superheated gas region
h1 = x(5);     % Specific enthalpy of liquid/gas mix
M1 = x(6);     % Mass of liquid/gas mix
M2 = x(7);     % Mass of superheated gas
Tm1 = x(8);     % Temperature of the metal [C�]
Tm2 = x(9);     % Temperature of the metal [C�]
Tsup = x(10);  % Temperature of supply air to the box [C�]
Tsuc = x(11);
Tevap = x(12);
T0 = x(13);
Tretm = x(14);
Tsupm1 = x(15);
Tsupm2 = x(16);
mdotair = x(17);

pin     = u(1); % Pressure on the input side [Bar]
hin     = u(2); % Specific entahlpy of refrigerant on the input [J/kg]
mdotout = u(3); % Mass flow of refrigerant on the output [kg/s]
Tret    = u(4); % Temperature of return air from the box [C�]
vfan    = u(5); % Fan speed [0, 1, 2]
vexp    = u(6); % Expansion valve opening [%]
Hevap   = u(7);
Tamb    = u(8);
FaultMode = u(9); % Used to simulate various faults (Tsup sensors)

Cp_air = 1.0035e3; % [J/(kg*K)]
Mmetal = 22.976; % Mass of metal [kg]
Cpmetal = 900;   % Heat capacity of metal [J/(kg*K)]
% Inner pipe diameter
Di = 0.007; %[m]
% Cross sectional area of evaporator
Ac = 2*pi*(Di/2)^2*18*6; %[m^2]
Vt = Ac*1.827; %[m^3] = 15.18 Liter
X1 = 0.045; % 0.1

alfa1 = 2500; %2500 is from measurement data cap_ctrl_steps_MCI_021009.mat assuming a sigma of 0.8
alfa2 = 2500;% 300; % Metal to gas
alfa3 = 50; %  Important for equalization of temperatures when system is off
%vexp_const = 0.81e-5; % [kg/s]
vexp_const = 0.74e-5; % [kg/s]

% Handle fault mode
if(FaultMode == 0)
  Ts1TaFact = 0;
  Ts2TaFact = 0;
elseif (FaultMode <= 1)
  Ts1TaFact = FaultMode;
  Ts2TaFact = 0;  
elseif (FaultMode <= 2)
  Ts1TaFact = 0;
  Ts2TaFact = FaultMode-1;      
elseif (FaultMode <= 3)
  Ts1TaFact = FaultMode-2;
  Ts2TaFact = FaultMode-2;
end
    
% A sigma value of zero results in near divide by zeroes so we limit it to
% be at least 0.001
sigma_lower_lim = 0.001;
sigma_lim = LimitValue(sigma,sigma_lower_lim, 1);

p1 = LimitValue(pout, 0.1, 50); %sigma*dpdz
% p12 = (pout+p1)/2;
T1 = LimitValue(Ref.TDewP(p1),-60, 100);
T2 = LimitValue(Ref.THP(h2,pout), -60, 100);
rho_air = 1.3 + Tret * -0.005;     % [kg/m^3]
% 2297 m^3/h at low speed and 4774 m^3/h at high speed
mdotair_ref = (vfan.^2*3400.5 + vfan.^3*-1103.5)/3600*rho_air;
mdotairdot = 0.1*(mdotair_ref - mdotair);


% Most of the fans power is converted into kinetic energy and a small part
% into heat before the evaporator. The kinetic energy is converted into
% heat in the box when the air slows down. 
Qfan = (155*vfan^2 + 40*vfan^3) * 0.2; % 80% Fan motor efficiency
% Calculate the air temperature after the fans
if(mdotair > 0.1)
  Tret2 = Tret + Qfan/(mdotair*Cp_air);
else
  Tret2 = Tret;
end

if(sigma < 1)
  Q1 = alfa1*(Tm1-T1)*sigma; % Allow negative Q1 dirung pump down
else
  Q1 = alfa1*(Tm1-T1)*sigma_lim; % Never allow too large Q1
end
Q2 = alfa2*(Tm2-T2)*(1-sigma_lim);
% Superheating power
Qam2 = Cp_air*mdotair*(Tret2-Tm2);%*(1-sigma_lim);  
% Calculate temeprature for air after passing the superheat section of the
% evaporator.
if(mdotair > 0.0001)
  Tret3 = Tret2 - Qam2/(mdotair*Cp_air);
else
  Tret3 = Tret2;
end
% Evaporation power
Qam1 = Cp_air*mdotair*(Tret3-Tm1);%*sigma_lim;
Qm2m1 = (Tm2-Tm1)*alfa3;
Qheat = Hevap*30; % Input in % and 3kW heater

% Get the specific volume before the expansion
Vin_be = Ref.VHP(hin,pin);
Vdew = Ref.VDewP(p1);
h12 = LimitValue(Ref.HDewP(p1), 130000, 560000);

if(sigma >= 1) % Liquid slugging 
  V1 = Ref.VHP(h1,p1);
  %V1 = LimitValue(Ref.VPX(p1,X1), 0, 2);
  v1 = V1*M1;
  
  V2 = Ref.VHP(h2,p1);
  v2 = V2*M2;

  % Since enthalpy and quality is linearily dependent and we assume that
  % quality decrase linearily over the evaporator we can calculate the
  % enthalpy of h1 as:
  %h1_ref = LimitValue(Ref.HPX(p1,X1), 130000, 560000);
  %   h1dot = 1*(h1_ref-h1);
    
  h1dot = ((hin-h1)*mdotin + Q1)/M1;
  %   sigma_ref = h1_ref/h1;
  
  if(mdotout > 0)
    sigma_ref = (h2-hin)/(Ref.HDewP(p1)-hin);
     V11 = LimitValue(Ref.VPX(p1,X1), 0, 2);
     v11 = V11*M1;
     sigma_ref = v11/Vt;
    %sigma_ref = Ref.HDewP(p1)/h2;
  else
    sigma_ref = v1/Vt;
  end
  
  if(mdotout > 0.0001)
    h2_ref = h1; %hin + Q1/mdotout;
    h2dot = h2_ref - h2 + h1dot;
  else
    h2dot = h1 - h2 + h1dot;
  end
  
  
    
  mdot12 = -M2*0.1 + mdotout; 
  Mdot1 = mdotin-mdot12;
  Mdot2 = mdot12-mdotout;
  %poutdot = (v1-Vt)/Vt + (Mdot1*V1/Vt);
  poutdot = ((v1-Vt)/Vt + (v2-Vt)/Vt) + (Mdot1*V1 + Mdot2*V2)/Vt;

  sigmadot = (sigma_ref - sigma)*0.1;
  Tm1dot = (Qam1+Qam2+Qm2m1-Q1)/(Mmetal*Cpmetal);
  Tm2dot = 0.1*(Tm1-Tm2);
  
else % For sigma < 1, normal situation
  V1 = LimitValue(Ref.VPX(p1,X1), 0, 2);
  V2 = LimitValue((Vdew + Ref.VHP(h2,p1))/2, 0.001, 2);
  v1 = V1*M1;  
  v2 = V2*M2;
  
  if(Q1 > 0)
    mdot12 = Q1/(h12-hin);
  else
    mdot12 = 0;
  end
    
  sigma_ref = LimitValue(v1/Vt, 0, 2);
  sigmadot = (sigma_ref - sigma);
  h1_ref = LimitValue(Ref.HPX(p1,X1), 130000, 560000);
  h1dot = 1*(h1_ref-h1);
  %h1dot = ((hin-h1)*mdotin-Q1)/M1;
  
  if(M2 < 0)
    Mdot1 = mdotin-mdot12+2*M2;
    Mdot2 = mdot12-mdotout-2*M2;
  else
     if(mdot12-mdotout + M2 < 0)
       mdot12 = mdot12 - (mdot12-mdotout + M2)*2;
       Mdot1 = mdotin-mdot12;
       Mdot2 = mdot12-mdotout;
     else
       Mdot1 = mdotin-mdot12;
       Mdot2 = mdot12-mdotout;
     end
  end
  
    
  % In order to avoid badly conditioned matrices due to an
  % "almost-divide-by-zero" we use this little numerical hack
  if(M2 >= 0.001)
    h2dot = 0.1*(mdot12*(h12-h2) + Q2)/M2;
  else
    h2dot = 0.1*(mdot12*(h12-h2) + Q2)/0.001;
  end
  
  % Stop h2 from getting below zero
  % (Energy balance? what energy balance?) 
  if(h2dot + h2 < 0)
    h2dot = 0.1*(h1-h2);
  end
  % Do not allow h2 to be less than h1
  if(h2 < h1)
    h2dot = 0.1*(h1-h2);
  end  
  
  if(M1 < 0.001)
    v1 = V1*0.001;
  end
  if(sigma_lim < 0.001)
    Tm1dot = 0; %(Qam1+Qm2m1-Q1)/(Mmetal*Cpmetal*0.001);
  else
    Tm1dot = (Qam1+Qm2m1-Q1)/(Mmetal*Cpmetal*sigma_lim);
  end
  % In order to avoid badly conditioned matrices due to an
  % "almost-divide-by-zero" we use this little numerical hack
  if(sigma_lim > 0.999)
    Tm2dot = 0; %(Qam2-Qm2m1-Q2)/(Mmetal*Cpmetal*0.001);
  else
    Tm2dot = (Qam2-Qm2m1-Q2)/(Mmetal*Cpmetal*(1-sigma_lim));
  end
  
  poutdot = ((v1-Vt)/Vt + (v2-Vt)/Vt) + (Mdot1*V1 + Mdot2*V2)/Vt;
  
  if(poutdot + pout < 0)
    poutdot = -pout*0.1;
  end
  
end


% Calculate the change in mass flow into the evaporator
% Model the expanion valve as a volume flow in order to account for reduced
% flow in case of vapor in the supply line
% vexp_const = 4e-7; % [kg/s]
% mdotref = vexp * sqrt(pin-pout) * 1/Vin_be * vexp_const;
%vexp_const = 0.82e-5; % [kg/s]

%vexp_const = 0.84e-5; % [kg/s]

% Test code for robustness checks 
% if(t > 100 && t < 120)
%   vexp = 100;
% end
% 
% if(t > 500 && t < 800)
%   vexp = 0;
% end

% Needs a higher pressure drop at high mass flows
if(pin > pout) % Check for negative pressure over the expansion valve
  mdotref = vexp * sqrt(2*1/Vin_be*(pin-p1)) * vexp_const;
else
  mdotref = 0;
end
mdotref = LimitValue(mdotref, 0, 0.3);
mdotindot = (mdotref - mdotin);

if(mdotair > 0.1)
%   Tsupdot = 0.1*(Tret2 - Tsup + (Qheat-Qam1-Qam2)/(Cp_air*mdotair));
  Tsupdot = (Tret2 - Tsup + (Qheat-Qam1-Qam2)/(Cp_air*mdotair));
  Tretmdot = 0.005*(Tret - Tretm); 
  if(Ts1TaFact > 0)
    Tsupm1dot = 0.01*(Tsup*(1-Ts1TaFact) + Tamb*Ts1TaFact - Tsupm1);
  else
    Tsupm1dot = 0.01*(Tsup - Tsupm1);
  end
  
  if(Ts2TaFact > 0)
    Tsupm2dot = 0.01*(Tsup*(1-Ts2TaFact) + Tamb*Ts2TaFact - Tsupm2);
  else
    Tsupm2dot = 0.01*(Tsup - Tsupm2);
  end
else
  Tsupdot = 0.01*(Tret2 - Tsup - 0.1); % Go towards Tret 2 in order to include the fan power
  Tretmdot = 0.0002*((Tret+Tamb)/2 - Tretm);
  Tsupm1dot = 0.00005*((Tsup+Tamb)/2 - Tsupm1);
  Tsupm2dot = 0.00005*((Tsup+Tamb)/2 - Tsupm2);
end

% Make a smoth transition on Tsuc at near run-through
TsucLim = 0.95;
if(sigma > TsucLim)
%   W = LimitValue((sigma-TsucLim)/(1-TsucLim),0,1);
%   TsucRef = W*T1 + (1-W)*Tret2; 
  TsucRef = Pctrl(sigma, TsucLim, 1, T2, T1);
  Tsucdot = 0.05*(TsucRef-Tsuc);
else
  Tsucdot = 0.01*(Tret2-Tsuc);
%   Tsucdot = 0.05*(T2-Tsuc);
end

% Tsucdot = 0.01*(T2-Tsuc);


%TevapScale = 0.5;
%TevapRef = TevapScale*((sigma)*Tm1 + (1-sigma)*Tm2) + (1-TevapScale)*(Tm1+Tm2)/2;
%Tevapdot = 0.1*(TevapRef-Tevap);

TevapSigmaLim = 0.9;
TevapSigma = LimitValue(sigma/TevapSigmaLim, 0, 1);
TevapRef = Tret*TevapSigma + Tsup*(1-TevapSigma);
Tevapdot = 0.1*(TevapRef-Tevap);

T0dot = 0.05*(Ref.TDewP(pout)-T0);
%T0dot = 0.1*(Ref.TDewP(pout)-T0);

% if(t > 7)
%   poutdot = NaN;
% end

% Build xdot
xdot = [poutdot h2dot mdotindot sigmadot h1dot Mdot1 Mdot2 Tm1dot Tm2dot...
  Tsupdot Tsucdot Tevapdot T0dot Tretmdot Tsupm1dot Tsupm2dot mdotairdot]';

% if(1 == CheckNanImg(x, u, xdot'))
%   Vin_be
%   pin
%   pout
% end

