classdef name < handle
	properties
		% Constants
					% Initial value of state
		Ts			% Simulation sampling time

		% Inputs
% 		pin
% 		hin
% 		mdotin

		% States


		% Outputs
		hout1
		hout2
		mdotout1
		mdotout2
	end

% %%% EQUATIONS
% m_dot_5_FT	=	( m_dot_3_Con*(h4 -h5) )/(h5 + h6)		;	% FT	
% m_dot_4_FT	=	m_dot_3_Con - m_dot_5_FT				;	% FT

	methods
		% Constructor method
		% ---------------------------------
		function obj = name(ref)
			obj.ref = ref;

		end
		% ---------------------------------


		function out = simulate(obj, pin, hin, mdotin)
			% Update states
			
			
			% Outputs
			obj.hout1		= ref.HDewP(pin); 									% liquid enthalpy
			obj.hout2		= ref.HBubP(pin); 									% vapour enthalpy
			obj.mdotout1	= mdotin*(hin - obj.hout2)/(obj.hout2 + obj.hout1); % liquid mass flow
			obj.mdotout2	= mdotin - obj.mdotout1;							% vapour mass flow

			out = [obj.hout1 obj.hout2 obj.mdotout1 obj.mdotout2];
		end
	end
end