function [Fcpr Vexp Veco Mcond Mevap Hevap Tamb] = LogDataController(t)
global ld
%global LogData
%global Sample
%global model
%global MaSCHIL_path

if(t == 1)
  %LogDataTemp = LogData;
  DataFile = 'cap_ctrl_steps_MCI_021009.mat'
  %DataFile = ['"' MaSCHIL_path 'data\cap_ctrl_steps_MCI_021009.mat"']
  load(DataFile)
  ld = LogData;
  %LogData = LogDataTemp;
end

Tstart = 90000;
Sample = t;
%ld.SampleValues(getLogDataIndex(ld, 'Fcpr'),Sample+Tstart+1800)
%ld.SampleValues(1,Tstart+1800:Tstart+5000)

%Get the control signals
Fcpr = ld.SampleValues(getLogDataIndex(ld, 'Fcpr'),Sample+Tstart);
Vexp = ld.SampleValues(getLogDataIndex(ld, 'Vexp'),Sample+Tstart);
Veco = ld.SampleValues(getLogDataIndex(ld, 'Veco'),Sample+Tstart);
%D.Vhg = ld.SampleValues(getLogDataIndex(ld, 'Vhg'),Sample+Tstart);
Mcond = ld.SampleValues(getLogDataIndex(ld, 'Mcond'),Sample+Tstart);
Mevap = ld.SampleValues(getLogDataIndex(ld, 'Mevap'),Sample+Tstart);
Hevap = ld.SampleValues(getLogDataIndex(ld, 'Hevap'),Sample+Tstart);


% Insert the measure Tamb in the model
if(1)
  Tamb = ld.SampleValues(getLogDataIndex(ld, 'Tamb'),Sample+Tstart);  
end

if(0)
  Q_cool_req = ld.SampleValues(getLogDataIndex(ld, 'QCoolReq'),Sample+Tstart);
  Q_cool_ref = ld.SampleValues(getLogDataIndex(ld, 'QCoolRef'),Sample+Tstart);
  QCoolAct = ld.SampleValues(getLogDataIndex(ld, 'QCoolAct'),Sample+Tstart);
  TSH = ld.SampleValues(getLogDataIndex(ld, 'TSH'),Sample+Tstart);
  Tret = ld.SampleValues(getLogDataIndex(ld, 'Tret'),Sample+Tstart);
  Tsup = ld.SampleValues(getLogDataIndex(ld, 'Tsup1'),Sample+Tstart);
  Tsuc = ld.SampleValues(getLogDataIndex(ld, 'Tsuc'),Sample+Tstart);
  T0 = ld.SampleValues(getLogDataIndex(ld, 'T0'),Sample+Tstart);
  Pdis = ld.SampleValues(getLogDataIndex(ld, 'Pdis'),Sample+Tstart);
  Tusda1 = ld.SampleValues(getLogDataIndex(ld, 'Tusda1'),Sample+Tstart);
  Tusda2 = ld.SampleValues(getLogDataIndex(ld, 'Tusda2'),Sample+Tstart);
  Tusda3 = ld.SampleValues(getLogDataIndex(ld, 'Tusda3'),Sample+Tstart);
  Tusda4 = ld.SampleValues(getLogDataIndex(ld, 'Tusda4'),Sample+Tstart);
  
  addCtrlVar('QCoolRef', Q_cool_ref, 1, 0.01, 0);
  addCtrlVar('QCoolReq', Q_cool_req, 1, 0.01, 0);
  addCtrlVar('QCoolActM', QCoolAct, 1, 0.01, 0);
  addCtrlVar('TSHM', TSH, 1, 1, 0);
  addCtrlVar('TretM', Tret, 1, 1, 0);
  addCtrlVar('TsupM', Tsup, 1, 1, 0);
  addCtrlVar('T0M', T0, 1, 1, 0);
  addCtrlVar('TsucM', Tsuc, 1, 1, 0);
  addCtrlVar('PdisM', Pdis, 1, 1, 0);
  addCtrlVar('Tusda1', Tusda1, 1, 1, 0);
  addCtrlVar('Tusda2', Tusda2, 1, 1, 0);
  addCtrlVar('Tusda3', Tusda3, 1, 1, 0);
  addCtrlVar('Tusda4', Tusda4, 1, 1, 0);
  
end
% D.Fcpr