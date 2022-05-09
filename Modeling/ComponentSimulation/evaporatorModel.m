classdef evaporatorModel < handle
	properties
		% Constants
		% --------------
% 		Ts			% Simulation sampling time

		Mlvinit		% [kg] Initial value of state
		Mvinit		% [kg] 
		Tmlvinit	% [K] 
		Tmvinit		% [K] 
		mdotairinit	% [kg/s] 
		poutinit	%

		Vi			% [m3] Internal volume
		Cpair		% [J/K] Heat capacity of air
		Cpm			% [J/K] Heat capacity of metal
		rhoair		% [kg/m3] 
		UA1			% [W/(m2K)] Heat transfer coeff. m -> lv
		UA2			% [W/(m2K)] Heat transfer coeff. m -> v
		UA3			% [W/(m2K)] Heat transfer coeff. mv -> mlv
		Mm			% [kg] Evaporator metal mass
		Xe			% [] Average quality content

		INPUT_SCALE_MAX
		FAN_MAX

		% Coolprop wrapper object
		ref			% Wrapper

		% "Internal" variables
		% --------------
		sigma		% [% (0-1)] Boundary
		v1			% [m3/kg] LUT. refrig. spec. volume
		Tretfan		% [K] 
		Tretsh		% [K] 

		Ustarp		% [] 
		Ustarmdot	% [] 
		Vbardotair	% [m3/s] 
		mbardotair	% [kg/s] 

		Qfan		% [] Fan -> Air
		Qamv		% [] Ambient air -> (vapor) metal
		Qamlv		% [] Ambient air -> (liquid-vapor) metal
		Qmvmlv		% [] (vapor) metal -> (liquid-vapor) metal
		Qmv			% [] Metal -> Vapor
		Qmlv		% [] Metal -> liquid-vapor
		Tlv			% [K] LUT. liquid-vapor refrig temp
		Vlv			% [m3] liquid-vapor volume
		hlv			% [J/kg] Specific enthalpy of liquid-vapor CV
		hdew		% [J/kg] LUT. From pressure before evaporator
		mdotdew		% [kg/s] 
	
		warningflag % for PIlut

		% Inputs
		% --------------
		% hin
		% pin
		% mdotin
		% mdotout
		% Tret		% Return air temperature
		% Ufan
		% Tv		% [K] 

		% States
		% --------------
		Mlv			% [kg] 
		Mv			% [kg] 
		Tmlv		% [K] 
		Tmv			% [K] 
		mdotair		% [kg/s] 
		Mlvdiriv	% [kg] 
		Mvdiriv		% [kg] 
		Tmlvdiriv	% [K] 
		Tmvdiriv	% [K] 
		mdotairdiriv% [kg/s] 

		% Outputs
		% --------------
		pout		% [Pa] LUT
		hv			% [J/kg] Output vapor specific enthalpy
		Tsup		% [K] 
	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = evaporatorModel(Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, poutinit,...
			Vi, Cpair, Cpm, rhoair, UA1, UA2, UA3, Mm, Xe, INPUT_SCALE_MAX, ...
			FAN_MAX, ref)
			obj.Mlvinit		= Mlvinit		;
			obj.Mvinit		= Mvinit		;
			obj.Tmlvinit	= Tmlvinit		;
			obj.Tmvinit		= Tmvinit		;
			obj.mdotairinit	= mdotairinit	;
			obj.Mlv			= Mlvinit		;
			obj.Mv			= Mvinit		;
			obj.Tmlv		= Tmlvinit		;
			obj.Tmv			= Tmvinit		;
			obj.mdotair		= mdotairinit	;
			obj.poutinit	= poutinit		;

			obj.Vi			= Vi			;
			obj.Cpair		= Cpair			;
			obj.Cpm			= Cpm			;
			obj.rhoair		= rhoair		;
			obj.UA1			= UA1			;
			obj.UA2			= UA2			;
			obj.UA3			= UA3			;
			obj.Mm			= Mm			;
			obj.Xe			= Xe			;

			obj.INPUT_SCALE_MAX = INPUT_SCALE_MAX;
			obj.FAN_MAX		= FAN_MAX		;
			obj.ref			= ref			; % CoolProp Wrapper object

			% initialising pout for Tlv
			obj.pout		= poutinit		; 


			obj.warningflag = 0;
		end
		% ---------------------------------

		function [vars, out] = simulate(obj, hin, pin, mdotin, mdotout, Tv, Tret, Ufan, Ts)	
			% Internal variables
			obj.Tlv				= obj.Philut(hin, pin);
		
			obj.v1				= obj.Lambdalut(obj.pout, obj.Xe);
			obj.sigma			= min(obj.Mlv * obj.v1 / obj.Vi, 0.99);

			% Fan shit
			obj.Ustarp			= (obj.scalein(Ufan)*100-55.56)*0.0335;
			obj.Qfan			= 177.76 + 223.95*obj.Ustarp + 105.85*obj.Ustarp^2 + 16.74*obj.Ustarp^3;
			obj.Ustarmdot		= (obj.scalein(Ufan)*3060 - 2270.4)*0.0017;
			obj.Vbardotair 		= 0.7273 + 0.1202*obj.Ustarmdot - 0.0044*obj.Ustarmdot; 
			obj.mbardotair 		= obj.Vbardotair*obj.rhoair;
			
			obj.Tretfan 		= Tret + obj.Qfan/(obj.mdotair*obj.Cpair);
			obj.Qamv			= obj.Cpair*obj.mdotair*(obj.Tretfan - obj.Tmv);
			obj.Tretsh			= obj.Tretfan - obj.Qamv/(obj.mdotair * obj.Cpair);
			obj.Qamlv			= obj.Cpair*obj.mdotair * (obj.Tretsh - obj.Tmlv);


			% Heat transfers
			obj.Qmvmlv			= obj.UA3*(obj.Tmv - obj.Tmlv);
			obj.Qmlv			= obj.UA1*(obj.Tmlv - obj.Tlv)*obj.sigma;
			 		
			obj.mdotdew 		= obj.Qmlv/(obj.hdewlut(obj.pout) - hin);
	
			% pout
			obj.Qmv				= obj.UA2*(obj.Tmv - Tv)*(1 - obj.sigma);
			obj.hdew			= obj.hdewlut(obj.pout);
