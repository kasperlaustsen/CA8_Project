function D = CalculateTsup_subst(D)
  
global Ridx
% Comensate for pressure drop dependence on cooling capacity (cpr speed). 
% A more accurate pressure model would improve results.    
dp_const_vexp = 0; % Full speed range pressure compensation for expansion valve
dt_const_cpr = 0;  % Full speed range temperature compensation for compressor

dt_cpr = dt_const_cpr * D.FcprAct/110;
dp_vexp = dp_const_vexp * LimitSignal(D.FcprAct, [0 70])/110; 
  
P_cpr = PDewT(Ridx, D.Tret - dt_cpr); 
P_vexp = PDewT(Ridx, D.Tret) - dp_vexp; 

% Calculate the compressor mass flow.
cprpoly = [0.024758845397019  -0.000410714195467];
m_dot_fcpr = (cprpoly(1)*P_cpr + cprpoly(2)) * D.FcprAct/50;

% Calculate the specific volume of the refrigerant before the expansion
% valve. 
vpoly = [ -0.000000000083062481   0.000000005586158757  -0.000000147138845584   0.000001930615153995  -0.000013349523114061   0.000059382509766808   0.000676613497662099];
Vin_be = vpoly(1)*D.Pdis^6 + vpoly(2)*D.Pdis^5 + vpoly(3)*D.Pdis^4 + vpoly(4)*D.Pdis^3 + vpoly(5)*D.Pdis^2 + vpoly(6)*D.Pdis + vpoly(7);

% Calculate the expansion valve mass flow
vexp_const = 0.84e-5; % [kg/s]
m_dot_vexp = D.Vexp * vexp_const * sqrt(2/Vin_be*(D.Pdis - P_vexp));

% Calculate the compressor reliability
mdot_diff = m_dot_vexp - m_dot_fcpr;
mdot_avg = (m_dot_vexp + m_dot_fcpr)/2;
mdot_avg_scale = 0.25;

X = LimitSignal((0.005 + mdot_avg*mdot_avg_scale)/abs(mdot_diff), [0 1])^2;

% Plot variables (MaSCHIL specific)
addCtrlVar('X', X, 1, 10, 0)
%addCtrlVar('MdotFcpr', m_dot_fcpr, 1, 1000, 0)
%addCtrlVar('MdotVexp', m_dot_vexp, 1, 1000, 0)


% Create A matrix
A = [0                          1/(1+(D.Tsup1-D.Tsup2)^2)      1/(1+(D.Tsup1-D.Tsup_calc)^2); 
     1/(1+(D.Tsup2-D.Tsup1)^2)      0                          1/(1+(D.Tsup2-D.Tsup_calc)^2); 
     1/(1+(D.Tsup_calc-D.Tsup1)^2)  1/(1+(D.Tsup_calc-D.Tsup2)^2)  1 ];
  
% Create B matrix
B = [D.Tsup1 D.Tsup2 D.Tsup_calc];

% D Matrix
Dm = [1 0 0;
      0 1 0
      0 0 X];
   
% Calculate the normalized errors for the sensors
e = [1 1 1]*(A*Dm);
e = e/sum(e);

% Plot the errors
%addCtrlVar('e1', e(1), 1, 100, 0)
%addCtrlVar('e2', e(2), 1, 100, 0)
%addCtrlVar('e3', e(3), 1, 100, 0)

% Reset Cusum at startup
if(~isfield(D, 'TsupCusum') || D.t == 1)
  D.TsupCusum = [0 0 0];  
end

% Error limits 
e_limits = [0.15 0.15 0.2];
% Cucum limits
c_limits = [60 60 300];

% Handle the cusums
for(k=1:3)
  if(e(k) < e_limits(k))
    if(D.TsupCusum(k) < c_limits(k))
      D.TsupCusum(k) = D.TsupCusum(k) + 1;
    end
  else
    D.TsupCusum(k) = 0;
  end
end

% Plot the cusum sums
%addCtrlVar('c1', D.TsupCusum(1), 1, 0.1, 0)
%addCtrlVar('c2', D.TsupCusum(2), 1, 0.1, 0)
%addCtrlVar('c3', D.TsupCusum(3), 1, 0.1, 0)

% Get the weights 
Weights = [1 1 1] * (A*Dm);
% Dot product of the weights for Tsup1 and Tsup2 and Tsup1 and Tsup2
% divided by the sum of the weights. Essentially a weighted average. 
D.Tsup_subst = sum([D.Tsup1 D.Tsup2].*Weights(1:2))/sum(Weights(1:2));
