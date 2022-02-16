
fh = figure(999);
clf

sim_result = out.xout;

% Set up axes
ax = tight_subplot(3,2,[.01 .03],[.1 .01],[.03 .03]);
pa_width = 0.4;


out.xout.getElementNames;
out.logsout.getElementNames;


% plot control signals
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(1);
plot_spec.line = '-';

data_ts = out.logsout.getElement('Fcpr').Values;
plot_spec.display_name = 'Fcpr';
plot_spec.color = rgb('black');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);
hold(plotaxes, 'on')

data_ts = out.logsout.getElement('Vexp').Values;
plot_spec.display_name = 'Vexp';
plot_spec.color = rgb('red');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('VFT').Values;
plot_spec.display_name = 'VFT';
plot_spec.color = rgb('green');
PlotTimeSeries(plotaxes, data_ts, @(x) x*0.02,  plot_spec);

data_ts = out.logsout.getElement('Vcond').Values;
plot_spec.display_name = 'Vcond';
plot_spec.color = rgb('magenta');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);


data_ts = out.logsout.getElement('cond_fan_pct').Values;
plot_spec.display_name = 'CondSpeed';
plot_spec.color = rgb('blue');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('evap_fan_pct').Values;
plot_spec.display_name = 'EvapSpeed';
plot_spec.color = rgb('brown');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('Hevap_pct').Values;
plot_spec.display_name = 'Hevap';
plot_spec.color = rgb('orange');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);



lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')


% plot pressures
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(2);
plot_spec.line = '-';
value_converter = [];%@(x) x/100000;

