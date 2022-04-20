function Tsup = CalculateTsup(Tsup1, Tsup2, Tsup_calc, Fcpr, Vexp, Tret, Pdis)

% Create A matrix
A = [0                          1/(1+(Tsup1-Tsup2)^2)      1/(1+(Tsup1-Tsup_calc)^2); 
     1/(1+(Tsup2-Tsup1)^2)      0                          1/(1+(Tsup2-Tsup_calc)^2); 
     1/(1+(Tsup_calc-Tsup1)^2)  1/(1+(Tsup_calc-Tsup2)^2)  1 ];
   
   
% Create B matrix
B = [Tsup1;
     Tsup2;
     Tsup_calc];
   
% X weight that indicates how good the Tsup_calc value is
P_Tret = PDewT(Tret);

cprpoly = [ 0.025650216921242  -0.005438535900323];

m_dot_fcpr = (cprpoly(1)*P_Tret + cprpoly(2)) * Fcpr/50;

vexp_const = 0.84e-5; % [kg/s]
% Vin_be = getRefrigSpecVol(hin,pin);
% if(pin > pout) % Check for negative pressure over the expansion valve
%   mdotref = vexp * sqrt(2*1/Vin_be*(pin-pout)) * vexp_const;
% else
%   mdotref = 0;
% end

%vpoly = 1.0e-003 * [  -0.000004789187229   0.000160210643980  -0.002096139295352   0.013623631291752  -0.046723284893519   0.098339445512784   0.664080899574507];
vpoly = [-0.000000004789187229   0.000000160210643980  -0.000002096139295352   0.000013623631291752  -0.000046723284893519   0.000098339445512784   0.000664080899574507];

Vin_be = vpoly(1)*P_Tret^6 + vpoly(2)*P_Tret^5 + vpoly(3)*P_Tret^4 + vpoly(4)*P_Tret^3 + vpoly(5)*P_Tret^2 + vpoly(6)*P_Tret + vpoly(7);

m_dot_vexp = Vexp * vexp_const * sqrt(2/Vin_be*(Pdis - P_Tret));

X = 1/((m_dot_fcpr)/(m_dot_vexp))^2;
addCtrlVar('X', X, 1, 10, 0)
   
% D Matrix
D = [1 0 0;
     0 1 0
     0 0 X];
   
c = A*D*B;
   
Tsup = sum(c)/sum(A*D*[1 1 1]');