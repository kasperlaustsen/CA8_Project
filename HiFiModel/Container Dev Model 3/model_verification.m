global ld
global LogData



LogDataTemp = LogData;
%   DataFile = 'C:\MATLAB\work\ControlDev\Tools\MaSCHIL\data\cap_ctrl_steps_MCI_061009.mat';
DataFile = 'C:\MATLAB\work\ControlDev\Tools\MaSCHIL\data\model_verification3_cap_ctrl_steps_MCI_021009.mat'
load(DataFile)
ld = LogData;
LogData = LogDataTemp;
range = 1:length(ld.TimeVector)-1;
range = 1:3600*3;

PdisModel = ld.SampleValues(getLogDataIndex(ld, 'Pdis'),range);
PdisMeas = ld.SampleValues(getLogDataIndex(ld, 'PdisM'),range);
TcModel = getRefrigDewTemp(PdisModel);
TcMeas = getRefrigDewTemp(PdisMeas);
TcErr = mean(abs(TcMeas - TcModel))%./abs(TcMeas))*100

TsupMeas = ld.SampleValues(getLogDataIndex(ld, 'TsupM'),range);
TsupModel = ld.SampleValues(getLogDataIndex(ld, 'Tsup1'),range);
TsupErr = mean(abs(TsupMeas - TsupModel))%./abs(TsupMeas))*100

TretMeas = ld.SampleValues(getLogDataIndex(ld, 'TretM'),range);
TretModel = ld.SampleValues(getLogDataIndex(ld, 'Tret'),range);
TretErr = mean(abs(TretMeas - TretModel))%./abs(TretMeas))*100

T0Meas = ld.SampleValues(getLogDataIndex(ld, 'T0M'),range);
T0Model = ld.SampleValues(getLogDataIndex(ld, 'T0'),range);
T0Err = mean(abs(T0Meas - T0Model))%./abs(T0Meas))*100

TsucMeas = ld.SampleValues(getLogDataIndex(ld, 'TsucM'),range);
TsucModel = ld.SampleValues(getLogDataIndex(ld, 'Tsuc'),range);
TsucErr = mean(abs(TsucMeas - TsucModel))%./abs(TsucMeas))*100

QCoolActModel = ld.SampleValues(getLogDataIndex(ld, 'QCoolAct'),range);
QCoolActMeas = ld.SampleValues(getLogDataIndex(ld, 'QCoolActM'),range);
QCoolRef = ld.SampleValues(getLogDataIndex(ld, 'QCoolRef'),range);
index = find(QCoolActMeas > 100);
QCoolActErr = mean(abs(QCoolActMeas(index) - QCoolActModel(index)))%./abs(QCoolActMeas(index)))*100

% figure(2)
% plot((abs(QCoolActMeas(index) - QCoolActModel(index))./abs(QCoolActMeas(index))))

n = 1:length(PdisModel);
t = (n)/60;

width = 0.67;
color = [1 1 1]*0.7;
figure(1)
clf
ax(1) = subplot(411);
whitebg('w')
plot(t,QCoolActModel,'k');
hold on
plot(t,QCoolActMeas,'Color',color);
plot(t,QCoolRef,'k--');
ylabel('Cooling Cap [W]')
set(gca,'xtick',[])
leg = legend('Model','Meas','Reference','Location','BestOutside');
set(leg, 'FontSize',12);
pos = get(gca,'Position');
set(gca, 'Position', [pos(1:2) width pos(4)])
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12)
set(gca,'FontSize',12)
ylim([0 5000])

ax(2) = subplot(412);
whitebg('w')
plot(t,TcModel,'k');
hold on
plot(t,TcMeas,'Color',color);
ylabel('Temp [C^\circ]')
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12)
leg = legend('Tcond Model','Tcond Meas','Location','BestOutside');
set(leg, 'FontSize',12);
pos = get(gca,'Position');
set(gca, 'Position', [pos(1:2) width pos(4)])
set(gca,'xtick',[])
set(gca,'FontSize',12)
ylim([16 30])

ax(3) = subplot(413);
whitebg('w')
plot(t,TsupModel,'k');
hold on
plot(t,TsupMeas,'Color',color);
plot(t,TretModel,'k--');
plot(t,TretMeas,'--','Color',color);
leg = legend('Tsup Model','Tsup Meas','Tret Model','Tret Meas','Location','BestOutside');
set(leg, 'FontSize',12);
ylabel('Temp [C^\circ]')
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12)
pos = get(gca,'Position');
set(gca, 'Position', [pos(1:2) width pos(4)])
set(gca,'xtick',[])
set(gca,'FontSize',12)
ylim([-28 -18])

ax(4) = subplot(414);
whitebg('w')
plot(t,T0Model,'k');
hold on
plot(t,T0Meas,'-','Color',color);
plot(t,TsucMeas,'k--');
plot(t,TsucModel,'--','Color',color);
leg = legend('T0 Model','T0 Meas','Tsuc Model','Tsuc Meas','Location','BestOutside');
set(leg, 'FontSize',12);
ylabel('Temp [C^\circ]')
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12)
xlabel('Time [min]');
xlhand = get(gca,'xlabel');
set(xlhand,'fontsize',12)
pos = get(gca,'Position');
set(gca,'FontSize',12)
set(gca, 'Position', [pos(1:2) width pos(4)])
ylim([-31 -17])

linkaxes(ax,'x')%set(gcf, 'PaperUnits', 'centimeters')

%set(gcf,' PaperPosition', [0.634518 5.22718 28.4084 15.1223])
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperOrientation', 'landscape');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0.634518 5.22718 28.4084 15.1223]);


print -deps model_results.eps
xlim([0 35])
ylim(ax(1),[0 3000])
ylim(ax(2),[16 30])
ylim(ax(3),[-22 -17])
ylim(ax(4),[-25 -19])
print -deps model_results_PWM.eps
xlim([0 t(end)])
ylim(ax(1),[0 5000])
ylim(ax(2),[16 30])
ylim(ax(3),[-28 -18])
ylim(ax(4),[-31 -17])


