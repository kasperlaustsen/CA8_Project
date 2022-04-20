classdef ModelCtrlHandler < ExtCtrlHandler

  methods (Access = public)
    function obj = ModelCtrlHandler()
      
    end
  end
  
  methods (Access = public)
   
    function [Names, Values] = GetControlValues(obj)
      Names = { 
        'Control.Fcpr'      
        'Control.VexpPct'       
        'Control.VecoPct'       
        'Control.Mcond'     
        'Control.Mevap'
        'Control.HevapPct'};
      
      Values = [
        obj.Fcpr
        obj.Vexp
        obj.Veco
        obj.Mevap
        obj.Mcond
        obj.Hevap];
    end
    
    function Fcpr = GetFcpr(obj)
      Fcpr = obj.Fcpr;
    end
    
    function Vexp = GetVexp(obj)
      Vexp = obj.Vexp;
    end
    
    function Veco = GetVeco(obj)
      Veco = obj.Veco;
    end
    
    function Mcond = GetMcond(obj)
      Mcond = obj.Mcond;
    end
    
    function Mevap = GetMevap(obj)
      Mevap = obj.Mevap;
    end
    
    function Hevap = GetHevap(obj)
      Hevap = obj.Hevap;
    end
    
  end   
end