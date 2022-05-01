classdef condenserModel < handle
	properties
		% Constants
		Mrinit
		Tminit
		UA_rm
		UA_ma
		V_i_Con
		v_Con
		lambda
		M_m_Con
		Cp_m
		
		% Inputs
% 		hin
% 		mdotin
% 		pout
% 		T_ambi
		
		% StatesT_m
		Mr
		Mr_diriv
		Tm
		Tm_diriv

		% Outputs
		hout
		mdotout
		pin
	end
	
% % % EQUATIONS FROM CONSTRAINTS_FULL_SIMULATION AND COLLECTING_COMPONENTS
% % Q_rm			= 		UA_rm * (T_r - T_m)  												;	% Con	
% % h4				= 		h3 - Q_rm/m_dot_2_COM2 		 										;	% Con
% % m_dot_3_Con		= 		m_dot_2_COM2 + M_Con - V_i_Con/v_Con								;	% Con	- new used
% % p2				= 		p3 - lambda*m_dot_2_COM2 *100000	 								;	% Con
% % Q_ma			= 		UA_ma*(T_m - T_ambi)*(0.05 + U_fan_1*(FAN_MAX/INPUT_SCALE_MAX)*2)  	;	% Con	
% % M_Con_dot		= 		m_dot_2_COM2 - m_dot_3_Con;
% % T_m_dot			= 		(Q_rm - Q_ma)/(M_m_Con * Cp_m);

	methods
		% Constructor method
		% ---------------------------------
		function obj = condenserModel(Mrinit, Tminit, UA_rm, UA_ma, V_i_Con, v_Con, lambda, M_m_Con, Cp_m)
			obj.Mrinit = Mrinit;
			obj.Tminit = Tminit;
			obj.Mr = Mrinit;
			obj.Tm = Tminit;
			
			obj.UA_rm	= UA_rm;
			obj.UA_ma	= UA_ma;
			obj.V_i_Con = V_i_Con;
			obj.v_Con	= v_Con;		%	 could be exchanged with a table lookup?
			obj.lambda	= lambda;
			obj.M_m_Con = M_m_Con;
			obj.Cp_m	= Cp_m;
		

		end
		% ---------------------------------


		function out = simulate(obj, mdotin, hin, pout,	T_r, T_ambi, U_fan,FAN_MAX,INPUT_SCALE_MAX,	Ts,	ref)
% 			v_Con = ref.VHP(hin,pin)
			Q_rm		=	obj.UA_rm * (T_r - obj.Tm);	
			obj.hout	= 	hin - Q_rm/mdotin;
			obj.mdotout	= 	mdotin + obj.Mr - obj.V_i_Con/obj.v_Con;	% Con	- new used
			obj.pin		= 	pout - obj.lambda*mdotin * 1e5;
			Q_ma		= 	obj.UA_ma*(obj.Tm - T_ambi)*(0.05 + U_fan*(FAN_MAX/INPUT_SCALE_MAX)*2)  	;	% Con	
			

			% Update states
			obj.Mr_diriv	= 	mdotin - obj.mdotout;
			obj.Tm_diriv	= 	(Q_rm - Q_ma)/(obj.M_m_Con * obj.Cp_m);
			
			obj.Mr			= obj.Mr + obj.Mr_diriv * Ts;
			obj.Tm			= obj.Tm + obj.Tm_diriv * Ts;

			% Outputs
			out = [obj.hout obj.mdotout obj.pin obj.Mr obj.Tm];
		end
	end
end