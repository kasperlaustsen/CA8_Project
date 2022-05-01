classdef name < handle
	properties
		% Constants
		THETA_MAX
		INPUT_SCALE_MAX
		K_Val

		% Inputs
% 		pin
% 		hin
% 		mdotin
% 		Theta
		

		% States


		% Outputs
		pout
	end
% %%%EQUATIONS	
% p1	=	p3 - m_dot_3_Con^2/ (Theta_2*(THETA_MAX/INPUT_SCALE_MAX)*K_Val)^2 * rho_CTV %ref.VHP(h4, p3)	; % CTV


	methods
		% Constructor method
		% ---------------------------------
		function obj = name(THETA_MAX,INPUT_SCALE_MAX,K_Val)
			obj.THETA_MAX		= 	THETA_MAX;
			obj.INPUT_SCALE_MAX = 	INPUT_SCALE_MAX;
			obj.K_Val			= 	K_Val;

		end
		% ---------------------------------


		function out = simulate(obj,pin, hin, mdotin, Theta, ref)
			% Update states

			
			% Outputs
			obj.pout	=	pin - mdotin^2/ (Theta*(obj.THETA_MAX/obj.INPUT_SCALE_MAX)*obj.K_Val)^2 * ref.VHP(hin, pin);

			out = 0;
		end
	end
end