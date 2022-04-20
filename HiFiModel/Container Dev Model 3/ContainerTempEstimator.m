function D = ContainerTempEstimator(D)

% Constants, from www.maerskbox.com
alfa   = 41.84;    % Ambient to box 40.5 [(j/s)/k], [w/k]
alfa_cargo = 1000;
alfa_alu = 1500;
Vbox   = 67.88;    % m^3
Cp_alu = 900;      % [J/(kg*K)]
Cp_steel = 500;
Cp_air = 1.0035e3; % [J/(kg*K)]
Cp_cargo = 5044;   % [J/(kg*K)] (Pork)
M_alu   = 460 + 82;     % [kg]
M_steel = 282;
m_alu = 879;
m_cargo = 20000;     % [kg] Maximum allowed mass is 30k kg

if(~isfield(D, 'TcargoEst'))
  D.TcargoEst = D.Tret;
end
if(~isfield(D, 'TairEst'))
  D.TairEst = D.Tret;
end
if(~isfield(D, 'TaluEst'))
  D.TaluEst = D.Tret;
end
if(~isfield(D, 'MevapCounter'))
  D.MevapCounter = 0;
end
if(~isfield(D, 'MeasConfidence'))
  D.MeasConfidence = 0;
end

if(D.t == 1)
  D.TairEst = D.Tset;
  D.TaluEst = D.Tset;
  D.TcargoEst = D.Tset;
end

D.MeasConfidence = 0;
if(D.MevapAct > 0)
  D.MevapCounter = LimitSignal(D.MevapCounter + 1, [0 150]);
  % If the evap fan has been running for more than two minutes the
  % measurement is good
  if(D.MevapCounter > 120)
    D.MeasConfidence = 1;
  end
else
  D.MevapCounter = LimitSignal(D.MevapCounter - 0.1, [0 150]);
%   if(D.MevapCounter <= 140)
%     D.MeasConfidence = 0;
%   end
end

rho_air = 1.3 + D.TairEst * -0.005;     % [kg/m^3]
m_air = Vbox*rho_air; % [kg]


if(D.MeasConfidence == 1)
  D.TairEst = real(D.TairEst + 0.1*(D.Tret-D.TairEst));
  QambToalu = (D.Tamb - D.TaluEst)*alfa*0.19; % 0.19 of the box surface area is the aluminum T-profile floor
  QcargoToair = (D.TcargoEst-D.TairEst)*alfa_cargo;
  QaluToair = (D.TaluEst-(D.TairEst+D.Tsup1)/2)*alfa_alu;
  
  D.TaluEst = real(D.TaluEst + (QambToalu-QaluToair)/(Cp_alu*m_alu));
  D.TcargoEst = real(D.TcargoEst - QcargoToair/(Cp_cargo*m_cargo));
%   D.TcargoEst = D.Tret;
else % If the measurement is bad we only use the model
  QambToair = (D.Tamb - D.TairEst)*alfa*0.81; % 0.81 of the box surface area is normal wall
  QambToalu = (D.Tamb - D.TaluEst)*alfa*0.19; % 0.19 of the box surface area is the aluminum T-profile floor
  QcargoToair = (D.TcargoEst-D.TairEst)*alfa_cargo;
  QaluToair = (D.TaluEst-D.TairEst)*alfa_alu;
  
  D.TairEst = D.TairEst + (QaluToair + QcargoToair + QambToair)/(Cp_air*m_air);
  D.TaluEst = D.TaluEst + (QambToalu-QaluToair)/(Cp_alu*m_alu);
  D.TcargoEst = D.TcargoEst - QcargoToair/(Cp_cargo*m_cargo);  
end










