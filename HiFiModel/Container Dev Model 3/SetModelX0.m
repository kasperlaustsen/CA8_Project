function model = SetModelX0_unified_cond_recv(model, Tamb, Tset)

global Ref
disp('Container dev model 2 init func')
T0 = Tset-2;
P0 = Ref.PDewT(T0);
hDew = Ref.HDewT(Tset)+5000;
hBub = Ref.HBubT(Tset-2)+8000;
Pdis = Ref.PDewT(Tamb+11);
Pim = sqrt(Pdis+P0);

model.X0(getAbsStateIndex(model, 'cond_recv.Tm')) = Tamb+5;
model.X0(getAbsStateIndex(model, 'cond_recv.hrefrig')) = Ref.HBubT(Tamb+5);
model.X0(getAbsStateIndex(model, 'cond_recv.pout')) = Pdis;
model.X0(getAbsStateIndex(model, 'cond_recv.pin')) = Pdis;
model.X0(getAbsStateIndex(model, 'box.Talu')) = Tset-1;
model.X0(getAbsStateIndex(model, 'box.Tcargo')) = Tset;
model.X0(getAbsStateIndex(model, 'box.Tret')) = Tset;
model.X0(getAbsStateIndex(model, 'ctrl.Tset')) = Tset;
model.X0(getAbsStateIndex(model, 'ctrl.Tamb')) = Tamb;
model.X0(getAbsStateIndex(model, 'evap.Tsup')) = Tset-1;
model.X0(getAbsStateIndex(model, 'evap.Tevap')) = Tset;
model.X0(getAbsStateIndex(model, 'evap.T0')) = T0;
model.X0(getAbsStateIndex(model, 'evap.Tsuc')) = Tset;
model.X0(getAbsStateIndex(model, 'evap.Tretm')) = Tset+1;
model.X0(getAbsStateIndex(model, 'evap.Tsupm1')) = Tset-1;
model.X0(getAbsStateIndex(model, 'evap.Tsupm2')) = Tset-1;
model.X0(getAbsStateIndex(model, 'evap.Tm1')) = Tset-1;
model.X0(getAbsStateIndex(model, 'evap.Tm2')) = Tset-1;
model.X0(getAbsStateIndex(model, 'evap.pout')) = P0;
model.X0(getAbsStateIndex(model, 'evap.hout')) = hDew;
model.X0(getAbsStateIndex(model, 'evap.h1')) = hBub;

model.X0(getAbsStateIndex(model, 'cpr.pim')) = Pim;



