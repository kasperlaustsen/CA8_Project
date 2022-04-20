% Controller synchronized to the MPC period

function [handles, D] = CapCtrl(handles, D)

global Ref

if(~isfield(D, 'Q_ref') || D.t <= 1)
  D.Q_ref = 0;
  D.Q_int = 0;
  D.Q_cool_req = 0;
  D.intg_vexp = 0;
  D.intg_fcpr = 0;
  D.intg_mcond = 0;
  D.fcpr_switch_counter = 0;
  D.run_time = 0;
  D.running = 1;
  D.intg_lock = 0;
  D.TempIntgr = 0;
  D.Vexp = 0;
  D.Fcpr = 0;
end

fcpr_min_speed = 20;



if(D.Tset > -5) % Chill mode
  Treg = D.Tsup;
%   Kp_fcpr = 30;
%   Ki_fcpr = 0.1;
%   Limit_ifcpr = [-80 80];
%   Kp_vexp = 30;
%   Ki_vexp = .001;
  Limit_ivexp = [-80 80];
%   Kp_vexpP = 200;
%   Ki_vexpP = 20;
  Kp_vexpT = 2;
  Ki_vexpT = 0.01;
else % Freeze mode
  Treg = D.Tret;
%   Kp_fcpr = 30;
%   Ki_fcpr = 3;
%   Limit_ifcpr = [-80 80];
%   Kp_vexpP = 200;
%   Ki_vexpP = 20;
  Kp_vexpT = 4;
  Ki_vexpT = 0.02;
  Limit_ivexp = [-20 40];
end



% Compressor control
Q_max = D.Tret * 250 + 11237;

% Stand alone capacity controller. Q_cool_req is set by internal temperature
% controller
if(isfield(D, 'CapCtrlStandAlone'))
  if(D.CapCtrlStandAlone == 1)
    TempError = D.Tret - D.Tset;
    TempFfwd = (D.Tamb - D.Tret)*41;
    D.TempIntgr = D.TempIntgr + TempError * 0.1;
    D.Q_cool_req = D.TempIntgr + TempError*1000 + TempFfwd;    
  end  
end

QCoolActLim = LimitValue(D.QCoolAct, 0, 20000);
% D.Q_int = D.Q_int + D.Q_cool_req - QCoolActLim;
% Q_cool_req = LimitSignal((D.Q_cool_req + D.Q_int*2e-3), [0 20000]);
Q_cool_req = D.Q_cool_req;
%addCtrlVar('Qint', D.Q_int, 0, 0.00001, 0);
%addCtrlVar('QCoolRef', D.Q_cool_req, 1, 0.01, 0);
%addCtrlVar('QCoolReq', Q_cool_req, 1, 0.01, 0);
fcpr_max = 110;
fcpr_OL = fcpr_max*Q_cool_req/Q_max*0.77;
%addCtrlVar('fcpr_ref_OL', fcpr_OL, 0);

% if(D.intg_lock == 0)
%   D.intg_fcpr = LimitSignal(D.intg_fcpr + 0.0001*(Q_cool_req-QCoolActLim)/Q_max*fcpr_max, [-40 40]);
% end
if((fcpr_OL < 20) && (D.Fcpr < 20.5))
  D.Fcpr = fcpr_OL;
elseif((fcpr_OL >= 20) && (D.FcprAct == 0))
  D.Fcpr = 20;
else
  D.Fcpr = LimitValue(fcpr_OL, D.FcprAct-0.12, D.FcprAct+0.12);% + D.intg_fcpr + 0.2*(Q_cool_req-QCoolActLim)/Q_max*fcpr_max;
end

% if(D.ctrl_mode == 4) % For making COP data
%   if(D.t > 1000)
%     D.Fcpr = max([floor((D.t-2000)/500)*10 + 20, floor((D.t-500)/1000)*10 + 20]);
%   else
%     D.Fcpr = 20;
%   end
% end

  

D.Fcpr = LimitValue(D.Fcpr, 0, 110);

% Injection control
%Pret = PDewT(Ridx, D.Tret);

D = MssSearch(D);

% TshRef = LimitSignal((D.Fcpr+20)/10 + (D.Fcpr)*0.02,[4 10]);
% TshRef = LimitValue((D.Tret-D.Tsup)*1.3 + D.Fcpr*0.02, 4, 15);
TshRef = D.MSS.SH_ref;


