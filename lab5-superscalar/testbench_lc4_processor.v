`timescale 1ns / 1ps
`default_nettype none

`define EOF 32'hFFFF_FFFF
`define NEWLINE 10
`define NULL 0

// NB: .set_testcase.v is auto-generated by vivado.mk
`include ".set_testcase.v"

module test_processor;
   `include "include/lc4_prettyprint_errors.v"
   
   integer     input_file, output_file, errors, tests;
   integer     insns; 
   integer     num_cycles;
   integer     consecutive_stalls;

   // Set this to non-zero to cause the testbench to halt at the first
   // failure. Often useful when debugging.
   integer     exit_at_first_failure = 0;

   // Inputs
   reg clk;
   reg rst;
   wire [15:0] cur_insn_A, cur_insn_B;
   wire [15:0] cur_dmem_data;

   // Outputs
   wire [15:0] cur_pc, cur_pc_plus1;
   wire [15:0] dmem_addr;
   wire [15:0] dmem_towrite;
   wire        dmem_we;

   wire [1:0]  test_stall_A,        test_stall_B; // Testbench: is this is stall cycle? (don't compare the test values)
   wire [15:0] test_cur_pc_A,       test_cur_pc_B; // Testbench: program counter
   wire [15:0] test_cur_insn_A,     test_cur_insn_B; // Testbench: instruction bits
   wire        test_regfile_we_A,   test_regfile_we_B; // Testbench: register file write enable
   wire [2:0]  test_regfile_wsel_A, test_regfile_wsel_B; // Testbench: which register to write in the register file
   wire [15:0] test_regfile_data_A, test_regfile_data_B; // Testbench: value to write into the register file
   wire        test_nzp_we_A,       test_nzp_we_B; // Testbench: NZP condition codes write enable
   wire [2:0]  test_nzp_new_bits_A, test_nzp_new_bits_B; // Testbench: value to write to NZP bits
   wire        test_dmem_we_A,      test_dmem_we_B; // Testbench: data memory write enable
   wire [15:0] test_dmem_addr_A,    test_dmem_addr_B; // Testbench: address to write memory
   wire [15:0] test_dmem_data_A,    test_dmem_data_B; // Testbench: value to write memory
   
   reg [1:0]   verify_stall_A,        verify_stall_B; 
   reg [15:0]  verify_cur_pc_A,       verify_cur_pc_B; 
   reg [15:0]  verify_cur_insn_A,     verify_cur_insn_B; 
   reg         verify_regfile_we_A,   verify_regfile_we_B; 
   reg [15:0]  verify_regfile_data_A, verify_regfile_data_B; 
   reg [2:0]   verify_regfile_wsel_A, verify_regfile_wsel_B; 
   reg         verify_nzp_we_A,       verify_nzp_we_B; 
   reg [2:0]   verify_nzp_new_bits_A, verify_nzp_new_bits_B; 
   reg         verify_dmem_we_A,      verify_dmem_we_B; 
   reg [15:0]  verify_dmem_addr_A,    verify_dmem_addr_B; 
   reg [15:0]  verify_dmem_data_A,    verify_dmem_data_B; 
   
   wire [15:0] vout_dummy;  // video out
   
   always #5 clk <= ~clk;
   
   // Produce gwe and other we signals using same modules as lc4_system
   wire        i1re, i2re, dre, gwe;
   lc4_we_gen we_gen(.clk(clk),
		     .i1re(i1re),
		     .i2re(i2re),
		     .dre(dre),
		     .gwe(gwe));
  
   
   // Data and video memory block 
   lc4_memory memory (.idclk(clk),
		      .i1re(i1re),
		      .i2re(i2re),
		      .dre(dre),
		      .gwe(gwe),
		      .rst(rst),
                      .i1addr(cur_pc),
		      .i2addr(cur_pc_plus1),
                      .i1out(cur_insn_A),
                      .i2out(cur_insn_B),
                      .daddr(dmem_addr),
		      .din(dmem_towrite),
                      .dout(cur_dmem_data),
                      .dwe(dmem_we),
                      .vclk(1'b0),
                      .vaddr(16'h0000),
                      .vout(vout_dummy));
   
   
   // Instantiate the Unit Under Test (UUT)
   lc4_processor proc_inst (.clk(clk), 
                            .rst(rst),
                            .gwe(gwe),
                            .o_cur_pc(cur_pc), 
                            .i_cur_insn_A(cur_insn_A),
                            .i_cur_insn_B(cur_insn_B), 
                            .o_dmem_addr(dmem_addr), 
                            .o_dmem_towrite(dmem_towrite), 
                            .i_cur_dmem_data(cur_dmem_data), 
                            .o_dmem_we(dmem_we),
                            // test signals
                            .test_stall_A(test_stall_A),
                            .test_stall_B(test_stall_B),
                            .test_cur_pc_A(test_cur_pc_A),
                            .test_cur_pc_B(test_cur_pc_B),
                            .test_cur_insn_A(test_cur_insn_A),
                            .test_cur_insn_B(test_cur_insn_B),
                            .test_regfile_we_A(test_regfile_we_A),
                            .test_regfile_we_B(test_regfile_we_B),
                            .test_regfile_wsel_A(test_regfile_wsel_A),
                            .test_regfile_wsel_B(test_regfile_wsel_B),
                            .test_regfile_data_A(test_regfile_data_A),
                            .test_regfile_data_B(test_regfile_data_B),
                            .test_nzp_we_A(test_nzp_we_A),
                            .test_nzp_we_B(test_nzp_we_B),
                            .test_nzp_new_bits_A(test_nzp_new_bits_A),
                            .test_nzp_new_bits_B(test_nzp_new_bits_B),
                            .test_dmem_we_A(test_dmem_we_A),
                            .test_dmem_we_B(test_dmem_we_B),
                            .test_dmem_addr_A(test_dmem_addr_A),
                            .test_dmem_addr_B(test_dmem_addr_B),
                            .test_dmem_data_A(test_dmem_data_A),
                            .test_dmem_data_B(test_dmem_data_B),
                            // misc I/O
                            .switch_data(8'd0)
                            );
   
   assign cur_pc_plus1 = cur_pc + 16'd1;

   task printPoints;
      input [31:0] possible, actual;
      begin
         $display("<scorePossible>%d</scorePossible>", possible);
         $display("<scoreActual>%d</scoreActual>", actual);
      end
   endtask

   task assertEqual;
      input wire[15:0] expected, actual;
      input reg[159:0]  label; // HACK: max length of 20 chars
      // uses "global" variables: num_cycles, errors and exit_at_first_failure
      begin
         if (actual !== expected) begin
            $display("Error at cycle %d: %s should be %h (but was %h)",
                     num_cycles, label, expected, actual);
            errors = errors + 1;
            if (exit_at_first_failure) begin
               $finish;
            end
         end
      end
   endtask
   
   initial begin
      // Initialize Inputs
      clk = 0;
      rst = 1;
      insns = 0;
      errors = 0;
      tests = 0; 
      num_cycles = 0;
      consecutive_stalls = 0;
      
      // open the test inputs
      input_file = $fopen(`INPUT_FILE, "r");
      if (input_file == `NULL) begin
         $display("Error opening file: %s", `INPUT_FILE);
         $finish;
      end

      // open the output file
