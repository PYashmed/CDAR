//双色点阵综合驱动模块
//传入mode：00xx为cat的xx帧，从左至右00-11 01xx：dog  10xx：mouse






module dotmatric (
    input clk1khz,output [7:0]row,colr,colg,input [3:0]mode
);
    wire [7:0]cat,dog,mouse;
    wire [2:0]cnt;
    cnt8 u1(
        .clk(clk1khz),
        .cnt(cnt)
    );
    bicolor_dot_matrix u2(
        .cnt(cnt),
        .row(row),
        .r(colr),
        .g(colg),
        .cat(cat),
        .dog(dog),
        .mouse(mouse)
    );

    changemode u3(
        .mode(mode),
        .clk1hz(clk1hz),
        .cat(cat),
        .dog(dog),
        .mouse(mouse),
        .cat(mode0[0]),
        .dog(mode0[1]),
        .mouse(mode[2])
    );
    divide #(.wide(10),.n(1000)) u4(
        .clk(clk1khz),
        .clkout(clk1hz)
    );
    reg [7:0]mode0[2:0];
always @(cat or dog or mouse) begin
    mode0[0]=cat;
    mode0[1]=dog;
    mode0[2]=mouse;
end
endmodule
//行扫描计数时钟（附属模块）
module cnt8 (
    input clk,output reg [2:0]cnt
);
always @(posedge clk) begin
    if(cnt==3'b111)
        cnt=3'b000;
    else
        cnt=cnt+1'b1;
end
endmodule



//点阵驱动模块(行扫描显示)
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


module changemode (
    input [3:0]mode,output reg [7:0]cat,dog,mouse,input clk1hz,input [7:0]cat,dog,mouse
);

initial begin
    cat=8'b11000000;
    dog=8'b11000000;
    mouse=8'b11000000;
end
//动画每帧
always @(posedge clk1hz) begin
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

endmodule


module divide (input clk,output clkout);
	parameter	wide = 3;
	parameter	n = 5;
 
	reg [wide-1:0]	cntp,cntn;
	reg clkp,clkn;
	//上升沿触发时计数器的控制
always @(posedge clk)
	begin
		if (cntp==(n-1))
			cntp<=0;
		else cntp<=cntp+1;//模n的计数器
	end

	//上升沿触发的分频时钟输出,如果n为奇数得到的时钟占空比不是50%；如果n为偶数得到的时钟占空比为50%
always @(posedge clk)
	begin
		if (cntp<(n>>1))//除以2去掉余数
			clkp<=0;
		else 
			clkp<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

	//下降沿触发时计数器的控制
always @(negedge clk)
	begin
		if (cntn==(n-1))
			cntn<=0;
		else cntn<=cntn+1;
	end

	//下降沿触发的分频时钟输出，和clkp相差半个时钟
always @(negedge clk)
	begin
		if (cntn<(n>>1))  
			clkn<=0;
		else 
			clkn<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

    assign clkout = (n==1)?clk:(n[0])?(clkp&clkn):clkp;//条件判断表达式
                                                          //当n=1时，直接输出clk
                                                          //当n为偶数也就是n的最低位为0，n（0）=0，输出clkp
                                                          //当n为奇数也就是n最低位为1，n（0）=1，输出clkp&clkn。正周期多所以是相与
endmodule