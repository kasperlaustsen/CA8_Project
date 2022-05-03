classdef valveModel < handle
	properties
		% Constants
		% --------------
		K		% Valve constant

		THETA_MAX
		INPUT_SCALE_MAX
		
		ref		% Coolprop Wrapper object input
		
		% "Internal variables"
		% --------------
		v		% Specific enthalpy

		% Inputs
		% --------------
% 		pin
% 		hin
% 		mdotin
% 		Theta
		
		% Outputs
		% --------------
		pout
	end

	methods
		% Constructor method
		% ---------------------------------
		function obj = valveModel(THETA_MAX,INPUT_SCALE_MAX,K,ref)
			obj.K				= 	K;

			obj.THETA_MAX		= 	THETA_MAX;
			obj.INPUT_SCALE_MAX = 	INPUT_SCALE_MAX;

			obj.ref				=	ref;
		end
		% ---------------------------------


		function out = simulate(obj, pin, hin, mdotin, Theta)
			% Outputs
			obj.v	 =	obj.vhplut(hin, pin*1e-5);
			obj.pout =	pin - (mdotin*abs(mdotin))/(scalein(Theta)*obj.K)^2 * obj.v;

			out		 = obj.pout;
		end
		
		function v = vhplut(obj, h, p)
			% Specific volume lut from specific enthalpy and pressure
			v = obj.ref.VHP(h, p*1e-5);
		end
		
	end

	methods (Access = private)
		function out = scalein(obj, in)
			out = obj.THETA_MAX/obj.INPUT_SCALE_MAX * in;
		end

	end
end