function [fcpr Vexp Veco mcond mevap intg_vexp intg_cpr intg_mcond Hevap dummy1 dummy3]...
  = starcoolctrl(t, psuc, Tsuc, econ_psuc, econ_Tsuc, pdis, Tamb, Tsup,...
  Tret, Tset, intg_vexp, intg_cpr, mcond, intg_mcond, HevapAct, FcprAct, ctrl_mode, dummy1, dummy3)

global Ref
% min_mcond_on_time = 10; % [sec]
% min_mcond_off_time = 10; % [sec]
% mcond_period = 120; % [sec]


if(Tset > -5) % Chill mode
  Treg = Tsup;
  Kp_fcpr = 10;
  Ki_fcpr = 0.1;
  Limit_ifcpr = [-80 80];
  Kp_vexp = 1;
  Ki_vexp = .001;
  Limit_ivexp = [-80 80];
else % Freeze mode
  Treg = Tret;
  Kp_fcpr = 30;
  Ki_fcpr = 1;
  Limit_ifcpr = [-30 30];
  Kp_vexp = 1;
  Ki_vexp = 0.002;
  Limit_ivexp = [-20 50];
end

% Limiters
T0 = Ref.TDewP(psuc);
Tc = Ref.TDewP(pdis);
FcprRateLimit = 0.12;
TcCorr = PLimit(80, 67, Tc, 50, FcprRateLimit, FcprRateLimit+2.03);
T0Corr = PLimit(-55, -45, T0 , -35, FcprRateLimit, FcprRateLimit+2.03);
MaxFcprLimiter = FcprRateLimit - max([TcCorr T0Corr]);

% Compressor control
%fcpr_old = fcpr;
if(ctrl_mode ~= 1) % Disable update of fcpr speed in ctrl mode 1
  intg_cpr = LimitSignal(intg_cpr + Ki_fcpr*(Treg - Tset), Limit_ifcpr);
  fcpr = intg_cpr + Kp_fcpr*(Treg - Tset);
  if(FcprAct < 20 && fcpr > 20)
    FcprAct = 20;
  end
  fcpr = LimitValue(fcpr, FcprAct-3, FcprAct+MaxFcprLimiter);
  fcpr = LimitValue(fcpr, 0, 110);
else
  fcpr = FcprAct; 
end

fcpr_commands = [0  100 200 300 400 500 600 700 800 900;
                50  60  40  70  30  80  20  90  20 100 ];
               
%fcpr_commands = [0  100 150 200 250 300 350 400 450 500 550 600 610 650 700 800 900;
%                 50  60  50  40  60 70  110  30  80  20  90  20 100  30  70  20  40 ];
               
% fcpr_commands = [ 500 600 700 800 900;
%                    80  20  90  20 100 ];         
               
if(ctrl_mode == 2)
  idx = find(fcpr_commands(1,:) < t);
  if(~isempty(idx))
    fcpr = LimitValue(fcpr_commands(2,idx(end)),FcprAct-1, FcprAct+1);
    %fcpr = fcpr_commands(2,idx(end));
    %fcpr = 50 + 15*sin(t*2*pi/200) * (1 + t/1000);
  else
    fcpr = 50; %1 + 30*sin(t*2*pi/200);
  end
end

% Increase speed in steps 
if(ctrl_mode == 4 || ctrl_mode == 5)
  if(t > 1000)
    fcpr = floor((t-1000)/500)*10 + 20;
  else
    fcpr = 20;
  end
end

% Injection control
%TSHRef = LimitSignal((Tret-Tsup)*1.2 + 1,[4 10]);

TshRef = 5 + Tret/10 + fcpr/25;
TshRef = LimitValue((Tret-Tsup)*1.0 + FcprAct*0.02, 4, 10);

T0 = LimitValue(Ref.TDewP(psuc), -80, 100);
% Tsuc
TSH = LimitValue(Tsuc - T0, -30, 30);
TSHErr = LimitSignal(TSH - TshRef, [-30 30]);
intg_vexp = LimitSignal(intg_vexp + Ki_vexp * LimitSignal(TSHErr, [-5 5]), Limit_ivexp);

Vexp = intg_vexp + Kp_vexp * TSHErr + fcpr*psuc*0.3;
Veco = Vexp*0.5;
Gain = 235;
C = -530;
Veco =  LimitValue(((Tc-T0)^2*Gain - C)/1000000 * Vexp, 0, 100);

Vexp = (LimitSignal(Vexp, [0 100]));
Veco = (LimitSignal(Veco, [0 100]));

Tc = Ref.TDewP(pdis);
Tc_min = LimitValue(Ref.TDewP(Ref.PDewT(Tset)+3), 0, 65);
Tc_set = LimitValue(Tamb + 11, Tc_min, 70);

CondGain = Pctrl(Tc_min - (Tamb + 11), 0, 30, 0.2, 0.01);
TCLimitSpeedup = Pctrl(Tc, 70, 85, 0, 2);
dummy1 = TCLimitSpeedup;

intg_mcond = LimitValue(intg_mcond + CondGain*0.001*(Tc - Tc_set), -1, 2);
mcond_error = CondGain*10 + intg_mcond + 0*CondGain*(Tc - Tc_set) + TCLimitSpeedup;

Tc_set = LimitValue(Tamb + 11, T0 + 30, 70);
mcond_error = 0.3*(Tc - Tc_set) + TCLimitSpeedup;

mcond_req = mcond_error;
if(mcond_error > 3 && mcond == 2)
  mcond_error = 1;
end
if(mcond_error < -3 && mcond == 0)
  mcond_error = -1;
end
%mcond_req = 1 + round(mcond_error);
mcond = LimitValue(mcond_req, 0.001, 2);

if(ctrl_mode == 2)
  if(fcpr > 20)
    mcond = 2;
  else
    mcond = 1;
  end
end

mevap = 1;

% Increase speed in steps 
if(ctrl_mode == 4)
  mcond = LimitValue(1 + mcond_error*0.1, 0, 2);
%   mcond = 2;
  mevap = 1;
end

if(ctrl_mode == 5)
  mcond = LimitValue(1 + mcond_error*0.1, 0, 2);
%   mcond = 2;
  mevap = 2;
end

if(Treg+1 < Tset && fcpr == 0)
  Hevap = LimitSignal(30*(Tset-Tsup), [0 100]);
  Hevap = 0;
else
  Hevap = 0;
end

% if(ctrl_mode == 1)
%   Q_heater = LimitValue((Tset-Treg)*5000  + 1000*PDewT(Ridx, Tset), 0, 10000);
%   HevapReq = Q_heater/30;
%   dummy1 = LimitValue(dummy1 + (Tset-Treg)*0.1, 0, 150);
%   Hevap = LimitValue(LimitValue(dummy1 + HevapReq, 0, 600), HevapAct-1, HevapAct+1);
%   %mcond = 2;
% end

if(fcpr < 20)
  intg_vexp = 0;
  if(ctrl_mode == 6)
    mevap = 0;
  end
  %intg_cpr = 0;
  fcpr = 0;
  Vexp = 0;
  Veco = 0;
  mcond = 0;
end

