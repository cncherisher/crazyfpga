% ���溯��������һ��ͼƬ��ԭʼRGB���ݺ�ת�����YCbCr���ݣ�����ɶ������ļ�
% ��FPGA����Ա�����
% simulate(uint8 img_RGB, uint8 img_YCbCr)
% img_RGB������������RGBͼ��
% img_YCbCr�����봦����YCbCrͼ��
% img_RGB.dat����� �������RGBͼ��hex���ݣ��ȶ�Դ���ݣ�
% img_YCbCr.dat������������YCbCrͼ��hex���ݣ��ȶԽ����


function simulate(img_RGB, img_YCbCr)
h1 = size(img_RGB,1);         % ��ȡԭʼͼ��߶�
w1 = size(img_RGB,2);         % ��ȡԭʼͼ����
h2 = size(img_YCbCr,1);       % ��ȡת����ͼ��߶�
w2 = size(img_YCbCr,2);       % ��ȡת����ͼ����

% simulation source data generate
bar = waitbar(0, 'RGB data generating...'); %create process bar
fd = fopen('./img_RGB.dat','wt');
for row = 1:h1
    r = lower(dec2hex(img_RGB(row,:,1),2))';    %��ÿһ�е�����ת����hex��ȡ��Ȼ��ת����Сд
    g = lower(dec2hex(img_RGB(row,:,2),2))';
    b = lower(dec2hex(img_RGB(row,:,3),2))';
    str_data_tmp=[];
    for col = 1 : w1
        str_data_tmp = [str_data_tmp,r(col*2-1:col*2),' ',g(col*2-1:col*2),' ',b(col*2-1:col*2),' '];   %��RGB����ȫ��д�뵽һ���ַ�������
    end
    str_data_tmp = [str_data_tmp , 10];     %������һ��\n����
    fprintf(fd,'%s',str_data_tmp);
    waitbar(row/h1);
end
fclose(fd);    %д���ļ���
close(bar);   % Close waitbar

%------------------------------------------
% Simulation Target Data Generate
bar = waitbar(0,'YCbCr data generating...');   %Create process bar
fd = fopen('./img_YCbCr.dat', 'wt');
for row = 1 : h2
    Y=lower(dec2hex(img_YCbCr(row,:,1),2))';
    Cb=lower(dec2hex(img_YCbCr(row,:,2),2))';
    Cr=lower(dec2hex(img_YCbCr(row,:,3),2))';
    str_data_tmp=[];
        for col = 1 : w2
        str_data_tmp = [str_data_tmp,Y(col*2-1:col*2),' ',Cb(col*2-1:col*2),' ',Cr(col*2-1:col*2),' '];   %��YCbCr����ȫ��д�뵽һ���ַ�������
    end
    str_data_tmp = [str_data_tmp , 10];     %������һ��\n����
    fprintf(fd,'%s',str_data_tmp);
    waitbar(row/h2);
end
fclose(fd);    %д���ļ���
close(bar);   % Close waitbar