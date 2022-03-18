% Evaluate data in matrix form. Returns is same size as inputs. 
% Useful for meshgrid data used for 3d plotting. 
% Input must be a cell array containing the matrices with input data. 
function out = EvaluateMatrix(obj, inputs)

n_rows = size(inputs{1},1);
n_cols = size(inputs{1},2);

indepvar = [];

% Check sizes
for (k = 1:length(inputs))
  if(size(inputs{k},2) ~= n_cols)
    error('the input matrices must have the same number of columns')
  end
  if(size(inputs{k},1) ~= n_rows)
    error('the input matrices must have the same number of columns')
  end
  indepvar(:,k) = reshape(inputs{k}, numel(inputs{k}), 1);
end

% Convert to single point precision, 4 byte float
indepvar = single(indepvar);



[~, n_inputs] = size(indepvar);

if (size(obj.nPoly.ModelTerms, 2) ~= n_inputs)
  error('indepvar must be a NxM array, where N is the number of data points and M is the number of inputs')
end

% Range limit inputs
for(k=1:n_inputs)
  indepvar(:,k) = LimitValues(indepvar(:,k), obj.MinValidIn(k), obj.MaxValidIn(k));
end

% Scale inputs
indepvar = (indepvar - obj.InputOffset) .* obj.InputScale;


depvar = obj.sc_polyvaln(obj.nPoly, indepvar);

out = reshape(depvar, n_rows, n_cols);
