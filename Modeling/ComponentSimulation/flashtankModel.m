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
		hout1		% [J/kg] 
		hout2		% [J/kg] 
		mdotout1	% [kg/s] 
		mdotout2	% [kg/s] 
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
			obj.hout1		= obj.Mlut(pin); 									% liquid enthalpy
			obj.hout2		= obj.Nlut(pin); 									% vapour enthalpy
			obj.mdotout1	= mdotin*(hin - obj.hout2)/(obj.hout2 + obj.hout1); % liquid mass flow
			obj.mdotout2	= mdotin - obj.mdotout1;							% vapour mass flow

			out = [obj.hout1 obj.hout2 obj.mdotout1 obj.mdotout2];
		end

		function h = Mlut(p)
			% dew point enthalpy from pressure (in bar)
			h = obj.ref.HDewP(p*1e-5);
		end

		function h = Nlut(p)
			% bubble point enthalpy from pressure (in bar)
			h = obj.ref.HBupP(p*1e-5);
		end
	end
end