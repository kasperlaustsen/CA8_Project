classdef ModelAdapter < handle
    
  properties (Constant)
    NameMap = {...
        % Model name              Virtual name 
        'ctrl.cpr_speed'          , 'Control.Fcpr',          ; ...
        'ctrl.evap_vexp'          , 'Control.VexpPct'        ; ...
        'ctrl.econ_vexp'          , 'Control.VecoPct'        ; ...
    %    ''                        , 'Control.VhgPct'         ; ...
        'ctrl.vfan_evap'          , 'Control.Mevap',         ; ...
        'ctrl.vfan_cond'          , 'Control.Mcond',         ; ...
        'ctrl.Hevap'              , 'Control.HevapPct'       ; ...
        'evap.Tsup'               , 'Input.Tsup1'            ; ...
        'evap.Tsup'               , 'Input.Tsup2'            ; ...
        'box.Tret'                , 'Input.Tret'             ; ...
        'evap.Tevap'              , 'Input.Tevap'            ; ...
        'ctrl.Tamb'               , 'Input.Tamb'             ; ...
        'evap.Tsuc'               , 'Input.Tsuc'             ; ...
        'evap.T0'                 , 'Input.T0'               ; ...
        'cond_recv.Tc'            , 'Input.Tc'               ; ...
        'evap.pout'               , 'Input.Psuc'             ; ...
        'cond_recv.pout'          , 'Input.Pdis'             ; ...
        'ctrl.Tset'               , 'User.Tset'              ; ...
        'box.RH'                  , 'Input.RH'               };
  end
  
  properties (SetAccess = public)
    MatlabCtrlHandler
  end
   
  
  methods (Access = public)    
    
    function obj = ModelAdapter()
      obj.MatlabCtrlHandler = ModelCtrlHandler();
    end
    
    
    
    function SetVariables(obj, VarNames, Values)
      %disp('SetVar')
      global model
      VarNames = obj.TranslateVarNames(VarNames);
      idx =  getCellStrIndexes(model.absstatelist, VarNames);
      model.x(idx,model.n) = Values;
    end
    
    function varargout = GetVariables(obj, VarNames)      
      global model
      VarNames = obj.TranslateVarNames(VarNames);
      idx =  getCellStrIndexes(model.absstatelist, VarNames);
      n = LimitValue(model.n-1, 1, 10000000);
      Vars = model.x(idx,n);
      if(nargout > 1)
        for(k = 1:nargout)
          varargout{k} = Vars(k);
        end
      else
        varargout{1} = Vars;
      end
    end
    
    function varargout = GetVariablesAndNames(obj)
      global model
      VarNames = obj.NameMap(:, 1);
      idx =  getCellStrIndexes(model.absstatelist, VarNames);
      n = LimitValue(model.n-1, 1, 10000000);
      Vars = model.x(idx,n);
      varargout{1} = obj.NameMap(:, 2);
      varargout{2} = Vars;
    end
       
    
  end
  
  methods (Access = private)    
    function VarNames = TranslateVarNames(obj, VarNames)
      if(~iscell(VarNames))
        VarNames = {VarNames};
      end
      for(i = 1:length(VarNames))
        idx = strcmp(obj.NameMap(:,2), VarNames{i});
        if(sum(idx) == 1)
          %fprintf('Translation found %s = %s\n', VarNames{i}, obj.NameMap.Map{idx, 1})
          VarNames{i} = obj.NameMap{idx, 1};
        end
      end
    end
    
  end
end