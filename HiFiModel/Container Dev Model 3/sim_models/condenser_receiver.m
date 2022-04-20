% The condenser cools the gas from the compressor resulting in condesation
% of some or all of the gas. It is modelled with a single control volume to
% which the total heat flux is calculated on the basis of heat transfer
% coefficients and the quality of the refrigerant. The more liquid it
% contains the more heat can be transfered because liquid has a higher
% heat transfer coefficient than gas. 

% 
% <inputs>
%   <input name="hin" type="Enthalpy" min="0" max="50" description="Specific Enthalpy [J/kg]"/>  
%   <input name="mdotin" type="Mass Flow" min="0" max="1"   description="Mass flow [kg/s]"/>
%   <input name="vfan" type="Fan Speed" min="-40" max="110" description="Fan Speed"/>
%   <input name="Tamb" type="Temperature" min="-40" max="110" description="Air Temperature [deg-C]"/>
%   <input name="mdotout1" type="Mass Flow" min="0" max="1" description="Mass flow [kg/s]"/>
%   <input name="mdotout2" type="Mass Flow" min="0" max="1" description="Mass flow [kg/s]"/>
% </inputs>
%  <!-- State section. States must be listed in the
% correct order -->
% 
% <states>  
%   <state name="pout" type="Pressure" min="0" max="50" default="8" description="Pressure [Bar]"/>
%   <state name="hout" type="Enthalpy" min="0" max="50" default="230000" description="Specific Enthalpy [J/kg]"/>  
%   <state name="pin" type="Pressure" min="0" max="50" default="8" description="Pressure [Bar]"/>
%   <state name="hrefrig" type="Enthalpy" min="0" max="50" default="320000" description="Specific Enthalpy [J/kg]"/>
%   <state name="mrefrig" type="Mass" min="0" max="1" default="1.25" description="Refrigerant Mass [kg]"/>
%   <state name="Tm" type="Temperature" min="-50" max="100" default="10" description="Metal Temperature"/>
%   <state name="mdotair" type="mass flow" min="0" max="2" default="0" description="Air mass flow"/>  
% </states>

function xdot = condenser_receiver(t,x,u,p)
global Ref

pout    = x(1);
hout    = x(2);
pin     = x(3);
hr      = x(4);
mr      = x(5);
Tm      = x(6);
mdotair = x(7);
Tc      = x(8);

hin      = u(1);
mdotin   = u(2);
vfan     = u(3);
Tamb     = u(4);
mdotout1 = u(5);
mdotout2 = u(6);

% Constants
% Internal volume of the condenser [m^3] (1.8 liter)
% Receiver internal volume, 5 liters, [m^3]
vi = 0.0068;
m_metal = 22.976; % Mass of metal [kg] 22.976
Cp_metal = 387;   % Heat capacity of metal [J/(kg*K)] 
rho_air = 1.3 + Tamb * -0.005; 
alpha_rm = 1000; % Heat transfer coefficient from refrigerant to metal
alpha_ma = 1000; % Heat transfer coefficient from metal to air
vapor_flow_resistance = 100; % Pressure increse pr kg/sec mass flow

% 1800 m^3/h at low speed and 3600 m^3/h at high speed

if(vfan > 0)
  mdotair_ref = 0.5*vfan*rho_air;
  mdotair_dot = (mdotair_ref - mdotair)*1; % Forced convection when fan is on
else
  mdotair_ref = abs(Tamb-Tm)*0.01; % Natural convection depending on temperature difference
  mdotair_dot = (mdotair_ref - mdotair)*1; % Simulate fan spin down
end

% Mass balance
mdotout = mdotout1 + mdotout2;
mr_dot = mdotin - mdotout;

% Energy balances for refrigerant
Qmdotin = mdotin*(hin - hr);
Qmdotout = mdotout*(hout - hr);
Tr_in = Ref.THP(hin, pin)*mdotin + Ref.THP(hr,pout);
Qrefrig_to_metal = (Tr_in-Tm)*alpha_rm;
hr_dot = (Qmdotin - Qmdotout - Qrefrig_to_metal)/mr;

% Energy balance for metal
Q_metal_to_air = (Tm-Tamb)*alpha_ma*mdotair^2; % Is this a linear function of air flow? Probably squared
Tm_dot = (Qrefrig_to_metal-Q_metal_to_air)/(Cp_metal*m_metal);

% Calculate pressure based on volume, mass and enthalpy
HDew = Ref.HDewP(pout);
HBub = Ref.HBubP(pout);
% TDew = Ref.TDewP(pout);
% if(hr >= HDew)
%   liquid_vapor_mass_fraction = 1;
% elseif(hr <= HBub)
%   liquid_vapor_mass_fraction = 0;
% else
%   liquid_vapor_mass_fraction = Pctrl(hr, HBub, HDew, 0, 1);
% end

hout_dot = (HBub - hout);

% Calculate actual volume of refrigerant, given m, h and p
v_refrig = Ref.VHP(hr, pout)*mr;
pout_dot = (v_refrig-vi)*100;
% v_liquid = (1-liquid_vapor_mass_fraction) * mr * Ref.VBubP(pout); % Volume of liquid
% v_vapor  = vi - v_liquid; % Volume of vapor
% m_vapor = liquid_vapor_mass_fraction * mr;  % Mass of vapor
% V_vapor = v_vapor/m_vapor;
% pout_dot = Ref.PTV(TDew, V_vapor) - pout;

pin_dot = ((pout + mdotin*vapor_flow_resistance) - pin);
Tc_dot = (Ref.TDewP(pout) - Tc); % Just track the pressure

xdot = [pout_dot hout_dot pin_dot hr_dot mr_dot Tm_dot mdotair_dot Tc_dot]';