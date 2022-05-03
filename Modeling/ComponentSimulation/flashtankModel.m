classdef flashtankModel < handle
	properties
		% Constants
		% --------------
		ref			% CoolProp wrapper


		% "Internal" variables
		% --------------


		% Inputs
		% --------------
% 		pin
% 		hin
% 		mdotin

% 		Ts			% Simulation sampling time

		% Outputs
		% --------------
		hout_liq		% [J/kg] 
		hout_vap		% [J/kg] 
		mdotout_liq		% [kg/s] 
		mdotout_vap		% [kg/s] 
	end

	methods
		% Constructor method
		% ---------------------------------
		function obj = flashtankModel(ref)
			obj.ref = ref;
		end
		% ---------------------------------


		function out = simulate(obj, pin, hin, mdotin)
			% Outputs
			obj.hout_liq		= obj.Mlut(pin); 					% liquid enthalpy
			obj.hout_vap		= obj.Nlut(pin); 					% vapour enthalpy
			obj.mdotout_vap		= mdotin*(hin - obj.hout_liq) ...	% liquid mass flow
								/(obj.hout_vap - obj.hout_liq);							
			obj.mdotout_liq		= mdotin - obj.mdotout_vap;			% vapour mass flow

			out = [obj.hout_liq, obj.hout_vap, obj.mdotout_liq, obj.mdotout_vap];
		end

		function h = Mlut(obj, p)
			% bubble point enthalpy from pressure (in bar)
			h = obj.ref.HBubP(p*1e-5);

		end

		function h = Nlut(obj, p)
			% dew point enthalpy from pressure (in bar)
			h = obj.ref.HDewP(p*1e-5);

		end
	end
end