function PolyElement = CreateXmlNPolyElement(docNode, name, Poly)

[n_terms, n_inputs] = size(Poly.ModelTerms)

PolyElement = docNode.createElement('PolyNData');
PolyElement.setAttribute('name', name);
PolyElement.setAttribute('size', num2str(n_terms));
PolyElement.setAttribute('scale', sprintf('%f',Poly.Scale));


InputListElement = docNode.createElement('Inputs');

for(k = 1:n_inputs)
  InputElement = docNode.createElement('Input');
  InputElement.setAttribute('name', Poly.InputNames{k});
  InputElement.setAttribute('minValidInput', sprintf('%f',Poly.MinValidIn(k)));
  InputElement.setAttribute('maxValidInput', sprintf('%f',Poly.MaxValidIn(k)));
  InputElement.setAttribute('index', sprintf('%d', k-1));
  for(i = 1:n_terms)
    TermElement = docNode.createElement('Term');
    TermElement.setAttribute('value', sprintf('%d', Poly.ModelTerms(i,k)));
    TermElement.setAttribute('index', sprintf('%d', i-1));
    InputElement.appendChild(TermElement);
  end 
  InputListElement.appendChild(InputElement);
end
PolyElement.appendChild(InputListElement);
CoeffListElement = docNode.createElement('Coefficients');

for(k = 1:n_terms)
  CoefElement = docNode.createElement('Coefficient');
  CoefElement.setAttribute('index', num2str(k-1));
  CoefElement.setAttribute('value', sprintf('%f',Poly.ScaledCoefficients(k)));
  CoeffListElement.appendChild(CoefElement);
end
PolyElement.appendChild(CoeffListElement);


%  <PolyNData name="HTP" scale="1.0">
%          <Inputs>
%             <Input name="T" minValidInput="1.0" maxValidInput="2.0">
%                <Term value="2"/>
%                <Term value="1"/>
%                <Term value="2"/>
%                <Term value="3"/>
%                ...
%             </Input>
%             <Input name="P" minValidInput="1.0" maxValidInput="2.0">
%                <Term value="2"/>
%                <Term value="1"/>
%                <Term value="2"/>
%                <Term value="3"/>
%                ...
%             </Input>
%          </Inputs>
%          <Coefficients>
%             <Coefficient value="-0.3233"/>
%             <Coefficient value="-0.3223"/>
%             <Coefficient value="-0.4343"/>
%             <Coefficient value="1.2333"/>
%             <Coefficient value="-0.3233"/>
%             <Coefficient value="-0.3233"/>
%          </Coefficients>
%       </PolyNData>  