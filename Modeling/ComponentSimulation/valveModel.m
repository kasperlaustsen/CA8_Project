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


		function [vars, out] = simulate(obj, pin, hin, mdotin, Theta)
			% Outputs
			obj.v	 =	obj.vhplut(hin, pin);
			tempmdot	= (mdotin*abs(mdotin));
			tempThetaK = 1/(obj.scalein(Theta)*obj.K)^2;
			obj.pout =	pin - (mdotin*abs(mdotin)) * 1/(obj.scalein(Theta)*obj.K)^2 * obj.v;

			out		 = obj.pout;
			vars	 = [obj.v, tempmdot, tempThetaK];
		end
		
		function v = vhplut(obj, h, p)
			% Specific volume lut from specific enthalpy and pressure
			v = obj.ref.VHP(h, p*1e-5);
		end
		
	end

	methods (Access = private)
		function out = scalein(obj, in)
% 			m = 0.0461512;
% 			c = 0;
% 			fx = exp(m*in + c) - 1;
			out = obj.THETA_MAX/obj.INPUT_SCALE_MAX * in;
% 			out = obj.THETA_MAX/obj.INPUT_SCALE_MAX * fx;

		end

	end
end