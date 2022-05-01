function new_input = transformControllerInput(input,input_timescale,output_timescale)
	% this function transforms inputs to align with output_timescale
	% 
	% This is needed so that dimensions of the inputs to the simulation 
	% aligns. Fx, for the compressor, the input pressures are sampled with
	% with a variable time solver, where as the control input omega is 
	% sampled every second. 
	N = length(output_timescale);
	roundTargets = input_timescale;
	v = output_timescale;
	vRounded = interp1(roundTargets,roundTargets,v,'previous');
	
	for i = 1:N
		input_time = vRounded(i);
		idx = find(input_timescale == input_time,1);
		new_input(i) = input(idx);
	end
	new_input = new_input';
end

%%%%%%%%%test script
% load('HiFi_model_data_for_component_tests.mat')
% input = out.logsout{6}.Values.Data(:,:);
% input_timescale = out.logsout{6}.Values.Time
% t = out.tout
% new_input = transformControllerInput(input,input_timescale,t) 
% 
% myfig(-1)
% plot(t,new_input)
% hold on
% plot(input_timescale, input+.1)
% legend('New input for all time steps', 'old input with greater sample time')
