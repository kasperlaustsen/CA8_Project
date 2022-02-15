classdef PIDController < handle
  properties (SetAccess = private, SetObservable = true)
    MinOut
    MaxOut
    Ke
    Ki
    Kp
    Kd
    Kf    
    Output
    DerivativeTn    
  end
  
  properties (SetAccess = private)
    Integrator
    Error
    OldError
    Derivative
    Feedback
    Reference
    FeedForward
    Antiwindup
    LastOutputSum
    SampleTime
    
  end
  
  methods (Access = public)
    function obj = PIDController()
      obj.Integrator = 0;
      obj.Antiwindup = 0;
      obj.MinOut = -100;
      obj.MaxOut = 100;
      obj.Feedback = 0;
      obj.FeedForward = 0;
      obj.Output = 0;
      obj.Reference = 0;
      obj.Ke = 1;
      obj.Kp = 1;
      obj.Kf = 1;
      obj.Ki = 0.1;
      obj.Kd = 0;
      obj.DerivativeTn = 10;
      obj.Derivative = 0;
      obj.Error = 0;
      obj.OldError = 0;
      obj.LastOutputSum = 0;
      obj.SampleTime = 1;
    end
    
    function SetOutputLimits(obj, min_out, max_out)
      obj.MinOut = min_out;
      obj.MaxOut = max_out;
    end
    
    function SetMaxOut(obj, max_out)
      obj.MaxOut = max_out;
    end
    
    function SetMinOut(obj, min_out)
      obj.MinOut = min_out;
    end
    
    
    function SetInput(obj, feedback, reference, ffwd, varargin)
      obj.Feedback = feedback;
      obj.Reference = reference;
      obj.FeedForward = ffwd;
      if(nargin > 4)
        obj.Antiwindup = varargin{1};
      else
        obj.Antiwindup = obj.Output;
      end
    end
    
    function SetTaui(obj, taui)
      if(taui > 0)
        obj.Ki = 1/(taui/obj.SampleTime);
      else
        obj.Ki = 0;
      end
    end
    
    function SetTaud(obj, taud)
      obj.DerivativeTn = taud/obj.SampleTime;
    end
    
    function SetIntegratorInit(obj, int)
      obj.Integrator = int;
    end
    
    function SetKe(obj, ke)
      obj.Ke = ke;
      
    end function SetKp(obj, kp)
      obj.Kp = kp;
      
    end function SetKd(obj, kd)
      obj.Kd = kd;
      
    end function SetKf(obj, kf)
      obj.Kf = kf;
      
    end function SetCoefficients(obj, kp, taui, taud, kf)
      obj.Kp = kp;
      obj.SetTaui(taui);
      obj.DerivativeTn = taud;
      obj.Kf = kf;
    end
    
    function SetControllerSampleTime(obj, sample_time)
      obj.SampleTime = sample_time;
    end
    
    % Run cotroller
    function Run(obj)
      obj.Error = obj.Ke * (obj.Reference - obj.Feedback);
      
      obj.Derivative = ffilter(obj.Derivative, obj.Error-obj.OldError, obj.DerivativeTn);
      obj.OldError = obj.Error;
      
      pOutput = obj.Error*obj.Kp;
      fOutput = obj.FeedForward*obj.Kf;
      dOutput = obj.Derivative*obj.Kd;
      iOutput = obj.Integrator + obj.Error*obj.Ki;
      
      outputSum = pOutput + fOutput + dOutput + iOutput;
      
      obj.Integrator = iOutput - (obj.LastOutputSum - obj.Antiwindup);
      
      
      
      %obj.LastOutputSum = ErrPlusFFWD + obj.Integrator;
      obj.LastOutputSum = outputSum;
      obj.Output = LimitValue(obj.LastOutputSum, obj.MinOut, obj.MaxOut);
      
    end
    
    % Run cotroller
    function Run2(obj)
      obj.Error = obj.Ke * (obj.Reference - obj.Feedback);
      
      obj.Derivative = ffilter(obj.Derivative, obj.Error-obj.OldError, obj.DerivativeTn);
      obj.OldError = obj.Error;
      
      OutputSum = obj.FeedForward*obj.Kf + obj.Error*obj.Kp + obj.Derivative*obj.Kd;
      obj.Integrator  = obj.Integrator + obj.Error*obj.Ki;
      MinIntLim = obj.MinOut;% - OutputSum;
      MaxIntLim = obj.MaxOut - OutputSum;
      
      obj.Integrator = LimitValue(obj.Integrator, MinIntLim, MaxIntLim);
      obj.Output = LimitValue(OutputSum + obj.Integrator, obj.MinOut, obj.MaxOut);
      
    end
    
    % Preset integrstor such that outputs matches PresetValue, with the
    % current Feedback, feeedforward and reference.
    function Preset(obj, PresetValue)
      obj.Derivative = 0;
      PresetValue = obj.LimitValue(PresetValue, obj.MinOut, obj.MaxOut);
      obj.Error = obj.Ke * (obj.Reference - obj.Feedback);
      ErrPlusFFWD = obj.FeedForward + obj.Error*obj.Kp;
      
      MinIntLim = obj.MinOut - ErrPlusFFWD;
      MaxIntLim = obj.MaxOut - ErrPlusFFWD;
      
      obj.Integrator = LimitValue(PresetValue - ErrPlusFFWD, MinIntLim, MaxIntLim);
      obj.Output = LimitValue(ErrPlusFFWD + obj.Integrator, obj.MinOut, obj.MaxOut);
    end
    
    function Reset(obj)
      obj.Integrator = 0;
    end
    
    function int = GetIntegrator(obj)
      int = obj.Integrator;
    end
    
    
  end
  
  methods (Access = private)
    
    function value = LimitValue(value, min_lim, max_lim)
      if(value < min_lim)
        value = min_lim;
      elseif(value > max_lim)
        value = max_lim;
      end
    end
    
    function out = ffilter(old, in, tau_up, tau_down)
      if(nargin < 4)
        tau_down = tau_up;
      end
      
      if(in > old)
        tau = tau_up;
      else
        tau = tau_down;
      end
      
      out = ((old * tau) + in) ./ (tau+1);
      
    end
  end
  
end