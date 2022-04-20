% The splitting junction is quite simple because the states are simply
% dictated by the inputs. The output pressures and enthalpys are the same
% as that of the input and the input mass flow is equal to the sum of the
% two output mass flows. This function is solved by a single call because
% of its simplicity and therefore it must supply a new value for x instead
% of its derivative as used for ODE solvers. 

function x = splitting_junction(t,x,u,p)

pout1 = x(1);
hout1 = x(2);
pout2 = x(3);
hout2 = x(4);
mdotin = x(5);

pin = u(1);
hin = u(2);
mdotout1 = u(3);
mdotout2 = u(4);

pout1 = pin;
pout2 = pin;
hout1 = hin;
hout2 = hin;
mdotin = mdotout1 + mdotout2;

x = [pout1 hout1 pout2 hout2 mdotin]';
