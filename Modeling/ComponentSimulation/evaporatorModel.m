classdef evaporatorModel < handle
	properties
		% Constants
		% --------------
		Ts			% Simulation sampling time

		Mlvinit		% Initial value of state
		Mvinit		% 
		Tmlvinit	% 
		Tmvinit		% 
		mdotairinit	% 

		Tvinit		% To set the "old" value of Tv (Tvold) for algebraic loop
		
		Vi			% [m3] Internal volume
		Cpair		% 
		rhoair		% 
		UA1			% Heat transfer coeff. m -> lv
		UA2			% Heat transfer coeff. m -> v
		UA3			% Heat transfer coeff. mv -> mlv
		Mm			% Evaporator metal mass


		% Inputs
		% --------------
		% hin
		% pin
		% mdotin
		% mdotout
		% Tret		% Return air temperature
		% Ufan


		% States
		% --------------
		Mlv			% 
		Mv			% 
		Tmlv		% 
		Tmv			% 
		mdotair		% 
		Mlvdiriv	% 
		Mvdiriv		% 
		Tmlvdiriv	% 
		Tmvdiriv	% 
		mdotairdiriv% 


		% "Internal" variables
		% --------------
		sigma		% Boundary
		v1			% LUT. refrig. spec. volume
		Tretfan		%
		Tretsh		%

		Ustarp		%
		Ustarmdot	%
		Vbardotair	%
		mbardotair	%
		
		Qfan		% Fan -> Air
		Qamv		% Ambient air -> (vapor) metal
		Qamlv		% Ambient air -> (liquid-vapor) metal
		Qmvmlv		% (vapor) metal -> (liquid-vapor) metal
		Qmv			% Metal -> Vapor
		Qmlv		% Metal -> liquid-vapor
		Tlv			% LUT. liquid-vapor refrig temp
		Tv			% LUT. liquid-vapor refrig temp
		Vlv			% [m3] liquid-vapor volume
		hlv
		hdew		% LUT. From pressure before evaporator
		mdotdew		% 

		%poutold		% old pressure out variable (used to fix algebraic loop)
		Tvold


		% Outputs
		% --------------
		pout		% LUT
		hv			% 
		Tsup		% 
				

	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = evaporatorModel(Ts, Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit, ...
			Vi, Cpair, rhoair, UA1, UA2, UA3, Mm, Tvinit)
			obj.Ts			= Ts;

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
			
			obj.Vi			= Vi			;
			obj.Cpair		= Cpair			;
			obj.rhoair		= rhoair		;
			obj.UA1			= UA1			;
			obj.UA2			= UA2			;
			obj.UA3			= UA3			;
			obj.Mm			= Mm			;

			obj.Tvold		= Tvinit		; % A Tv variable is needed to get things started
		end
		% ---------------------------------


		function out = simulate(obj, hin, pin, mdotin, mdotout, Tret, Ufan)	
			% Internal variables
			obj.Tlv		= obj.Philut(pin, hin);				% Not good that its table lookup?

			obj.v1		= obj.gammalut(obj.Tlv, pin);
			obj.sigma	= obj.Mlv * obj.v1 / obj.Vi;

			% Fan shit
			obj.Ustarp	= (Ufan*100-55.56)*0.0335;
			obj.Qfan	= 177.76 + 223.95*obj.Ustarp + 105.85*obj.Ustarp^2 + 16.74*obj.Ustarp^3;
			obj.Ustarmdot	= (Ufan*3060 - 2270.4)*0.0017;
			obj.Vbardotair = 0.7273 + 0.1202*obj.Ustarmdot - 0.0044*obj.Ustarmdot; 
			obj.mbardotair = obj.Vbardotair*obj.rhoair; 	
			
			obj.Tretfan = Tret + obj.Qfan/(obj.mdotair*obj.Cpair);
			obj.Qamv	= obj.Cpair*obj.mdotair*(obj.Tretfan - obj.Tmv);
			obj.Tretsh	= obj.Tretfan - obj.Qamv/(obj.mdotair * obj.Cpair);
			obj.Qamlv	= obj.Cpair*obj.mdotair * (obj.Tretsh - obj.Tmlv);


			% Heat transfers
			obj.Qmvmlv	= obj.UA3*(obj.Tmv - obj.Tmlv);
			obj.Qmlv	= obj.UA1*(obj.Tmlv - obj.Tlv)*obj.sigma;
			 
			obj.mdotdew = obj.Qmlv/(obj.hdewlut(pin) - hin);

			% Tv and pout
			obj.Qmv		= obj.UA2*(obj.Tmv - obj.Tvold)*(1 - obj.sigma);
			obj.hv		= obj.hdewlut(pin) + obj.Qmv/mdotin;
			obj.Vlv		= obj.sigma * obj.Vi;
			obj.pout	= obj.PIlut(obj.hv, obj.Mv/(obj.Vi - obj.Vlv))
			obj.Tv		= obj.Philut(obj.pout, obj.hv);
			% Save old value
			obj.Tvold	= obj.Tv;

			% Update states
			obj.Mlvdiriv	= mdotin - obj.mdotdew;
			obj.Mvdiriv		= obj.mdotdew - mdotout;
			obj.mdotairdiriv = (obj.mbardotair - obj.mdotair)/10;
			
			sprintf('Qamlv = %.2f, Qmlv = %.2f, Qmvmlv = %.2f, Mm = %.2f, ,sigma = %.2f, Cpair = %.2f, ', ...
				obj.Qamlv, obj.Qmlv, obj.Qmvmlv, obj.Mm, obj.sigma, obj.Cpair)
			obj.Tmlvdiriv	= (obj.Qamlv - obj.Qmlv + obj.Qmvmlv)/(obj.Mm*obj.sigma*obj.Cpair);
			obj.Tmvdiriv	= (obj.Qamlv - obj.Qmv + obj.Qmvmlv)/(obj.Mm*(1 - obj.sigma)*obj.Cpair);

			obj.Mlv			= obj.Mlv * obj.Mlvdiriv	* obj.Ts;
			obj.Mv			= obj.Mv * obj.Mvdiriv		* obj.Ts;
			obj.mdotair		= obj.mdotair * obj.mdotairdiriv * obj.Ts;
			obj.Tmlv		= obj.Tmlv * obj.Tmlvdiriv	* obj.Ts;
			obj.Tmv			= obj.Tmv * obj.Tmvdiriv	* obj.Ts;

			% Outputs
			obj.Tsup = obj.Tretfan + (obj.Qamlv + obj.Qamv)/(obj.Cpair*obj.mdotair)

			out = [obj.pout, obj.hv, obj.Tsup]
		end

		function v = gammalut(obj, T, p)
			v = T*p;
		end

		function T = Philut(obj, p, h)
			T = p*h;
		end

		function hdew = hdewlut(obj, p)
			% Dew point enthalpy. Probably just from input pressure
			hdew = p;
		end

		function p = PIlut(obj, h, D)
			% Pressure from enthalyp and density
			p = h*D;
		end
	end
end