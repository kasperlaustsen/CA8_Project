classdef condenserModel < handle
	properties
		% Constants
		% --------------
		Mrinit				% [] 
		Tminit				% [] 
		UArm				% [] 
		UAma				% [] 
		Vi					% [] 

		% "Internal" variables
		% --------------
		v					% [] 
		lambda				% [] 
		Mm					% [] 
		Cpm					% [] 
		FAN_MAX				% [] 
		INPUT_SCALE_MAX		% [] 
		Qrm					% []
		Qma					% []
		ref 
		% Inputs
		% --------------
% 		hin
% 		mdotin
% 		pout
% 		T_ambi
		
		% States
		% --------------
		Mr					% [] 
		Mrdiriv				% [] 
		Tm					% [] 
		Tmdiriv				% [] 

		% Outputs
		% --------------
		hout				% [J/kg] 
		mdotout				% [] 
		pin					% [] 
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
		function obj = condenserModel(Mrinit, Tminit, UArm, UAma, Vi, lambda, ...
				Mm, Cpm, ref, FAN_MAX, INPUT_SCALE_MAX)
			obj.Mrinit = Mrinit;
			obj.Tminit = Tminit;
			obj.Mr = Mrinit;
			obj.Tm = Tminit;
			
			obj.UArm	= UArm;
			obj.UAma	= UAma;
			obj.Vi = Vi;
			obj.lambda	= lambda;
			obj.Mm = Mm;
			obj.Cpm	= Cpm;
			obj.FAN_MAX = FAN_MAX;
			obj.INPUT_SCALE_MAX = INPUT_SCALE_MAX;
			obj.Qma = 0;
			obj.Qrm = 0;
			obj.ref = ref;

		end
		% ---------------------------------


		function out = simulate(obj, mdotin, hin, pout,	Tr, Tambi, Ufan, Ts)
			obj.pin		= 	pout - obj.lambda*mdotin * 1e5;
			obj.v		=	obj.ref.VHP(hin,obj.pin);
			obj.Qrm		=	obj.UArm * (Tr - obj.Tm);	
			obj.hout	= 	hin - obj.Qrm/mdotin;
			obj.mdotout	= 	mdotin + obj.Mr - obj.Vi/obj.v;	% Con	- new used
			obj.Qma		= 	obj.UAma*(obj.Tm - Tambi)*(0.05 + obj.scalein(Ufan)*2);	% Con	

			% Update states
			obj.Mrdiriv	= 	mdotin - obj.mdotout;
			obj.Tmdiriv	= 	(obj.Qrm - obj.Qma)/(obj.Mm * obj.Cpm);
			
			obj.Mr			= obj.Mr + obj.Mrdiriv * Ts;
			obj.Tm			= obj.Tm + obj.Tmdiriv * Ts;

			% Outputs
			out = [obj.hout obj.mdotout obj.pin obj.Mr obj.Tm];
		end

		function out = scalein(obj, in)
			% Scale input to between 0 and INPUT_SCALE_MAX
			out = obj.FAN_MAX/obj.INPUT_SCALE_MAX * in;
		end
	end
end