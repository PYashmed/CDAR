//行扫描
module bicolor_dot_matrix (
    output reg [7:0]r,g,row,input [2:0]cnt,input [7:0]cat,dog,mouse
);
//显示模块（行扫描显示）
always @(cnt) begin
    case(cnt)
        3'b000:begin row=8'b11111110;r=cat; g=8'b0; end
        3'b001:begin row=8'b11111101;r=cat; g=8'b0; end
        3'b010:begin row=8'b11111011;r=8'b0; g=8'b0; end
        3'b011:begin row=8'b11110111;r=dog;g=dog; end
        3'b100:begin row=8'b11101111;r=dog;g=dog; end
        3'b101:begin row=8'b11011111;r=8'b0;g=8'b0; end
        3'b110:begin row=8'b10111111;r=8'b0;g=mouse; end
        3'b111:begin row=8'b01111111;r=8'b0;g=mouse; end
        default:row=8'b11111111;
    endcase
end
endmodule


module guohe (
    input cat,dog,mouse,output reg [7:0]c,d,m
);
    if(cat)begin
        if(c==8'b11000000) begin
            
endmodule

module animation(
    input clk,tol,tor,output reg [7:0]a
);
always @(*) begin
    if(tol)begin
        a=8'b00000011;
    end
    if(tor)begin
        a=8'b11000000;
    end
end
    wire clk1hz;
divide #(.wide(32),.n(1000)) u1(
    .clk(clk),
    .clkout(clk1hz)
);
    reg gol;
always @(posedge clk1hz or posedge tol or posedge tor) begin
    if(tol)begin
        if(a==8'b11000000)begin
            a=8'b00000011;
        end
        gol=1;
    end
    if(gol)begin
        if(a!=8'b11000000)begin
            a<=a<<2;
        end
        else begin
            gol=0;
        end
    end
    if(tor)begin
        if(a!=8'b00000011)begin
            a<=a>>2;
        end
    end
end
endmodule