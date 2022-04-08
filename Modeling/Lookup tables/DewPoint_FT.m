% ========================================================================
% Preamble 
% ======================
clc;clear;close all;

% Default figure size
% fwidth = 600; fheight = 400;	% Height and width of figures in pixels
% fXpos = 0.1; fYpos = 0.5;			% Position of figures (between 0 and 1)
% figpos = [fXpos fYpos fwidth fheight];


% ========================================================================
% Method of linearizations
% ========================================================================
ref = CoolPropPyWrapper('HEOS::R134a');             % Initialize refridgerant

%pressure = 0.01:0.01:40;                            % Define pressure vector for plotting
pressure = 1 * ones(1,2201);
%T = 20 * ones(1,4000);
T = -100:0.5:1000;
enthalpy = ref.HTP(T,pressure);                     % Define enthalpy vector for plotting
%f = myfig(-1, figpos);
plot(T,enthalpy);                            % Plot nonlinear p-h relationship
%hold on

% Linearize in x0
% ---------------------------------------
p0 = 1;                                             % Pressure operating point
delta_X = 0.001;                                    % Slope calculation width (keep it small)
linearOffset = ref.HDewP(p0);                       % Calculate f(p0) and f'(p0)
linearSlope = ( ref.HDewP(p0 + delta_X) - ref.HDewP(p0 - delta_X) ) / (2*delta_X);  

enthalpy_linear = linearOffset + linearSlope * (pressure-p0);
                                                    % Calculate linearized enthalpy
%plot(pressure,enthalpy_linear,'r');                 % Plot linearized enthalpy


% ========================================================================
% Functions
% ========================================================================

% Calculate linear "y = ax+b" parameters pressure operating point p0
% ---------------------------------------
    p = 1;                                         % Pressure
    T = -26;                                         % Temperature
    [a,b] = DewPoint_LinParam(p0);                  % Only pass a scalar pressure


    
% Calculate enthalpy h from pressure and pressure operating point p0
% ----------------------------
    [h_bub] = DewPointLinearization(p, p0, "Bub")       % Takes either a scalar or vector p
    [h_HTP] = DewPointLinearization(p, p0, "HTP",T)       % Takes either a scalar or vector p



