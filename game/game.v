module game (
    input clk1khz,cat,dog,mouse,human,rst,off,output [15:0]led
);
// output reg [7:0]row,r,g,
    // animation u1(
    //     .cat(cat),
    //     .dog(dog),
    //     .mouse(mouse),
    //     .clk1khz(clk1khz),
    //     .rst(rst),
    //     .off(off),
    //     .row(row),
    //     .r(r),
    //     .g(g)
    // );
    humanmove u2(
        .human(human),
        .clk1khz(clk1khz),
        .rst(0),
        .off(0),
        .led(led)
    );

    
endmodule


module humanmove(
    input human,clk1khz,rst,off,output reg[15:0]led
);
    divide#(.wide(10),.n(250))u1(
        .clk(clk1khz),
        .rst(human),
        .clkout(clk25mhz)
    );

initial begin
    led=16'b1000_0000_0000_0000;
end


    reg humanisr,humanmove,movedone;
always @(posedge clk1khz or posedge off or posedge rst or posedge movedone) begin
    if(off)begin
        humanmove=0;
    end
    else if(rst)begin
        humanmove=0;
    end
    else if(movedone)begin
        humanmove=0;
    end
    else if(humanmove==0)begin
        if(human)begin
            humanmove=1;
            humansetr=humanisr;
        end
    end
end
    reg humansetr=0;
always @(negedge clk25mhz or posedge rst or posedge off or negedge humanmove) begin
    if(off)begin
        led=0;
    end
    else if(rst)begin
        led=16'b1000_0000_0000_0000;
    end
    else if(~humanmove)begin
        movedone=0;
    end
    else begin
        if(humanmove)begin
            if(humansetr)begin
                if(led==16'b1000_0000_0000_0000)begin
                    movedone=1;
                    humanisr=0;
                end
                else begin
                    led=led<<1;
                end
            end
            else begin
                if(led==16'b0000_0000_0000_0001)begin
                    movedone=1;
                    humanisr=1;
                end
                else begin
                    led=led>>1;
                end
            end
        end
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