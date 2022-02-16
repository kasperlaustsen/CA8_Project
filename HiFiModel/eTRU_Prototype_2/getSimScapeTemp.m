function data_ts = getSimScapeTemp(Ref, sim_result, name_p, name_u)

u = sim_result.getElement(name_u).Values.Data*1000;
p = sim_result.getElement(name_p).Values.Data;
t = sim_result.getElement(name_p).Values.Time;
idx = getReducedSampleRateIdx(t, 1);
data_ts = timeseries(Ref.TPU(p(idx),u(idx)), t(idx));