// `ifdef OUTPUT_FILE
//       output_file = $fopen(`OUTPUT_FILE, "w");
//       if (output_file == `NULL) begin
//          $display("Error opening file: %s", `OUTPUT_FILE);
//          $finish;
//       end
// `endif


      #80; 
      // Wait for global reset to finish
      rst = 0;
      #32;
  
      while (22 == $fscanf(input_file, "%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                           verify_stall_A,
                           verify_stall_B,
                           verify_cur_pc_A,
                           verify_cur_pc_B,
                           verify_cur_insn_A,
                           verify_cur_insn_B,
                           verify_regfile_we_A,
                           verify_regfile_we_B,
                           verify_regfile_wsel_A,
                           verify_regfile_wsel_B,
                           verify_regfile_data_A,
                           verify_regfile_data_B,
                           verify_nzp_we_A,
                           verify_nzp_we_B,
                           verify_nzp_new_bits_A,
                           verify_nzp_new_bits_B,
                           verify_dmem_we_A,
                           verify_dmem_we_B,
                           verify_dmem_addr_A,
                           verify_dmem_addr_B,
                           verify_dmem_data_A,
                           verify_dmem_data_B)) begin

         if (num_cycles % 10000 == 0) begin
            $display("Cycle number: %d", num_cycles);
         end

         if (verify_stall_A == 2'b0) begin
            insns = insns + 1; 
         end
         if (verify_stall_B == 2'b0) begin
            insns = insns + 1; 
         end
            
         if (output_file) begin
            $fdisplay(output_file, "%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                      verify_stall_A,
                      verify_stall_B,
                      verify_cur_pc_A,
                      verify_cur_pc_B,
                      verify_cur_insn_A,
                      verify_cur_insn_B,
                      verify_regfile_we_A,
                      verify_regfile_we_B,
                      verify_regfile_wsel_A,
                      verify_regfile_wsel_B,
                      verify_regfile_data_A,
                      verify_regfile_data_B,
                      verify_nzp_we_A,
                      verify_nzp_we_B,
                      verify_nzp_new_bits_A,
                      verify_nzp_new_bits_B,
                      verify_dmem_we_A,
                      verify_dmem_we_B,
                      verify_dmem_addr_A,
                      verify_dmem_addr_B,
                      verify_dmem_data_A,
                      verify_dmem_data_B);
         end

         // run the cycle, then verify outputs
         num_cycles = num_cycles + 1;
	 #40;

         tests = tests + 2;
         
         // stall
         assertEqual(.expected(verify_stall_A), .actual(test_stall_A), .label("test_stall_A"));
         // if A does not stall, check test_stall_B as usual
         // else, only count error if test_stall_B is not 0 or is undefined
         // (i.e. has X or Z values)
         if (verify_stall_A === 2'b00) begin
            assertEqual(.expected(verify_stall_B), .actual(test_stall_B), .label("test_stall_B"));
         // accounts for X and Z values
         end else if ((test_stall_B !== 2'b01) & (test_stall_B !== 2'b10) & (test_stall_B !== 2'b11)) begin
            // force error; if A stalls, B should stall
            // even if it's not with the value in the ctrace file
            // copied from assertEqual so we can have custom error message
            $display("Error at cycle %d: test_stall_B should have non-zero value due to stall in A (but was %h)",
                     num_cycles, test_stall_B);
            errors = errors + 1;
            if (exit_at_first_failure) begin
               $finish;
            end
         end

         // count consecutive stalls
         if (test_stall_A !== 2'd0 && test_stall_B !== 2'd0) begin
            if (consecutive_stalls >= 5) begin
               $display("Error at cycle %d: your pipeline has stalled for more than 5 cycles in a row, which should never happen. This might indicate your pipeline will be stuck stalling forever, so the testbench will now exit.", num_cycles);
               printPoints(1, 0); 
               $finish;
            end
            consecutive_stalls = consecutive_stalls + 1;
        end else begin
            consecutive_stalls = 0;
        end


         if (verify_stall_A === 2'b00) begin // verify pipe A signals

            tests = tests + 10;

            assertEqual(.expected(verify_cur_pc_A), .actual(test_cur_pc_A), .label("test_cur_pc_A"));
            
            // insn
            if (verify_cur_insn_A !== test_cur_insn_A) begin
               $write("Error at cycle %d: insn_A should be %h (", num_cycles, verify_cur_insn_A);
               pinstr(verify_cur_insn_A);
               $write(") but was %h (", test_cur_insn_A);
               pinstr(test_cur_insn_A);
               $display(")");
               errors = errors + 1;
               if (exit_at_first_failure) begin
                  $finish;
               end
            end

            assertEqual(.expected(verify_regfile_we_A), .actual(test_regfile_we_A), .label("test_regfile_we_A"));

            assertEqual(.expected(verify_regfile_wsel_A), .actual(test_regfile_wsel_A), .label("test_regfile_wsel_A"));

            assertEqual(.expected(verify_regfile_data_A), .actual(test_regfile_data_A), .label("test_regfile_data_A"));

            assertEqual(.expected(verify_nzp_we_A), .actual(test_nzp_we_A), .label("test_nzp_we_A"));

            assertEqual(.expected(verify_nzp_new_bits_A), .actual(test_nzp_new_bits_A), .label("test_nzp_new_bits_A"));

            assertEqual(.expected(verify_dmem_we_A), .actual(test_dmem_we_A), .label("test_dmem_we_A"));

            assertEqual(.expected(verify_dmem_addr_A), .actual(test_dmem_addr_A), .label("test_dmem_addr_A"));

            assertEqual(.expected(verify_dmem_data_A), .actual(test_dmem_data_A), .label("test_dmem_data_A"));

         end // non-stall cycle, A pipe

         if (verify_stall_B === 2'b00) begin // verify pipe B signals

            tests = tests + 10;

            assertEqual(.expected(verify_cur_pc_B), .actual(test_cur_pc_B), .label("test_cur_pc_B"));
            
            // insn
            if (verify_cur_insn_B !== test_cur_insn_B) begin
               $write("Error at cycle %d: insn_B should be %h (", num_cycles, verify_cur_insn_B);
               pinstr(verify_cur_insn_B);
               $write(") but was %h (", test_cur_insn_B);
               pinstr(test_cur_insn_B);
               $display(")");
               errors = errors + 1;
               if (exit_at_first_failure) begin
                  $finish;
               end
            end

            assertEqual(.expected(verify_regfile_we_B), .actual(test_regfile_we_B), .label("test_regfile_we_B"));

            assertEqual(.expected(verify_regfile_wsel_B), .actual(test_regfile_wsel_B), .label("test_regfile_wsel_B"));

            assertEqual(.expected(verify_regfile_data_B), .actual(test_regfile_data_B), .label("test_regfile_data_B"));

            assertEqual(.expected(verify_nzp_we_B), .actual(test_nzp_we_B), .label("test_nzp_we_B"));

            assertEqual(.expected(verify_nzp_new_bits_B), .actual(test_nzp_new_bits_B), .label("test_nzp_new_bits_B"));

            assertEqual(.expected(verify_dmem_we_B), .actual(test_dmem_we_B), .label("test_dmem_we_B"));

            assertEqual(.expected(verify_dmem_addr_B), .actual(test_dmem_addr_B), .label("test_dmem_addr_B"));

            assertEqual(.expected(verify_dmem_data_B), .actual(test_dmem_data_B), .label("test_dmem_data_B"));

         end // non-stall cycle, B pipe
         
      end // while ($fscanf(input_file, ...))

         
      if (input_file) $fclose(input_file); 
      if (output_file) $fclose(output_file);
      
      $display("Simulation finished: %d test cases %d errors [%s]", tests, errors, `INPUT_FILE);
      printPoints(tests, tests-errors); 
      //$display("<scorePossible>%d</scorePossible>", tests);
      //$display("<scoreActual>%d</scoreActual>", tests - errors);
      
      
      $display("  Instructions:         %d", insns);
      $display("  Total Cycles:         %d", num_cycles);
      $display("  CPI x 1000: %d", (1000 * num_cycles) / insns);
      $display("  IPC x 1000: %d", (1000 * insns) / num_cycles); 
            
      $finish;
   end // initial begin
   
endmodule

