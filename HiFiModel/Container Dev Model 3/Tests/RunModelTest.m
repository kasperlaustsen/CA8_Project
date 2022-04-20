%% Clean up and initialize the refrigeration library
clc
clear all
format long
commandwindow
global RunFromLogData
global modeldir
global Ref
global model
global OptimControllerReference
%global box_tref
% Initialize refrigerant stuff
%Ref = CoolPropWrapper('HEOS::R134a');


LETools_root = getLETools_root();

load([LETools_root '/CoolProp/Maps/HEOS__R134a.mat'])

Ref = R134aM;

dbglevel = 4;

modeldir = [LETools_root '../Modelling/Modular/Models/Container Dev Model 3/'];
disp('Adding directories to path...')
addpath([modeldir 'sim_models'], [modeldir 'sim_models/definitions']...
  ,modeldir, [modeldir '../../model_parser'], [LETools_root '../Control/MIMO controller/Cooling'])

% Model file name
filename = [modeldir 'sim_models/definitions/Container_dev_model_3.xml'];


%% Load the model
[model error] = load_model(modeldir, filename, dbglevel);
if(error == 1)
  return
end

% Create an instance of a ModelAdaptor to interface between sim model and
% TestRunner controller
model.Adapter = ModelAdapter();
% model.Adapter.SetVariables('Input.Tsuc', 12.4)
% model.Adapter.GetVariables('Input.Tsuc')
%
% model.Adapter.SetVariables({'Input.Tsup1', 'Control.Fcpr'}, [32.4, 45])
% model.Adapter.GetVariables({'Input.Tsup1', 'Control.Fcpr'})

RunFromLogData = 0;

%% Linearize_model_monolithic(model, x0, excl_comp)
excl_comp = {'ctrl'}
model = linearize_model_monolithic(model, model.X0, excl_comp);
% figure(12345)
% whitebg('w')
% pzmap(model.linsys)



% Cap ctrl stand alone
%model.X0(getAbsStateIndex(model, 'ctrl.Controller')) = 1;

%% Simulate
% Define the simulation time
t = 1:3000;

% Simulation options
opts.plotupd = 0;
opts.plotfcnhandle = [];
opts.max_steps_warn = 0;
opts.print_n = 0;
opts.print_comp = 0;
opts.stop_on_NaN = 1;
opts.ODE_RelTol = 0.001;            % Default is 0.001 which is 0.1% accuracy
opts.FE_enable = 1;                 % FE solver
opts.FE_use_FOH_input = 1;          % FOH inputs instead of ZOH
opts.FE_Stepsize = 0;               % Variable step size
opts.FE_reltol = 0.0001;
opts.FE_minstep = 0.001;
opts.FE_maxstep = 1;


% Initialize the model to the working point
Tamb = 30;
Tset = -20;
model = feval(model.InitFunc, model, Tamb, Tset);

% Select the H-inf controller
model.X0(getAbsStateIndex(model, 'ctrl.Controller')) = 11;

model.X0(getAbsStateIndex(model, 'evap.Tsuc')) = -15;
model.X0(getAbsStateIndex(model, 'ctrl.Tset')) = -25;

OptimControllerReference.SHRef = [4*ones(1,1500) linspace(4, 7, 500) 9-2*cos((1:1000)*2*pi/500)];
OptimControllerReference.TretTsupDiffRef = [ones(1,1500)  3*ones(1,750) 5*ones(1,750)];
OptimControllerReference.MevapRef = ones(1,length(t));

% Simulate the model
SimError = simulate_global_model(t, opts)

if(SimError == 1)
  Error = 1000 % Max punishment for simulation errors
  feval(model.PlotFunc, model, 1)
