`timescale 1ns/1ns
module RGB8882YCbCr444
(
//global clock and reset
input	clk,	//cmos video pixel clock
input	rst_n,	//global reset


//Image data before process
input 	before_img_vsync,	//Prepared Image data vsync valid signal
input 	before_img_href,	//Prepared Image date href vaild signal
input [7:0]	before_img_red,	//Prepared Image red data to be processed
input [7:0]	before_img_green,	//Prepared Image green data to be processed
input [7:0]	before_img_blue,	//Prepared Image blue data to be processed

//Image data after process

output after_img_vsync,	//Processd Image data vsync vaild signal
output after_img_href,	//Processd Image data href vaild signal
output [7:0] after_img_Y,	//Processed Image brightness output
output [7:0] after_img_Cb,	//Processed Image blue shading output
output [7:0] after_img_Cr	//Processed Image red shading output
);

//------------------------------
//step1: ����9���˷�����
reg [15:0]	img_red_r0,	img_red_r1,	img_red_r2;
reg [15:0]	img_green_r0, img_green_r1, img_green_r2;
reg [15:0]	img_blue_r0, img_blue_r1, img_blue_r2;

always@(posedge clk)
begin
	//�ȴ����3����ɫ����
	img_red_r0 <= before_img_red * 8'd76;
	img_red_r1 <= before_img_red * 8'd43;
	img_red_r2 <= before_img_red * 8'd128;
	//����3����ɫ����
	img_green_r0 <= before_img_green * 8'd150;
	img_green_r1 <= before_img_green * 8'd84;
	img_green_r2 <= before_img_green * 8'd107;
	//����3����ɫ����
	img_blue_r0 <= before_img_blue * 8'd29;
	img_blue_r1 <= before_img_blue * 8'd128;
	img_blue_r2 <= before_img_blue * 8'd20;
end

//------------------------------
//step2: ���мӼ�������
reg [15:0]	img_Y_r0;
reg [15:0]	img_Cb_r0;
reg [15:0]	img_Cr_r0;

always@(posedge clk)
begin
	img_Y_r0 <= img_red_r0 + img_green_r0 + img_blue_r0;
	img_Cb_r0 <= -img_red_r1 - img_green_r1 + img_blue_r1 + 16'd32768;
	img_Cr_r0 <= img_red_r2 - img_green_r2 - img_blue_r2 + 16'd32768;
end

//------------------------------
//step3: �����ݳ���256������ȡ��Ч���ݣ�ֱ��ȡ��8λ
reg [7:0]	img_Y_r1;
reg [7:0]	img_Cb_r1;
reg [7:0]	img_Cr_r1;

always@(posedge clk)
begin
	img_Y_r1 <= img_Y_r0[15:8];
	img_Cb_r1 <= img_Cb_r0[15:8];
	img_Cr_r1 <= img_Cr_r0[15:8];
end

//------------------------------
//vsync href�Ӻ�3�ģ���֤ʱ��
reg [2:0]	before_img_vsync_r;
reg [2:0]	before_img_href_r;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
	before_img_vsync_r <= 0; 	//��ʼֵΪ�͵�ƽ
	before_img_href_r <=0 ;		//��ʼֵΪ�͵�ƽ
	end
else
	begin
	before_img_vsync_r <= {before_img_vsync_r[1:0], before_img_vsync};
	before_img_href_r <= {before_img_href_r[1:0], before_img_href};
	end
end
assign after_img_vsync = before_img_vsync_r[2];
assign after_img_href = before_img_href_r[2];
assign after_img_Y = after_img_href ? img_Y_r1 : 8'd0;
assign after_img_Cb = after_img_href ? img_Cb_r1 : 8'd0;
assign after_img_Cr = after_img_href ? img_Cr_r1 : 8'd0;

endmodule