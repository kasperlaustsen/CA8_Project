classdef flashtankModel < handle
	properties
		% Constants
		% --------------
					% Initial value of state

		% "Internal" variables
		% --------------
		ref			% CoolProp wrapper

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
		mdotout_liq	% [kg/s] 
		mdotout_vap	% [kg/s] 
	end

% %%% EQUATIONS
% m_dot_5_FT	=	( m_dot_3_Con*(h4 -h5) )/(h5 + h6)		;	% FT	
% m_dot_4_FT	=	m_dot_3_Con - m_dot_5_FT				;	% FT

	methods
		% Constructor method
		% ---------------------------------
		function obj = flashtankModel(ref)
			obj.ref = ref;
		end
		% ---------------------------------


		function out = simulate(obj, pin, hin, mdotin)
			% Outputs
			obj.hout_liq		= obj.Mlut(pin); 									% liquid enthalpy
			obj.hout_vap		= obj.Nlut(pin); 									% vapour enthalpy
			obj.mdotout_vap		= mdotin*(hin - obj.hout_liq)/(obj.hout_vap - obj.hout_liq); % liquid mass flow
			obj.mdotout_liq		= mdotin - obj.mdotout_vap;							% vapour mass flow

			out = [obj.hout_liq, obj.hout_vap, obj.mdotout_liq, obj.mdotout_vap];
		end

		function h = Mlut(obj, p)
			% bubble point enthalpy from pressure (in bar)
% 			h = obj.ref.HDewP(p*1e-5);
			h = obj.ref.HBubP(p*1e-5);

		end

		function h = Nlut(obj, p)
			% dew point enthalpy from pressure (in bar)
% 			h = obj.ref.HBubP(p*1e-5);
			h = obj.ref.HDewP(p*1e-5);

		end
	end
end