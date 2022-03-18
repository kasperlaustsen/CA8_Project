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

function PrintPolyToBifrost(obj, fid, poly_name)

[n_terms, n_inputs] = size(obj.nPoly.ModelTerms);

% Print the header
PolyStr = sprintf('\n// %s data:\n', poly_name);

% Print the type definition
% using DefaultPolynomialData_t = Math::TPolynomiumData<float, 11>;
type_name = [poly_name 'NData_t'];
PolyStr = sprintf('%susing %s = Math::TPolyNData<float, %d, %d, %d>;\n', PolyStr, type_name, n_terms, n_inputs, n_terms);

% Print the input structures arrays
for(k = 1:n_inputs)
  % Print info
  PolyStr = sprintf('%s// Data for input number %d, name: %s\n', PolyStr, k, obj.InputNames{k});
  % Print terms
  PolyStr = sprintf('%sconst %s::Input_t::TermArray_t %s_InputTerms%d {%d', PolyStr, type_name, poly_name, k, obj.nPoly.ModelTerms(1, k));
  for(i = 2:n_terms)
    PolyStr = sprintf('%s, %d', PolyStr, obj.nPoly.ModelTerms(i,k));
  end
  PolyStr = sprintf('%s};\n', PolyStr);
end

% Print the coefficients
PolyStr = sprintf('%sconst %s::Coefficients_t %s_Coefficients {%ff', PolyStr, type_name, poly_name, obj.nPoly.Coefficients(1));
for(i = 2:n_terms)
  PolyStr = sprintf('%s, %ff', PolyStr, obj.nPoly.Coefficients(i));
end
PolyStr = sprintf('%s};\n', PolyStr);

% Print the input definition

 PolyStr = sprintf('%sconst %s::ArrayInput_t %s_Inputs {\n', PolyStr, type_name, poly_name);
for(k = 1:n_inputs)  
  if(k < n_inputs)
    comma = ',';
  else
    comma = '';
  end
  PolyStr = sprintf('%s  %s::Input_t {%13ff, %13ff, %13ff, %13ff, %s_InputTerms%d}%s\n', ...
  PolyStr, type_name, obj.MinValidIn(k), obj.MaxValidIn(k), obj.InputScale(k), obj.InputOffset(k), poly_name, k, comma);
end
PolyStr = sprintf('%s};\n\n', PolyStr); 


% Print the poly definition
PolyStr = sprintf('%sconst %s %s {%s_Inputs, %s_Coefficients};', PolyStr, type_name, poly_name, poly_name, poly_name);


% PolyStr
fprintf(fid, '%s\n', PolyStr);
