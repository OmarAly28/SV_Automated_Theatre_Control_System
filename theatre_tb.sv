//Name: Omar Aly
//Purpose of Program: Test the theatre system for several different cases
//*******************************************

//standardize the time units
`timescale 1ns/100ps
// format is timescale/precision

module theatre_tb;

reg clk_tb, reset_tb, EN_tb, House_tb, Music_tb, Speaker_tb, Play_tb, TL_tb, TC_tb, TR_tb; //test bench Inputs

wire HL_tb, VD_tb; // test bench outputs
  wire [2:0] S1_tb; //spotlight switch output
theatre dut(.clk(clk_tb),.reset(reset_tb),.EN(EN_tb),.House(House_tb),.Music(Music_tb),.Speaker(Speaker_tb),.Play(Play_tb),.TL(TL_tb),.TC(TC_tb),.TR(TR_tb),.HL(HL_tb),.VD(VD_tb),.S1(S1_tb));
//instantiation call

initial begin 
  clk_tb = 0; //Initialize clock = 0
end
always begin
  #5 clk_tb = ~clk_tb; // clock changes after 5 seconds
end

initial begin
  reset_tb = 1; EN_tb =0; House_tb = 0; Music_tb = 0; Speaker_tb= 0; Play_tb = 0; TL_tb = 1;TC_tb = 1; TR_tb = 1; //Initializing out input Variables
end
  
initial//block that controls testing
begin
//this is where you load your test pattern
//so telling the inputs when to change to look at another input condition

  #10 reset_tb = 0;
  
  // Test case 1: Enable on with no mode
  #30 EN_tb = 1; House_tb = 0; Music_tb = 0; Speaker_tb = 0; Play_tb=0;
  
  // test case 2: House Mode
  #30 EN_tb = 1; House_tb = 1; Music_tb = 0; Speaker_tb = 0; Play_tb=0;
  
  //test case 3: Music Mode
  #30 EN_tb = 1; House_tb = 0; Music_tb = 1; Speaker_tb = 0; Play_tb=0;
  
  //test case 4: Speaker Mode
  #30 EN_tb = 1; House_tb = 0; Music_tb = 0; Speaker_tb = 1; Play_tb=0;
  #40 TL_tb = 0; TC_tb = 1; TR_tb = 1; // left
  #40 TL_tb = 1; TC_tb = 0; TR_tb = 1; // center
  #40 TL_tb = 1; TC_tb = 1; TR_tb = 0; // right
  #40 TL_tb = 1; TC_tb = 1; TR_tb = 1; // off, positioned at center
  
  //test case 5: Play Mode
  #30 EN_tb = 1; House_tb = 0; Music_tb = 0; Speaker_tb = 0; Play_tb=1;
  #40 TL_tb = 0; TC_tb = 1; TR_tb = 1; // left
  #40 TL_tb = 1; TC_tb = 0; TR_tb = 1; // center
  #40 TL_tb = 1; TC_tb = 1; TR_tb = 0; // right
  #40 TL_tb = 1; TC_tb = 1; TR_tb = 1; // off, positioned at center
  
  //test case 6: Asynchronous reset
  #10 reset_tb = 1; // turn on reset
  #10 reset_tb = 0; //turn off reset
  
  //test case 7: transition test (all light should turn off)
  //We're still at play = 1 from last case
  #30 EN_tb = 1; House_tb = 0; Music_tb = 0; Speaker_tb = 0; Play_tb=0; //turn play off
  #30 EN_tb = 1; House_tb = 0; Music_tb = 0; Speaker_tb = 0; Play_tb=1; //turn play on again
  // test case 8: Global Disable override
  #40 EN_tb = 0; TL_tb = 0; TC_tb = 1; TR_tb = 1; //system was enabled in play mode and positions inputs at center, but now disable activated
  
  #40 $finish;
  
end
  //This is the code for making the waveform
  initial 
    begin
      $dumpfile("theatre_wave.vcd");
      $dumpvars;
    end


//log output
initial begin
  $display("clk rst EN H M Sp P TL TC TR | HL VD  S1");
  
  $monitor("%b   %b   %b  %b %b %b %b  %b  %b  %b  | %b  %b  %03b",clk_tb, reset_tb, EN_tb,House_tb, Music_tb, Speaker_tb, Play_tb, TL_tb, TC_tb, TR_tb, HL_tb, VD_tb, S1_tb);
  
end
endmodule