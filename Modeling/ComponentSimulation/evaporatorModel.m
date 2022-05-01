classdef evaporator < handle
	properties
		% Constants
		Ts			% Simulation sampling time

		Mlvinit		% Initial value of state
		Mvinit		% 
		Tmlvinit	% 
		Tmvinit		% 
		mdotairinit	% 
		
		Vi			% [m3] Internal volume
		Cpair		% 
		rhoair		% 
		UA1			% Heat transfer coeff. m -> lv
		UA2			% Heat transfer coeff. m -> v
		UA3			% Heat transfer coeff. mv -> mlv


		% Inputs
		% hin
		% pin
		% mdotin
		% mdotout
		% Tret		% Return air temperature
		% Ufan

		Ufan		% 

		% States
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
		sigma		% Boundary
		v1			% LUT. refrig. spec. volume
		Tretfan		%
		Tretsh		%

		Ustarp		%
		Ustarmdot	%
		Vbardotair	%
		mbardotair	%
		
		Qfan		% 
		Qamv		% 
		Qamlv		% 
		Qmvmlv		% 
		Tlv			% LUT. liquid-vapor refrig temp
		Tv			% LUT. liquid-vapor refrig temp
		Vlv			% [m3] liquid-vapor volume
		hlv
		hdew		% LUT. From pressure before evaporator
		mdotdew		% 



		% Outputs
		pout		% LUT
		hv			
		Tsup		% 
				

	end
	


	methods
		% Constructor method
		% ---------------------------------
		function obj = evaporator(Ts, Mlvinit, Mvinit, Tmlvinit, Tmvinit, mdotairinit ...
			Vi, Cpair, thoair, UA1, UA2, UA3)
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
		end
		% ---------------------------------


		function out = simulate(obj, hin, pin, mdotin, mdotout, Tret, Ufan)	
			% Internal variables
			obj.Tlv		= obj.Philut(pin,hin);			% NOT GOOD???
			obj.v1		= obj.gammalut(obj.Tlv, pin);
			obj.sigma	= obj.Mlv * obj.v1 / obj.Vi;
			obj.Vlv		= obj.sigma * obj.Vi;

			% PROBLEM: Tv needs pout, but pout req. hv req. qmv req. Tv and 
			% so on.. We need a state or old variable 
			obj.Tv		= obj.Philut(obj.pout,hout);	% NOT GOOD???
			obj.Qmv		= obj.UA2*(obj.Tmv-obj.Tv)*(1-obj.sigma);
			obj.hv		= obj.somethinglut(pin)+obj.Qmv/mdotin;

			obj.pout	= PIlut(obj.hv, obj.Mv/(obj.Vi-obj.Vlv))

			
			
			
			
			% Fan shit
			obj.Ustarp	= (Ufan*100-55.56)*0.0335;
			obj.Qfan	= 177.76 + 223.95*obj.Ustarp + 105.85*obj.Ustarp^2 + 16.74*obj.Ustarp^3;

			obj.Ustarmdot	= (Ufan*3060-2270.4)*0.0017;
			obj.Vbardotair = 0.7273 + 0.1202*obj.Ustarmdot - 0.0044*obj.Ustarmdot; 
			obj.mbardotair = obj.Vbardotair*obj.rhoair; 	
			
			obj.Tretfan = Tret + obj.Qfan/(obj.mdotair*obj.Cpair);
			obj.Tretsh	= obj.Tretfan - obj.Qamv/(obj.mdotair * obj.Cpair);

			obj.Qamv	= obj.Cpair*obj.mdotair*(obj.Tretfan-obj.Tmv);
			obj.Qamlv	= obj.Cpair*obj.mdotair * (obj.Tretsh-obj.Tmlv);

			obj.Qmvmlv	= obj.UA3*(obj.Tmv-obj.Tmlv); 							 						;	% Eva	
			obj.Qmlv	= obj.UA1*(obj.Tmlv-obj.Tlv)*obj.sigma 	;					 					;	% Eva	
			 
			obj.mdotdew = 20000;

			% Update states
			obj.Mlvdiriv = mdotin - obj.mdotdew;
			obj.Mvdiriv = obj.mdotdew - mdotout;
			obj.mdotairdiriv = (obj.mbardotair-obj.mdotair)/10;

			% Outputs


			out = 0;
		end

		function out = gammalut(T, p)
			v = T*P;
		end

		function out = Philut(p, h)
			T = p*h;
		end

		function hdew = somethinglut(p)
			% Dew point enthalpy. Probably just from input pressure
			hdew = p;
		end
	end
end