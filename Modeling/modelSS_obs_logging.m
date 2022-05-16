clc; close all;

% Pull out data log from simulation (is made automatically when logging
% signals)
data = out.logsout;

% Extract simulation time index
ts = data.get('u_Theta_1').Values.Time;
tHour = ts/3600;

% Extract input signals
Ainputs = [gdata('u_Theta_1', data), gdata('u_U_fan_2', data)];
Ainputs = squeeze(Ainputs); % Remove a random third dimension..
% Legend names for plotting
legInput = ["$\Theta_1$", "$U_{fan_2}$"];


% Extract state signals
Astates = [gdata('x_m_dot_air', data), gdata('x_T_mlv', data), gdata('x_T_mv', data), ...
gdata('x_M_lv', data), gdata('x_T_air', data), gdata('x_T_box', data), ...
gdata('x_T_cargo', data), gdata('x_T_v', data)];
Astates = squeeze(Astates); % Remove a random third dimension..
% Legend names for plotting
legStates = ["4: $\dot{m}_{air}$", "5: $T_{mlv}$", "6: $T_{mv}$", ...
	"7: $M_{lv}$", "9: $T_{air}$",  "10: $T_{box}$",  "11: $T_{cargo}$",  "12: $T_{v}$"];

% Extract observed state signals
AtildeStates = [gdata('tilde_x_m_dot_air', data), gdata('tilde_x_T_mlv', data), ... 
gdata('tilde_x_T_mv', data), gdata('tilde_x_M_lv', data), gdata('tilde_x_T_air', data), ...
gdata('tilde_x_T_box', data), gdata('tilde_x_T_cargo', data), gdata('tilde_x_T_v', data)];
AtildeStates = squeeze(AtildeStates);  % Remove a random third dimension..
% Legend names for plotting
legTildeStates = ["4: $\tilde{\dot{m}}_{air}$", "5: $\tilde{T}_{mlv}$", "6: $\tilde{T}_{mv}$", ...
	"7: $\tilde{M}_{lv}$", "9: $\tilde{T}_{air}$",  "10: $\tilde{T}_{box}$",  "11: $\tilde{T}_{cargo}$",  "12: $\tilde{T}_{v}$"];

f = [];

% Plot 1: States and inputs - full time length
% ---------------------------
fig = myfig(-1);
f = [f fig];
ax1 = subplot(211);
plot(tHour, Astates)
title('States')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
legend(legStates)


ax2 = subplot(212);
plot(tHour, Ainputs')
title('Inputs')
xlabel('Time [hours]')
ylabel('Input deviation $(u - u_o)$')
legend(legInput)

linkaxes([ax1 ax2],'x'); % Link x axes (not y)


% Plot 2: States and inputs - shorter time length
% ---------------------------
fig = myfig(-1);
f = [f fig];
ax1 = subplot(211);
plot(tHour, Astates)
title('States')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
xlim([0 1]) % In hours
legend(legStates)

ax2 = subplot(212);
plot(tHour, Ainputs')
title('Inputs')
xlabel('Time [hours]')
ylabel('Input deviation $(u - u_o)$')
xlim([0 1]) % In hours
legend(legInput)

linkaxes([ax1 ax2],'x'); % Link x axes (not y)


% Plot 3: States and observed states - 1 hour time length
% ---------------------------
fig = myfig(-1);
f = [f fig];
ax1 = subplot(211);
plot(tHour, Astates)
title('States')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
xlim([0 1]) % In hours
ylim([-4 2])
legend(legStates)

ax2 = subplot(212);
plot(tHour, AtildeStates')
title('Observed states from Kalman Decomposition observer')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
xlim([0 1]) % In hours
ylim([-4 2])
legend(legTildeStates)

linkaxes([ax1 ax2],'x'); % Link x axes (not y)



% Plot 4: States and observed states - 0.1 hour time length
% ---------------------------
fig = myfig(-1);
f = [f fig];
ax1 = subplot(211);
plot(tHour, Astates)
title('States')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
xlim([0 0.002]) % In hours
ylim([-4 1.1])
legend(legStates)
legend(legStates, 'Location', 'southwest')

ax2 = subplot(212);
plot(tHour, AtildeStates')
title('Observed states from Kalman Decomposition observer')
xlabel('Time [hours]')
ylabel('State deviation $(x - x_o)$')
xlim([0 0.002]) % In hours
% ylim([])
legend(legTildeStates, 'Location', 'southeast')

linkaxes([ax1 ax2],'x'); % Link x axes (not y)




% Plot 5
% ---------------------------



%% EXPORT
% ---------------------------
savepath = 'C:\Users\kaspe\Documents\Git\Repos\CA8_Writings\Graphics';
filenames = ["fig_stateInput30h.png", "fig_stateInput1h.png", "fig_stateObsState1h.png", "fig_stateObsState002h.png"];
myfigexport(savepath, f, filenames, "false", 'Figures', 300);

% NOTE: Commit ny myfigexport funktion!!!


%%
% State overview
% T_m_dot			
% m_dot_air_dot	
% T_mlv_dot		
% T_mv_dot		
% M_lv_dot	   
% M_v_dot			
% T_air_dot      
% T_box_dot      
% T_cargo_dot    
% T_v_dot


% Functions
function out = gdata(name, data)
	% Pull data from name
	out = data.get(name).Values.Data;
end



