function data = getData(name, measurement, out)
% this function finds data for you so you dont have to keep track of
% indices and measurement numbers
% 
% names can be : 
%				'tcargo'	'ft_in_line'	'cond_out_line'	'ctrl_out'	
%				'ctrl_in'	'Fcpr'	'Hevap_pct'	'VFT'	'Vcond'	'Vexp'	
%				'cond_fan_pct'	'evap_fan_pct'	'evap_exv_out_line'	
%				'evap_out_line'	'tret'	'tret_bf_fan'	'tsuc'	'tsup'	
%				'ft_exv_out_line'	'ft_liq_out_line'	'ft_vap_out_line'	
%				'Tamb'	''	''	'cpr_disc_line'	'meas_com1in'	
%				'meas_com1out'	'meas_com2in' 'm_dot_air' 'T_air' 'Sigma'

% Note: T_air and tret_bf_fan are the same.
% 
% measurements can be: 
% 			'p'		: 	Pressure		[bar]
% 			'h'		: 	Enthalpy		[?]
% 			'T'		: 	Temperature		[K]
% 			'Phi'	:	Phi				[?]
% 			'm'		:	mdot			[?]

	for i=1:out.logsout.numElements
		if string(out.logsout{i}.Name) == string(name)
			break
		end
	end
	
	if size(out.logsout{i}.Values.Data,2) == 5
		meas_arr = ["p", "h", "T", "Phi", "m"];
		for j =1:length(meas_arr)
			if meas_arr(j) == string(measurement)
				break
			end
		end
	elseif size(out.logsout{i}.Values.Data,2) == 1
		j = 1;
	elseif size(out.logsout{i}.Values.Data,2) == 3 % for Sigma
		j = 2;
	end

	datatemp = out.logsout{i}.Values.Data(:,j);
	if range(datatemp) == 0
		sprintf('Data is not collected. Perhabs name error')
	else
		data = datatemp;
	end
end
