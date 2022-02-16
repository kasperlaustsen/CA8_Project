% First order filter function, must be
% called for each sample but can handle multiple values from the same sample
% at once.
% Usage:
% out = ffilter(old, new, tau_up, tau_down)
% old = old value, last output fom filter
% new = new input value
% tau_up = time constant for increasing values (and decreasing values if tau_down isn't given)
% tau_up = time constant for dereasing values


function out = ffilter(old, new, tau_up, tau_down)

if(nargin < 4)
  tau_down = tau_up;
end

if(new > old)
  tau = tau_up;
else
  tau = tau_down;
end

out = ((old * tau) + new) ./ (tau+1);