function plotfcn(model, clearfig)
%hep = 1

global Ref

N = size(model.x,2)-1;
model.x = model.x(:,1:N);
model.t = model.t(1:N);
t = model.t;
% x = model.x;
% size(x)



%% Get the gas temperatures
evap_T0 = Ref.TDewP(getSignal(model, 'evap.pout'));
econ_T0 = Ref.TDewP(getSignal(model, 'cpr.pim'));
econ_Hdew_Pim = Ref.HDewP(getSignal(model, 'cpr.pim'));
cond_P0 = Ref.PBubT(getSignal(model, 'ctrl.Tamb'));
cond_P0_opt = Ref.PBubT(getSignal(model, 'ctrl.Tamb')+11);
recv_TDew = Ref.TDewP(getSignal(model, 'cond_recv.pout'));
recv_Tv = Ref.THP(getSignal(model, 'cond_recv.hrefrig'), getSignal(model, 'cond_recv.pout'));
recv_Tl = Ref.THP(getSignal(model, 'cond_recv.hrefrig'), getSignal(model, 'cond_recv.pout'));
cond_Tv = Ref.THP(getSignal(model, 'cond_recv.hrefrig'), getSignal(model, 'cond_recv.pin'));
cond_Tl = Ref.THP(getSignal(model, 'cond_recv.hrefrig'), getSignal(model, 'cond_recv.pout'));
recv_HDew = Ref.HDewP(getSignal(model, 'cond_recv.pout'));
recv_HBub = Ref.HBubP(getSignal(model, 'cond_recv.pout'));
Tsuc = Ref.THP(getSignal(model, 'evap.hout'), getSignal(model, 'evap.pout'));
TsucMeas = getSignal(model, 'evap.Tsuc');

Ts1in = Ref.THP(getSignal(model, 'evap.hout'), getSignal(model, 'evap.pout'));
Ts1out = Ref.THP(getSignal(model, 'cpr.s1hout'), getSignal(model, 'cpr.pim'));
Timin = Ref.THP(getSignal(model, 'econ.hout2'), getSignal(model, 'cpr.pim'));
TSC = Ref.THP(getSignal(model, 'econ.hout1'), getSignal(model, 'econ.pout1'));
Ts2in = Ref.THP(getSignal(model, 'cpr.h'), getSignal(model, 'cpr.pim'));
Ts2out = Ref.THP(getSignal(model, 'cpr.hout'), getSignal(model, 'cond_recv.pin'));
% Trecvout = Ref.THP(getSignal(model, 'cond_recv.hout'), getSignal(model, 'cond_recv.pout'));
% Plot the reults

figure1 = figure(54);
set(figure1, 'Name', 'Overview');
if(clearfig)
  clf
end
%Create axes
ax54 = axes(...
  'XColor',[0.502 0.502 0.502],...
  'XGrid','on',...
  'YColor',[0.502 0.502 0.502],...
  'YGrid','on',...
  'ZColor',[0.502 0.502 0.502],...
  'Parent',figure1);
whitebg('k')
%hold(axes1,'all');
%   hold on
set(gcf, 'InvertHardCopy', 'off');

ax54(1) = subplot(321);
sim_plot(model, 'evap.pout', 'b'); % Suction pressure
hold on
sim_plot(model, 'cpr.pim', 'm'); % Intermidiate  pressure
sim_plot(model, 'cpr.pim', 'm--'); % Intermediate pressure
sim_plot(model, 'cpr.pim', 'm:'); %Intermediate pressure
sim_plot(model, 'cond_recv.pin', 'r');
sim_plot(model, 'cond_recv.pout', 'r--');
sim_plot(model, 'cond_recv.pout', 'r:');
sim_plot(model, 'econ.pout1', 'g--');
plot(model.t, cond_P0,'y')
plot(model.t, cond_P0_opt,'y:')
% handle = legend('s1in','s1out', 'imin', 's2suc', 's2out','condout', 'recvout','econexpout','econSCout','evapin', 'Location', 'BestOutside');
% set(handle, 'TextColor', 'w' )