plot_spec.display_name = 'Comp $P_{dis}$';
plot_spec.color = [1, 0, 0];
data_ts = out.logsout.getElement('cpr_disc_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);
hold(plotaxes, 'on')

data_ts = out.logsout.getElement('cond_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]
plot_spec.display_name = 'Cond ${P}_{out}$';
plot_spec.color = [1, 1, 0];
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('ft_liq_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]
plot_spec.display_name = 'FT $P_{flash}$';
plot_spec.color = rgb('purple');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('ft_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]
plot_spec.display_name = 'Comp $P_{int}$';
plot_spec.color = rgb('magenta');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

% signal_name = 'eTRU_prototype_2.Evap_exv.Out.p';
data_ts = out.logsout.getElement('evap_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]

plot_spec.display_name = 'Evap $P_{in}$';
plot_spec.color = rgb('blue');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

data_ts = out.logsout.getElement('evap_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature]
plot_spec.display_name = 'Evap $P_{suc}$';
plot_spec.color = rgb('cyan');
PlotTimeSeries(plotaxes, data_ts, [], plot_spec);

lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')

% plot mass 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(3);
plot_spec.line = '-';

signal_name = 'eTRU_prototype_2.two_stage_compressor.cpr_v_int.mass';
plot_spec.display_name = 'Cpr $m$';
plot_spec.color = [1, 1, 0];
PlotSimScapeSignal(plotaxes, sim_result, signal_name, [], plot_spec);
hold(plotaxes, 'on')

signal_name = 'eTRU_prototype_2.Condenser.ref_hx.mass' ;
plot_spec.display_name = 'Cond $m$';
plot_spec.color = [1, 0, 0];
PlotSimScapeSignal(plotaxes, sim_result, signal_name, [], plot_spec);

signal_name = 'eTRU_prototype_2.Flash_tank.Tank.mass_vap';
plot_spec.display_name = 'FT ${m}_{vap}$';
plot_spec.color = rgb('purple');
PlotSimScapeSignal(plotaxes, sim_result, signal_name, [], plot_spec);

signal_name = 'eTRU_prototype_2.Flash_tank.Tank.mass_liq';
plot_spec.display_name = 'FT ${m}_{liq}$';
plot_spec.color = rgb('blue');
PlotSimScapeSignal(plotaxes, sim_result, signal_name, [], plot_spec);

signal_name = 'eTRU_prototype_2.Evaporator.evap_hx.two_phase_fluid.mass';
plot_spec.display_name = 'Evap $m$';
plot_spec.color = rgb('cyan');
PlotSimScapeSignal(plotaxes, sim_result, signal_name, [], plot_spec);

lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')


% plot enthalpy
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(4);
plot_spec.line = '-';
value_converter = [];

%data_ts = getSimScapeEnthalpy(Ref, sim_result, 'eTRU_prototype_2.Condenser.ref_hx.A.p'  , 'eTRU_prototype_2.Condenser.ref_hx.A.u');
data_ts = out.logsout.getElement('cpr_disc_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature]
plot_spec.display_name = 'Comp ${h}_{out}$';
plot_spec.color = rgb('red');
PlotTimeSeries(plotaxes, data_ts, @(x) x*0.001, plot_spec);
hold(plotaxes, 'on')
 
% data_ts = getSimScapeEnthalpy(Ref, sim_result, 'eTRU_prototype_2.Flash_tank.p', 'eTRU_prototype_2.Evap_exv.In.u');
data_ts = out.logsout.getElement('cond_out_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Cond ${h}_{out}$';
plot_spec.color = rgb('mediumblue');
PlotTimeSeries(plotaxes, data_ts, @(x) x*0.001, plot_spec);

data_ts = out.logsout.getElement('ft_vap_out_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'FT ${hvap}_{out}$';
plot_spec.color = rgb('greenyellow');
PlotTimeSeries(plotaxes, data_ts, @(x) x/1000, plot_spec);
% 
data_ts = getSimScapeEnthalpy(Ref, sim_result, 'eTRU_prototype_2.Flash_tank.Tank.p', 'eTRU_prototype_2.Flash_tank.Tank.u_vap');
plot_spec.display_name = 'FT ${hvap}_{int}$';
plot_spec.color = rgb('green');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = getSimScapeEnthalpy(Ref, sim_result, 'eTRU_prototype_2.Flash_tank.Tank.p', 'eTRU_prototype_2.Flash_tank.Tank.u_liq');
plot_spec.display_name = 'FT ${hliq}_{int}$';
plot_spec.color = rgb('dodgerblue');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('ft_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Comp ${him}_{in}$';
plot_spec.color = rgb('magenta');
PlotTimeSeries(plotaxes, data_ts, @(x) x/1000, plot_spec);

data_ts = out.logsout.getElement('evap_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Evap ${h}_{in}$';
plot_spec.color = rgb('yellow');
PlotTimeSeries(plotaxes, data_ts, @(x) x/1000, plot_spec);

data_ts = out.logsout.getElement('evap_out_line').Values;
data_ts.Data = data_ts.Data(:,2); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Comp ${hsuc}_{in}$';
plot_spec.color = rgb('cyan');
PlotTimeSeries(plotaxes, data_ts, @(x) x/1000, plot_spec);

lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')


% plot mass flows
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(5);
plot_spec.line = '-';

data_ts = out.logsout.getElement('cpr_disc_line').Values;
data_ts.Data = data_ts.Data(:,5); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Cpr $\dot{m}_{out}$';
plot_spec.color = rgb('red');
PlotTimeSeries(plotaxes, data_ts, @(x) x*1000, plot_spec);
hold(plotaxes, 'on')

data_ts = out.logsout.getElement('cond_out_line').Values;
data_ts.Data = data_ts.Data(:,5); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Cond $\dot{m}_{out}$';
plot_spec.color = rgb('yellow');
PlotTimeSeries(plotaxes, data_ts, @(x) x*1000, plot_spec);

data_ts = out.logsout.getElement('ft_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,5); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'CprIm $\dot{m}$';
plot_spec.color = rgb('purple');
PlotTimeSeries(plotaxes, data_ts, @(x) x*1000, plot_spec);

data_ts = out.logsout.getElement('evap_exv_out_line').Values;
data_ts.Data = data_ts.Data(:,5); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Evap $\dot{m}_{in}$';
plot_spec.color = rgb('blue');
PlotTimeSeries(plotaxes, data_ts, @(x) x*1000, plot_spec);

data_ts = out.logsout.getElement('evap_out_line').Values;
data_ts.Data = data_ts.Data(:,5); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Evap $\dot{m}_{out}$';
plot_spec.color = rgb('cyan');
PlotTimeSeries(plotaxes, data_ts, @(x) x*1000, plot_spec);

lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')

% plot Temperatures
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotaxes = ax(6);
cla(plotaxes)
plot_spec.line = '-';

data_ts = out.logsout.getElement('cpr_disc_line').Values;
data_ts.Data = data_ts.Data(:,3); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Tdis';
plot_spec.color = rgb('red');
PlotTimeSeries(plotaxes, data_ts, @(x) x, plot_spec);
hold(plotaxes, 'on')

data_ts = out.logsout.getElement('cpr_disc_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature, Phi, mdot]
data_ts.Data = Ref.TDewP(data_ts.Data);
plot_spec.display_name = 'Tc';
plot_spec.color = rgb('black');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('Tamb').Values;
plot_spec.display_name = 'Tamb';
plot_spec.color = rgb('orange');
PlotTimeSeries(plotaxes, data_ts, @(x) x-273.15, plot_spec);

data_ts = out.logsout.getElement('cond_out_line').Values;
data_ts.Data = data_ts.Data(:,3); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Tcondout';
plot_spec.color = rgb('green');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('ft_liq_out_line').Values;
data_ts.Data = data_ts.Data(:,3); % [Pressure, Enthalpy, Temperature, Phi, mdot]
plot_spec.display_name = 'Tliquid';
plot_spec.color = rgb('magenta');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('ft_liq_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature, Phi, mdot]
data_ts.Data = Ref.TDewP(data_ts.Data);
plot_spec.display_name = 'T0ft';
plot_spec.color = rgb('lightgreen');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('evap_out_line').Values;
data_ts.Data = data_ts.Data(:,1); % [Pressure, Enthalpy, Temperature, Phi, mdot]
data_ts.Data = Ref.TDewP(data_ts.Data);
plot_spec.display_name = 'T0';
plot_spec.color = rgb('cyan');
PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec);

data_ts = out.logsout.getElement('tsuc').Values;
plot_spec.display_name = 'Tsuc';
plot_spec.color = rgb('blue');
PlotTimeSeries(plotaxes, data_ts,  @(x) x-273.15, plot_spec);

data_ts = out.logsout.getElement('tsup').Values;
plot_spec.display_name = 'Tsup';
plot_spec.color = rgb('yellow');
PlotTimeSeries(plotaxes, data_ts,  @(x) x-273.15, plot_spec);

data_ts = out.logsout.getElement('tret').Values;
plot_spec.display_name = 'Tret';
plot_spec.color = rgb('green');
PlotTimeSeries(plotaxes, data_ts,  @(x) x-273.15, plot_spec);

data_ts = out.logsout.getElement('tcargo').Values;
plot_spec.display_name = 'Tcargo';
plot_spec.color = rgb('white');
PlotTimeSeries(plotaxes, data_ts,  @(x) x-273.15, plot_spec);

lh = legend(plotaxes, 'interpreter', 'latex', 'fontsize', 12, 'location', 'bestoutside');
pa_pos = get(plotaxes, 'position');
pa_pos(3) = pa_width;
set(plotaxes, 'position', pa_pos)
grid(plotaxes, 'on')


% remove unwanted time tick labels
set(ax(1:4),'XTickLabel','');
linkaxes(ax, 'x')
set(ax,'Color', rgb('gray'))

% tts('Plot ready')