//Name:Omar Aly
//Purpose of Program: Final Project, theatre system Design. System will consist of Mode FSM, SpotLight FSM connected together to control our system outputs.
//*******************************************

module DFF(clk, D, reset, Q); //D Flip flop, will be used in the theatre module generally for our bits
  input D, clk, reset; // Inputs
  output reg Q; // output Q 
  always @(posedge clk or posedge reset) 
    begin
      if(reset==1'b1)
        Q <= 0;
      else
        Q <= D;
    end
endmodule

module encoder4to2(House, Music, Speaker, Play, M1, M0); //module to encode our 4 Modes to 2 binary outputs
  input House, Music, Speaker, Play;
  output reg M1, M0;
  always @(*)
    begin
      M1 = 0;
      M0 = 0;
      //this is also our encoding of House mode = 00
      if (House)
        begin
          M1 = 0; M0 = 0;
        end
      else if (Music)
        begin
          M1 = 0; M0 = 1; //Music Mode = 01
        end
      else if (Speaker)
        begin
          M1 = 1; M0 = 0; // Speaker Mode: 10
        end
      else if (Play)
        begin
          M1 = 1; M0 = 1; //Play Mode = 11
        end
    end
endmodule

module encoder3to2(TL,TC,TR, T1, T0); //encoder to encode the 3 input sensors to a 2 bit output, input sensors are active low
  input TL, TC, TR; //inputs
  output reg T1, T0; //outputs
  
  always @(*)
    begin
      if (!TL)
        begin
          T1 = 0; T0 = 0;
        end
      else if (!TC)
        begin
          T1 = 0; T0 = 1;
        end
      else if (!TR)
        begin
          T1 = 1; T0 = 1;
        end
      else
        begin
          T1 = 0; T0 = 1; 
          //If no sensor is active. then go to center as a default
        end
    end
endmodule

module ns_Mode_FSM(Q2, Q1, Q0, EN, M1, M0, Q2_n,Q1_n, Q0_n );
  input Q2, Q1, Q0, EN, M1, M0;
  output Q2_n, Q1_n, Q0_n;
  
  assign Q2_n = EN & (Q2&~Q0 | M0&M1&Q2 | M0&Q0&~Q2 | M1&Q1&~Q0 | Q1&~M0&~M1 | M1&Q0&~Q1&~Q2); //Q2* from the k-map
  assign Q1_n = EN & (M0&Q0&Q2&~M1 | M0&~M1&Q1&~Q0 | M1&Q0&Q1&~M0 | M1&Q0&Q2&~M0); //Q1* from the k-map
  assign Q0_n = EN & (~M0 | M1&~Q2 | Q0&~Q2 | ~M1&~Q0&~Q1); //Q0* equations from k-map
  
endmodule

module ns_Spotlight_FSM(R1,R0,EN,T1,T0,SP_A, R1_n, R0_n);
  input R1, R0, EN, T1, T0, SP_A;
  output R1_n, R0_n;
  wire E; //wire E, it only occurs when EN=1 (system is active) and SP_A (spot light Activated) = 1
  assign E = EN & SP_A;
    
  assign R1_n = E & ( R0&T1 | ~T0&(R0 ^ R1)); //NS eqaution from the k-map
  assign R0_n = E & (T0 | R1&R0 | ~R1&~R0); //NS equation from the k-map
  
endmodule

module theatre_outputs(Q2,Q1,Q0,R1,R0,HL,VD,SP_A,S1); 
  //formalizing the output from ps and NS using the output equations derived from the k-maps.
  input Q2,Q1,Q0,R1,R0; //inputs
  output HL,VD,SP_A; //outputs
  output[2:0] S1;
  
  assign HL = ~Q2 & ~Q1; //HL equation from the k-map
  assign VD = ~Q0 & (Q1 ^ Q2); //From the k-map equation
  assign SP_A = (~Q2 & Q1 & Q0) | (Q2 & ~Q1 & ~Q0); //SpotLight_Activated. it's an internal output, it's only use is to be ANDed with Enable in order to activate spotlight FSM, it only = 1 at Play (100) and Speaker(011)
  assign S1[2] = (R1 | R0) & SP_A;
  assign S1[1] = (R1&R0) & SP_A;
  assign S1[0] = ((~R1 | R0) & SP_A) | ~SP_A;
  
endmodule

module theatre(clk, reset, EN, House, Music, Speaker, Play, TL, TC, TR, HL, VD, S1); // the actual theatre system module, using all of above modules
  input clk, reset, EN, House, Music, Speaker, Play, TL, TC, TR; //inputs
  output HL, VD; //outputs
  output [2:0] S1;// outputs
  wire Q2, Q1, Q0, R1, R0, M1, M0, T1, T0, SP_A;
  wire Q2_n, Q1_n, Q0_n, R1_n, R0_n; //internal wires
  
  DFF dff_Q2(.clk(clk), .D(Q2_n), .reset(reset), .Q(Q2));
  DFF dff_Q1(.clk(clk), .D(Q1_n), .reset(reset), .Q(Q1));
  DFF dff_Q0(.clk(clk), .D(Q0_n), .reset(reset), .Q(Q0));

  DFF dff_S1(.clk(clk), .D(R1_n), .reset(reset), .Q(R1));
  DFF dff_S0(.clk(clk), .D(R0_n), .reset(reset), .Q(R0));
  
  //here we used our wires as flip flops synchronized with clock
  encoder4to2 mode_enc(.House(House), .Music(Music),.Speaker(Speaker), .Play(Play),.M1(M1), .M0(M0)); //encoding 4 inputs to 2 bit output

  encoder3to2 spot_enc(.TL(TL), .TC(TC), .TR(TR),.T1(T1), .T0(T0));//encoding 3 inputs to 2 bit output
  
  ns_Mode_FSM mode_ns(.Q2(Q2), .Q1(Q1), .Q0(Q0),.EN(EN), .M1(M1), .M0(M0), .Q2_n(Q2_n), .Q1_n(Q1_n), .Q0_n(Q0_n)); //implementinh the Mode FSM

  ns_Spotlight_FSM spot_ns(.R1(R1), .R0(R0), .EN(EN),.T1(T1), .T0(T0), .SP_A(SP_A),.R1_n(R1_n), .R0_n(R0_n)); //implementing SpotLight FSM
  
  theatre_outputs outputs(.Q2(Q2), .Q1(Q1), .Q0(Q0),.R1(R1), .R0(R0),.HL(HL), .VD(VD),.SP_A(SP_A), .S1(S1)); //Using output Equations to produce the final outputs
  
endmodule