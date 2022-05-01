classdef compressorModel
	properties
		% Constants
		V1		% Cylinder internal volume
		Vc		% Cylinder clearance volume
		kl1		% Valve loss constant
		kl2		% Valve loss constant

		Ccp		% Spec heat cap - constant pressure
		Ccv		% Spec heat cap - constant pressure

		% Inputs
		pin		% [Pa] Input pressure
		pout	% [Pa] Output pressure
		Tin		% [K] Input temperature
		
		% "Internal" variables
		v1		% Refri spec vol bf stroke
		v2		% Refri spec vol after stroke
		gamma	% Heat capacity ratio
		p1		% [Pa] Pressure bf stroke
		p2		% [Pa] Pressure bf stroke

		omega	% Compressor speed

		% Outputs
		mdot	% [m3/s] Flow through compressor
		hout	% Enthalpy out
		Tout	% [K] Output temperature

	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = compressorModel(V1, Vc, kl1, kl2, Ccp, Ccv, pin, pout, Tin, omega)
				obj.V1 = V1;
				obj.Vc = Vc;
				obj.kl1 = kl1;
				obj.kl2 = kl2;
				obj.Ccp = Ccp;
				obj.Ccv = Ccv;

				% Inputs
				obj.pin = pin;
				obj.pout = pout;
				obj.Tin = Tin;
				
				obj.gamma = Ccp/Ccv;
				obj.p1 = pin - kl1*omega;
				obj.p2 = pout - kl2*omega
				obj.v1 = obj.gammalut();
				obj.v2 = (obj.p2/obj.p1)^(-1/obj.gamma);

				obj.mdot = (obj.V1/obj.v1 - obj.Vc/obj.v2)*omega/2;
				obj.Tout = obj.Tin * (obj.pout/obj.pin)^((obj.gamma-1)/obj.gamma);
				obj.hout = obj.upsilonlut();
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

		function out = output(obj)
			out = [obj.mdot obj.hout obj.Tout];
		end

		% Table lookups
		function h = upsilonlut(obj)
			% This is the lookup table function
			% Currently a placeholder where T is multiplied with p
			h = obj.Tout * obj.pout;
		end

		function v = gammalut(obj)
			% This is the lookup table function
			% Currently a placeholder where T is multiplied with p
			v = obj.Tin*obj.p1;
		end

	end
end