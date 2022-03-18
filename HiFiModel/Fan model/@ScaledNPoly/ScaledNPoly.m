classdef ScaledNPoly < handle
  
  properties (SetAccess = public)

  end
  
  properties (SetAccess = private)
    nPoly
    MinValidIn
    MaxValidIn
    InputScale    
    InputOffset
    InputNames
  end
  
  methods (Access = public)
    function obj = ScaledNPoly()
      obj.nPoly = [];
      obj.MinValidIn = [];
      obj.MaxValidIn = [];
      obj.InputScale = [];
      obj.InputNames = {};
    end
    
    function obj = OverrideMaxValidIn(obj, MaxValidIn)
      obj.MaxValidIn = MaxValidIn;
    end
    
    function obj = OverrideMinValidIn(obj, MinValidIn)
      obj.MinValidIn = MinValidIn;
    end
    
    
    depvar = Evaluate(obj, indepvar);
    depvar = EvaluateMatrix(obj, inputs);
    Fit(obj, indepvar, input_names, depvar, poly_spec);
    FitReduced(obj, indepvar, input_names, depvar, max_order, max_terms, red_limit)
    PrintPolyStats(obj, Title)
    PrintPolyToBifrost(obj, fid, poly_name)
    
    
  end
  
  methods (Static)
    polymodel = sc_polyfitn(indepvar, depvar, modelterms);
    depvar = sc_polyvaln(polymodel, indepvar);    
  end
  
  
  
  
end