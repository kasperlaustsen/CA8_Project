
% load('HiFi_model_data_for_component_tests_02.mat')
load('HiFi_model_data_for_component_tests_03.mat') % measurement file with sigma


% for figures
b = 2;
width = [700*b];
height = [500*b];


N = size(out.tout,1);
% Beware of the sample time in simulink..
t = out.tout;
Ts_arr = [out.tout(2:N); out.tout(end)] - [0; out.tout(1:end-1)];