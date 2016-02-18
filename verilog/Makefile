rom: data_rom.v tb_data_rom.v
	iverilog data_rom.v tb_data_rom.v -o rom
	iverilog data_rom.v differentiator.v tb_diff.v -o diff
	iverilog data_rom.v differentiator.v integrator.v tb_int.v -o int 

results:
	./int > results_int.dat

clean:
	rm int

compare:
	diff -wq results_diff.dat ../data/ecg_diff.dat
	diff -wq results_int.dat ../data/ecg_int.dat
