% ========================================================================
% Preamble 
% ======================
clc;clear;close all;
ref = CoolPropPyWrapper('HEOS::R134a');                 % Initialize refridgerant
delta_X = 0.001;                                       % Slope calculation width (keep it small)

% ========================================================================
% Operating point
% ========================================================================
T1_op        = 45;
% T1_op        = out.logsout{26}.Values.Data(end,3);
T2_op        = 33.6;
% T2_op        = out.logsout{27}.Values.Data(end,3);
T3_op        = 48.2;    % found from Kresten Sim
% T3_op        = out.logsout{25}.Values.Data(end,3);
T7_op        = 22.2;
% T7_op        = out.logsout{28}.Values.Data(end,3);
pi1_com1_op  = 10;
pi1_com2_op  = 10;
p1_op        = 1.9;
% p1_op        = out.logsout{26}.Values.Data(end,1);
p2_op        = 7.8;
% p2_op        = out.logsout{25}.Values.Data(end,1);

hv_op        = 10;
Vi_op        = 1;
Vl_op        = 1;
Mv_op        = 10; 

% ========================================================================
% Linearisation
% ========================================================================


% Linearize h3 in compressor stage 2
% ---------------------------------------

linearOffset_h3 = ref.HTP(T3_op,p2_op);                       % Calculate f(p0) and f'(p0)
linearSlope_h3 = (  ref.HTP(T3_op,p2_op + delta_X) -  ref.HTP(T3_op,p2_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p



% Linearize v1_COM2 in compressor stage 2
% ---------------------------------------

linearOffset_v1_COM2 = ref.HTP(T2_op,pi1_com2_op);                       % Calculate f(p0) and f'(p0)
linearSlope_v1_COM2 = (  ref.HTP(T2_op,pi1_com2_op + delta_X) -  ref.HTP(T2_op,pi1_com2_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p




% Linearize h1 in compressor stage 1
% ---------------------------------------

linearOffset_h1 = ref.HTP(T1_op,p1_op);                       % Calculate f(p0) and f'(p0)
linearSlope_h1 = (  ref.HTP(T1_op,p1_op + delta_X) -  ref.HTP(T1_op,p1_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p



% Linearize v1_COM1 in compressor stage 1
% ---------------------------------------

linearOffset_v1_COM1 = ref.HTP(T7_op,pi1_com1_op);                       % Calculate f(p0) and f'(p0)
linearSlope_v1_COM1 = (  ref.HTP(T7_op,pi1_com1_op + delta_X) -  ref.HTP(T7_op,pi1_com1_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p



% Linearize h5 in flash tank
% ---------------------------------------

linearOffset_h5 = ref.HBubP(p1_op);                       % Calculate f(p0) and f'(p0)
linearSlope_h5 = (ref.HBubP(p1_op + delta_X) -  ref.HBubP(p1_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p



% Linearize h6 in flash tank
% ---------------------------------------

linearOffset_h6 = ref.HDewP(p1_op);                       % Calculate f(p0) and f'(p0)
linearSlope_h6 = (ref.HDewP(p1_op + delta_X) -  ref.HDewP(p1_op - delta_X) ) / (2*delta_X);  % linearised w. respect to p




% Linearize p5 in evaporator
% ---------------------------------------

% linearOffset_p5 = ref.PHD(hv_op, (Vi_op-Vl_op)/Mv_op);                       % Calculate f(p0) and f'(p0)
% linearSlope_p5 = (ref.PHD(hv_op + delta_X, (Vi_op-Vl_op)/Mv_op) -  ref.PHD(hv_op - delta_X, (Vi_op-Vl_op)/Mv_op) ) / (2*delta_X);  % linearised w. respect to h





