function t = getTime(name, out)
% this function finds timebase for you so you dont have to keep track of
% indices and measurement numbers
% 
% names can be : 
%				'tcargo'	'ft_in_line'	'cond_out_line'	'ctrl_out'	
%				'ctrl_in'	'Fcpr'	'Hevap_pct'	'VFT'	'Vcond'	'Vexp'	
%				'cond_fan_pct'	'evap_fan_pct'	'evap_exv_out_line'	
%				'evap_out_line'	'tret'	'tret_bf_fan'	'tsuc'	'tsup'	
%				'ft_exv_out_line'	'ft_liq_out_line'	'ft_vap_out_line'	
%				'Tamb'	''	''	'cpr_disc_line'	'meas_com1in'	
%				'meas_com1out'	'meas_com2in'


	for i=1:out.logsout.numElements
		if string(out.logsout{i}.Name) == string(name)
			break
		end
	end
	
% 	if size(out.logsout{i}.Values.Data,2) == 5
% 		meas_arr = ["p", "h", "T", "Phi", "m"];
% 		for j =1:length(meas_arr)
% 			if meas_arr(j) == string(measurement)
% 				break
% 			end
% 		end
% 	elseif size(out.logsout{i}.Values.Data,2) == 1
% 		j = 1;
% 	end
	t = out.logsout{i}.Values.Time;
end
