function x = system_monitor(t,x,u,p)
persistent D % Struct for use with MPC controller from MaCHIL
global Ref

evap_psuc = u(1);
evap_Tsuc = u(2);
econ_psuc = u(3);
econ_Tsuc = u(4);
pdis      = u(5);
hdis      = u(6);
Tret      = u(7);
Tsup1     = u(8);
Tsup2     = u(9);
Tcargo    = u(10);
Tfc       = u(11);
Tamb      = u(12);
Tset      = u(13);
RH        = u(14);
Mevap     = u(15);


% Calculate the cooling capacity based on the air temperatures and flow
D.Tret = Tret;
D.Tsup = (Tsup1+Tsup2)/2;
D.Tsup1 = Tsup1;
D.Tsup2 = Tsup2;
D.Tamb = Tamb;
D.MevapAct = Mevap;
D.RH = RH;
D.T0 = Ref.TDewP(evap_psuc);
D = getCoolingCap(D);

% Calculate the superheat
Tsh = evap_Tsuc - Ref.TDewP(evap_psuc);

x = [D.Q_cool_air D.Q_cond_water D.Q_amb Tsh]'; 

