classdef boxModel < handle
	properties
		% Constants
		% --------------
		FAN_MAX
		INPUT_SCALE_MAX
		
		Cp_air
		Cp_box
		Cp_cargo

		UA_amb
		UA_ba      
		UA_cargo 
		
		M_air
		M_box
		M_cargo

		% "Internal" variables
		% --------------
		U_star_p
		Q_fan_2
		Q_cool
		Q_amb
		Q_ca
		Q_ba

		% Inputs
		% --------------
% 		U_fan_2
% 		m_dot_air
% 		T_ret
% 		T_sup
% 		T_ambi
		
		% States
		% --------------
		Tair
		Tair_deriv
		Tbox
		Tbox_deriv
		Tcargo
		Tcargo_deriv

		% Outputs
		% --------------
	end

% %%%EQUATIONS	
% U_star_p		= ((U_fan_2*(FAN_MAX/INPUT_SCALE_MAX))*100-55.56)*0.0335 		 					;	% Eva	
% Q_fan_2		= 177.76 + 223.95*U_star_p + 105.85*U_star_p^2 + 16.75*U_star_p^3 	; 	% Eva	
% Q_cool        = Cp_air*m_dot_air *(T_ret - T_sup)                                   ;   % Box
% Q_amb         = (T_ambi - T_box) * UA_amb                                           ;   % Box
% Q_ba          = (T_box - T_air) * UA_ba                                             ;   % Box
% Q_ca          = (T_cargo - T_air) * UA_cargo                                        ;   % Box

% T_air_dot     = (Q_ca + Q_ba + Q_fan_2 - Q_cool ) / (M_air * Cp_air);
% T_box_dot     = (Q_amb - Q_ba ) / (M_box * Cp_box);
% T_cargo_dot   = -Q_ca / (M_cargo * Cp_cargo);

	methods
		% Constructor method
		% ---------------------------------
		function obj = boxModel(FAN_MAX, INPUT_SCALE_MAX, Cp_air, Cp_box, ...
				Cp_cargo, UA_amb, UA_ba, UA_cargo, M_air, M_box, M_cargo)

			obj.FAN_MAX 		= FAN_MAX;		
			obj.INPUT_SCALE_MAX = INPUT_SCALE_MAX;				
			obj.Cp_air 			= Cp_air;	
			obj.Cp_box 			= Cp_box;	
			obj.Cp_cargo 		= Cp_cargo;		
			obj.UA_amb 			= UA_amb;	
			obj.UA_ba      		= UA_ba; 				
			obj.UA_cargo  		= UA_cargo ;		
			obj.M_air 			= M_air;	
			obj.M_box 			= M_box;	
			obj.M_cargo 		= M_cargo;		
			obj.U_star_p		= 0;
			obj.Q_fan_2			= 0;		
			obj.Q_cool			= 0;		
			obj.Q_amb			= 0;		
			obj.Q_ca			= 0;					
			obj.Q_ba			= 0;					

		end
		% ---------------------------------


		function out = simulate(obj, U_fan_2, m_dot_air, T_ret, T_sup, T_ambi, Ts)
			% Internal variables
			obj.U_star_p	= ((U_fan_2*(obj.FAN_MAX/obj.INPUT_SCALE_MAX))*100-55.56)*0.0335 		 		;	% Eva	
			obj.Q_fan_2		= 177.76 + 223.95*obj.U_star_p + 105.85*obj.U_star_p^2 + 16.75*obj.U_star_p^3		; 	% Eva	
			obj.Q_cool      = obj.Cp_air*m_dot_air *(T_ret - T_sup)										;   % Box
			obj.Q_amb       = (T_ambi - T_box)	* obj.UA_amb											;   % Box
			obj.Q_ba        = (T_box - T_air)	* obj.UA_ba												;   % Box
			obj.Q_ca        = (T_cargo - T_air) * obj.UA_cargo											;   % Box
			
			% Update states
			obj.Tair_deriv     = (obj.Q_ca + obj.Q_ba + obj.Q_fan_2 - obj.Q_cool ) / (obj.M_air * obj.Cp_air);
			obj.Tbox_deriv     = (obj.Q_amb - obj.Q_ba ) / (obj.M_box * obj.Cp_box);
			obj.Tcargo_deriv   = -obj.Q_ca / (obj.M_cargo * obj.Cp_cargo);
			
			obj.Tair	= obj.Tair	+ Tair_deriv   * Ts;
			obj.Tbox	= obj.Tbox	+ Tbox_deriv   * Ts;
			obj.Tcarg	= obj.Tcarg + Tcargo_deriv * Ts;
			% Outputs


			out = 0;
		end

		function out = scalein(obj, in)
			% Scale input to between 0 and INPUT_SCALE_MAX
			out = obj.FAN_MAX/obj.INPUT_SCALE_MAX * in;
		end
		
	end
end