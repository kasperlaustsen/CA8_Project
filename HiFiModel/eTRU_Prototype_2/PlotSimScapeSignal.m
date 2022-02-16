function line_handle = PlotSimScapeSignal(plotaxes, sim_result, signal_name, value_converter, plot_spec)

line_handle = [];

% get timeseries data
data_ts = sim_result.getElement(signal_name).Values;

if isa(value_converter, 'function_handle')
  data_ts.Data = value_converter(data_ts.Data);
end

line_handle = plot(plotaxes, data_ts.Time, data_ts.Data, plot_spec.line, 'color', plot_spec.color);
line_handle.DisplayName = plot_spec.display_name;

end