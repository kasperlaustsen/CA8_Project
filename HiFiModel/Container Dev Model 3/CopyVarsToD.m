function D = CopyVarsToD(D, evap_T0, evap_psuc, evap_Tsuc, econ_psuc, econ_Tsuc, pdis, ...
      Tamb, Tsup, Tret, Tset, intg_vexp, intg_cpr, mcond, mcond_cont, ...
      Hevap, fcpr_old, t, mevap, Q_ref, Q_int, fcpr_off_counter, Tcargo, ...
      Talu, RH, ctrl_mode)
    
    D.T0 = evap_T0;
    D.Psuc = evap_psuc;
    D.Tsuc = evap_Tsuc;
    D.econ_Psuc = econ_psuc;
    D.econ_Tsuc = econ_Tsuc;
    D.Pdis = pdis;
    D.Tamb = Tamb;
    D.Tsup = Tsup;
    D.Tsup1 = Tsup;
    D.Tsup2 = Tsup;
    D.Tret = Tret;
    D.Tset = Tset;
    D.intg_vexp = intg_vexp;
    D.intg_cpr = intg_cpr;
    D.McondAct = mcond;
    D.mcond_cont = mcond_cont;
    D.Hevap = Hevap;
    D.FcprAct = fcpr_old;
    D.t = t;
    D.MevapAct = mevap;
    D.Q_ref = Q_ref;
    D.Q_int = Q_int;
    D.fcpr_off_counter = fcpr_off_counter;
    D.Tcargo = Tcargo;
    D.Talu = Talu;
    D.RH = RH;
    D.ctrl_mode = ctrl_mode;