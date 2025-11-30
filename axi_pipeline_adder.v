module axis_pipeline_adder #(
    parameter DATA_WIDTH =32
) (
    input wire clk,
    input wire rst_n,

    input wire [DATA_WIDTH-1:0] cfg_add_value,

    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire                  s_axis_tvalid,
    output wire                 s_axis_tready,
    input wire                  s_axis_tlast,
    input wire [DATA_WIDTH/8-1:0] s_axis_tkeep,

    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input wire                   m_axis_tready,
    output wire                  m_axis_tlast,
    output wire [DATA_WIDTH/8-1:0] m_axis_tkeep
);
    reg [DATA_WIDTH-1:0]        r_tdata;
    reg                         r_tvalid;
    reg                         r_tlast;
    reg [DATA_WIDTH/8-1:0]      r_tkeep;

    wire [DATA_WIDTH-1:0] processed_data;
    assign processed_data = s_axis_tdata + cfg_add_value;

    assign m_axis_tdata = r_tdata;
    assign s_axis_tready = m_axis_tready|| ~r_tvalid;
    assign m_axis_tvalid= r_tvalid;
    assign m_axis_tlast = r_tlast;
    assign m_axis_tkeep = r_tkeep;

    always @(posedge clk) begin
        if(!rst_n)begin
            r_tvalid <= 1'b0;
            r_tdata <= 32'd0;
            r_tlast <= 1'b0;
            r_tkeep <= 4'b0;
        end
        else if(s_axis_tready ==1) begin
            r_tvalid <= s_axis_tvalid;
            r_tdata <= processed_data;
            r_tlast <= s_axis_tlast;
            r_tkeep <= s_axis_tkeep;            
        end
    end
endmodule