function out = eTRU_controller(in)

global Ref
global eTRU_ctrl

fcpr_min_speed = 20;
cpr_state_stopped = 0;
cpr_state_min_speed = 1; %
cpr_state_running = 2;
cpr_min_runtime = 15;
cpr_min_stoptime = 30;
cpr_restart_time = 120;

if(eTRU_ctrl.init_sim == 1)
  eTRU_ctrl.init_sim = 0;
end

eTRU_ctrl.sim_time = eTRU_ctrl.sim_time + 1;
% eTRU_ctrl.sim_time

Tcondout = in(1);
Pft = in(2);
Pdis = in(3);
Psuc = in(4);
Tamb = in(5);
Tsuc = in(6);
Tret = in(7);
Tsup = in(8);


Tact = Tsup;
%Tact = Tret;

% if (eTRU_ctrl.sim_time > 2000)
%   Tset = 10;
% else
Tset = -10;
% end

T0 = Ref.TDewP(Psuc);
Tc = Ref.TDewP(Pdis);

Tsh = Tsuc - T0;
% Tsh_ref_target = 5;
% Tsh_ref_target = Pctrl(eTRU_ctrl.cpr_run_time, cpr_min_runtime, cpr_min_runtime+20, 2, 5);
Tsh_ref_target = Pctrl(eTRU_ctrl.fcpr_pid.Output, 20, 100, 5, 15);

eTRU_ctrl.Tsh_ref = ffilter(eTRU_ctrl.Tsh_ref, Tsh_ref_target, 30);

% Run temperature controller
eTRU_ctrl.fcpr_pid.SetInput(Tact, Tset, 0);
eTRU_ctrl.fcpr_pid.Run();

% CalcScaledCapLimit(In, LimitStart, Limit, LimitMax)
Tc_hard_limit = CalcScaledCapLimit(Tc, 60, 67, 71);
Tc_soft_limit = CalcScaledCapLimit(Tc, Tamb+13, Tamb+20, Tamb+25);
%Tc_soft_limit = 1;
T0_limit = CalcScaledCapLimit(T0, -35, -45, -50);
Tsh_limit = CalcScaledCapLimit(Tsh, eTRU_ctrl.Tsh_ref+2, eTRU_ctrl.Tsh_ref+5, eTRU_ctrl.Tsh_ref+10);
% Tsh_limit = 1;

min_limiter = min([Tc_hard_limit, Tc_soft_limit, T0_limit, Tsh_limit]);


% int = eTRU_ctrl.fcpr_pid.GetIntegrator()
Fcpr_lim_max = LimitValue(eTRU_ctrl.cpr_speed_act + min_limiter, 20, 100);
Fcpr_req = LimitValue(eTRU_ctrl.fcpr_pid.Output, 0, Fcpr_lim_max);


switch(eTRU_ctrl.cpr_state)
  case cpr_state_stopped
    Fcpr_set = 0;
    if((Fcpr_req >= fcpr_min_speed) && (eTRU_ctrl.cpr_stop_time >= cpr_min_stoptime) && (eTRU_ctrl.cpr_restart_timer >= cpr_restart_time))
      eTRU_ctrl.cpr_state = cpr_state_min_speed;
      eTRU_ctrl.cpr_restart_timer = 0;
      Fcpr_set = fcpr_min_speed;
    end
    
  case cpr_state_min_speed
    Fcpr_set = fcpr_min_speed;
    if((Fcpr_req < fcpr_min_speed) && (eTRU_ctrl.cpr_run_time >= cpr_min_runtime))
      eTRU_ctrl.cpr_state = cpr_state_stopped;
    end
    if((Fcpr_req > fcpr_min_speed) && (eTRU_ctrl.cpr_run_time >= cpr_min_runtime))
      eTRU_ctrl.cpr_state = cpr_state_running;
    end
    
  case cpr_state_running
    Fcpr_set = Fcpr_req;
    if(Fcpr_req < fcpr_min_speed)
      eTRU_ctrl.cpr_state = cpr_state_min_speed;
    end
