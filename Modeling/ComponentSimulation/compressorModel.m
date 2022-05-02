classdef compressorModel < handle
	properties
		% Constants
		% --------------
		V1		% Cylinder internal volume
		Vc		% Cylinder clearance volume
		kl1		% Valve loss constant
		kl2		% Valve loss constant

		Ccp		% Spec heat cap - constant pressure
		Ccv		% Spec heat cap - constant pressure
		ref
		OMEGA_MAX
		INPUT_SCALE_MAX
		
		% "Internal" variables
		% --------------
		v1		% Refri spec vol bf stroke
		v2		% Refri spec vol after stroke
		gamma	% Heat capacity ratio
		p1		% [Pa] Pressure bf stroke
		p2		% [Pa] Pressure bf stroke

		% Inputs
		% --------------
% 		pin		% [Pa] Input pressure
% 		pout	% [Pa] Output pressure
% 		Tin		% [K] Input temperature

% 		omega	% Compressor speed

		% Outputs
		% --------------
		mdot	% [m3/s] Flow through compressor
		hout	% Enthalpy out
		Tout	% [K] Output temperature
	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = compressorModel(V1, Vc, kl1, kl2, Ccp, Ccv, ...
				OMEGA_MAX, INPUT_SCALE_MAX, ref)
				obj.V1 = V1;
				obj.Vc = Vc;
				obj.kl1 = kl1;
				obj.kl2 = kl2;
				obj.Ccp = Ccp;
				obj.Ccv = Ccv;
				obj.ref = ref;
				obj.gamma = Ccp/Ccv;
				obj.OMEGA_MAX = OMEGA_MAX;
				obj.INPUT_SCALE_MAX = INPUT_SCALE_MAX;
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
			obj.p1 = pin  - obj.kl1*obj.scalein(omega);
			obj.p2 = pout + obj.kl2*obj.scalein(omega);
			obj.v1 = obj.gammalut(Tin, obj.p1);
			obj.v2 = (obj.p2/obj.p1)^(-1/obj.gamma);

			% Outputs
			obj.mdot = (obj.V1/obj.v1 - obj.Vc/obj.v2)*(obj.scalein(omega))/2;
			obj.Tout = Tin * (pout/pin)^((obj.gamma-1)/obj.gamma);
			obj.hout = obj.upsilonlut(obj.Tout, pout);

			out = [obj.mdot, obj.Tout, obj.hout];
		end

		% Table lookups
		function h = upsilonlut(obj, T, p)
			h = obj.ref.HTP(T, p*1e-5);
% 			h = obj.ref.HTP(T, p);

		end

		function v = gammalut(obj, T, p)
			v = obj.ref.VTP(T, p*1e-5);
% 			v = obj.ref.VTP(T, p);

		end
		
		function out = scalein(obj, in)
			% Scale input to between 0 and INPUT_SCALE_MAX
			out = obj.OMEGA_MAX/obj.INPUT_SCALE_MAX * in;
		end
		
	end
end