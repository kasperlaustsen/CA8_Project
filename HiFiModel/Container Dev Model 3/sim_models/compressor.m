% Unified model wrapper for cpr1, cpr2 and joining junction. 
function xdot = compressor(t,x,u,p)

hout       = x(1);
s1_hout    = x(2);
pim        = x(3);
mdotin_suc = x(4);
mdotout    = x(5);
h          = x(6);
m          = x(7);
Tfc        = x(8);% Temperature of frequency converter 

pin       = u(1); 
pout      = u(2);
hin_suc   = u(3);
hin_im    = u(4);
mdotin_im = u(5);
speed     = u(6);         % Speed [rotations per second]
FaultMode = u(7); %


% Call first compressor stage
%          pin pout hin     speed FaultMode
cpr1a_u = [pin pim  hin_suc speed FaultMode];
cpr1a_x = cpr1a(cpr1a_u);
cpr1a_hout = cpr1a_x(1);
cpr1a_mdot = cpr1a_x(2);

% Call second compressor stage
%          pin pout hin     speed FaultMode
cpr2a_u = [pim pout  h       speed FaultMode];
cpr2a_x = cpr2a(cpr2a_u);
cpr2a_hout = cpr2a_x(1);
cpr2a_mdot = cpr2a_x(2);

% Call the joining junction
%       hin1    hin2   mdotin1    mdotin2   mdotout
jj_u = [cpr1a_hout hin_im cpr1a_mdot mdotin_im cpr2a_mdot];
%       p   hout m
jj_x = [pim h    m];
jj_xdot = joining_junction(jj_x,jj_u);
jj_pdot  = jj_xdot(1);
jj_houtdot  = jj_xdot(2);
jj_mdot = jj_xdot(3);

hout_dot       = cpr2a_hout - hout;
s1_hout_dot    = cpr1a_hout - s1_hout;
pim_dot        = jj_pdot;
mdotin_suc_dot = cpr1a_mdot - mdotin_suc;
mdotout_dot    = cpr2a_mdot - mdotout;
h_dot          = jj_houtdot;
m_dot          = jj_mdot;
Tfc_dot        = 0;
% Make the xdot vector
xdot = [hout_dot s1_hout_dot pim_dot mdotin_suc_dot mdotout_dot h_dot m_dot Tfc_dot]';

% if(1 == CheckNanImg(x, u, xdot'))
%   hout_dot
%   s1_hout_dot
%   pim_dot
%   mdotin_suc_dot
%   mdotout_dot
%   h_dot 
%   m_dot
% end
