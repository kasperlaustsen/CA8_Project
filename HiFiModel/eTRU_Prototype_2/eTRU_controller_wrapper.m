function out = eTRU_controller_wrapper(in)



% Get inputs ref_lines are [p, h, T, Phi, mdot]
% Condout
% Pcondout = in(1);
% Hcondout = in(2);
Tcondout = in(3);

% FT liquid
Pft_liq = in(6);
% Hft_liq = in(7);
% Tft_liq = in(8);

% Discharge
Pdis = in(11);
% Hdis = in(12);
% Tdis = in(13);

% Intermediate
% Pim = in(16);
% Him = in(17);
% Tim = in(18);

% Suction
Psuc = in(21);
% Hsuc = in(22);
% Tsuc_vapor = in(23);

% Tcargo = in(26)-273.15;
Tamb = in(27)-273.15;

Tsuc = in(28)-273.15;

% Tret_bf = in(29)-273.15;
Tret = in(30)-273.15;
Tsup = in(31)-273.15;


out = eTRU_controller([Tcondout, Pft_liq, Pdis, Psuc, Tamb, Tsuc, Tret, Tsup]);