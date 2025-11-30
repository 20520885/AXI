module cnn_accelerator #(
    parameter DATA_WIDTH = 32
    )(
    input wire clk,
    input wire rst_n,
    //AXI-STREAM
   
    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire                  s_axis_tvalid,
    output wire                 s_axis_tready,
    input wire                  s_axis_tlast,
    input wire [DATA_WIDTH/8-1:0] s_axis_tkeep,

    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input wire                   m_axis_tready,
    output wire                  m_axis_tlast,
    output wire [DATA_WIDTH/8-1:0] m_axis_tkeep,

    //AXI_LITE
    //WRITE ADDRESS 
    input wire [31:0]   s_axi_aw_addr,
    input wire          s_axi_aw_valid,
    output wire         s_axi_aw_ready,
    //WRITE DATA
    input wire [31:0]   s_axi_w_data,
    input wire          s_axi_w_valid,
    output wire         s_axi_w_ready,
    //WRITE RESPONSE
    output wire [1:0]   s_axi_b_resp,
    output wire         s_axi_b_valid,
    input wire          s_axi_b_ready,
    //READ ADDRESS
    input wire [31:0]   s_axi_ar_addr,
    input wire          s_axi_ar_valid,
    output wire         s_axi_ar_ready,
    //READ DATA
    output wire [31:0]  s_axi_r_data,
    output wire [1:0]   s_axi_r_resp,
    output wire         s_axi_r_valid,
    input wire          s_axi_r_ready
);
    //--- 1.KHAI BAO INTERNAL WIRE
    //MANG DATA TU SLAVE LITE -> STREAM ADDER
    wire [31:0] w_ksize_config;

    //Khai bao truoc
    wire [31:0] w_control_config;
    wire [31:0] w_width_config;

    //INSTANTIATION

    // A. Lắp Module AXI-Lite Slave
    axil_slave u_control_plane (
        .clk              (clk),
        .rst_n            (rst_n),
        
        .s_axi_aw_addr(s_axi_aw_addr),
        .s_axi_aw_valid(s_axi_aw_valid),
        .s_axi_aw_ready(s_axi_aw_ready),
        //WRITE DATA
        .s_axi_w_data(s_axi_w_data),
        .s_axi_w_valid(s_axi_w_valid),
        .s_axi_w_ready(s_axi_w_ready),
        //WRITE RESPONSE
        .s_axi_b_resp(s_axi_b_resp),
        .s_axi_b_valid(s_axi_b_valid),
        .s_axi_b_ready(s_axi_b_ready),
        //READ ADDRESS
        .s_axi_ar_addr(s_axi_ar_addr),
        .s_axi_ar_valid(s_axi_ar_valid),
        .s_axi_ar_ready(s_axi_ar_ready),
        //READ DATA
        .s_axi_r_data(s_axi_r_data),
        .s_axi_r_resp(s_axi_r_resp),
        .s_axi_r_valid(s_axi_r_valid),
        .s_axi_r_ready(s_axi_r_ready),
        // Cổng cấu hình nội bộ (Quan trong!)
        .cfg_data_control (w_control_config),
        .cfg_data_width   (w_width_config),
        .cfg_data_ksize   (w_ksize_config) // Nối vào dây w_ksize_config
    );

    // B. Lắp Module AXI-Stream Adder
    axis_pipeline_adder #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_data_plane (
        .clk           (clk),
        .rst_n         (rst_n),
        
        // Cổng cấu hình (Lấy từ dây w_ksize_config)
        .cfg_add_value (w_ksize_config), 
   
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tkeep(s_axis_tkeep),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tkeep(m_axis_tkeep)
        
    );


endmodule