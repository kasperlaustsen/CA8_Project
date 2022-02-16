function Result = Pctrl(Input, Minin, Maxin, Minout, Maxout)

Result = Input;

for(k = 1:length(Input))
  if (Input(k) < Minin)
    Result(k) = Minout;
  elseif (Input(k) > Maxin)
    Result(k) = Maxout;
  else
    % P control
    if (Minin < Maxin)
      Result(k) =  Minout + (Input(k)-Minin)*(Maxout-Minout) / (Maxin - Minin);
    else
      Result(k) =  Minout;
    end
  end
end
