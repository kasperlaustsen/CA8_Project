clear all
clc




% Do a multistep heat transfer calculation starting with ToutL and TinE and
% step forward through the economizer. At the end the difference between
% the resulting TinL and the actual TinL will give the derivative of ToutL. 
% The derivative of ToutE is the difference between actual ToutL and the
% just calculated ToutL

% Liquid side
% ToutL              TinL   
% ------------------------
% TinE               ToutE
% Evaporation side

N = 5;

Tin_l(1) = 30
Tout_l(1) = 5
m_l(1) = 0.5;
Cpl = 200;

Tin_e(1) = 4;
Tout_e(1) = 25
m_e(1) = 0.2;
Cpe = 100;

alfa_sh = 2;
alfa_liq = 100;

for(i = 1:N)
  Qle = (Tout_l(i) - Tin_e(i))*alfa_sh
  Tin_e(i+1) = Tin_e(i) + Qle /(m_e*Cpe)
  Tout_l(i+1) = Tout_l(i) - Qle /(m_l*Cpl)
  
end










