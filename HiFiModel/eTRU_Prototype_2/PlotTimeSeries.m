function line_handle = PlotTimeSeries(plotaxes, data_ts, value_converter, plot_spec)


if isa(value_converter, 'function_handle')
  data_ts.Data = value_converter(data_ts.Data);
end

line_handle = plot(plotaxes, data_ts.Time, data_ts.Data, plot_spec.line, 'color', plot_spec.color);
line_handle.DisplayName = plot_spec.display_name;

end