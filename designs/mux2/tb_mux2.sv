`timescale 1ns/1ps 

module tb_mux2; 

	logic a; 
	logic b; 
	logic sel; 
	logic y; 

	mux2 dut(
		.a(a), 
		.b(b),
		.sel(sel), 
		.y(y) 
		);

		initial begin 
			//select a when sel is 0
			a= 1'b0; 
			b= 1'b1; 
			sel = 1'b0; 
			#1; 
			if(y !== 1'b0)
				$fatal(1, "Test 1 fatal: expected y=0"); 
