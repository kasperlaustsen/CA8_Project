function ScaledLimit = CalcScaledCapLimit(In, LimitStart, Limit, LimitMax)

degree = 2;

ScaledLimit = zeros(1,length(In));
for(k = 1:length(In))
  if(Limit > LimitStart) % Positive direction limiter (Tc, Tfc, Itot, Ifc)
    if(In(k) <= Limit) % Still allowed to increase
      ScaledLimit(k) = Pctrl(In(k), LimitStart, Limit, 1, 0)^degree;
    else  % Decrease cap
      ScaledLimit(k) = -(Pctrl(In(k), Limit, LimitMax, 0, 1)^degree);      
    end
  else % Negative direction limiter (T0)
     if(In(k) >= Limit) % Still allowed to increase
      ScaledLimit(k) = Pctrl(In(k), Limit, LimitStart, 0, 1)^degree;
    else  % Decrease cap
      ScaledLimit(k) = -(Pctrl(In(k), LimitMax, Limit, 1, 0)^degree);
    end
  end  
end
end

