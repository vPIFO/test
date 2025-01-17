`timescale 1ns/10ps    //cycle

/*-----------------------------------------------------------------------------

Proprietary and Confidential Information

Module: TC.v
Author: Xiaoguang Li
Date  : 06/2/2019

Description: Top-level module simulation. 

			 
Issues:  

-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// Module Port Definition
//-----------------------------------------------------------------------------
module TC();

//-----------------------------------------------------------------------------
// Include Files
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Register and Wire Declarations
//-----------------------------------------------------------------------------

// 4 LEVEL push to full and pop to empty


parameter PTW = 16;
parameter MTW = 0;
parameter CTW = 16;
parameter LEVEL = 4;
parameter TREE_NUM = 4;
parameter FIFO_SIZE = 2048;
parameter TREE_NUM_BITS = $clog2(TREE_NUM);

reg            clk;
reg            arst_n;

integer        seed;
integer        R;
reg [LEVEL-1:0] push;
reg [LEVEL-1:0] pop;
reg [PTW-1:0]      push_data [0:LEVEL-1];
reg [TREE_NUM_BITS-1:0]      tree_id [0:LEVEL-1];
reg [TREE_NUM_BITS-1:0]      pop_tree_id [0:LEVEL-1];
integer        data_gen [49:0];
integer        i;
wire [PTW-1:0]      pop_data [0:LEVEL-1];
wire [LEVEL-1:0] task_fifo_full;
wire [LEVEL-1:0] is_level0_pop;

reg [PTW-1:0]      push_data_0;
reg [PTW-1:0]      push_data_1;
reg [PTW-1:0]      push_data_2;
reg [PTW-1:0]      push_data_3;
// reg [PTW-1:0]      push_data_4;
// reg [PTW-1:0]      push_data_5;
// reg [PTW-1:0]      push_data_6;
// reg [PTW-1:0]      push_data_7;

reg [PTW-1:0]      pop_data_0;
reg [PTW-1:0]      pop_data_1;
reg [PTW-1:0]      pop_data_2;
reg [PTW-1:0]      pop_data_3;
// reg [PTW-1:0]      pop_data_4;
// reg [PTW-1:0]      pop_data_5;
// reg [PTW-1:0]      pop_data_6;
// reg [PTW-1:0]      pop_data_7;

//-----------------------------------------------------------------------------
// Instantiations
//-----------------------------------------------------------------------------
PIFO_SRAM_TOP 
#(
   .PTW   (PTW),
   .MTW   (MTW),
   .CTW   (CTW),
   .LEVEL (LEVEL),
   .TREE_NUM (TREE_NUM),
   .FIFO_SIZE (FIFO_SIZE)
) u_PIFO_TOP (
   .i_clk       ( clk            ),
   .i_arst_n    ( arst_n         ),
   
   .i_push_tree_id   ( tree_id        ),
   .i_push      ( push           ),
   .i_push_data ( push_data      ),
   
   .i_pop       ( pop            ),
   .i_pop_tree_id   ( tree_id        ),

   .o_tree_id   (pop_tree_id),
   .o_pop_data  ( pop_data       ),

   .o_is_level0_pop  (is_level0_pop),
   .o_task_fifo_full (task_fifo_full)      
);

//-----------------------------------------------------------------------------
// Clocks
//-----------------------------------------------------------------------------
always #4 begin clk = ~clk; end

assign push_data_0 = push_data[0];
assign push_data_1 = push_data[1];
assign push_data_2 = push_data[2];
assign push_data_3 = push_data[3];
// assign push_data_4 = push_data[4];
// assign push_data_5 = push_data[5];
// assign push_data_6 = push_data[6];
// assign push_data_7 = push_data[7];

assign pop_data_0 = pop_data[0];
assign pop_data_1 = pop_data[1];
assign pop_data_2 = pop_data[2];
assign pop_data_3 = pop_data[3];
// assign pop_data_4 = pop_data[4];
// assign pop_data_5 = pop_data[5];
// assign pop_data_6 = pop_data[6];
// assign pop_data_7 = pop_data[7];
  
//-----------------------------------------------------------------------------
// Initial
//-----------------------------------------------------------------------------  

initial begin            
   $dumpfile("wave.vcd"); // 指定用作dumpfile的文件
   $dumpvars; // dump all vars
end

initial begin
    for (i=0;i<50;i=i+1) begin
      data_gen[i] = $dist_uniform(seed,0,256);
    end
end

initial
begin
  clk    = 1'b0;
  arst_n = 1'b0;    
  seed   = 1;
  push   = 1'b0;
  pop    = 1'b0;

  for (integer j = 0; j < LEVEL; j++) begin
    tree_id[j] = '0;
  end
 
   #400;
   arst_n = 1'b1;

  // push all for prepare
  for (i=0; i< 4 * ((4 ** LEVEL - 1) / 3); i=i+1) begin
    @ (posedge clk);
    fork
      for (integer j = 0; j < LEVEL; j++) begin
        pop[j] = 1'b0;
        push[j] = 1'b1;
        push_data[j] = 4096 * j + i;
        tree_id[j] = j;
      end
    join
  end

  @ (posedge clk);
  fork 
    for (integer j = 0; j < LEVEL; j++) begin
      pop[j] = 1'b0;
      push[j] = 1'b0;
      push_data[j] = 0;
      tree_id[j] = j;
    end
  join

  // pop all
  for (i=0; i< 4 * ((4 ** LEVEL - 1) / 3); i=i+1) begin
    @ (posedge clk);
    fork
      for (integer j = 0; j < LEVEL; j++) begin
        pop[j] = 1'b1;
        push[j] = 1'b0;
        push_data[j] = 0;
        tree_id[j] = j;
      end
    join
  end


  @ (posedge clk);
  fork 
    for (integer j = 0; j < LEVEL; j++) begin
      pop[j] = 1'b0;
      push[j] = 1'b0;
      push_data[j] = 0;
      tree_id[j] = j;
    end
  join

  #50000;   
  $stop;

  end
//-----------------------------------------------------------------------------
// Functions and Tasks
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Sequential Logic
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Combinatorial Logic / Continuous Assignments
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Output Assignments
//-----------------------------------------------------------------------------  

endmodule
