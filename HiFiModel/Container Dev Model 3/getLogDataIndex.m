function index = getLogDataIndex(logdata, IndexName)

index = 0;

for k = 1:size(logdata.Vars,1)
  if(strcmp(IndexName, logdata.Vars{k,2}))
    index = k;
    break
  end
end

if(index == 0)
  disp(['ERROR: getLogDataIndex could not finde a variable named "' IndexName '"']);
end