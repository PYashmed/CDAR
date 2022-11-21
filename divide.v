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