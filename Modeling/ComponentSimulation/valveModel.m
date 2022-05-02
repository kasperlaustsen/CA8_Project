classdef valveModel < handle
	properties
		% Constants
		THETA_MAX
		INPUT_SCALE_MAX
		K
		
		ref
		vin
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
		function obj = valveModel(THETA_MAX,INPUT_SCALE_MAX,K,ref)
			obj.THETA_MAX		= 	THETA_MAX;
			obj.INPUT_SCALE_MAX = 	INPUT_SCALE_MAX;
			obj.K				= 	K;
			obj.ref				=	ref;
		end
		% ---------------------------------


		function out = simulate(obj,pin, hin, mdotin, Theta)
			% Update states

			
			% Outputs
			obj.vin		=	obj.ref.VHP(hin, pin*1e-5);
% 			obj.pout	=	pin - mdotin^2/ (Theta*(obj.THETA_MAX/obj.INPUT_SCALE_MAX)*obj.K)^2 * ref.VHP(hin, pin);
			obj.pout	=	pin - (mdotin*abs(mdotin))/ (Theta*(obj.THETA_MAX/obj.INPUT_SCALE_MAX)*obj.K)^2 * obj.vin;

			out = obj.pout;
		end
		
	end
end