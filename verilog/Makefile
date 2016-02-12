rom: data_rom.v tb_data_rom.v
	iverilog data_rom.v tb_data_rom.v -o rom
	iverilog data_rom.v differentiator.v tb_diff.v -o diff

results:
	./diff > results_diff.dat

clean:
	rm rom results_diff.dat

compare:
	diff -wq results_diff.dat ../data/ecg_diff.dat
