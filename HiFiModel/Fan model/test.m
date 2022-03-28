
clc; clear; close all;

load("DeltaAirflowPoly_from_data.mat")

speed_rpm = 0
% then call poly evaluation:
volume_flow = fan_airflow_poly.Evaluate(speed_rpm)

% volume_flow * 3600	% CMH, fits in between point 1 and 2 in datasheet, with
					% a pressure increase across fan.  