ax54(2) = subplot(322);
sim_plot(model, 'evap.hout', 'b'); % Suction pressure
hold on
sim_plot(model, 'cpr.s1hout', 'm'); % Intermidiate  pressure
sim_plot(model, 'econ.hout2', 'm--'); % Intermediate pressure
sim_plot(model, 'cpr.h', 'm:'); %Intermediate pressure
sim_plot(model, 'cpr.hout', 'r');
sim_plot(model, 'cond_recv.hrefrig', 'r--');
sim_plot(model, 'cond_recv.hout', 'r:');
sim_plot(model, 'cond_recv.hout', 'g');
sim_plot(model, 'econ.hout1', 'g--');
handle = legend('s1in','s1out', 'imin', 's2suc', 's2out','condout', 'recvout','econin','econSCout'...
  , 'Location', 'BestOutside');
set(handle, 'TextColor', 'w' )

ax54(3) = subplot(323);
sim_plot(model, 'cpr.mdotin_suc', 'b');
hold on
sim_plot(model, 'cpr.mdotin_suc', 'm');
sim_plot(model, 'econ.mdotout2', 'm--');
sim_plot(model, 'cpr.mdotout', 'm:');
sim_plot(model, 'cpr.mdotout', 'r');
sim_plot(model, 'econ.mdotin1', 'r--');
sim_plot(model, 'econ.mdotin2', 'r:');
sim_plot(model, 'econ.mdotin2', 'g');
sim_plot(model, 'evap.mdotin', 'g--');
%handle = legend('s1in','s1out', 'imin', 's2suc', 's2out','condout', 'recvout','econexpout','evapin', 'Location', 'BestOutside');
%set(handle, 'TextColor', 'w' )
%ylim([-0.01 0.05])

ax54(5) = subplot(325);
sim_plot(model, 'ctrl.cpr_speed', 'b');
hold on
sim_plot(model, 'ctrl.evap_vexp', 'r');
plot(model.t, getSignal(model,'ctrl.econ_vexp'), 'Color', [0 0.5 0]);
plot(model.t, getSignal(model, 'ctrl.vfan_cond')*10, 'c');
plot(model.t, getSignal(model, 'ctrl.vfan_evap')*10, 'm');
plot(model.t, getSignal(model, 'ctrl.Hevap'), 'Color', [ 246, 96, 171]/256);
sim_plot(model, 'ctrl.intg_cpr', 'b:');
sim_plot(model, 'ctrl.intg_vexp', 'r:');
sim_plot(model, 'ctrl.dummy1', 'w');
sim_plot(model, 'ctrl.dummy2', 'm:');
% sim_plot(model, 'ctrl.fcpr_off_counter', 'w--');
handle = legend('Fcpr','Vexp','Veco', 'Mcond', 'Mevap','Hevap','intg-cpr','intg-vexp','dummy1','dummy2', 'Location', 'BestOutside');
set(handle, 'TextColor', 'w' )

% subplot(326)
% sim_plot(model, 'cond_recv.ml', 'b');
% hold on
% sim_plot(model, 'cond_recv.mg', 'b--');
% sim_plot(model, 'evap.m1', 'r');
% sim_plot(model, 'evap.m2', 'r--');
% sim_plot(model, 'econ.m1', 'g');
% sim_plot(model, 'econ.ml2', 'g--');
% sim_plot(model, 'econ.mg2', 'g:');
% sim_plot(model, 'evap.sigma', 'y');
% sim_plot(model, 'cond_recv.ml', 'm');
% legend('cond_recv.ml','cond_recv.mg','evap.m1','evap.m2','econ.m1','econ.ml2','econ.mg2','evap.sigma','cond_recv.ml', 'Location', 'BestOutside')



