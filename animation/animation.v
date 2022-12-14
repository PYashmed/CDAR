module animation (
    input cat,dog,mouse,clk1khz,output [7:0]r,g,row,input rst,off
);
    //前两位选择动物，后两位播放四帧动画
    reg [1:0]animal,move;
    wire [3:0]mode;
initial begin
    animal=2'b11;
    move=2'b00;
end

// assign mode={animal,move};
//这里直接赋值会出现animal置位速度快于move，导致出现animal出现在不该出现的move位置上
//比如animal：00->10,move==00没变，出现一帧mode=1000，而此时mouse在右边
// 88行处使用同步置位


assign mode={ani,move};
    dotmatric u1(
        .clk1khz(clk1khz),
        .row(row),
        .colg(g),
        .colr(r),
        .mode(mode),
        .rst(rst),
        .off(off)
    );
    wire clk1hz;
    divide1#(
        .wide(10),
        .n(1000)
    ) u2(
        .clk(clk1khz),
        .clkout(clk1hz),
        .rst(cat || dog ||mouse)
    );


    wire a;
assign a=cat||dog||mouse;


    reg catisr,dogisr,mouseisr,movesetr;
always @(posedge clk1khz or posedge off or posedge rst) begin
    if(off || rst)begin
        enmove=0;
        animal=2'b11;
    end
    else begin
        if(movedone)begin
            enmove=0;
        end
        if(enmove==0)begin
            if(cat)begin
                animal=2'b00;
                movesetr=catisr;
                enmove=1;
            end
            if(dog)begin
                animal=2'b01;
                movesetr=dogisr;
                enmove=1;
            end
            if(mouse)begin
                animal=2'b10;//曾经这里写的10，意味着这是10...而不是2'b10,然后就显示不出来
                movesetr=mouseisr;
                enmove=1;
            end
        end
    end
end


    reg [1:0]ani=2'b00;
    reg enmove=0;//接受允许播放信号
    reg moveset=0;
    reg movedone=0;
always @(negedge clk1hz or posedge off or posedge rst or negedge enmove) begin
    if(off || rst)begin
        movedone=0;
        move=2'b00;
        moveset=0;
        catisr=0;
        dogisr=0;
        mouseisr=0;
    end
    else if(~enmove)begin
        movedone=0;
    end
    else begin
        movedone=0;
        if (enmove) begin
            if(!moveset)begin
                case(animal)
                    2'b00:ani=2'b00;
                    2'b01:ani=2'b01;
                    2'b10:ani=2'b10;
                    default:;
                endcase
                if(movesetr)begin
                    move=2'b11;
                    moveset=1;
                end
                else begin
                    move=2'b00;
                    moveset=1;
                end
            end
            else begin
                if(movesetr)begin
                    if(move==2'b00)begin
                        movedone=1;
                        moveset=0;
                        case(animal)
                            2'b00:catisr=0;
                            2'b01:dogisr=0;
                            2'b10:mouseisr=0;
                            default:;
                        endcase
                    end
                    else begin
                        move=move-1'b1;
                    end
                end
                else begin
                    if(move==2'b11)begin
                        movedone=1;
                        moveset=0;
                        case(animal)
                            2'b00:catisr=1;
                            2'b01:dogisr=1;
                            2'b10:mouseisr=1;
                            default:;
                        endcase
                    end
                    else begin
                        move=move+1'b1;
                    end
                end
            end
        end
    end
end


endmodule




























//双色点阵综合驱动模块
//传入mode：00xx为cat的xx帧，从左至右00-11 01xx：dog  10xx：mouse






module dotmatric (
    input clk1khz,output [7:0]row,colr,colg,input [3:0]mode,input rst,off
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
        .mouse(mouse),
        .off(off)
    );

    changemode u3(
        .mode(mode),
        .clk1hz(clk1hz),
        .cat(cat),
        .dog(dog),
        .mouse(mouse),
        .rst(rst)
    );
    divide #(.wide(10),.n(20)) u4(
        .clk(clk1khz),
        .clkout(clk1hz)
    );
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
    output reg [7:0]r,g,row,input [2:0]cnt,input [7:0]cat,dog,mouse,input off
);
//显示模块（行扫描显示）
always @(cnt) begin
    if(off)begin
        row<=8'b11111111;
    end
    else begin
        case(cnt)
            3'b000:begin row<=8'b11111110;r<=cat; g<=8'b0; end
            3'b001:begin row<=8'b11111101;r<=cat; g<=8'b0; end
            3'b010:begin row<=8'b11111011;r<=8'b0; g<=8'b0; end
            3'b011:begin row<=8'b11110111;r<=8'b0; g<=dog; end
            3'b100:begin row<=8'b11101111;r<=8'b0; g<=dog; end
            3'b101:begin row<=8'b11011111;r<=8'b0;g<=8'b0; end
            3'b110:begin row<=8'b10111111;r<=mouse;g<=mouse; end
            3'b111:begin row<=8'b01111111;r<=mouse;g<=mouse; end
            default:row<=8'b11111111;
        endcase
    end
