% 
global Ref




ambient_temp = 20;

box_start_temp = 20;

start_pressure_high = Ref.PDewT(ambient_temp)
start_pressure_im = Ref.PDewT(ambient_temp) + 1
start_pressure_low = Ref.PDewT(box_start_temp) + 2

cargo_start_temp = box_start_temp;
cargo_mass = 1000;



eTRU_controller_init