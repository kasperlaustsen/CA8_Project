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
		type    % valve type
		thetareal % theta after opening degree function

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
		function obj = valveModel(type, THETA_MAX,INPUT_SCALE_MAX,K,ref)
			obj.K				= 	K;
			obj.type			=	type;

			obj.THETA_MAX		= 	THETA_MAX;
			obj.INPUT_SCALE_MAX = 	INPUT_SCALE_MAX;

			obj.ref				=	ref;
		end
		% ---------------------------------


		function [vars, out] = simulate(obj, pin, hin, mdotin, Theta)
			% Temporary intermediate variables:
			thetaoffset = 0.01; % Offset to not have zero valve opening for test
			obj.thetareal = obj.valvechar(Theta, obj.type);
			tempmdot	= (mdotin*abs(mdotin));
			tempThetaK = 1/(obj.scalein(Theta)*obj.K)^2;
			% Outputs
			obj.v	 =	obj.vhplut(hin, pin);
			obj.pout =	pin - (mdotin*abs(mdotin)) * 1/((obj.valvechar(obj.scalein(Theta), obj.type) + thetaoffset)*obj.K)^2 * obj.v;

			out		 = obj.pout;
			vars	 = [obj.v, tempmdot, tempThetaK, obj.thetareal];
		end
		
		function v = vhplut(obj, h, p)
			% Specific volume lut from specific enthalpy and pressure
			v = obj.ref.VHP(h, p*1e-5);
		end
		
	end

	methods (Access = private)
		function out = scalein(obj, in)
			% Scales input
			out = obj.THETA_MAX/obj.INPUT_SCALE_MAX * in;
		end

		function out = valvechar(obj, theta, type)
			% Valve characteristic function.
			switch type
				case 'ep'
					% Equal percentage
					m = 0.0461512;
					c = 0;
					out = exp(m*theta + c) - 1;
				case 'fo'
					% Fast opening
					out = 21.5+theta*(1/3);
				case 'lin'
					% Linear
					out = theta;
			end
		end

	end
end