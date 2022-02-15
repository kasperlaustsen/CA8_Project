function value = LimitValue(value, min_lim, max_lim)


if(value < min_lim)
  value = min_lim;
elseif(value > max_lim)
  value = max_lim;
end
  
