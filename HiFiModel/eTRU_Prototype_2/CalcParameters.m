% Calculate derived motor parameters from basic motor data in asm.nom struct
% Created : 7/1-09 HJN

% Calculated motor parameters and constants
asm.nom.Ls = asm.nom.Lh + asm.nom.Lsl;
asm.nom.Lr = asm.nom.Lh + asm.nom.Lrl;
asm.nom.sigma = 1 - asm.nom.Lh^2/(asm.nom.Lr*asm.nom.Ls);
asm.nom.Ts = asm.nom.Ls/asm.nom.Rs;
asm.nom.Tr = asm.nom.Lr/asm.nom.Rr;
asm.nom.UsyNom = asm.nom.Voltage/sqrt(3)*sqrt(2)*1.5;
asm.nom.WsNom = 2*pi*asm.nom.Frequency;
asm.nom.Wslip = asm.nom.WsNom - asm.nom.Speed/60*asm.nom.Zpp*2*pi;
asm.nom.Pin = (3*asm.nom.Rs*asm.nom.Current*asm.nom.Current+asm.nom.Power*asm.nom.WsNom/(asm.nom.WsNom-asm.nom.Wslip));
asm.nom.IsyNom = 1.5*asm.nom.Pin/asm.nom.UsyNom;
asm.nom.Imset = (asm.nom.UsyNom-asm.nom.Rs*asm.nom.Current)/(asm.nom.WsNom*asm.nom.Ls);
asm.nom.wSlipNom = (asm.nom.Frequency-asm.nom.Speed*asm.nom.Zpp/60)*2*pi; % Rated slip [rad/s] 
asm.nom.Torque = asm.nom.Zpp*asm.nom.Power/(asm.nom.WsNom-asm.nom.wSlipNom);	% [Nm] Rated motor torque
asm.nom.psiNom   = asm.nom.Voltage*sqrt(2.0/3.0)/(asm.nom.Frequency*2*pi);      %  Rated flux (dq)
asm.nom.UfGain = 1.025*1.5*(asm.nom.Voltage/sqrt(3) - asm.nom.Rs*asm.nom.Current)*sqrt(2)/asm.nom.WsNom;
asm.nom.UfOffset = 1.5* sqrt(2)* asm.nom.Rs*asm.nom.Current;
