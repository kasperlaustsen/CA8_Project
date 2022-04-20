function x = FaultSimulator(t,x,u,p)

if(t == 1)
  CprFault = 0;
  EvapFault = 0.0
else
  CprFault = x(1);
  EvapFault = x(2);
end

% if(t == 3000)
%   CprFault = 0.2
% end

if(0)
  
%   if(t == 360)
%     EvapFault = 0.01;
%   end
  
  if(t == 900)
    EvapFault = 0.4;
  end
  
  if(t == 1800)
    EvapFault = 1.4;
  end
  
  if(t == 2400)
    EvapFault = 0
  end
  
  if(t == 3000)
    CprFault = 0.3
  end
  
  if(t == 3500)
    EvapFault = 0.5
  end
  
  if(t == 4000)
    EvapFault = 1.2
  end
else
%   CprFault = 0;
  EvapFault = 0;
end
%Cpr1Fault = 1;
  
x = [CprFault EvapFault]';