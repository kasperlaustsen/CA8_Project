function xdot = joining_junction(x,u)
global Ref

p = x(1);
hout = x(2);
m = x(3);

hin1 = u(1);
hin2 = u(2);
mdotin1 = u(3);
mdotin2 = u(4); % From economizer
mdotout = u(5);

Vi = 0.01; % 10 Liter internal volume


mdot = mdotin1 + mdotin2 - mdotout;

if (m + mdot < 0)
  mdot = -m; 
end

% In the gas phase use a calculation based on calculated specific
% volume
if(hout > Ref.HDewT(Ref.TDewV(Vi/m)))
  Tg = Ref.THV(hout,Vi/m);
  pdot = Ref.PTV(Tg, Vi/m) - p;
else
  % In the mixed or liquid phase use an aproximation based on pressure 
  % instead of calculated specific volume. The specific volume is
  % calculated from enthalpy and pressure and used to calculate dp/dt
  V = Ref.VHP(hout,p);
  pdot = (m*V - Vi)/Vi + (mdot*V)/Vi;
end

if (p + pdot < 0)
  pdot = -p;
end


% ((j/kg)*(kg/s))/kg = j/(kg*s)
if(mdotin2 > 0)
  houtdot = ((hin1-hout)*mdotin1 + (hin2-hout)*mdotin2)/m;
else
  houtdot = ((hin1-hout)*mdotin1)/m;
end

xdot = [pdot houtdot mdot]';
