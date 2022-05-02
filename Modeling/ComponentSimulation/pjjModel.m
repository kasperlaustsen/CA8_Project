classdef pjjModel < handle
	properties
		% Constants
		% --------------
		Minit		% Initial value of state

		% Inputs
% 		mdotin1		% [kg/s] Input flow 1
% 		mdotin2		% [kg/s] Input flow 2
% 		mdotout		% [kg/s] Output flow
% 		hin1		% [J/kg] Input enthalpy
% 		hin2		% [J/kg] Input enthalpy

%		Ts			% Sample time

		% States
		% --------------
		M			% [kg] Mass inside pjj
		Mdiriv		% [kg] Mass time derivative

		% Outputs
		% --------------
		hout		% [J/kg] Enthalpy out
	end
	
	methods


		% Constructor method
		% ---------------------------------
		function obj = pjjModel(Minit)
			obj.Minit = Minit;	% Save in seperate variable for debugging
			obj.M = Minit;		% 

		end
		% ---------------------------------

		function out = simulate(obj, mdotin1, mdotin2, mdotout, hin1, hin2, Ts)
			% Update states
			obj.Mdiriv = mdotin1 + mdotin2 - mdotout;
			obj.M = obj.M + obj.Mdiriv * Ts;
			
			% Outputs
% 			obj.hout = (hin1*mdotin1 + hin2*mdotin2)/(mdotin1 * mdotin2);
			obj.hout = (hin1*mdotin1 + hin2*mdotin2)/mdotout;

			out = [obj.hout obj.M];
		end
	end
end