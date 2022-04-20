function x = container_controller2(t,x,u,p)
persistent D % Struct for use with MPC controller from MaCHIL
global Ref
global model
global SimTimeIdx

evap_psuc = u(1) + rand(1,1)*0.02;
evap_hsuc = u(2);
econ_psuc = u(3);
econ_hsuc = u(4);
pdis      = u(5) + rand(1,1)*0.02;
hdis      = u(6);
Tret      = u(7) + rand(1,1)*0.02;
Tsup      = u(8) + rand(1,1)*0.02;
Tcargo    = u(9);
Talu      = u(10);
Tfc       = u(11);

evap_vexp        = x(1);
econ_vexp        = x(2);
fcpr_old         = x(3);
Tamb             = x(4);
mcond            = x(5);
mevap            = x(6);
evap_Tsuc        = x(7);
intg_vexp        = x(8);
intg_cpr         = x(9);
mcond_cont       = x(10);
Hevap            = x(11);
Q_ref            = x(12);
Q_int            = x(13);
fcpr_off_counter = x(14);
dummy1           = x(15);
dummy2           = x(16);
dummy3           = x(17);
Vhg              = x(18);
RH               = x(19);
Tset             = x(20);
QHeat            = x(21);
controller       = round(x(22));
ctrl_mode        = round(x(23));

%Tfc = 60;
%Tamb = 25;

% if(controller == 1 && (ctrl_mode == 4 || ctrl_mode == 6))
% %   Tamb = 25;
% else
%   if(~isfield(D, 'Tamb0') || t == 0)
%     disp(['Setting D.Tamb0 = ' num2str(Tamb)])
%     D.Tamb0 = Tamb;
%   end
%   if(controller == 7 && ctrl_mode == 4) % COP data mode
%     D.TambDelta = 0;
%   else
%     D.TambDelta = 5;
%   end
%     
%   Tamb = D.Tamb0 + D.TambDelta*sin(t/86400*2*pi);
% end
%Tsup_set = -10;
%Tset = -26;
%controller = 1; % Choose which controller to use 
                % 1 = Starcool Pi control
                % 2 = Inject2 controller
                % 3 = Linearizing capacity controller for MPC

% global RunFromLogData
% global Control

%  if(t > 100)
%    Tset = -5 + (t-100)*0.01;
%  end

% evap_Tsuc = evap_Tsuc + 0.025*(getRefrigTemp(evap_hsuc, evap_psuc) - evap_Tsuc);
if(t <= 2) 
  evap_Tsuc = LimitValue(Ref.THP(evap_hsuc, evap_psuc), -80, 100);
else
  evap_Tsuc = LimitValue(evap_Tsuc + 0.01*(Ref.THP(evap_hsuc, evap_psuc) - evap_Tsuc), -80, 100) + rand(1,1)*0.02;
end
evap_Pt = Ref.PDewT(evap_Tsuc);
evap_T0 = Ref.TDewP(evap_psuc);

econ_Tsuc = LimitValue(Ref.THP(econ_hsuc, econ_psuc), -80, 100);
econ_T0 = Ref.TDewP(econ_psuc);

handles = [];
D = CopyVarsToD(D, evap_T0, evap_psuc, evap_Tsuc, econ_psuc, econ_Tsuc, pdis, ...
  Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond, mcond_cont, ...
  Hevap, fcpr_old, t, mevap, Q_ref, Q_int, fcpr_off_counter, Tcargo, ...
  Talu, RH, ctrl_mode);
D = ContainerTempEstimator(D);
D = getCoolingCap(D);
D.QCoolAct = LimitSignal(D.Q_cool_air,[-4000 20000]);

dummy2 = D.QCoolAct/100;
D.FanAlwaysOn = 0;
D.CapCtrlStandAlone = 0;  
D.Vexp = evap_vexp;
  
switch(controller)
  case 1
[fcpr vexp veco mcond mevap intg_vexp intg_cpr mcond_cont Hevap] = starcoolctrl(t, evap_psuc, evap_Tsuc, econ_psuc,...
  econ_Tsuc, pdis, Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond, mcond_cont, Hevap, fcpr_old, ctrl_mode);


  case 2
