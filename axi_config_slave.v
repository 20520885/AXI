module axil_slave (
    input wire clk,
    input wire rst_n,

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
    input wire          s_axi_r_ready,

    //CFG OUT
    output wire [31:0] cfg_data_control,
    output wire [31:0] cfg_data_width,
    output wire [31:0] cfg_data_ksize
);
    
    // do CNN accelerator là 1 slave đơn giản nên luôn ss nhận lệnh.
    assign s_axi_b_resp = 2'b00;
    assign s_axi_r_resp = 2'b00;
    //logic handshake 
    assign s_axi_aw_ready = 1'b1;
    assign s_axi_w_ready  = 1'b1;
    // Logic cho Bvalid:
    //Khi nhan duoc Addr va Data thi Bvalid = 1

    reg [31:0] reg0_control;
    reg [31:0] reg1_width;
    reg [31:0] reg2_ksize;
    reg r_b_valid;
    //Gan gia tri thanh ghi ra ngoai
    assign cfg_data_control = reg0_control;
    assign cfg_data_ksize = reg2_ksize;
    assign cfg_data_width = reg1_width;
    assign s_axi_b_valid = r_b_valid;

    always @(posedge clk) begin
        if (!rst_n) begin
            reg0_control <= 0;
            reg1_width   <= 0;
            reg2_ksize   <= 0;
            r_b_valid    <= 0;
        end
        else begin
            r_b_valid <= 1'b0;
            if (s_axi_aw_valid && s_axi_w_valid) begin
                case (s_axi_aw_addr[3:2])
                    2'b00: reg0_control <= s_axi_w_data;
                    2'b01: reg1_width <= s_axi_w_data;
                    2'b10: reg2_ksize <= s_axi_w_data;
                    default: ;

                endcase

                r_b_valid <= 1'b1;
            end
        end
    end

    //--READ LOGIC
    //san sang nhan dia chi doc
    assign s_axi_ar_ready = 1'b1;
    assign s_axi_r_resp   = 2'b00;
    
    //Thanh ghi de ghi du lieu doc tra ve
    reg [31:0] r_rdata;
    reg        r_rvalid;

    assign s_axi_r_valid = r_rvalid;
    assign s_axi_r_data =r_rdata;

    always @(posedge clk) begin
        if (!rst_n) begin
            r_rdata <=0;
            r_rvalid <=0;
        end else begin 
            //RVALID mac dinh tat sau 1 nhip
            r_rvalid <= 1'b0;

            //Khi co dia chi hop le ar_valid
            if(s_axi_ar_valid) begin
                r_rvalid <= 1'b1;
                case( s_axi_ar_addr[3:2])
                    2'b00: r_rdata <= reg0_control;
                    2'b01: r_rdata <= reg1_width;
                    2'b10: r_rdata <= reg2_ksize;
                    //REG gia su tra ve 1 ID hoac status
                    2'b11: r_rdata <= 32'hCAFEBABE;
                    default: r_rdata <= 32'b0;
                endcase
            end
        end
    end

endmodule