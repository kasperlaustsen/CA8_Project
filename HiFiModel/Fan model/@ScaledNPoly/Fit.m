% function Fit(obj, indepvar, input_names, depvar, poly_spec)
% Fit poly from inputs indepvar to output depvar, using polyspec
function Fit(obj, indepvar, input_names, depvar, poly_spec)

% Convert to single point precision, 4 byte float
indepvar = single(indepvar);
depvar = single(depvar);

[n_data, n_inputs] = size(indepvar);

if ((size(depvar, 1) <= 1) || (size(depvar, 2) ~= 1) )
  error('depvar must be a Nx1 array, where N is the number of data points')
elseif (n_data ~= length(depvar))
  error('indepvar must be a NxM array, where N is the number of data points and M is the number of inputs')
end


if(~iscell(input_names))
  error('InputNames must be a cell array with one name for each input')
elseif(length(input_names) ~= n_inputs)
  error('InputNames must be a cell array with one name for each input')
end

InputOffset = mean(indepvar);
InputScale  = 1./std(indepvar);
MinValidIn = min(indepvar);
MaxValidIn = max(indepvar);

indepvar = (indepvar - InputOffset) .* InputScale;

obj.nPoly = obj.sc_polyfitn(indepvar, depvar, poly_spec);
fprintf('\nScaledNPoly: performing fit based on %d data-points\n', n_data); 
fprintf('%20s %7s %16s %16s %16s %16s\n', 'Fit type', 'Terms', 'RSE_MEAN', 'RSE_MAX', 'RSE_MEAN [%]','RSE_MAX [%]')
fprintf('%20s %7d %16.5f %16.5f %16.5f %16.5f\n', 'Full order fit', ...
  size(obj.nPoly.ModelTerms, 1), obj.nPoly.RSE_MEAN, obj.nPoly.RSE_MAX, obj.nPoly.RSE_MEAN_PCT, obj.nPoly.RSE_MAX_PCT)

obj.nPoly

obj.InputOffset = InputOffset;
obj.InputScale = InputScale;
obj.MinValidIn = MinValidIn;
obj.MaxValidIn = MaxValidIn;
obj.InputNames = input_names;

