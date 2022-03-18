% // ScaledNPoly type data structures. Adapted from polyvaln and polyfitn and
% // encapsulated in Matlab class ScaledNPoly
% // Allows arbitrary amounts of independent variables.
% // http://www.mathworks.com/matlabcentral/fileexchange/34765-polyfitn
% typedef struct
% {
%   float fMinValidInput;
%   float fMaxValidInput;
%   float fInputScale;
%   float fInputOffset;
%   const unsigned char *Terms; // Pointers to an array of terms for each input.
% }tScaledNPolyInput;
% 
% typedef struct
% {
%   unsigned char n_inputs;
%   unsigned char n_terms;
%   const float *fCoefficients; // Array of coefficients for each term.
%   const tScaledNPolyInput *Input;
% }tScaledNPoly;

function PrintPolyToC(obj, fid, poly_name)


[n_terms, n_inputs] = size(obj.nPoly.ModelTerms);

% Print the header
PolyStr = sprintf('\n// %s data:\n', poly_name);

% Print the input structures arrays
for(k = 1:n_inputs)
  % Print info
  PolyStr = sprintf('%s// Data for input number %d, name: %s\n', PolyStr, k, obj.InputNames{k});
  % Print terms
  PolyStr = sprintf('%sconst unsigned char %s_InputTerms%d[] = {%d', PolyStr, poly_name, k, obj.nPoly.ModelTerms(1, k));
  for(i = 2:n_terms)
    PolyStr = sprintf('%s, %d', PolyStr, obj.nPoly.ModelTerms(i,k));
  end
  PolyStr = sprintf('%s};\n', PolyStr);
  % Print the input struct
  PolyStr = sprintf('%sconst tScaledNPolyInput %s_Input%d = {%13ff, %13ff, %13ff, %13ff, %s_InputTerms%d};\n\n', ...
  PolyStr, poly_name, k, obj.MinValidIn(k), obj.MaxValidIn(k), obj.InputScale(k), obj.InputOffset(k), poly_name, k);
end

% Print the coefficients
PolyStr = sprintf('%sconst float %s_Coefficients[] = {%ff', PolyStr, poly_name, obj.nPoly.Coefficients(1));
for(i = 2:n_terms)
  PolyStr = sprintf('%s, %ff', PolyStr, obj.nPoly.Coefficients(i));
end
PolyStr = sprintf('%s};\n', PolyStr);





% Print the poly definition
PolyStr = sprintf('%sconst tScaledNPoly %s = {%d, %d, %s_Coefficients, {&%s_Input1', PolyStr, poly_name, n_inputs, n_terms, ...
  poly_name, poly_name);
for(i = 2:n_inputs)
  PolyStr = sprintf('%s, &%s_Input%d', PolyStr, poly_name, i);
end
  PolyStr = sprintf('%s}};\n', PolyStr);

% PolyStr
fprintf(fid, '%s\n', PolyStr);
