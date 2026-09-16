`timescale 1ns/1ps 

module mux2( 
	input logic a, 
	input logic b, 
	input logic sel, 
	output logic y); 
	
	always_comb begin 
		if(sel) begin 
			y=b; 
		end else begin 
			y= a; 
		end
	end
	endmodule 