end
endmodule


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





module divide (input clk,rst,output clkout);
	parameter	wide = 3;
	parameter	n = 5;
 
	reg [wide-1:0]	cntp,cntn;
	reg clkp,clkn;
	//上升沿触发时计数器的控制
always @(posedge clk or posedge rst)
	begin
		if(rst)begin
			cntp<=0;
		end
		else if (cntp==(n-1))
			cntp<=0;
		else cntp<=cntp+1;//模n的计数器
	end

	//上升沿触发的分频时钟输出,如果n为奇数得到的时钟占空比不是50%；如果n为偶数得到的时钟占空比为50%
always @(posedge clk or posedge rst)
	begin
		if(rst)begin
			clkp<=0;
		end
		else if (cntp<(n>>1))//除以2去掉余数
			clkp<=0;
		else 
			clkp<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

	//下降沿触发时计数器的控制
always @(negedge clk or posedge rst)
	begin
		if(rst)begin
			cntn<=0;
		end
		else if (cntn==(n-1))
			cntn<=0;
		else cntn<=cntn+1;
	end

	//下降沿触发的分频时钟输出，和clkp相差半个时钟
always @(negedge clk or posedge rst)
	begin
		if(rst)
			clkn<=0;
		else if (cntn<(n>>1))  
			clkn<=0;
		else 
			clkn<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

    assign clkout = (n==1)?clk:(n[0])?(clkp&clkn):clkp;//条件判断表达式
                                                          //当n=1时，直接输出clk
                                                          //当n为偶数也就是n的最低位为0，n（0）=0，输出clkp
                                                          //当n为奇数也就是n最低位为1，n（0）=1，输出clkp&clkn。正周期多所以是相与
endmodule



module divide1 (input clk,rst,output clkout);
	parameter	wide = 3;
	parameter	n = 5;
 
	reg [wide-1:0]	cntp,cntn;
	reg clkp,clkn;
	//上升沿触发时计数器的控制
always @(posedge clk or posedge rst)
	begin
		if(rst)begin
			cntp<=n>>1-1'b1;
		end
		else if (cntp==(n-1))
			cntp<=0;
		else cntp<=cntp+1;//模n的计数器
	end

	//上升沿触发的分频时钟输出,如果n为奇数得到的时钟占空比不是50%；如果n为偶数得到的时钟占空比为50%
always @(posedge clk or posedge rst)
	begin
		if(rst)begin
			clkp<=0;
		end
		else if (cntp<(n>>1))//除以2去掉余数
			clkp<=0;
		else 
			clkp<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

	//下降沿触发时计数器的控制
always @(negedge clk or posedge rst)
	begin
		if(rst)begin
			cntn<=n>>1-1'b1;
		end
		else if (cntn==(n-1))
			cntn<=0;
		else cntn<=cntn+1;
	end

	//下降沿触发的分频时钟输出，和clkp相差半个时钟
always @(negedge clk or posedge rst)
	begin
		if(rst)
			clkn<=0;
		else if (cntn<(n>>1))  
			clkn<=0;
		else 
			clkn<=1;//得到的分频时钟正周期比负周期多一个clk时钟
	end

    assign clkout = (n==1)?clk:(n[0])?(clkp&clkn):clkp;//条件判断表达式
                                                          //当n=1时，直接输出clk
                                                          //当n为偶数也就是n的最低位为0，n（0）=0，输出clkp
                                                          //当n为奇数也就是n最低位为1，n（0）=1，输出clkp&clkn。正周期多所以是相与
endmodule