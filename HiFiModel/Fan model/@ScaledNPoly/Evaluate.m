function depvar = Evaluate(obj, indepvar)

% Convert to single point precision, 4 byte float
indepvar = single(indepvar);



[~, n_inputs] = size(indepvar);

if (size(obj.nPoly.ModelTerms, 2) ~= n_inputs)
  error('indepvar must be a NxM array, where N is the number of data points and M is the number of inputs')
end

% Range limit inputs
for(k=1:n_inputs)
  indepvar(:,k) = LimitValue(indepvar(:,k), obj.MinValidIn(k), obj.MaxValidIn(k));
%   indepvar(:,k) = LimitValues(indepvar(:,k), obj.MinValidIn(k), obj.MaxValidIn(k));

end

% Scale inputs
indepvar = (indepvar - obj.InputOffset) .* obj.InputScale;


depvar = obj.sc_polyvaln(obj.nPoly, indepvar);