% 			obj.hdew			= obj.hdewlut(pin);
			obj.hv				= obj.hdew + obj.Qmv/obj.mdotdew; % possible divide by zero
% 			obj.hv				= obj.hdewlut(obj.pout) + obj.Qmv/obj.mdotdew; % possible divide by zero
			obj.Vlv				= obj.sigma * obj.Vi;
			obj.pout			= obj.PIlut(obj.hv, obj.Mv/(obj.Vi - obj.Vlv), obj.pout);

			% Update states
			obj.Mlvdiriv		= mdotin - obj.mdotdew;
			obj.Mvdiriv			= obj.mdotdew - mdotout;
			obj.mdotairdiriv	= (obj.mbardotair - obj.mdotair)/10;
			obj.Tmlvdiriv		= (obj.Qamlv - obj.Qmlv + obj.Qmvmlv)/(obj.Mm*obj.sigma*obj.Cpm);
			obj.Tmvdiriv		= (obj.Qamlv - obj.Qmv + obj.Qmvmlv)/(obj.Mm*(1 - obj.sigma)*obj.Cpm);

			obj.Mlv				= obj.Mlv 		+ obj.Mlvdiriv	* Ts;
			obj.Mv				= obj.Mv 		+ obj.Mvdiriv		* Ts;
			obj.mdotair			= obj.mdotair	+ obj.mdotairdiriv * Ts;
			obj.Tmlv			= obj.Tmlv		+ obj.Tmlvdiriv	* Ts;
			obj.Tmv				= obj.Tmv 		+ obj.Tmvdiriv	* Ts;

			% Outputs
			obj.Tsup = obj.Tretfan + (obj.Qamlv + obj.Qamv)/(obj.Cpair*obj.mdotair);
			vars = [	obj.Tlv,		obj.v1,				obj.sigma,		obj.Ustarp,			obj.Qfan, ...
						obj.Ustarmdot,	obj.Vbardotair, 	obj.mbardotair, obj.Tretfan,		obj.Qamv, ...
						obj.Tretsh,		obj.Qamlv, 			obj.Qmvmlv,		obj.Qmlv,			obj.mdotdew, ...
						obj.Qmv,		obj.hv,				obj.Vlv,		obj.pout,			obj.Mlvdiriv, ...
						obj.Mvdiriv, 	obj.mdotairdiriv,	obj.Tmlvdiriv,	obj.Tmvdiriv,		obj.Mlv, ...
						obj.Mv,			obj.mdotair,		obj.Tmlv,		obj.Tmv,			obj.hdew];

			out = [obj.pout, obj.hv, obj.Tsup];
		end

		function v = Lambdalut(obj, p, X)
			v = obj.ref.VPX(p*1e-5, X); % Pressure in bar
		end

		function T = Philut(obj, h, p)
			T = obj.ref.THP(h, p*1e-5) + 273.15; % Pressure in bar
		end

		function hdew = hdewlut(obj, p)
			% Dew point enthalpy. Probably just from input pressure
			hdew = obj.ref.HDewP(p*1e-5); % Pressure in bar
		end

		function p = PIlut(obj, h, D, p)
			% Pressure from enthalyp and density
			
			try
				p = obj.ref.PHD(h, D);
				if obj.warningflag == 1;
					obj.warningflag =0;
				end
			catch
				if obj.warningflag == 0
					% include dewpoint density instead of previous pressure.
% 					warning('PIlut couldnt execute. Previous value is assigned')
					sprintf('PIlut couldnt execute. Previous value is assigned')
					obj.warningflag = 1;
					p = p;
				end
				
			end
		end

		function out = scalein(obj, in)
			% Scale input to between 0 and INPUT_SCALE_MAX
			out = obj.FAN_MAX/obj.INPUT_SCALE_MAX * in;
		end
	end
end