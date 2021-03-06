classdef pjjModel < handle
	properties
		% Constants
		% --------------
		Minit		% Initial value of state
		ref
		% Inputs
% 		mdotin1		% [kg/s] Input flow 1
% 		mdotin2		% [kg/s] Input flow 2
% 		mdotout		% [kg/s] Output flow
% 		hin1		% [J/kg] Input enthalpy
% 		hin2		% [J/kg] Input enthalpy
% 		pin			% [Pa] Input pressure

%		Ts			% Sample time

		% States
		% --------------
		M			% [kg] Mass inside pjj
		Mdiriv		% [kg] Mass time derivative

		% "Internal" variables
		%---------------
		Tout		% [K] Output temperature

		% Outputs
		% --------------
		hout		% [J/kg] Enthalpy out
	end
	
	methods


		% Constructor method
		% ---------------------------------
		function obj = pjjModel(Minit,ref)
			obj.Minit = Minit;	% Save in seperate variable for debugging
			obj.M = Minit;		% 
			obj.ref = ref;
		end
		% ---------------------------------

		function [vars, out] = simulate(obj, mdotin1, mdotin2, mdotout, hin1, hin2, pin, Ts)
			% Update states
			obj.Mdiriv = mdotin1 + mdotin2 - mdotout;
			obj.M = obj.M + obj.Mdiriv * Ts;
			
			% Outputs
			obj.hout = (hin1*mdotin1 + hin2*mdotin2)/mdotout;
			obj.Tout = obj.Philut(obj.hout, pin*1e-5);

			out = [obj.hout obj.Tout];
			vars = [obj.M];
		end
	end

	methods (Access = private)
		
		function T = Philut(obj, h, p)
			T = obj.ref.THP(h, p*1e-5) + 273.15; % Pressure in bar
		end

	end
end