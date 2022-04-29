classdef className
	properties
		a		% Some property which is assigned during construction

		b		% calculated from a function
		c		% ..
	end
	
	% Execution of functions
% 	obj.HpHuSizeWarning();


	methods
		% Constructor method
		% ---------------------------------
		function obj = MPClifting(a)
				obj.a = a;

				obj.b		= obj.bfunc();

				obj.c		= obj.a * obj.b;
		end
		% ---------------------------------


		% Functions
		function b = bfunc(obj)
			% calculates C_caligraphic as diag(C_z)			
			% NEW
			b = obj.a * 2;
		end
	

	end
end