else
  feval(model.PlotFunc, model, 1)
  LogDataViewerClass(model.DataRecorder.LogData)
  Fcpr = getSignal(model, 'ctrl.cpr_speed');
  Vexp = getSignal(model, 'ctrl.evap_vexp');
  Tret = getSignal(model, 'box.Tret');
  Tsup = getSignal(model, 'evap.Tsup');
  EvapSigma = getSignal(model,'evap.sigma'); % Filling degree of evaporator
  TsupTarget = Tret - OptimControllerReference.TretTsupDiffRef;
  
  T_MeanErrorReal = mean(abs(TsupTarget-Tsup));
  T_MeanErrorOptim = mean(abs(TsupTarget-Tsup).^2)*5;
  
  % TshRef = OptimControllerReference.SHRef;
  T0Ref = model.DataRecorder.LogData.GetSignals('T0Ref')';
  %TshRef = getSignal(model, 'evap.Tsuc') - T0Ref;
  T0 = getSignal(model, 'evap.T0');
  
  Tsuc = getSignal(model, 'evap.Tsuc');
  LiqSlugRange = (Fcpr > 0) & (Tret - T0 > 3);
  LiqSlugErr = mean(  ((Tsuc(LiqSlugRange) - T0(LiqSlugRange)) < 2)) * 1000;
  
  T0ErrRange = Fcpr > 0;
  FcprOnTimer = 0;
  
  for(k = 1:length(T0ErrRange))
    if(T0ErrRange(k) == 0)
      FcprOnTimer = 0;
    else
      FcprOnTimer = FcprOnTimer + 1;
    end
    if(FcprOnTimer < 20)
      T0ErrRange(k) = 0;
    end
    
  end
  
  
  T0_MeanErrorReal = mean(abs(T0Ref(T0ErrRange) - T0(T0ErrRange)));
  T0_MeanErrorOptim = mean(abs(T0Ref(T0ErrRange) - T0(T0ErrRange)).^2);
  
  
  fs = 1;
  % wnd = 200;
  % for(k = 1:length(Fcpr)-wnd)
  %   [freq,value] = kfft(fs,Fcpr(k:k+wnd));
  %   [~, idx] = max(value(4:end));
  %   dval(k) = value(idx+3);
  %   dfreq(k) = freq(idx+3);
  % end
  Vexp = Vexp(Vexp > 1);
  Vexp = HighPassFilter(Vexp, 80);
  Vexp = HighPassFilter(Vexp, 80);
  
  [freq,value] = kfft(fs,Vexp);
  OscErrorVexp = sum(value(freq > 0.2))*0.01;
  
  
  Fcpr = Fcpr(Fcpr > 20);
  if(~isempty(Fcpr))
    Fcpr = HighPassFilter(Fcpr, 80);
    Fcpr = HighPassFilter(Fcpr, 80);
    
    [freq,value] = kfft(fs,Fcpr);
    OscErrorFcpr = sum(value(freq > 0.02))*0.1;
  else
    OscErrorFcpr = 0;
  end
  %
  % figure(85)
  % clf
  % plot(Fcpr)
  %
  % figure(86)
  % clf
  % hold on
  % % plot(dfreq.*dval, 'b')
  % % plot(dval, 'r')
  % plot(freq, value)
  
  
  
  Error = T0_MeanErrorOptim + T_MeanErrorOptim + LiqSlugErr + OscErrorFcpr + OscErrorVexp;
  ErrStr = sprintf('Err:%0.2f, T0: %0.2f, Tset: %0.2f, LiqSlug: %0.2f, OscFcpr: %0.2f, OscVexp: %0.2f', ...
    Error, T0_MeanErrorOptim, T_MeanErrorOptim, LiqSlugErr, OscErrorFcpr, OscErrorVexp);
  
  %%
  if(1)
    %   feval(model.PlotFunc, model, 1)
    %   figure(54)
    %%
    figure(64)
    clf
    whitebg('w')
    ax = tight_subplot(3, 1, 0.01, [.1 .1], [.1 .1]);
    
    axes(ax(1));
    plot(model.t, getSignal(model, 'ctrl.cpr_speed'), 'b');
    hold on
    plot(model.t, getSignal(model, 'ctrl.evap_vexp'), 'r');
    plot(model.t, getSignal(model, 'ctrl.econ_vexp'), 'g');
    plot(model.t, getSignal(model, 'ctrl.vfan_evap')*10, 'm');
    grid on
    legend('Fcpr', 'Vexp', 'Veco', 'Mevap', 'Location', 'BestOutside')
    
    axes(ax(2));
    
    
    plot(model.t, Tsup, 'b');
    hold on
    plot(model.t, TsupTarget, 'm');
    plot(model.t, Tsup-TsupTarget, 'r');
    grid on
    text(10, 6500, ['Mean error: ' num2str(T_MeanErrorReal) 'K'])
    legend('Tsup', 'TsupTarget', 'Error', 'Location', 'BestOutside');
    %ylim([-1000 7000])
    
    axes(ax(3));
    
    plot(model.t, T0,'c');
    hold on
    plot(model.t, T0Ref, 'm');
    plot(model.t, Tsuc, 'b');
    plot(model.t, Tret, 'g');
    plot(model.t, getSignal(model,'evap.sigma')*10-10, 'r');
    plot(model.t, T0ErrRange*2-35, 'k')
    grid on
    text(10, -13, ErrStr)
    %text(10, -3, ['LiqSlugErr: ' num2str(LiqSlugErr)])
    
    legend('T0', 'T0Ref', 'Tsuc', 'Tret', 'sigma', 'Location', 'BestOutside')
    %ylim([-5 16])
    ylabel('Temp. [K]')
    linkaxes(ax, 'x')
    AlignAxesVert(ax)
    set(ax(1:2), 'XTickLabel', '')
    xlim([-100 length(model.t)])
    %print('-dpng', '-r600', 'HinfControllerModelTest.png')
    %%
  end
end

%%
ProfilerPlot(model, 1337)







