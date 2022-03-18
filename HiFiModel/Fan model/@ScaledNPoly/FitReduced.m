% function FitReduced(obj, indepvar, input_names, depvar, initial_order, max_terms, red_limit)
% Fit poly from inputs indepvar to output depvar, starting at
% initial_order, using all terms. If max_terms is larger than zero the
% least significant terms will be removed to limit the number of terms to
% max_terms. red_limit is scalar and terms with coefficients smaller than red_limit * mean(coefficients)
% will be removed. 
function FitReduced(obj, indepvar, input_names, depvar, initial_order, max_terms, red_limit)
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
else
  obj.InputNames = input_names;
end


InputOffset = mean(indepvar);
InputScale  = 1./std(indepvar);
MinValidIn = min(indepvar);
MaxValidIn = max(indepvar);


indepvar = (indepvar - InputOffset) .* InputScale;

% Fit at max order first, to determine insignificant terms
nPoly = obj.sc_polyfitn(indepvar, depvar, initial_order);
fprintf('\nScaledNPoly: performing reduced fit based on %d data-points.\n', n_data) 
fprintf('Initial fit order: %d, Max number of terms: %d, Term reduction limit %f\n', initial_order, max_terms, red_limit)
fprintf('%20s %7s %16s %16s %16s %16s\n', 'Fit type', 'Terms', 'RSE_MEAN', 'RSE_MAX', 'RSE_MEAN [%]','RSE_MAX [%]')
fprintf('%20s %7d %16.5f %16.5f %16.5f %16.5f\n', 'Full order fit', ...
  size(nPoly.ModelTerms, 1), nPoly.RSE_MEAN, nPoly.RSE_MAX, nPoly.RSE_MEAN_PCT, nPoly.RSE_MAX_PCT)


if (max_terms > 0) && (max_terms < length(nPoly.Coefficients)) 
  % Keep max_terms number of terms
  [~, sorted_idx] = sort(abs(nPoly.Coefficients), 'descend');
  keep_idx = sorted_idx(1:max_terms);
  poly_spec = nPoly.ModelTerms(keep_idx, :);
  nPoly = obj.sc_polyfitn(indepvar, depvar, poly_spec);
fprintf('%20s %7d %16.5f %16.5f %16.5f %16.5f\n', 'Max terms fit', ...
  size(nPoly.ModelTerms, 1), nPoly.RSE_MEAN, nPoly.RSE_MAX, nPoly.RSE_MEAN_PCT, nPoly.RSE_MAX_PCT)
end

if (red_limit > 0)
  % Remove insignificant terms and refit to new polyspec.
  keep_idx = abs(nPoly.Coefficients) > (red_limit * mean(abs(nPoly.Coefficients)));
  poly_spec = nPoly.ModelTerms(keep_idx, :);
  nPoly = obj.sc_polyfitn(indepvar, depvar, poly_spec);
  fprintf('%20s %7d %16.5f %16.5f %16.5f %16.5f\n', 'Small terms fit', ...
  size(nPoly.ModelTerms, 1), nPoly.RSE_MEAN, nPoly.RSE_MAX, nPoly.RSE_MEAN_PCT, nPoly.RSE_MAX_PCT)
end

fprintf('%20s %7d %16.5f %16.5f %16.5f %16.5f\n', 'Final fit', ...
  size(nPoly.ModelTerms, 1), nPoly.RSE_MEAN, nPoly.RSE_MAX, nPoly.RSE_MEAN_PCT, nPoly.RSE_MAX_PCT)

obj.nPoly = nPoly;

obj.InputOffset = InputOffset;
obj.InputScale = InputScale;

obj.MinValidIn = MinValidIn;
obj.MaxValidIn = MaxValidIn;


