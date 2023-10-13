`timescale  1ns/1ns
module testbench;

localparam image_width  = 512;
localparam image_height = 512;
//----------------------------------------------------------------------
//  clk & rst_n
reg                             clk;
reg                             rst_n;

initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial
begin
    rst_n = 1'b0;
    repeat(50) @(posedge clk);
    rst_n = 1'b1;
end

//----------------------------------------------------------------------
//  Image data prepred to be processed
reg                             before_img_vsync;
reg                             before_img_href;
reg             [7:0]           before_img_red;
reg             [7:0]           before_img_green;
reg             [7:0]           before_img_blue;

//  Image data has been processed
wire                            after_img_vsync;
wire                            after_img_href;
wire            [7:0]           after_img_Y;
wire            [7:0]           after_img_Cb;
wire            [7:0]           after_img_Cr;

//----------------------------------------------------------------------
//  task and function
task image_input;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit             [7:0]       mem     [image_width*image_height*3-1:0];
    $readmemh("../../Matlab/img_RGB.dat",mem);
    
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        before_img_vsync = 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            before_img_href  = 1'b1;
            before_img_red   = mem[(row_cnt*image_width+col_cnt)*3+0];
            before_img_green = mem[(row_cnt*image_width+col_cnt)*3+1];
            before_img_blue  = mem[(row_cnt*image_width+col_cnt)*3+2];
            @(posedge clk);
        end
        before_img_href  = 1'b0;
    end
    before_img_vsync = 1'b0;
    @(posedge clk);
    
endtask : image_input

reg                             after_img_vsync_r;

always @(posedge clk)
begin
    if(rst_n == 1'b0)
        after_img_vsync_r <= 1'b0;
    else
        after_img_vsync_r <= after_img_vsync;
end

wire                            after_img_vsync_pos;
wire                            after_img_vsync_neg;

assign after_img_vsync_pos = ~after_img_vsync_r &  after_img_vsync;
assign after_img_vsync_neg =  after_img_vsync_r & ~after_img_vsync;

task image_result_check;
    bit                         frame_flag;
    bit         [31:0]          row_cnt;
    bit         [31:0]          col_cnt;
    bit         [ 7:0]          mem     [image_width*image_height*3-1:0];
    
    frame_flag = 0;
    $readmemh("../../Matlab/img_YCbCr.dat",mem);
    
    while(1)
    begin
        @(posedge clk);
        if(after_img_vsync_pos == 1'b1)
        begin
            frame_flag = 1;
            row_cnt = 0;
            col_cnt = 0;
            $display("##############image result check begin##############");
        end
        
        if(frame_flag == 1'b1)
        begin
            if(after_img_href == 1'b1)
            begin
                if((after_img_Y != mem[(row_cnt*image_width+col_cnt)*3+0])||(after_img_Cb != mem[(row_cnt*image_width+col_cnt)*3+1])||(after_img_Cr != mem[(row_cnt*image_width+col_cnt)*3+2]))
                begin
                    $display("result error ---> row_num : %0d;col_num : %0d;pixel data(y cb cr) : (%h %h %h);reference data(y cb cr) : (%h %h %h)",row_cnt+1,col_cnt+1,after_img_Y,after_img_Cb,after_img_Cr,mem[(row_cnt*image_width+col_cnt)*3+0],mem[(row_cnt*image_width+col_cnt)*3+1],mem[(row_cnt*image_width+col_cnt)*3+2]);
                end
                col_cnt = col_cnt + 1;
            end
            
            if(col_cnt == image_width)
            begin
                col_cnt = 0;
                row_cnt = row_cnt + 1;
            end
        end
        
        if(after_img_vsync_neg == 1'b1)
        begin
            frame_flag = 0;
            $display("##############image result check end##############");
        end
    end
endtask : image_result_check

//----------------------------------------------------------------------
RGB8882YCbCr444 u_RGB8882YCbCr444
(
    //  global clock
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    
    //  Image data prepred to be processed
    .before_img_vsync  (before_img_vsync  ),
    .before_img_href   (before_img_href   ),
    .before_img_red    (before_img_red    ),
    .before_img_green  (before_img_green  ),
    .before_img_blue   (before_img_blue   ),
    
    //  Image data has been processed
    .after_img_vsync (after_img_vsync ),
    .after_img_href  (after_img_href  ),
    .after_img_Y     (after_img_Y     ),
    .after_img_Cb    (after_img_Cb    ),
    .after_img_Cr    (after_img_Cr    )
);

initial
begin
    before_img_vsync = 0;
    before_img_href  = 0;
    before_img_red   = 0;
    before_img_green = 0;
    before_img_blue  = 0;
end

initial 
begin
    wait(rst_n);
    fork
        begin 
            repeat(5) @(posedge clk); 
            image_input;
        end 
        image_result_check;
    join
end 

endmodule