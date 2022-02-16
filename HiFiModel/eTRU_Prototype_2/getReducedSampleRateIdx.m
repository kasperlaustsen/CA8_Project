% Return idx with for data points with sample rate reduced to tx
function idx = getReducedSampleRateIdx(time, ts)

t = time/ts;
idx = islocalmin(t-floor(t));
idx(1) = 1;
idx(end) = 1;

end