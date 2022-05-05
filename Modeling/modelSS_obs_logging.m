clc; close all;

% Pull out data log from simulation (is made automatically when logging
% signals)
data = out.logsout;

% Extract simulation time index
ts = data.get('u_Theta_1').Values.Time;
tHour = ts/3600;

% gdata('u_Theta_1', data)
Ainputs = [gdata('u_Theta_1', data), gdata('u_Theta_2', data), gdata('u_U_fan_1', data), ...
	gdata('u_U_fan_2', data), gdata('u_omega', data)];
legInput = ["Theta_1", "Theta_2", "U_{fan}_1", "U_{fan}_2", "omega"];

Astates = [gdata('x_m_dot_air', data), gdata('x_T_mlv', data), gdata('x_T_mv', data), ...
gdata('x_M_mlv', data), gdata('x_T_air', data), gdata('x_T_box', data), ...
gdata('x_M_mlv', data)];
legStates = ["mdot_{air}", "T_{mlv}", "T_{mv}", "M_{mlv}", "T_{air}", "T_{box}", "M_{mlv}"];

Astates = squeeze(Astates); % Remove a random third dimension..


Atildestates = [gdata('tilde_x_m_dot_air', data), gdata('tilde_x_T_mlv', data), gdata('tilde_x_T_mv', data), ...
gdata('tilde_x_M_mlv', data), gdata('tilde_x_T_air', data), gdata('tilde_x_T_box', data), ...
gdata('tilde_x_T_cargo', data)];
legTildeStates = ["tilde_mdot_{air}", "tilde_T_{mlv}", "tilde_T_{mv}", "tilde_M_{mlv}", "tilde_T_{air}", "tilde_T_{box}", "tilde_M_{mlv}"];

f = [];

% Plot 1: States and inputs - full time length
% ---------------------------
fig = myfig(-1);
f = [f fig];
ax1 = subplot(211);
plot(tHour, Astates)
title('States')
xlabel('Time [hours]')
ylabel('State deviation (x - x_o)')
legend(legStates)


ax2 = subplot(212);
plot(tHour, Ainputs')
title('Inputs')
xlabel('Time [hours]')
ylabel('Input deviation (u - u_o)')
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
ylabel('State deviation (x - x_o)')
xlim([0 1]) % In hours
legend(legStates)

ax2 = subplot(212);
plot(tHour, Ainputs')
title('Inputs')
xlabel('Time [hours]')
ylabel('Input deviation (u - u_o)')
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
ylabel('State deviation (x - x_o)')
xlim([0 1]) % In hours
ylim([-2 2])
legend(legStates)

ax2 = subplot(212);
plot(tHour, Atildestates')
title('Observed states from Kalman Decomposition observer')
xlabel('Time [hours]')
ylabel('State deviation (x - x_o)')
xlim([0 1]) % In hours
ylim([-2 2])
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
ylabel('State deviation (x - x_o)')
xlim([0 0.002]) % In hours
ylim([-3 1.1])
legend(legStates)
legend(legStates, 'Location', 'southwest')

ax2 = subplot(212);
plot(tHour, Atildestates')
title('Observed states from Kalman Decomposition observer')
xlabel('Time [hours]')
ylabel('State deviation (x - x_o)')
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

function out = gdata(name, data)
	% Pull data from name
	out = data.get(name).Values.Data;
end



