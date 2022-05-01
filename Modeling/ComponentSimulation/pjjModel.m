classdef pjjModel < handle
	properties
		% Constants
		Minit		% Initial value of state
% 		Ts			% Simulation sampling time

		% Inputs
% 		mdotin1		% [kg/s] Input flow 1
% 		mdotin2		% [kg/s] Input flow 2
% 		mdotout		% [kg/s] Output flow
% 		hin1		% [] Input enthalpy
% 		hin2		% [] Input enthalpy

		% States
		M			% Mass inside pjj
		Mdiriv		% Mass time derivative

		% Outputs
		hout		% Enthalpy out
	end
	


	methods
% 		% Constructor method
% 		% ---------------------------------
% 		function obj = pjjModel(Minit, Ts)
% 			obj.Minit = Minit;	% Save in seperate variable for debugging
% 			obj.M = Minit;		% 
% 			obj.Ts = Ts;
% 
% 		end
% 		% ---------------------------------
		% Constructor method
		% ---------------------------------
		function obj = pjjModel(Minit)
			obj.Minit = Minit;	% Save in seperate variable for debugging
			obj.M = Minit;		% 

		end
		% ---------------------------------


% 		function out = simulate(obj, mdotin1, mdotin2, mdotout, hin1, hin2)
% 			% Update states
% 			obj.Mdiriv = mdotin1 + mdotin2 - mdotout;
% 			obj.M = obj.M + obj.Mdiriv * obj.Ts;
% 			
% 			% Outputs
% 			obj.hout = (hin1*mdotin1 + hin2*mdotin2)/(mdotin1 * mdotin2);
% 
% 			out = [obj.hout obj.M];
% 		end
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