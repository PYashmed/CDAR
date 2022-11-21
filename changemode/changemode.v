module changemode (
    input [3:0]mode,output reg [7:0]cat,dog,mouse,input clk1hz,rst
);

initial begin
    cat=8'b11000000;
    dog=8'b11000000;
    mouse=8'b11000000;
end
//动画每帧
always @(posedge clk1hz or posedge rst) begin
    if(rst)begin
        cat<=8'b11000000;
        dog<=8'b11000000;
        mouse<=8'b11000000;
    end
    else begin

        case(mode)//前两位（00：cat 01：dog 10：mouse，后两位，00：0帧（原位置）01：1帧 10：2帧 11：3帧
            4'b0000:begin cat<=8'b11000000; dog<=dog; mouse<=mouse; end
            4'b0001:begin cat<=8'b00110000; dog<=dog; mouse<=mouse; end
            4'b0010:begin cat<=8'b00001100; dog<=dog; mouse<=mouse; end
            4'b0011:begin cat<=8'b00000011; dog<=dog; mouse<=mouse; end
            4'b0100:begin cat<=cat; dog<=8'b11000000; mouse<=mouse; end
            4'b0101:begin cat<=cat; dog<=8'b00110000; mouse<=mouse; end
            4'b0110:begin cat<=cat; dog<=8'b00001100; mouse<=mouse; end
            4'b0111:begin cat<=cat; dog<=8'b00000011; mouse<=mouse; end
            4'b1000:begin cat<=cat; dog<=dog; mouse<=8'b11000000; end
            4'b1001:begin cat<=cat; dog<=dog; mouse<=8'b00110000; end
            4'b1010:begin cat<=cat; dog<=dog; mouse<=8'b00001100; end
            4'b1011:begin cat<=cat; dog<=dog; mouse<=8'b00000011; end
            default:begin cat<=cat; dog<=dog; mouse<=mouse; end
        endcase
    end
end

endmodule