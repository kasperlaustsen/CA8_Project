function UpdateLogPhPlot(SimModel, Sample, logph_plot_handle)
% Get the data for the logP-h figure, start at reciever output
ydata = [SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.p'),Sample)...      % 1
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'econ.pout1'),Sample)...  % 2 
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'evap.pout'),Sample)...   % 3 
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'evap.pout'),Sample)...   % 4
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.pim'),Sample)...        % 5
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.pim'),Sample)...        % 6
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cond.pin'),Sample)...    % 7 
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.p'),Sample)...      % 8
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.p'),Sample)...      % 9
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.pim'),Sample)...        % 10
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.pim'),Sample)];     % 11
        
xdata = [SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.hout'),Sample)...   % 1
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'econ.hout1'),Sample)...  % 2
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'econ.hout1'),Sample)...  % 3
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'evap.hout'),Sample)...   % 4
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.s1hout'),Sample)...   % 5 stage 1 out
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.h'),Sample)...     % 6
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.hout'),Sample)...   % 7
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cond.h'),Sample)...      % 8 
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.hout'),Sample)...   % 9
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'recv.hout'),Sample)...   % 10
         SimModel.x(getAbsStateIndexFast(SimModel.absstatelist,'cpr.h'),Sample)];      % 11 


  set(logph_plot_handle,'Xdata', xdata, 'Ydata', ydata);
