`include "../simpletestdir/simple_build/simple_dpi_pkg.sv"
import simple_dpi_pkg::*;

module tb_top();

	// -- Clocks and reset
    bit clk;
    bit clk_enable;
    bit reset;
	
	// -- inputs
    /* Simulink signal name: 'inputArg1' */
    bit [7:0] inputArg1 ;
    /* Simulink signal name: 'inputArg2' */
    bit [7:0] inputArg2 ;
	
	// -- outputs
    /* Simulink signal name: 'outputArg11' */
    bit [7:0] outputArg11; 

    chandle objhandle=null;

	simple_dpi dut ( .clk(clk),
			.clk_enable(clk_enable),
			.reset(reset),
		/* Simulink signal name: 'inputArg1' */
			.inputArg1(inputArg1) ,
		/* Simulink signal name: 'inputArg2' */
			.inputArg2(inputArg2) ,
		/* Simulink signal name: 'outputArg11' */
			.outputArg11(outputArg11)
	);
    initial begin
        objhandle = DPI_simple_initialize(objhandle);
		DPI_simple_setparam_opt1_f(objhandle, 8'b00000000);
		DPI_simple_setparam_valid(objhandle, 1'b0);
    end

	initial begin : tb_main
		#10
			reset = 1'b1;
		#10 
			reset = 1'b0;
			
		#10 
			clk_enable = 1'b1;
		#20 
			inputArg1 = 8'b00001000;
			inputArg2 = 8'b00000001;
		#20
			inputArg1 = 8'b00010000;
			inputArg2 = 8'b00000010;
		#20
			inputArg1 = 8'b00110000;
			inputArg2 = 8'b00000011;
		#20
			inputArg1 = 8'b01110000;
			inputArg2 = 8'b00000101;
		#20
			DPI_simple_setparam_valid(objhandle, 1'b1);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b0);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b1);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b0);
		#20 
			DPI_simple_setparam_opt1_f(objhandle, 8'b00000010);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b1);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b0);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b1);
		#20
			DPI_simple_setparam_valid(objhandle, 1'b0);
		#20
			inputArg1 = 8'b00001000;
			inputArg2 = 8'b00000111;
		#20
			inputArg1 = 8'b00010000;
			inputArg2 = 8'b00001000;

	end : tb_main

	initial
	begin
        clk_enable = 1'b0;
        clk = 1'b0;
	    reset = 1'b0;
	end

	always #10 clk <= ~clk;
	
endmodule // tb_top