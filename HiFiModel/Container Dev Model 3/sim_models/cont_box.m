function xdot = cont_box(t,x,u,p)
global box_tref

% Constants, from www.maerskbox.com
alfa   = 43;    % Ambient to box 43 [(j/s)/k], [w/k]
alfa_cargo = 1000;
alfa_alu = 1500;
% Asurf  = 143;      % Surface area [m^2]
% Length = 11.585;   % [m]
% Height = 2.554;    % [m]
% Width  = 2.294;    % [m] 
Vbox   = 67.88;    % m^3 
Cp_alu = 900;      % [J/(kg*K)]
Cp_steel = 500;
Cp_air = 1.0035e3; % [J/(kg*K)]
pa = 101325;       % [Pa] Standard pressure at sea level
hwe = 2.27e6;      % [J/kg] Heat of vaporization for water
Cp_water = 1840;   % [J/(kg*K)]
Cp_cargo = 5044;   % [J/(kg*K)] (Pork)
%M_alu   = 460 + 82;     % [kg]
%M_steel = 282;
%m_alu = 879;
m_alu = 2500;
 m_cargo = 5000;     % [kg] Maximum allowed mass is 30k kg
%m_cargo = 20000;     % [kg] Maximum allowed mass is 30k kg

if(~isempty(box_tref))
  const_temp = 1;
  temp_ref = box_tref;
else
const_temp = 0;
temp_ref = -20;
end
const_heat = 0;
heat_ref = 5000;

Tair = x(1);
Talu = x(2);
Tcargo = x(3);
Tret = x(4);
RH = x(5);
% mdotair = x(6);

Tamb = u(1);
Tsup = u(2);
vfan = u(3);
QHeat = u(4);

rho_air = 1.3 + Tair * -0.005;     % [kg/m^3]
m_air = Vbox*rho_air; % [kg]

% Calculate the actual cooling capacity
TsupK = Tsup + 273.15;
TretK = Tair + 273.15;

% Specific enthalpy of moist air can be expressed as:
% h = ha + x hw         (1)
% where
% h = specific enthalpy of moist air (kJ/kg)
% ha = specific enthalpy of dry air (kJ/kg)
% x = humidity ratio (kg/kg)
% hw = specific enthalpy of water vapor (kJ/kg)
%RH = 0.01;
% Get the saturated water pressure
pws_sup = sat_water_vapour_pres(TsupK);
pws_ret = sat_water_vapour_pres(TretK);
%
pw_sup = RH.*pws_sup/100;
pw_ret = RH.*pws_ret/100;
% Calculate the specific enthalpy of water vapor (kJ/kg)
hw_sup = Cp_water*TsupK + hwe;
hw_ret = Cp_water*TretK + hwe;
% Calculate the humidity ratio (kg/kg)
x_sup = 0.62198 * pw_sup / (pa - pw_sup);
x_ret = 0.62198 * pw_ret / (pa - pw_ret);
% Calculate the specific enthalpy of the air
h_air_sup = Cp_air*TsupK + x_sup*hw_sup;
h_air_ret = Cp_air*TretK + x_ret*hw_ret;

% 2297 m^3/h at low speed and 4774 m^3/h at high speed
% vfan = LimitSignal(round(vfan),[0 2]);
mdotair = (vfan.^2*3400.5 + vfan.^3*-1103.5)/3600*rho_air;
mcondwater = mdotair*(x_ret-x_sup);

% Most of the fans power is converted into kinetic energy and a small part
% into heat before the evaporator. The kinetic energy is converted into
% heat in the box when the air slows down. 
Qfan = (155*vfan^2 + 40*vfan^3) * 0.8; % 80% Fan motor efficiency

% if(vfan > 0)
%   Q_cond_water = mcondwater * hwe;
% else
%   Q_cond_water = 0;
% end
Qcool = (h_air_ret - h_air_sup) .* mdotair; % + Q_cond_water;

if(const_temp == 1)
  Q_heater = (temp_ref-Tair) * m_air *Cp_air;
elseif(const_heat == 1)
  Q_heater = heat_ref;
else
  Q_heater = 0;
end


TairMean = (Tsup+Tair)/2;

%Qairin = (Tsup - Tair)*mdotair*Cp_air; % K*(kg/s)*J/(kg*K) = J/s
QambToair = (Tamb - TairMean)*alfa*0.81; % 0.81 of the box surface area is normal wall
QambToalu = (Tamb - Talu)*alfa*0.19; % 0.19 of the box surface area is the aluminum T-profile floor
QcargoToair = (Tcargo-Tair)*alfa_cargo;
QaluToair = (Talu-TairMean)*alfa_alu;

Tairdot = (-Qcool + QaluToair + QcargoToair + QambToair + Q_heater + QHeat + Qfan)/(Cp_air*m_air);
Taludot = (QambToalu-QaluToair)/(Cp_alu*m_alu);
Tcargodot = -QcargoToair/(Cp_cargo*m_cargo);

Tretdot = 0;
RHdot = 0;

xdot = [Tairdot Taludot Tcargodot Tretdot RHdot]';
