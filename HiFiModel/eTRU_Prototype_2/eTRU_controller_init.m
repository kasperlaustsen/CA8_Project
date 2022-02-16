global eTRU_ctrl

eTRU_ctrl.fcpr_pid = PIDController();
eTRU_ctrl.vexp_pid = PIDController();
eTRU_ctrl.vcond_pid = PIDController();

eTRU_ctrl.fcpr_pid.SetKd(0);
eTRU_ctrl.fcpr_pid.SetKe(-1);
eTRU_ctrl.fcpr_pid.SetKf(0);
eTRU_ctrl.fcpr_pid.SetKp(5);
eTRU_ctrl.fcpr_pid.SetTaui(20);
eTRU_ctrl.fcpr_pid.SetOutputLimits(0, 100);

eTRU_ctrl.vexp_pid.SetKd(-2); %-2;
eTRU_ctrl.vexp_pid.SetKe(-1);
eTRU_ctrl.vexp_pid.SetTaud(3);
eTRU_ctrl.vexp_pid.SetKf(0.5);
eTRU_ctrl.vexp_pid.SetKp(2);
eTRU_ctrl.vexp_pid.SetTaui(50);
eTRU_ctrl.vexp_pid.SetOutputLimits(0, 100);

eTRU_ctrl.vcond_pid.SetKd(0);
eTRU_ctrl.vcond_pid.SetKf(0.5);
eTRU_ctrl.vcond_pid.SetKp(3);
eTRU_ctrl.vcond_pid.SetTaui(30);
eTRU_ctrl.vcond_pid.SetOutputLimits(5, 100);

eTRU_ctrl.init_sim = 1;
eTRU_ctrl.sim_time = 0;
eTRU_ctrl.cpr_run_time = 0;
eTRU_ctrl.cpr_stop_time = 0;
eTRU_ctrl.cpr_restart_timer = 0;
eTRU_ctrl.cpr_state = 0;
eTRU_ctrl.cpr_speed_act = 0;
eTRU_ctrl.vexp_gain = eTRU_ctrl.vexp_pid.Kp;
eTRU_ctrl.Tsh_ref = 5;