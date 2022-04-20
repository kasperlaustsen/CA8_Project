function Result = EconCalc(Tdiff, Vexp, ssGain1, ssC)



slTmp = uint32(Tdiff*100)              % [0..10000]
slTmp = slTmp * slTmp                  %    (Tc'-To')^2  [0..100000000]
slTmp = slTmp / 10000                  % [0..10000]
slTmp = slTmp * ssGain1 + ssC * 100    % (A*(Tc-To)^2 + C, max 2297000
slTmp = slTmp * Vexp
slTmp = slTmp / 1000000
Result = LimitValue(slTmp, 0, 100)