% TSHMin = LimitSignal(Q_cool_req/400, [4 10]);
% TSHRef = LimitSignal((D.Tret-D.Tsup1)*1.2 + Pret,[4 10]);
%addCtrlVar('TSHRef', TshRef, 1);
T0 = Ref.TDewP(D.Psuc);
TSH = LimitValue(D.Tsuc - T0, 0, 25);
Tc = Ref.TDewP(D.Pdis);

TSHErr = LimitSignal(TSH - TshRef, [-25 25]);
if(D.intg_lock == 0)
  D.intg_vexp = LimitSignal(D.intg_vexp + Ki_vexpT * LimitSignal(TSHErr, [-10 10]), Limit_ivexp);
end
D.Vexp = D.intg_vexp + Kp_vexpT * TSHErr;

D.Vexp = LimitSignal(D.Vexp, [0 100]);
Gain = 235;
C = -530;
D.Veco =  LimitValue((((Tc-T0)^2)*Gain/100 + C) * D.Vexp/10000, 0, D.Vexp*0.8);%D.Vexp*0.8;
%D.Veco = LimitSignal(D.Veco, [0 100]);

% Condenser Control

Tc_set = LimitValue(D.Tamb + 11, T0 + 30, 70);
mcond_error = 0.1*(Tc - Tc_set);
if(mcond_error > 0.3 && D.McondAct == 2)
  mcond_error = 1;
end
if(mcond_error < -0.3 && D.McondAct == 0)
  mcond_error = -1;
end
mcond_req = 1 + round(mcond_error);

% if(D.ctrl_mode == 4)
%   D.Mcond = LimitValue(1 + mcond_error*0.1, 0, 2);
% else
  D.Mcond = LimitSignal(mcond_req, [0 2]);
% end
% 
% D.Mcond = 2;

if(Treg+1 < D.Tset && D.FcprAct == 0)
  D.Hevap = LimitSignal(30*(D.Tset-D.Tsup), [0 100]);
  D.Hevap = 0;
else
  D.Hevap = 0;
end

% Limiters
FcprRateLimit = 1;
TcCorr = PLimit(80, 67, Tc, 50, FcprRateLimit, FcprRateLimit+2.03);
T0Corr = PLimit(-55, -45, T0 , -35, FcprRateLimit, FcprRateLimit+2.03);
MaxFcprLimiter = FcprRateLimit - max([TcCorr T0Corr]);

% Minimum on/off time state machine
if(D.running == 1 && D.fcpr_switch_counter == 0 && D.Fcpr < fcpr_min_speed)
  D.running = 0;
  D.fcpr_switch_counter = LimitValue(300 - D.run_time, 120, 300);
  disp(['Stop: ' num2str(D.fcpr_switch_counter)])
end


if(D.running == 0 && D.fcpr_switch_counter == 0 && D.Fcpr >= fcpr_min_speed)
  D.running = 1;
  D.fcpr_switch_counter = 300; % Lock speed for the first 15 seconds
  D.run_time = 0;
  disp('Start')
end

D.intg_lock = 0;
if(D.running == 0)
  D.Fcpr = 0;
  D.Vexp = 0;
  D.Veco = 0;
  D.Mevap = 0;
  D.Mcond = 0;
  D.intg_lock = 1; 
else  
  D.run_time = LimitValue(D.run_time + 1, 0, 300);
  if(D.FcprAct < fcpr_min_speed)
    D.FcprAct = fcpr_min_speed;
  end
  if(D.Fcpr < fcpr_min_speed)
    D.Fcpr = fcpr_min_speed;
  end
  if(D.fcpr_switch_counter > 0)
    if(D.Fcpr < fcpr_min_speed*2)
      D.Fcpr = fcpr_min_speed;
    end
  else
    D.Fcpr = LimitValue(D.Fcpr, D.FcprAct-3, D.FcprAct+MaxFcprLimiter);
  end
end

if(D.fcpr_switch_counter > 0)
  D.fcpr_switch_counter = D.fcpr_switch_counter - 1;
end

if(D.FanAlwaysOn == 1)
  D.Mevap = 1;
else
  if(D.Fcpr > 0)
    D.Mevap = 1;
  end
end

