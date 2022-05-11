% Symbolic variable definitions
% ========================================================================


% general interface variables
syms h [1 7]
syms p [1 5]
syms T [1 7]
syms m_dot_1 m_dot_2 m_dot_4 m_dot_5  

% variables in f
syms M_PJJ M_Con T_m Q_rm Q_ma  Cp_m m_dot_air m_dot_bar_air T_mlv Q_amlv 
syms Q_mlv Q_mvmlv sigma T_mv Q_amv Q_mv M_lv M_v m_dot_dew 

% pipe joining junction
syms % m_dot_2_PJJ

% compressor 2
syms V_1_COM2 V_C_COM2 v_1_COM2 v_2_COM2 omega p_i1_COM2 p_i2_COM2 gamma 
syms kl_1 kl_2 C_cp C_cvhtp syms  gamma2 %m_dot_2_COM2

% compressor 1
syms V_1_COM1 V_C_COM1 v_1_COM1 v_2_COM1 omega p_i1_COM1 p_i2_COM1 gamma 
syms kl_1 kl_2 C_cp C_cv gamma1

% condenser
syms Q_rm lambda M_Con M_m_Con V_i_Con v_Con UA_rm T_r T_m UA_ma T_ambi 
syms U_fan_1 %m_dot_3_Con	

% valve
syms Theta_1 Theta_2 K_Val v_CTV_in v_EV_in fp
syms % m_dot_3_Val m_dot_5_Val

% flash tank
syms N M 

% evaporator 
syms sigma v_Eva V_i_Eva T_retfan T_ret Q_fan_2 m_dot_air Cp_air T_retsh 
syms U_fan_2 U_star_P U_star_m_dot 
syms V_dot_bar_air rho_air UA_1 UA_2 UA_3 T_lv Pi V_lv h_lv h_dew m_dot_dew 
syms T_sup M_m_Eva m_bar_dot_air

% box
syms T_air Q_ca Q_ba Q_cool M_air 
syms T_box Q_amb M_box Cp_box
syms T_cargo M_cargo Cp_cargo
syms T_ambi UA_amb UA_ba UA_cargo T_v