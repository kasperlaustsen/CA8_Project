function [fcpr vexp veco mcond mevap intg_vexp intg_cpr Hevap Q_ref Q_int fcpr_off_counter dummy1 dummy2 dummy3] = CopyVarsFromD(D)

fcpr = D.Fcpr;
vexp = D.Vexp;
veco = D.Veco;
mcond = D.Mcond;
mevap = D.Mevap;
intg_vexp = D.intg_vexp;
intg_cpr = D.intg_cpr;
Hevap = D.Hevap;
Q_ref = D.Q_ref;
Q_int = D.Q_int;
fcpr_off_counter = D.fcpr_off_counter;
dummy1 = D.Q_cool_req;
dummy2 = D.QCoolAct;
dummy3 = D.TcargoEst;