%close all
clear all
global Ref

LETools_root = getLETools_root();

load([LETools_root '/CoolProp/Maps/HEOS__R134a.mat'])

Ref = R134aM;

% Test the Condenser/Receiver model
% Steady state
% pout    = x(1);
% hout    = x(2);
% pin     = x(3);
% hr      = x(4);
% mr      = x(5);
% Tm      = x(6);
% mdotair = x(7);
% Tc      = x(8);
% 
% hin      = u(1);
% mdotin   = u(2);
% vfan     = u(3);
% Tamb     = u(4);
% mdotout1 = u(5);
% mdotout2 = u(6);

Tamb0 = 20;

x0 = [5 250000 5 300000 0.5 Tamb0 0 Tamb0];
u0 = [450000 0.005 2 Tamb0 0.005 0];
dt = 0.1;

T = 1:dt:1250;
X = zeros(length(T), length(x0));
U = zeros(length(T), length(u0));

X(1,:) = x0;
U(1,:) = u0;

for(k = 1:length(T)-1)
  xdot = condenser_receiver(0,X(k,:),u0,[]);
  X(k+1,:) = xdot'*dt + X(k,:);
  U(k+1,:) = U(k,:);
end

pout    = X(:,1);
hout    = X(:,2);
pin     = X(:,3);
hr      = X(:,4);
mr      = X(:,5);
Tm      = X(:,6);
mdotair = X(:,7);
Tc      = X(:,8);

hin      = U(:,1);
mdotin   = U(:,2);
vfan     = U(:,3);
Tamb     = U(:,4);
mdotout1 = U(:,5);
%mdotout2 = u(6);

figure(2)
clf
subplot(3,1,1)
plot(T, pin, 'r')
hold on
plot(T, pout, 'b')
plot(T, Ref.PBubT(Tamb'), 'g')
legend('Pin', 'Pout', 'P(Tamb)', 'location', 'bestoutside')

subplot(3,1,2)
plot(T, hin, 'r')
hold on
plot(T, hout, 'b')
plot(T, hr, 'g')
plot(T, Ref.HBubP(pout'), 'c');
plot(T, Ref.HDewP(pout'), 'm');
legend('hin', 'hout', 'hr', 'HBub', 'HDew', 'location', 'bestoutside')

subplot(3,1,3)
plot(T, Ref.THP(hin, pin), 'r')
hold on
plot(T, Ref.THP(hout,pout), 'b')
plot(T, Ref.THP(hr, pout), 'g')
plot(T, Tm, 'y')
plot(T, Tamb, 'm')
plot(T, Tc, 'c')
legend('Tin', 'Tout', 'Tref', 'Tm', 'Tamb' , 'Tc', 'location', 'bestoutside')