[fcpr vexp veco mcond mevap intg_vexp intg_cpr mcond_counter mcond_cont] = Inject2_ctrl_wrapper(evap_psuc, evap_Tsuc, econ_psuc,...
  econ_Tsuc, pdis, Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond_cont, mcond);

  case 3
    [fcpr vexp veco mcond mevap intg_vexp intg_cpr mcond_cont Hevap Q_ref Q_int fcpr_off_counter dummy1 dummy2 dummy3] = linCapCtrlMPC(evap_psuc, evap_Tsuc, econ_psuc,...
  econ_Tsuc, pdis, Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond, mcond_cont, Hevap, fcpr_old, t, mevap, Q_ref, Q_int, fcpr_off_counter, dummy1, dummy2, dummy3);
  
  case 4
    [fcpr vexp veco mcond mevap intg_vexp intg_cpr mcond_cont Hevap] = P0ctrl(evap_psuc, evap_Tsuc, econ_psuc,...
      econ_Tsuc, pdis, Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond, mcond_cont, Hevap, t, fcpr_old);
    
  case 5
    if(ctrl_mode == 1)
      D.FanAlwaysOn = 1;
    end
    [~, D] = linCapCtrlMPC600rev5(handles, D);

    [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ... 
      fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);

  case 6
    [fcpr vexp veco mcond mevap Hevap Tamb] = LogDataController(t);
    
  case 7  
    if(ctrl_mode == 1)
      D.FanAlwaysOn = 1;
    end
    D.CapCtrlStandAlone = 1;  
    [~, D] = CapCtrl(handles, D);

    [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ... 
      fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);
    
    case 8
    if(ctrl_mode == 1)
      D.FanAlwaysOn = 1;
    end
    [~, D] = linCapCtrlMPC600rev6(handles, D);

    [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ... 
      fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);
  
  case 9 % Badass H-inf controller
    [~, D] = HinfCoolingController([], D);
    [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ... 
      fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);
    dummy1 = D.Q_cool_req;  
    dummy2 = D.QCoolAct;
    dummy3 = D.TshRef;
    
    case 10 % ExpansionValveMex
      D.CapCtrlStandAlone = 1;
      [~, D] = CapCtrl(handles, D);
      D = ExpansionValveMexWrapper(D);
      D.TshRef = 0;
      Tset = D.Tset;
      
      [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ...
        fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);

  case 11 % TestRunner MIMO controller
    SimTimeIdx = LimitValue(t-1, 1, 1000000000);
    if(t <= 1) % Initialize the Controller
      model.Time = now;
      [VarNames, VarValues] = model.Adapter.GetVariablesAndNames();
      model.DataRecorder.LogValueCache = LogValueCacheClass();      
      model.DataRecorder.LogValueCache.AddValues(model.Time, VarNames, VarValues);
      
      model.DataRecorder.LogData = LogDataClass(model.DataRecorder.LogValueCache.GetTime() , ...
        model.DataRecorder.LogValueCache.GetAllNames(),...
        model.DataRecorder.LogValueCache.GetAllValues()');
      
      % Initialize with empty testrunner to prevent live updates to LogDataViewer. 
      % model.DataRecorder
      model.CtrlObj = StarCoolCtrlMIMO('SimModel::StarCoolCtrlMIMO', model.DataRecorder, model.Adapter);
      model.CtrlObj.Init();      
      model.CtrlObj.DisableDefrosting();
    end
    
    % Run the controller
    model.Time = model.Time + 1/86400; % Increment timestamp by one second
%     datestr(model.Time)
%     datestr(model.DataRecorder.LogValueCache.GetTime())
    [VarNames, VarValues] = model.Adapter.GetVariablesAndNames();
    model.DataRecorder.LogValueCache.UpdateValuesByName(model.Time, VarNames, VarValues);
    
    model.DataRecorder.LogData.AppendSample(model.DataRecorder.LogValueCache.GetTime(), ...
      model.DataRecorder.LogValueCache.GetAllValues()');    
    model.CtrlObj.Service();

    
    % Copy ctrl signals
    fcpr  = model.Adapter.MatlabCtrlHandler.GetFcpr();
    vexp  = model.Adapter.MatlabCtrlHandler.GetVexp();
    veco  = model.Adapter.MatlabCtrlHandler.GetVeco();
    mcond = model.Adapter.MatlabCtrlHandler.GetMcond();
    mevap = model.Adapter.MatlabCtrlHandler.GetMevap();
    Hevap = model.Adapter.MatlabCtrlHandler.GetHevap();
    
    
%     [fcpr, vexp, veco, mcond, mevap, intg_vexp, intg_cpr, Hevap, Q_ref, Q_int, ... 
%       fcpr_off_counter, dummy1, dummy2, dummy3] = CopyVarsFromD(D);

    
    
    
  otherwise
    error('Undefined controller index');   

end

% fcpr 
% mcond
x = [vexp veco fcpr Tamb mcond mevap evap_Tsuc intg_vexp intg_cpr mcond_cont Hevap Q_ref Q_int fcpr_off_counter dummy1 dummy2 dummy3 Vhg RH Tset QHeat controller ctrl_mode]';

% if(RunFromLogData == 1)
%   x = [Control.Vexp(t) Control.Veco(t) Control.Tfc(t) Control.Fcpr(t) Control.Tamb(t)...
%        Control.Mcond(t) Control.Mevap(t) evap_Tsuc]';
% end

