

module prim_intr_hw # (
  parameter int unsigned Width = 1,
  parameter bit FlopOutput = 1
) (
  // event
  input logic clk_i,
  input logic rst_ni,
  input logic [Width-1:0]  event_intr_i,

  // register interface
  input logic [Width-1:0]  reg2hw_intr_enable_q_i,
  input logic [Width-1:0]  reg2hw_intr_test_q_i,
  input logic              reg2hw_intr_test_qe_i,
  input logic [Width-1:0]  reg2hw_intr_state_q_i,
  output logic             hw2reg_intr_state_de_o,
  output logic [Width-1:0]  hw2reg_intr_state_d_o,

  // outgoing interrupt
  output logic [Width-1:0]  intr_o
);

  logic  [Width-1:0]    new_event;
  assign new_event =
             (({Width{reg2hw_intr_test_qe_i}} & reg2hw_intr_test_q_i) | event_intr_i);
  assign hw2reg_intr_state_de_o = |new_event;
  // for scalar interrupts, this resolves to '1' with new event
  // for vector interrupts, new events are OR'd in to existing interrupt state
  assign hw2reg_intr_state_d_o  =  new_event | reg2hw_intr_state_q_i;

  if (FlopOutput == 1) begin : gen_flop_intr_output
    // flop the interrupt output
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        intr_o <= 1'b0;
      end else begin
        intr_o <= reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
      end
    end

  end else begin : gen_intr_passthrough_output
    logic unused_clk;
    logic unused_rst_n;
    assign unused_clk = clk_i;
    assign unused_rst_n = rst_ni;
    assign intr_o = reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
  end


endmodule
