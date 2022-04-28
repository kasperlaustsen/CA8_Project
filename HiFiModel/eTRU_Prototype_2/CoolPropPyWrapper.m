% Wraps CoolProp, uses bar and °C
% The wrapper implements the following functions:
% HBubP, HDewP,
% TBubP, TDewP,
% DBubP, DDewP
% DBubT, DDewT
% VBubP, VDewP
% VBubT, VDewT
% HBubT, HDewT,
% PBubT, PDewT
% HTP
% THP
% DHP
% VHP = 1/DHP
% DPX
% VPX
% QHP
% VTP
% STP
% PSV
% VPS
% DPS
% CpMassTP      Mass specific Cp value for constant pressure
% CvMassTV      Mass specific Cp value for constant volume
% CpRatioTP     Heat capacity ratio
classdef CoolPropPyWrapper < handle
  
  properties (SetAccess = protected)
    Refrigerant
    ShortName
    PressureMin
    PressureMax
    Tmin
    Tmax
    CP
    temp_offset
    pressure_ratio
  end
  
  properties (SetAccess = public)
    
  end
  
  methods (Access = private)
    function Pressure = ConvertAndLimitPressure(obj, Pressure)
      Pressure = Pressure * 100000; % Convert from Bar to Pascal
      %Pressure(Pressure < obj.PressureMin) = obj.PressureMin;
      %Pressure(Pressure > obj.PressureMax) = obj.PressureMax;
    end
  end
  
  
  methods (Static)
    function out = mat2py(in)
      N = length(in);
      if(N > 1)
        out = py.numpy.array(in);
      else
        out = py.numpy.double(in);
      end
    end
  end
  
  
  
  methods (Access = public)
    % Constructor
    function obj = CoolPropPyWrapper(varargin)
      obj.temp_offset = 273.15;
      obj.pressure_ratio = 100000;
      obj.CP = py.importlib.import_module('CoolProp.CoolProp');
      
      if(nargin > 0)
        Refrigerant = varargin{1};
        disp(['CoolProp version: ', char(obj.CP.get_global_param_string('version'))]);
        obj.ShortName = Refrigerant;
        obj.Refrigerant = obj.RefrigerantAlias(Refrigerant);
        T_triple =  PropsSI('TTRIPLE', obj.Refrigerant)-273.15;
        T_min = PropsSI('TMIN',obj.Refrigerant)-273.15;
        
        obj.Tmin = LimitValue(T_min, T_triple, 40000)+5;
        obj.Tmax = PropsSI('TCRIT',obj.Refrigerant)-273.15-5;
        try
          P_triple = PropsSI('PTRIPLE',obj.Refrigerant);
        catch e
          disp('Could not calculate tripple point, using 1000pa');
          P_triple = 1000;
        end
        obj.PressureMin = PropsSI('P','T', obj.Tmin+273.15,'Q', 1, obj.Refrigerant);
        obj.PressureMin = LimitValue(obj.PressureMin, P_triple, 10000000); % Make sure that min pressure is at least 0.1 bar and above triple point
        obj.PressureMin = LimitValue(obj.PressureMin, 10000, 10000000);
        obj.PressureMax = PropsSI('P','T', obj.Tmax+273.15,'Q', 1, obj.Refrigerant); % Must use critical point for mixtures
        
      end
    end
    
    function Version = GetCoolPropVersion(obj)
      Version = char(obj.CP.get_global_param_string('version'));
    end
    
    function Version = GetRefPropVersion(obj)
      Version = char(obj.CP.get_global_param_string('REFPROP_version'));
    end
    
    function UpgradePythonCoolProp(obj)
      % Install
      [v,e] = pyversion;
      system([e, ' -m pip install --upgrade pip'])
      system([e, ' -m pip install --upgrade CoolProp'])
      system([e, ' -m pip install --upgrade numpy'])
    end
    
    function InstallPythonCoolProp(obj)
      % Install
      [v,e] = pyversion;
      system([e, ' -m pip install --upgrade pip'])
      system([e,' -m pip install  CoolProp'])
      system([e,' -m pip install  numpy'])
      UpgradePythonCoolProp(obj);
    end
    
    
    function obj = SetPressureMin(obj, min_pressure)
      obj.PressureMin = min_pressure*100000;
      obj.Tmin = obj.TDewP(min_pressure);
    end
    
    function obj = SetPressureMax(obj, max_pressure)
      obj.PressureMax = max_pressure*100000;
      obj.Tmax = obj.TDewP(max_pressure);
    end
    
    % Alias for blends for easier configuration
    % Source https://www.ashrae.org/standards-research--technology/standards--guidelines/standards-activities/ashrae-refrigerant-designations
    % Refrop names may be found here (Page 46): http://www.nist.gov/srd/upload/REFPROP9.PDF
    function Refrigerant = RefrigerantAlias(obj, Refrigerant)
      if(strncmp(Refrigerant, 'ALIAS::', 7) == 1)
        Alias = Refrigerant(8:end);
        switch Alias
          case 'R170'
            Refrigerant = 'REFPROP::Ethane';
          case 'R290'
            Refrigerant = 'REFPROP::Propane';
          case 'R513A'
            Refrigerant = 'REFPROP::R134a[0.44]&R1234yf[0.56]';
          case 'R407A'
            Refrigerant =  'REFPROP::R32[0.20]&R125[0.40]&R134a[0.40]'
          case 'R407F'
            Refrigerant = 'REFPROP::R32[0.30]&R125[0.30]&R134a[0.40]'
          case 'R417A'
            Refrigerant = 'REFPROP::R134a[0.50]&R125[0.466]&Butane[0.034]'; %http://link.springer.com/article/10.1007/s10765-012-1172-6#/page-1
          case 'R417B'
            Refrigerant = 'REFPROP::R134a[0.1825]&R125[0.79]&Butane[0.0275]'; %http://link.springer.com/article/10.1007/s10765-012-1172-6#/page-1
          case 'R422A'
            Refrigerant = 'REFPROP::R125[0.851]&R134a[0.115]&ISOBUTAN[0.034]';
          case 'R422D'
            Refrigerant = 'REFPROP::R125[0.651]&R134a[0.315]&ISOBUTAN[0.034]';
          case 'R427A' % R-32/125/143a/134a (15.0/25.0/10.0/50.0)
            Refrigerant = 'REFPROP::R32[0.15]&R125[0.25]&R143a[0.10]&R134a[0.50]';
          case 'R434A' % 434A	R-125/143a/134a/600a
            Refrigerant = 'REFPROP::R125[0.632]&R143a[0.18]&R134a[0.16]&ISOBUTAN[0.028]';
          case 'R437A' % R437A R125/134a/Butane/ipentane 19.5/78.5/1.4/0.6
            Refrigerant = 'REFPROP::R125[0.195]&R134a[0.785]&Butane[0.014]&Ipentane[0.006]'
          case 'R438A' % R438A R32/125/134a/Butane/ipentane 8.5/45/44.2/1.7/0.6
            Refrigerant = 'REFPROP::R32[0.085]&R125[0.45]&R134a[0.442]&Butane[0.017]&Ipentane[0.006]'
          case 'R442A' % 	R-32/125/134a/152a/227ea (31.0/31.0/30.0/3.0/5.0)
            Refrigerant = 'REFPROP::R32[0.31]&R125[0.31]&R134a[0.30]&R152a[0.03]&R227ea[0.05]'
          case 'R448A'
            Refrigerant = 'REFPROP::R32[0.26]&R125[0.26]&R134a[0.21]&R1234yf[0.20]&R1234ze[0.07]' % http://www.diva-portal.org/smash/get/diva2:860053/FULLTEXT01.pdf
          case 'R449A'
            Refrigerant = 'REFPROP::R32[0.243]&R125[0.247]&R134a[0.257]&R1234yf[0.253]'
          case 'R450A'
            Refrigerant = 'REFPROP::R134a[0.42]&R1234ze[0.58]'
          case 'R502' %R502	R-22/115 (48.8/51.2)
            Refrigerant = 'REFPROP::R22[0.488]&R115[0.512]'
          otherwise
            Refrigerant = ['REFPROP::' Alias];
        end
      end
    end
    
    
    % Destructor
    function delete(obj)
    end
    
    function out = press_to_mpa(obj, in)
      out = in * obj.pressure_ratio;
      out(out < obj.PressureMin) = obj.PressureMin;
      out(out > obj.PressureMax) = obj.PressureMax;
    end
    
    function out = temp_to_kelvin(obj, in)
      out = in + obj.temp_offset;
    end
    
    function u = UTP(obj, t, p)
      u = double(PropsSI('U','P', obj.press_to_mpa(p), 'T', obj.temp_to_kelvin(t), obj.Refrigerant));
    end
    
    function h = HPU(obj, p, u)
      h = double(PropsSI('H','P', obj.press_to_mpa(p), 'U', (u), obj.Refrigerant));
    end
    
    function h = HBubP(obj, p)
      h = double(PropsSI('H','P', obj.press_to_mpa(p), 'Q', zeros(1,length(p)), obj.Refrigerant));
    end
    
    function h = HDewP(obj, p)
      h = double(PropsSI('H','P', obj.press_to_mpa(p), 'Q', ones(1, length(p)), obj.Refrigerant));
    end
    
    function h = HBubT(obj, t)
      h = double(PropsSI('H','T', obj.temp_to_kelvin(t), 'Q', zeros(1,length(t)), obj.Refrigerant));
    end
    
    function h = HDewT(obj, t)
      h = double(PropsSI('H','T', obj.temp_to_kelvin(t), 'Q', ones(1, length(t)), obj.Refrigerant));
    end
    
    function t = TBubP(obj, p)
      t = double(PropsSI('T','P', obj.press_to_mpa(p), 'Q', zeros(1,length(p)), obj.Refrigerant))-273.15;
    end
    
    function t = TDewP(obj, p)
      t = double(PropsSI('T','P', obj.press_to_mpa(p), 'Q', ones(1, length(p)), obj.Refrigerant))-273.15;
    end
    
    function p = PBubT(obj, t)
      p = double(PropsSI('P','T', obj.temp_to_kelvin(t), 'Q', zeros(1,length(t)), obj.Refrigerant))/100000;
    end
    
    function p = PDewT(obj, t)
      p = double(PropsSI('P','T', obj.temp_to_kelvin(t), 'Q', ones(1, length(t)), obj.Refrigerant))/100000;
    end
    
    function t = TDewV(obj, v)
      t = double(PropsSI('T','D', (1./v), 'Q', 1, obj.Refrigerant))-273.15;
    end
    
    function d = DHP(obj, h, p)
      d = double(PropsSI('D','P', obj.press_to_mpa(p), 'H', (h), obj.Refrigerant));
    end
    
    function v = VHP(obj, h, p)
      d = DHP(obj, h, p);
      v = 1./d;
    end
    
    function h = HTP(obj, t, p)
      try
        h = double(PropsSI('H','P', obj.press_to_mpa(p), 'T', obj.temp_to_kelvin(t), obj.Refrigerant));
      catch me
        getReport(me)
        %fprintf('CoolPropWrapper::HTP failed with T=%f and P=%f, TBubP=%f, Idx=%d', t(k), p(k)/100000, obj.TBubP(p(k)/100000), k)  % Re-throw as warning
        rethrow(me)
      end
    end
    
    function h = HTPX(obj, t, p, x)
      try
        h = zeros(1,length(p));
        p = ConvertAndLimitPressure(obj, p);
        tbub = obj.TBubP(p/100000);
        tdew = obj.TDewP(p/100000);
        Limit = 0.01;
        for(k=1:length(p))
          if((t(k) > tdew(k)+Limit) && (t(k) < tbub(k)-Limit)) % Gas or liquid phase
            h(k) = PropsSI('H','P', p(k),'T', t(k)+273.15, obj.Refrigerant);
          else % Two phase
            h(k) = obj.HPX(p(k)/100000, x(k));
          end
        end
      catch me
        getReport(me)
        fprintf('CoolPropWrapper::HTPX failed with T=%f and P=%f, X=%f, TBubP=%f, Idx=%d', t(k), p(k)/100000, x(k), obj.TBubP(p(k)/100000), k)  % Re-throw as warning
        error(me)
      end
    end
    
    function t = THP(obj, h, p)
      t = PropsSI('T', 'H', h, 'P',  obj.press_to_mpa(p), obj.Refrigerant) - obj.temp_offset;
    end
    
    function t = TPU(obj, p, u)
      try
        t = double(PropsSI('T','P', obj.press_to_mpa(p), 'U', (u), obj.Refrigerant)) - obj.temp_offset;
      catch err
        disp(getReport(err))
      end
    end
    
    function p = PTV(obj, t, v)
      p = double(PropsSI('P','Y', obj.temp_to_kelvin(t), 'D', (1/v), obj.Refrigerant)) / obj.pressure_ratio;
    end
    
    function q = QHP(obj, h, p)
      try
        q = zeros(1,length(p));
        p = ConvertAndLimitPressure(obj, p);
        for(k=1:length(p))
          q(k) = PropsSI('Q','P', p(k),'H', h(k), obj.Refrigerant);
          if(q(k) > 1)
            hdew = obj.HDewP(p(k)/100000);
            hbub = obj.HBubP(p(k)/100000);
            q(k) = 1+(h(k)-hdew)/(hdew-hbub);
          end
          if(q(k) < 0)
            hdew = obj.HDewP(p(k)/100000);
            hbub = obj.HBubP(p(k)/100000);
            q(k) = -(hbub-h(k))/(hdew-hbub);
          end
        end
        %q(q > 1) = -1; % Handle REFPROP output value of 998 in invalid areas
        %q(q < 0) = -1; % Handle REFPROP output value of < 0 in liquid areas
      catch err
        disp(getReport(err))
        Presure = p(k)
        Enthalpy = h(k)
      end
    end
    
    
    function d = DBubP(obj, p)
      d = double(PropsSI('D','P', obj.press_to_mpa(p), 'Q', zeros(1, length(p)), obj.Refrigerant));
    end
    
    function d = DDewP(obj, p)
      d = double(PropsSI('D','P', obj.press_to_mpa(p), 'Q', ones(1, length(p)), obj.Refrigerant));
    end
    
    function d = DBubT(obj, t)
      d = double(PropsSI('D','T', obj.temp_to_kelvin(t), 'Q', zeros(1, length(t)), obj.Refrigerant));
    end
    
    function d = DDewT(obj, t)
      d = double(PropsSI('D','T', obj.temp_to_kelvin(t), 'Q', ones(1, length(t)), obj.Refrigerant));
    end
    
    function v = VBubP(obj, p)
      v = 1./obj.DBubP(p);
    end
    
    function v = VDewP(obj, p)
      v = 1./obj.DDewP(p);
    end
    
    function v = VBubT(obj, t)
      v = 1./obj.DBubT(t);
    end
    
    function v = VDewT(obj, t)
      v = 1./obj.DDewT(t);
    end
    
    function d = DPX(obj, p, x)
      d = PropsSI('D', 'Q', x, 'P',  obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    function h = HPX(obj, p, x)
      h(k) = PropsSI('H', 'Q', x, 'P',  obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    function x = XHP(obj, h, p)
      x(k) = PropsSI('Q', 'H', h(k), 'P',  obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    function v = VPX(obj, p, x)
      v = 1./obj.DPX(p, x);
    end
    
    % VTP
    function v = VTP(obj, t, p)
      v = 1./PropsSI('D', 'T', t+273.15, 'P', obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % DTP
    function d = DTP(obj, t, p)
      d = 1./ obj.VTP(t, p);
    end
    
    % HPS
    function h = HPS(obj, p, s)
      h = PropsSI('H', 'S', s, 'P', obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % STP
    function s = STP(obj, t, p)
      s = PropsSI('S', 'T', t+273.15, 'P', obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % SHP
    function s = SHP(obj, h, p)
      s = PropsSI('S', 'H', h, 'P', obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % HPV
    function h = HPV(obj, p, v)
      h = PropsSI('H', 'D', 1./v, 'P', obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % THV
    function t = THV(obj, h, v)
      t(k) = PropsSI('T', 'H', h, 'D', 1./v, obj.Refrigerant) - 273.15;
    end
    
    function t = THD(obj, h, d)
      try
        t = PropsSI('T', 'H', h, 'D', d, obj.Refrigerant) - 273.15;
      catch err
        H = h
        D = d
        rethrow(err)
      end
    end
    
    function p = PHD(obj, h, d)
      p = PropsSI('P', 'H', h, 'D', d, obj.Refrigerant) - 273.15;
    end
        
    % TPS
    function t = TPS(obj, p, s)
      t = PropsSI('T', 'S', s, 'P',  obj.press_to_mpa(p), obj.Refrigerant) - 273.15;
    end
    
    % PSV
    function p = PSV(obj, s, v)
      p = zeros(1,length(s));
      StopError = 0.0001;
      Pressure = 1; % Start iteration at one bar
      vguess = obj.VPS(Pressure, s(1));
      Pressure_old = Pressure*2;
      vguess_old = obj.VPS(Pressure*2, s(1));
      try
        for(k=1:length(s))
          Error = v(k) - vguess;
          Count = 0;
          while(abs(Error) > StopError && Count < 10)
            Error = v(k) - vguess;
            % Update dvdP
            dvdP = (vguess-vguess_old)/(Pressure-Pressure_old);
            if((abs(dvdP) < 1e-8) || (isnan(dvdP)))
              break
            end
            Pressure_old = Pressure;
            vguess_old = vguess;
            Pressure = LimitValue(Pressure + LimitValue(Error/dvdP, -0.1, 0.1), obj.PressureMin/100000, obj.PressureMax/100000);
            vguess = obj.VPS(Pressure, s(k));
            Count = Count + 1;
          end
          p(k) = Pressure;
        end
      catch err
        
        getReport(err, 'extended')
        disp('PSV solver failed with inputs:')
        S = s(k)
        V = v(k)
        P = Pressure
        rethrow(err)
      end
    end
    
    % PSD
    function p = PSD(obj, s, d)
      p = obj.PSV(s, 1./d);
    end
    
    % TSV
    function t = TSV(obj, s, v)
      t = zeros(1,length(s));
      StopError = 0.0001;
      Temp = 1; % Start iteration at one bar
      vguess = obj.VPS(Temp, s(1));
      Temp_old = Temp*2;
      vguess_old = obj.VPS(Temp*2, s(1));
      for(k=1:length(s))
        Error = v(k) - vguess;
        Count = 0;
        while(abs(Error) > StopError && Count < 10)
          Error = v(k) - vguess;
          % Update dvdP
          dvdT = (vguess-vguess_old)/(Temp-Temp_old);
          Temp_old = Temp;
          vguess_old = vguess;
          Temp = Temp + LimitValue(Error/dvdT, -1, 1);
          vguess = obj.VTS(Temp, s(k));
          Count = Count + 1;
        end
        t(k) = Temp;
      end
    end
    
    % TSD
    function t = TSD(obj, s, d)
      t = obj.TSV(s, 1./d);
    end
    
    
    % VTS
    function v = VTS(obj, t, s)
      v = 1./PropsSI('D', 'S', s, 'T', t+273.15, obj.Refrigerant);
    end
    
    % DTS
    function t = DTS(obj, t, s)
      t = 1./obj.VTS(t, s);
    end
    
    % VPS
    function v = VPS(obj, p, s)
      v(k) = 1/PropsSI('D', 'S', s, 'P',  obj.press_to_mpa(p), obj.Refrigerant);
    end
    
    % DPS
    function d = DPS(obj, p, s)
      d = 1./obj.VPS(p, s);
    end
    
    function Cp = CpBubT(obj, t)
      Cp(k) = PropsSI('CPMASS','P', obj.PBubT(t), 'T', t+273.15, obj.Refrigerant);
    end
    
    function Cp = CpMassTP(obj, t, p)
      Cp = zeros(1,length(p));
      % CP mass is undefined on the saturation curve and therefore this
      % is avoided
      Tmax = obj.TDewP(obj.PressureMax/101000); % Make sure this works above the critical pressure.
      p = ConvertAndLimitPressure(obj, p);
      
      SatDiff = obj.PDewT(LimitValue(t, -273.15, Tmax))*100000 - p;
      idx = abs(SatDiff) < 1;
      p(idx) = p(idx) + 1; %sign(SatDiff(idx))
      
      for(k=1:length(p))
        Cp(k) = PropsSI('CPMASS','P', p(k), 'T', t(k)+273.15, obj.Refrigerant);
      end
    end
    
    function Cv = CvMassTP(obj, t, p)
      Cv = zeros(1,length(p));
      p = ConvertAndLimitPressure(obj, p);
      % CP mass is undefined on the saturation curve and therefore this
      % is avoided
      Tmax = obj.TDewP(obj.PressureMax/101000); % Make sure this works above the critical pressure.
      SatDiff = obj.PDewT(LimitValue(t, -273.15, Tmax))*100000 - p;
      idx = abs(SatDiff) < 1;
      p(idx) = p(idx) + 1; %sign(SatDiff(idx))
      for(k=1:length(p))
        Cv(k) = PropsSI('CVMASS','P', p(k),'T', t(k)+273.15, obj.Refrigerant);
      end
    end
    
    function Cp = CpMassHP(obj, h, p)
      Cp(k) = PropsSI('CPMASS','P', obj.press_to_mpa(p), 'H', h(k), obj.Refrigerant);
    end
    
    function Cv = CvMassHP(obj, h, p)
      Cv(k) = PropsSI('CVMASS','P',  obj.press_to_mpa(p),'H', h(k), obj.Refrigerant);
    end
    
    function Cv = CvMassTV(obj, t, v)
      Cv(k) = PropsSI('CVMASS','D', 1./v,'T', t+273.15, obj.Refrigerant);
    end
    
    % Mass specific gas constant (Truly constant but calculated at T=0°C and P=1bara)
    function Rm = Rmass(obj)
      v = obj.VTP(0, 1);
      Rmolar = PropsSI('GAS_CONSTANT',obj.Refrigerant); % J/mol/K
      Dmolar = PropsSI('DMOLAR','P', 100000,'T', 273.15, obj.Refrigerant); %mol/m^3
      Rm = Rmolar * v * Dmolar;
    end
    
    % Heat capacity ratio: https://en.wikipedia.org/wiki/Heat_capacity_ratio
    function Cp_r = CpRatioHP(obj, h, p)
      Cp = obj.CpMassHP(h,p);
      Cv = obj.CvMassHP(h,p);
      Cp_r = Cp./Cv;
    end
    
    % Heat capacity ratio: https://en.wikipedia.org/wiki/Heat_capacity_ratio
    function Cp_r = CpRatioTP(obj, t, p)
      %       v = obj.VTP(t, p);
      Cp = obj.CpMassTP(t,p);
      Cv = obj.CvMassTP(t,p);
      Cp_r = Cp./Cv;
    end
  end
end