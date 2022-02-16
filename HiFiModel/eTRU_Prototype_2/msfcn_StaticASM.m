function msfcn_StaticASM(block)
% Level-2 MATLAB file S-Function.
% Static model of asynchronous motor that based on motor voltage (u)
% frequency (f) and load calculates motor phase current (Iphase) motor
% speed and powerfactor (PF).
% Created 15/7 -20 hjn
   setup(block);
%endfunction

function SetInputPortSamplingMode(s, port, mode)
   s.InputPort(port).SamplingMode = mode;
%endfunction

function setup(block)
  %% Register number of input and output ports
  block.NumInputPorts  = 3;
  block.NumOutputPorts = 1;
  block.NumDialogPrms  = 1;
  
  block.OutputPort(1).Dimensions       = 1;
  block.OutputPort(1).DatatypeID  = 0; % double
  block.OutputPort(1).Complexity  = 'Real';
  block.OutputPort(1).SamplingMode = 'sample';
   
  block.InputPort(1).DirectFeedthrough = true;
  block.InputPort(2).DirectFeedthrough = true;
  
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Run accelerator on TLC
  block.SetAccelRunOnTLC(true);
  
  %% Register methods
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
%endfunction

function Output(block)
  % Convert from Simulink interface signal to "real" values
  U = block.InputPort(1).Data;  % [Vrms fase-0] Motor voltage
  f = block.InputPort(2).Data;  % [Hz] Stator frequency
  Load = block.InputPort(3).Data; % [Nm]
  asm = block.DialogPrm(1).Data; % [-] struct with motor data
  
  Wslip = Load/asm.nom.Torque*asm.nom.wSlipNom;
  if  Wslip == 0
      Wslip = 0.01;  % Avoid divide by zero
  end
  Ws = 2*pi*f;
  if (Ws < 1)       % Motor stopped, avoid divide by zero
      Slip = 0;
      Iphase = 0;
      Pin = 0;
      Prs = 0;
      Prr = 0;  
      Prfe = 0;
  else
    Slip = Wslip/Ws;
    Zs = asm.nom.Rs + 1i*Ws*asm.nom.Lsl;
    Zr1 = asm.nom.Rr/Slip + 1i*Ws*asm.nom.Lrl;
    Zlh = 1i*Ws*asm.nom.Lh;
    Zr2 = Zr1 * Zlh/(Zr1 + Zlh);
    Zr3 = asm.nom.Rfe * Zr2 /(asm.nom.Rfe + Zr2);
 % Speed = (Ws - Wslip)/(2*pi)*60/asm.nom.Zpp;
    if asm.nom.Rfe < 1      % Rfe < 1 => Rfe unknown
        I = U/(Zs+Zr2);
    else
        I = U/(Zs+Zr3);
    end

    Uq = U - Zs*I;          % voltage across mains inductance
    if asm.nom.Rfe < 1      % Rfe < 1 => Rfe unknown
        Prfe = 0;
    else
        Prfe = abs(Uq)*abs(Uq)/asm.nom.Rfe;       % [W] Iron losses
    end
    Iphase = abs(I);
    Prs = asm.nom.Rs*Iphase*Iphase;       % [W] Stator losses
    Irotor = Uq/Zr1;
    Prr = asm.nom.Rr*abs(Irotor)*abs(Irotor); % [W] Rotor losses
    Pin = Prs + Prfe + Prr + Load*(Ws)/asm.nom.Zpp; % Wslip removed to get accurate shaft power
  end
  % Send outputs to simulink
  block.OutputPort(1).Data = Iphase;            % [Arms] Motor phase current 
%endfunction