end

eTRU_ctrl.cpr_speed_act = Fcpr_set;

eTRU_ctrl.cpr_restart_timer = eTRU_ctrl.cpr_restart_timer + 1;

if(eTRU_ctrl.cpr_state == cpr_state_stopped)
  eTRU_ctrl.cpr_run_time = 0;
  eTRU_ctrl.cpr_stop_time = eTRU_ctrl.cpr_stop_time + 1;
else
  eTRU_ctrl.cpr_run_time = eTRU_ctrl.cpr_run_time + 1;
  eTRU_ctrl.cpr_stop_time = 0;
end

% https://iopscience.iop.org/article/10.1088/1742-6596/978/1/012098/pdf
% This needs verification, apparantly different systems deviate from the
% theory :-)
Pft_optimal = sqrt(Pdis*Psuc);
% Pft_ref = Pctrl(eTRU_ctrl.sim_time, 200, 800, Pdis, 5);
Pft_adjust = Pctrl(Tc-Tcondout, 1, 5, 0, 3);
Pft_ref = Pft_optimal + Pft_adjust;



if(Fcpr_set > 0)
  %   Tsh_err = Tsh_ref-Tsh; % Positive when Tsh is too low
  vexp_gain_target = abs(Pctrl(Tsh, 0, 5, 2, 0.5));
  eTRU_ctrl.vexp_gain = ffilter(eTRU_ctrl.vexp_gain, vexp_gain_target, 20);
  eTRU_ctrl.vexp_pid.SetKp(eTRU_ctrl.vexp_gain);
  eTRU_ctrl.vexp_pid.SetInput(Tsh, eTRU_ctrl.Tsh_ref, Fcpr_set);
  
  %   eTRU_ctrl.vexp_pid.FeedForward = Fcpr_set;
  eTRU_ctrl.vexp_pid.Run();
  VexpPct = eTRU_ctrl.vexp_pid.Output;
  
  % The coondenser throttle valve is used to keep the correct pressure in
  % the flash tank.
  eTRU_ctrl.vcond_pid.SetInput(Pft, Pft_ref, Fcpr_set);
  eTRU_ctrl.vcond_pid.Run();
  VcondPct = eTRU_ctrl.vcond_pid.Output;
  
  % The flash tank suction valve is openend when the compressor runs
  %   Vft = Pctrl(eTRU_ctrl.cpr_run_time, 0, 5, 0, 100);
  VftPct = 100;
  
  %   VftPct = 0;
  %   VcondPct = 100;
  
  HevapPct = 0;
  air_tdiff = abs(Tret-Tsup);
  EvapSpeedPct = Pctrl(air_tdiff, 2, 10, 30, 100);
  CondSpeedPct = Pctrl(Tc, Tamb+2, Tamb+15, 0, 100);
else
  VexpPct = 0;
  VcondPct = 0;
  VftPct = 0;
  if(Fcpr_req > 0)
    HevapPct = 0;
  else
    HevapPct = 0;%Pctrl(Tact, Tset-5, Tset, 100, 10);
  end
  
  air_tdiff = abs(Tret-Tsup);
  EvapSpeedPct = Pctrl(air_tdiff, 2, 10, 10, 100);
  CondSpeedPct = 0;
  %   CondSpeedPct = Pctrl(Tc, Tamb+2, Tamb+11, 0, 100);
end
%
% EvapSpeedPct = 100;

%
% if((eTRU_ctrl.sim_time > 4000) && (eTRU_ctrl.sim_time < 4010))
%   Vexp = 100;
% end

% if((eTRU_ctrl.sim_time > 1000) && (eTRU_ctrl.sim_time < 1300))
%   HevapPct = 100;
% end


out = [Fcpr_set, VexpPct, VftPct, VcondPct, EvapSpeedPct, CondSpeedPct, HevapPct];
