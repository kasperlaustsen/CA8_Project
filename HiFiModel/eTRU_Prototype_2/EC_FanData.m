%
% Measured and einterpolated used power and airlow versus speed and
% pressure difference for EC Fan.
% Data based on given data sheet, missing values determied by linear
% interpolation.
% hjn 13/7-20
%

Speed = [0,1840,2450,3060];
Pressure = [0,127,217,225,316,349,383,559,607,865];

AirFlow = [0 0 0 0 0 0 0 0 0 0; ...
    2205 1950 1701 1679 1297 658 0 0 0 0; ...
    2989 2767 2610 2594 2410 2343 2274 1771 0 0; ...
    3704 3545 3432 3422 3307 3266 3216 2958 2888 2215];

Power = [5 5 5 5 5 5 5 5 5 5; ...
    185 203 227 226 229 230 231 237 239 247; ...
    420 442 458 461 496 509 522 528 530 538; ...
    764 811 844 846 880 892 905 969 987 989];


