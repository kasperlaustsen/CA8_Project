classdef compressorModelV2 < handle
	properties
		% Constants
		V1		% Cylinder internal volume
		Vc		% Cylinder clearance volume
		kl1		% Valve loss constant
		kl2		% Valve loss constant

		Ccp		% Spec heat cap - constant pressure
		Ccv		% Spec heat cap - constant pressure
		ref
		% Inputs
% 		pin		% [Pa] Input pressure
% 		pout	% [Pa] Output pressure
% 		Tin		% [K] Input temperature

% 		omega	% Compressor speed
		

		% "Internal" variables
		v1		% Refri spec vol bf stroke
		v2		% Refri spec vol after stroke
		gamma	% Heat capacity ratio
		p1		% [Pa] Pressure bf stroke
		p2		% [Pa] Pressure bf stroke

		% Outputs
		mdot	% [m3/s] Flow through compressor
		hout	% Enthalpy out
		Tout	% [K] Output temperature
	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = compressorModelV2(V1, Vc, kl1, kl2, Ccp, Ccv, ref)
				obj.V1 = V1;
				obj.Vc = Vc;
				obj.kl1 = kl1;
				obj.kl2 = kl2;
				obj.Ccp = Ccp;
				obj.Ccv = Ccv;
				obj.ref = ref;
				obj.gamma = Ccp/Ccv;
		end
		% ---------------------------------


		% Functions
% 		function out = outputs(obj)
% 			obj.mdot = (obj.V1/obj.v1 - obj.Vc/obj.v2)*obj.omega/2;
% 			obj.Tout = obj.Tin * (obj.pout/obj.pin)^((obj.gamma-1)/obj.gamma);
% 			obj.hout = obj.upsilonlut(obj.Tout, obj.pout);
% 
% 			out = [obj.mdot, obj.hout, obj.Tout];
% 		end

		function out = simulate(obj, pin, pout, Tin, omega)
			% Intermediate variables
			obj.p1 = pin - obj.kl1*omega;
			obj.p2 = pout - obj.kl2*omega;
			obj.v1 = obj.gammalut(Tin, obj.p1);
			obj.v2 = (obj.p2/obj.p1)^(-1/obj.gamma);

			% Outputs
			obj.mdot = (obj.V1/obj.v1 - obj.Vc/obj.v2)*omega/2;
			obj.Tout = Tin * (pout/pin)^((obj.gamma-1)/obj.gamma);
			obj.hout = obj.upsilonlut(obj.Tout, pout);

			out = [obj.mdot, obj.Tout, obj.hout];
		end

		% Table lookups
		function h = upsilonlut(obj, T, p)
			% This is the lookup table function
			% Currently a placeholder where T is multiplied with p
% 			h = T*p;
			h = obj.ref.HTP(T,p);
		end

		function v = gammalut(obj, T, p)
			% This is the lookup table function
			% Currently a placeholder where T is multiplied with p
% 			v = T*p;
			v = obj.ref.VTP(T,p);
		end
	end
end