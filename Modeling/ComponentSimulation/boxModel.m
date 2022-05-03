classdef boxModel < handle
	properties
		% Constants
		% --------------
		Cpair
		Cpbox
		Cpcargo
		UAamb
		UAba      
		UAcargo 
		Mair
		Mbox
		Mcargo

		FAN_MAX
		INPUT_SCALE_MAX

		% "Internal" variables
		% --------------
		Ustarp
		Qfan2
		Qcool
		Qamb
		Qca
		Qba

		% Inputs
		% --------------
% 		mdotair
% 		Tsup
% 		Tambi

% 		Ufan2
		
		% States
		% --------------
		Tair
		Tairderiv
		Tbox
		Tboxderiv
		Tcargo
		Tcargoderiv

		% Outputs
		% --------------
		Tret
	end


	methods
		% Constructor method
		% ---------------------------------
		function obj = boxModel(Tairinit, Tboxinit, Tcargoinit, Cpair, Cpbox, Cpcargo, UAamb, UAba, UAcargo, ...
				Mair, Mbox, Mcargo, FAN_MAX, INPUT_SCALE_MAX)
			obj.Tair			= Tairinit;
			obj.Tbox			= Tboxinit;
			obj.Tcargo			= Tcargoinit;

			obj.Cpair 			= Cpair;
			obj.Cpbox 			= Cpbox;
			obj.Cpcargo 		= Cpcargo;
			obj.UAamb 			= UAamb;
			obj.UAba      		= UAba;
			obj.UAcargo  		= UAcargo ;
			obj.Mair 			= Mair;
			obj.Mbox 			= Mbox;
			obj.Mcargo			= Mcargo;
			
			obj.FAN_MAX 		= FAN_MAX;
			obj.INPUT_SCALE_MAX = INPUT_SCALE_MAX;
			
			% Initialize variables
			obj.Ustarp			= 0;
			obj.Qfan2			= 0;
			obj.Qcool			= 0;
			obj.Qamb			= 0;
			obj.Qca				= 0;
			obj.Qba				= 0;

		end
		% ---------------------------------


		function out = simulate(obj, Ufan2, mdotair, Tsup, Tambi, Ts)
			% Internal variables
			obj.Tret	= obj.Tair;
			obj.Ustarp	= (obj.scalein(Ufan2)*100 - 55.56)*0.0335;
			obj.Qfan2	= 177.76 + 223.95*obj.Ustarp + 105.85*obj.Ustarp^2 ...
							+ 16.75*obj.Ustarp^3;
			obj.Qcool	= obj.Cpair*mdotair*(obj.Tret - Tsup);
			obj.Qamb	= (Tambi - obj.Tbox)	* obj.UAamb;
			obj.Qba		= (obj.Tbox - obj.Tair)	* obj.UAba;
			obj.Qca		= (obj.Tcargo - obj.Tair) * obj.UAcargo;
			
			% Update states
			obj.Tairderiv     = (obj.Qca + obj.Qba + obj.Qfan2 - obj.Qcool ) ...
								/ (obj.Mair * obj.Cpair);
			obj.Tboxderiv     = (obj.Qamb - obj.Qba ) / (obj.Mbox * obj.Cpbox);
			obj.Tcargoderiv   = -obj.Qca / (obj.Mcargo * obj.Cpcargo);
			
			obj.Tair	= obj.Tair + obj.Tairderiv * Ts;
			obj.Tbox	= obj.Tbox + obj.Tboxderiv * Ts;
			obj.Tcargo	= obj.Tcargo + obj.Tcargoderiv * Ts;

			% Outputs
			out = [obj.Tret];
		end
	end
		
	methods (Access = private)
		% Private functions. Can't be used outside class.

		function out = scalein(obj, in)
			% Scale input to between 0 and INPUT_SCALE_MAX
			out = obj.FAN_MAX/obj.INPUT_SCALE_MAX * in;
		end
		
	end
end