if(0) % Mass plot
  figure57 = figure(57);
  set(figure55, 'Name', 'Mass plot')
  if(clearfig)
    clf
    
    %Create axes
    axes1 = axes(...
      'XColor',[0.502 0.502 0.502],...
      'XGrid','on',...
      'YColor',[0.502 0.502 0.502],...
      'YGrid','on',...
      'ZColor',[0.502 0.502 0.502],...
      'Parent',figure55);
    whitebg('k')
  end
  set(gcf, 'InvertHardCopy', 'off');

  sim_plot(model, 'evap.m1', 'b');
  hold on
  title('Mass Plot')
  sim_plot(model, 'evap.m2', 'b--');
  sim_plot(model, 'cpr.m', 'm--');
  sim_plot(model, 'cond_recv.m', 'r');
  sim_plot(model, 'cond_recv.ml', 'g');
  sim_plot(model, 'cond_recv.mg', 'g--');
  sim_plot(model, 'econ.m1', 'y');
  sim_plot(model, 'econ.m2', 'y--');
  handle = legend('evap.m1','evap.m2', 'jj.m','cond_recv.m', 'cond_recv.ml', 'cond_recv.mg',...
    'econ.m1','econ.m2','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
end

% Mass verification plot
if(1) % Mass plot
  h = figure(58);
  set(h, 'Name', 'Mass verification');
  if(clearfig)
    clf
    
    %Create axes
    axes1 = axes(...
      'XColor',[0.502 0.502 0.502],...
      'XGrid','on',...
      'YColor',[0.502 0.502 0.502],...
      'YGrid','on',...
      'ZColor',[0.502 0.502 0.502],...
      'Parent',h);
    whitebg('k')
  end
  set(gcf, 'InvertHardCopy', 'off');

  %subplot(211)
  
  total_mass = getSignal(model, 'evap.m1') + ...
               getSignal(model, 'evap.m2') + ...
               getSignal(model, 'cpr.m') + ...
               getSignal(model, 'cond_recv.mrefrig') + ...
               getSignal(model, 'econ.m1') + ...
               getSignal(model, 'econ.m2');
                   
  evap_mass11 = getSignal(model, 'evap.m1');
  evap_mass12 = getSignal(model, 'evap.m2');            
  evap_mass1 = evap_mass11 + evap_mass12;
  evap_mass2 = evap_mass1(1) + cumsum(getSignal(model, 'evap.mdotin')-getSignal(model, 'cpr.mdotin_suc'));
  %evap_diff = 1.3 + evap_mass1 - evap_mass2;
 
  cpr_mass1 = getSignal(model, 'cpr.m'); 
  cpr_mass2 = cpr_mass1(1) + cumsum(getSignal(model, 'cpr.mdotin_suc') + getSignal(model, 'econ.mdotout2')...
    - getSignal(model, 'cpr.mdotout'));
  
  cond_mass1 = getSignal(model, 'cond_recv.mrefrig');
  cond_mass2 = cond_mass1(1) + cumsum(getSignal(model, 'cpr.mdotout')-getSignal(model, 'econ.mdotin1')-getSignal(model, 'econ.mdotin2'));
  
  econ1_mass1 = getSignal(model, 'econ.m1'); 
  econ1_mass2 = econ1_mass1(1) + cumsum(getSignal(model, 'econ.mdotin1')-getSignal(model, 'evap.mdotin'));
  
  econ2_mass1 = getSignal(model, 'econ.m2'); 
  econ2_mass2 = econ2_mass1(1) + cumsum(getSignal(model, 'econ.mdotin2')-getSignal(model, 'econ.mdotout2'));
  
  plot(evap_mass1, 'b-')
  hold on
  title('Mass Verification Plot')
  grid on
  plot(evap_mass11, 'b:')
  plot(evap_mass12, 'b.-')
  plot(evap_mass2, 'b--')
  %plot(evap_diff, 'b--')
  plot(cpr_mass1, 'r-')
  plot(cpr_mass2, 'r--')
  plot(cond_mass1, 'g-')
  plot(cond_mass2, 'g--')
  plot(econ1_mass1, 'c-')
  plot(econ1_mass2, 'c--')
  plot(econ2_mass1, 'm-')
  plot(econ2_mass2, 'm--')
  plot(total_mass, 'w')
  handle = legend('evap.total','evap.m1','evap.m2','evap.cumsum', 'cpr.total','cpr.cumcum', 'cond.total', 'cond.cumsum', ...
  'econ.m1total','econ.m1cumsum','econ.m2total','econ.m2cumsum','Total','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
end

% evaporator
if(1)
  figure1 = figure(59);
  set(figure1, 'Name', 'Evaporator');
  if(clearfig)
    clf
  end
  %Create axes
  axes1 = axes(...
    'XColor',[0.502 0.502 0.502],...
    'XGrid','on',...
    'YColor',[0.502 0.502 0.502],...
    'YGrid','on',...
    'ZColor',[0.502 0.502 0.502],...
    'Parent',figure1);
  whitebg('k')
set(gcf, 'InvertHardCopy', 'off');

  ax(1) = subplot(411);
  pref = Ref.PDewT(getSignal(model,'box.Tret')-8);
  sim_plot(model, 'evap.pout', 'r');
  hold on
  plot(model.t,pref,'b');
  plot(model.t,getSignal(model,'ctrl.evap_vexp')/20,'y');
  plot(model.t,getSignal(model,'ctrl.cpr_speed')/20,'g');
  handle = legend('pout','pref','Vexp/20','Fcpr/20','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  title('Evaporator')
  ylim([0 5])
  
  ax(2) = subplot(412);
  sim_plot(model, 'evap.h1', 'b');
  hold on
  sim_plot(model, 'evap.hout', 'r');
  ylim([0 500000])
  handle = legend('h1','h2','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  
  ax(3) = subplot(413);
  sim_plot(model, 'ctrl.vfan_evap', 'g');
  hold on
  sim_plot(model, 'evap.m1', 'b');
  sim_plot(model, 'evap.m2', 'r');
  sim_plot(model, 'evap.sigma', 'y');
  sim_plot(model, 'evap.mdotair', 'm');
 
  handle = legend('Mevap','m1','m2','sigma','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  
  ax(4) = subplot(414);
  sim_plot(model, 'evap.Tm1', 'b');
  hold on
  sim_plot(model, 'evap.Tm2', 'b:');
  sim_plot(model, 'evap.Tsup', 'r');
  sim_plot(model, 'box.Tret', 'r:');
  sim_plot(model, 'evap.Tevap', 'w');
  sim_plot(model, 'evap.Tsuc', 'w:');
  plot(t, Tsuc-evap_T0,'y:');
  sim_plot(model, 'SysMon.Tsh', 'y');
  sim_plot(model, 'ctrl.dummy3', 'm');
  plot(t, evap_T0,'g');
  handle = legend('Tm1','Tm2','Tsup','Tret','Tevap','Tsuc','Tsh','TshMeas','TshRef','T0','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  ylim([-50 30])
  linkaxes(ax, 'x')
  AlignAxesVert(ax);

  %   handle = legend('evap.m1','evap.m2', 'jj.m', 'cond_recv.ml','cond_recv.mg', 'cond_recv.ml','cond_recv.mg',...
  %     'econ.m1','econ.m2','Location', 'BestOutside');
  %   set(handle, 'TextColor', 'w' )
end

% cond
if(1)
  figure1 = figure(60);
  set(figure1, 'Name', 'Condenser');
  if(clearfig)
    clf
  end
  set(gcf, 'InvertHardCopy', 'off');

  %Create axes
  axes1 = axes(...
    'XColor',[0.502 0.502 0.502],...
    'XGrid','on',...
    'YColor',[0.502 0.502 0.502],...
    'YGrid','on',...
    'ZColor',[0.502 0.502 0.502],...
    'Parent',figure1);
  whitebg('k')
  ax = [];
  ax(1) = subplot(411);
  sim_plot(model, 'cond_recv.pin', 'b');
  hold on
  title('cond')
  sim_plot(model, 'cond_recv.pout', 'r');
  handle = legend('pin','pout','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  title('cond')
  
  ax(2) = subplot(412);
  sim_plot(model, 'cond_recv.refrig', 'b');
  hold on
  sim_plot(model, 'cond_recv.hv_c', 'r');
  sim_plot(model, 'cpr.hout', 'g');
  handle = legend('hl','hv','hin','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  
  ax(3) = subplot(413);
  sim_plot(model, 'cond_recv.mrefrig', 'b');
  hold on
  plot(model.t, getSignal(model,'cpr.mdotout')*10,'g')
  plot(model.t, getSignal(model,'econ.mdotin1')*10,'m')
  plot(model.t, getSignal(model,'econ.mdotin2')*10,'m')
  sim_plot(model, 'cond_recv.mdotair', 'y:');
  handle = legend('mrefrig','mdotin*10','mdotout1*10', 'mdotout2*10','mdotair','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  grid on
  
  ax(4) = subplot(414);
  sim_plot(model, 'cond_recv.Tm', 'g');
  hold on
  sim_plot(model, 'ctrl.Tamb', 'g:');
  plot(model.t, Ts2out,'y')
  plot(model.t, cond_Tl,'b')
  plot(model.t, cond_Tv,'r')
  sim_plot_scale(model, 'ctrl.vfan_cond','m', 10);
  handle = legend('Tm','Tamb','Tin','Tl','Tv','Mcond*10','Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  linkaxes(ax, 'x')
  AlignAxesVert(ax)
end

figure(54)
sp234 = subplot(324);
ax54(4) = sp234;
Tsh = TsucMeas - evap_T0;
%if(clearfig)
  %   axes('Position',[0.55 0.1 0.4 0.5192])
  set(sp234, 'Position',[0.55 0.1 0.35 0.5192])
%end
plot(t,evap_T0,'y')
hold on
sim_plot(model, 'evap.Tm1', 'y-.');
sim_plot(model, 'ctrl.Tamb', 'm--');
sim_plot(model, 'box.Tret', 'w');
sim_plot(model, 'evap.Tsup', 'w--');
sim_plot(model, 'box.Talu', 'w:');
sim_plot(model, 'box.Tcargo', 'w-.');
plot(t,Ts1in,'b')
sim_plot(model, 'ctrl.evap_Tsuc', 'b:');
plot(t,Ts1out,'b--')
plot(t,Tsh,'r:')
plot(t,Timin,'m')
plot(t,econ_T0,'y--')
plot(t,TSC,'m:')
sim_plot(model, 'econ.Tm', 'y:');
plot(t,Ts2in,'r')
plot(t,Ts2out,'r--')
sim_plot(model, 'cond_recv.Tm', 'g');
plot(t,cond_Tl,'g--')
handle = legend('evap.T0','evap.Tm1','Tamb','Tret','Tsup','Talu','Tcargo','Ts1in','TsucFilt','Ts1out','Tsh','Timin',...
  'econT0','TSC','econ.Tm','Ts2in','Ts2out','cond_recv.Tm', 'Tcondout', 'Location', 'BestOutside');
set(handle, 'TextColor', 'w' )
ylim([-50 100])
linkaxes(ax54, 'x')
%%
% Energy plot
if(0)
figure1 = figure(61);
set(figure1, 'Name', 'Energy');
  if(clearfig)
    clf
  end
  %Create axes
  axes1 = axes(...
    'XColor',[0.502 0.502 0.502],...
    'XGrid','on',...
    'YColor',[0.502 0.502 0.502],...
    'YGrid','on',...
    'ZColor',[0.502 0.502 0.502],...
    'Parent',figure1);
  whitebg('k')
  set(gcf, 'InvertHardCopy', 'off');

Q_cool_ref = (getSignal(model, 'evap.hout') - getSignal(model, 'econ.hout1')) .* getSignal(model, 'cpr.mdotin_suc');
Cp_air = 1.0035e3; % [J/(kg*K)]
% Cp_air = 1.5e3;
rho_air = 1.3 + getSignal(model, 'box.Tret') * -0.005;
vfan = getSignal(model,'ctrl.vfan_evap');
mdotair = (-(vfan.^2)*200 + vfan*2600)/3600.*rho_air;
Q_cool_air = (getSignal(model, 'box.Tret') - getSignal(model, 'evap.Tsup')).*mdotair*Cp_air;
% [b,a] = butter(1,0.005*0.5);
% Q_cool_air_filt = filtfilt(b,a,Q_cool_air(2:end));
plot(t,Q_cool_ref,'b')
hold on
plot(t,Q_cool_air,'r')
% plot(t(1:end-1),Q_cool_air_filt,'c')
sim_plot(model, 'ctrl.Q_ref', 'g');
plot(t, getSignal(model, 'ctrl.Q_int')/1000, ':');
sim_plot(model, 'ctrl.dummy3', 'w');
handle = legend('Qcool-ref','Qcool-air','Q-ref','Q-int/1000','Q\_req','Location','BestOutSide');
set(handle, 'TextColor', 'w' )
xlabel('Time [s]')
ylabel('[W]')
% ylim([0 1.2*max(Q_cool_ref)])
% LogP,h system plot
end


if(1)
figure1 = figure(62);
set(figure1, 'Name', 'Box');
if(clearfig)
    clf
  end
  %Create axes
  axes1 = axes(...
    'XColor',[0.502 0.502 0.502],...
    'XGrid','on',...
    'YColor',[0.502 0.502 0.502],...
    'YGrid','on',...
    'ZColor',[0.502 0.502 0.502],...
    'Parent',figure1);
  whitebg('k')
  set(gcf, 'InvertHardCopy', 'off');

sim_plot(model, 'evap.Tsup', 'c');
hold on
sim_plot(model, 'box.Talu', 'b');
sim_plot(model, 'box.Tret', 'r');
sim_plot(model, 'box.Tcargo', 'g');
sim_plot(model, 'ctrl.Tamb', 'y');
sim_plot(model, 'ctrl.Tset', 'm');

handle = legend('Tsup','Talu','Tret','Tcargo','Tamb','Tset');
set(handle, 'TextColor', 'w' )
xlabel('Time [s]')
ylabel('Temperature[C]')
title('Box')
end

% Economizer
if(1)
  figure1 = figure(63);
  set(figure1, 'Name', 'Economizer');
  if(clearfig)
    clf
  end
  %Create axes
  axes1 = axes(...
    'XColor',[0.502 0.502 0.502],...
    'XGrid','on',...
    'YColor',[0.502 0.502 0.502],...
    'YGrid','on',...
    'ZColor',[0.502 0.502 0.502],...
    'Parent',figure1);
  whitebg('k')
  set(gcf, 'InvertHardCopy', 'off');
  %'econ.pout1'    'econ.hout1'    'econ.mdotin1'    'econ.hout2'
  %'econ.mdotin2'    'econ.mdotout2'    'econ.m1'    'econ.m2'    'econ.Tm'
 ax(1) = subplot(511);
  sim_plot(model, 'cond_recv.pout', 'b');
  hold on
  sim_plot(model, 'econ.pout1', 'b:');  
  sim_plot(model, 'cond_recv.pout', 'r.');
  sim_plot(model, 'cpr.pim', 'r:');
  handle = legend('pin1', 'pout1', 'pin2', 'pout2', 'Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  ylabel('Pressure [Bar]')
  title('Economizer')
  
  ax(2) = subplot(512);
  sim_plot(model, 'econ.m1', 'b');
  hold on
  sim_plot(model, 'econ.m2', 'r');
  handle = legend('m1', 'm2', 'Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  ylabel('Mass [kg]')
  
  ax(3) = subplot(513);
  sim_plot(model, 'econ.mdotin1', 'b');
  hold on
  sim_plot(model, 'evap.mdotin', 'b:');
  sim_plot(model, 'econ.mdotin2', 'r');
  sim_plot(model, 'econ.mdotout2', 'r:');
  handle = legend('mdotin1', 'mdotout1', 'mdotin2', 'mdotout2', 'Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  ylabel('Mass flow [kg/s]')
  
  ax(4) = subplot(514);
  sim_plot(model, 'econ.hout1', 'b');
  hold on
  sim_plot(model, 'econ.hout2', 'r');
  plot(t, econ_Hdew_Pim, 'r:');
  sim_plot(model, 'cond_recv.hout', 'y');
  handle = legend('hout1_{evap}', 'hout2_{cpr}', 'hout2_{cpr-dew}','hin', 'Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  
  ax(5) = subplot(515);
  plot(t,cond_Tl, 'r');
  hold on  
  plot(t,TSC, 'b');
  plot(t,econ_T0, 'm');
  plot(t,Timin, 'y--');
  sim_plot(model, 'econ.Tm', 'c');
  

  handle = legend('Tin', 'TSC_{out1}','T0_{econ}','Tsuc_{econ}','Tm', 'Location', 'BestOutside');
  set(handle, 'TextColor', 'w' )
  ylim([-30 50])
  xlabel('Time [s]')
  ylabel('Temp [^{\circ}C]')
  linkaxes(ax, 'x')
  AlignAxesVert(ax)
  
end



