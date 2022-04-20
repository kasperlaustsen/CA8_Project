%% Clean up and initialize the refrigeration library
matlabrc
clc
clear all
format long
global RunFromLogData
global modeldir
% Initialize refrigerant library
SetRNumber('R134a');    % Select refrigerant
SetPressureUnit(2);     % Pressure in [bar]
SetTemperatureUnit(1);  % Temperature in [°C]
SetEnthalpyUnit(0);     % Enthalpy in J/kg

dbglevel = 4;

% Model path
modeldir = 'C:\MATLAB\work\maschilDev\Modelling\Container Dev Model\';
disp('Adding directories to path...')
addpath(modeldir, [modeldir '\sim_models'], [modeldir '\sim_models\definitions']...
  ,[modeldir '\helper_functions'], [modeldir '\model_parser'])

% Model file name
filename = [modeldir 'sim_models\definitions\container_test_a.xml'];

%% Load the model
[model error] = load_model(modeldir, filename, dbglevel);
if(error == 1)
  return
end
% Load logdata
%datafile = [matlabroot '\work\StarCool\data\step 10 to -15.mat'];
% load xnul4
% load MPC_Q_reference
% global Q_refrig
% xnul = xnul4;
%xnul = CalculateInitialValues(datafile,model);
xnul = []

RunFromLogData = 0;
% Define the simulation time
runtime = 1; % Days
t = 1:3600*24*runtime;
t = 1:20000;


%% Run the simulation
opts.plotupd = 0;
opts.plotfcnhandle = [];
opts.max_steps_warn = 0;
opts.print_n = 0;
opts.print_comp = 0;
opts.stop_on_NaN = 1;
%[model x t error] = simulate_model_par(model, t, xnul, opts);
[model x t error] = simulate_model(model, t, opts);
model.x1 = model.x;
model.t1 = model.t;

%% load model10k
clearfig = 1;
plotfcn(model, clearfig)

%%
if(0)
  %%
  disp('Saving X0...')
  xnul4 = model.x1(:,end);
  save xnul4 xnul4
  disp('Done!')
  %%
end
%%
% ProfilerPlot

if(0)
  %%  Go ahead and lineraize
  excl_comp = {'controller'}
  t0 = 60;
  xnul = model.x1(:,t0);
  tic
  model = linearize_red_model_monolithic(model, xnul, excl_comp,1);
  toc

  % figure(4)
  % clf
  % pzmap(model.linsysd,'r')
  % hold on
  % pzmap(model.linsysd01,'b')

  x0 = model.x1(model.incl_st,t0);
  u0 = model.x1(model.excl_st,t0);

  model = simulate_model_linear(model, model.linsys, t, x0, u0);

  model.x = model.x_linsim;
  model.x2 = model.x_linsim;

  %model.x(model.incl_st,:) = X' + repmat(model.x1(model.incl_st,1),1,length(t));

  % model.x(model.incl_st,:) = y;
  % model.x(model.excl_st,:) = x_ctrl;

  container_test_plot_a2(model, 0)
  %%
end
%%
% figure(61)
% clf
% plot(ytime,ydot')
% legend('pout','h2','mdotin','sigma','h1','m1','m2','Tm','Tsup','Location','BestOutside');
%
% figure(62)
% clf
% plot(ytime,V1time,'r')
% hold on
% plot(ytime,V2time,'g')
% plot(ytime,T1time,'b')
% plot(ytime,T2time,'c')
% plot(ytime,h12time,'m')
% legend('V1','V2','T1','T2','h12','Location','BestOutside');
%
