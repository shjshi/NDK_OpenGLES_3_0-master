#version  320 es
precision highp float;
precision highp int;
in vec2 outTexCoords;

uniform sampler2D sampler;
uniform sampler2D TimeSampler;
uniform sampler2D sourceSampler;

uniform sampler2D texturetimespv;//页面单行时序
uniform sampler2D texturetimeline;//单行数据时序
uniform sampler2D texturewaveform;

out vec4  fragColor;

uniform float frame;

int get_waveform_data(float frame, float prev, float next){

    int postex =  int(0x10000 * int(frame) + 0x100 * int(prev) + int(next));
    int Xtex = int(floor(float(postex) - floor(float(postex)/4096.0)*4096.0));
    int Ytxex = int(floor(float(postex)/4096.0));

    float Xgl =  float(Xtex)/4096.0*2.0-1.0;
    float Ygl  = 1.0 -float(Ytxex)/4096.0*2.0;

    float s = (Xgl+1.0)/2.0;
    float t = -(Ygl-1.0)/2.0;
    return int(floor(texture(texturewaveform, vec2(s, t)).r*255.0+0.5));

}

//获取原图指定位置的R,G,B
int getTEXRgbByPoint(int Xtex, int Ytxex, int cur){
    float Xgl =  float(Xtex)/1872.0*2.0-1.0;
    float Ygl  = 1.0 -float(Ytxex)/1404.0*2.0;
    float s = (Xgl+1.0)/2.0;
    float t = -(Ygl-1.0)/2.0;
    if (cur == 0){
        return int(floor(texture(sourceSampler, vec2(s, t)).r*255.0+0.5));
    } else if (cur == 1){
        return int(floor(texture(sourceSampler, vec2(s, t)).g*255.0+0.5));
    } else if (cur == 2){
        return int(floor(texture(sourceSampler, vec2(s, t)).b*255.0+0.5));
    }
    return 0;
}
int getGrayDataFromSource(int Xtex, int Ytxex){
    float Xgl =  float(Xtex)/1872.0*2.0-1.0;
    float Ygl  = 1.0 -float(Ytxex)/1404.0*2.0;

    float s = (Xgl+1.0)/2.0;
    float t = -(Ygl-1.0)/2.0;
    return int(floor(texture(sourceSampler, vec2(s, t)).r*255.0+0.5));
}
//获取原图指定位置的EINK组合方式的,R,G,B
int getSourceImageRgb(int Xtex, int Ytex, float posTex, int BitsPerPixel){

    int Gray=0, R=0, G=0, B=0;
    int Gray1=0, R1=0, G1=0, B1=0;

    int x, y, x1, y1, Xtex1, Ytex1;
    float posTex1;
    int  c, d, tmp1, tmp2;

    posTex1 =  (float(Xtex))+float(Ytex)*234.0;//*float(BitsPerPixel);
    Ytex1 = Ytex;
    Xtex1 = Xtex-19;
    if (BitsPerPixel ==4)
    {
        //这里24字节转成黑白图  8字节*3(RGB) ->  4字节(16灰色)
        int d1 = 0, d2 = 0, d3 = 0, d4 = 0;
        int e1 = 0xff, e2 = 0xff, e3 = 0xff, e4 = 0xff;
        #if 0
        for (int j = 0;j<8;)
        {
            y = int(floor((posTex1*8.0+float(j))/1872.0));
            x = int(floor((float(Xtex1))*8.0+float(j)));
            y1 = int(floor((posTex1*8.0+float(j+1))/1872.0));
            x1 = int(floor((float(Xtex1))*8.0+float(j+1)));

            R = getTEXRgbByPoint(x, y, 0);
            G = getTEXRgbByPoint(x, y, 1);
            B = getTEXRgbByPoint(x, y, 2);

            R1 = getTEXRgbByPoint(x1, y1, 0);
            G1 = getTEXRgbByPoint(x1, y1, 1);
            B1 = getTEXRgbByPoint(x1, y1, 2);
            Gray = int(((R*299+G*587+B*114+500)/1000)>>4);
            Gray1 = int(((R1*299+G1*587+B1*114+500)/1000)>>4);
            Gray = Gray&0xFF;
            Gray1 = Gray1&0xFF;
            if (j == 0)
            {
                d1 = Gray|(Gray1<<4);
            }
            else if (j == 2)
            {
                d2 = Gray|(Gray1<<4);
            }
            else if (j == 4)
            {
                d3 = Gray|(Gray1<<4);
            }
            else if (j == 6)
            {
                d4 = Gray|(Gray1<<4);
            }
            j +=2;
        }
            #else
        for (int j = 0;j<8;)
        {
            y = int(floor((posTex1*8.0+float(j))/1872.0));
            x = int(floor((float(Xtex1))*8.0+float(j)));
            y1 = int(floor((posTex1*8.0+float(j+1))/1872.0));
            x1 = int(floor((float(Xtex1))*8.0+float(j+1)));
            Gray = int(getGrayDataFromSource(x, y)>>4);
            Gray1 = int(getGrayDataFromSource(x1, y1)>>4);
            Gray = Gray&0xFF;
            Gray1 = Gray1&0xFF;
            if (j == 0)
            {
                d1 = Gray|(Gray1<<4);
            }
            else if (j == 2)
            {
                d2 = Gray|(Gray1<<4);
            }
            else if (j == 4)
            {
                d3 = Gray|(Gray1<<4);
            }
            else if (j == 6)
            {
                d4 = Gray|(Gray1<<4);
            }
            j +=2;
        }
            #endif
        d1 = d1&0xFF;
        d2 = d2&0xFF;
        d3 = d3&0xFF;
        d4 = d4&0xFF;
        c = d1;
        c= c&0xFF;
        d = 0;
        #if 1
        d |= (get_waveform_data(frame, float(e3 & 0x0f), float(d3 & 0x0F))&0x3)<<6;
        d |= (get_waveform_data(frame, float((e3 >> 4) & 0x0f), float((d3 >> 4) & 0x0f))&0x3)<<4;
        d |= (get_waveform_data(frame, float(e4 & 0x0f), float(d4 & 0x0F))&0x3)<<2;
        d |= (get_waveform_data(frame, float((e4 >> 4) & 0x0f), float((d4 >> 4) & 0x0f))&0x3)<<0;
        #else
        if (float(d3&0x0F)>frame) d |=0x80; else d |= 0x40;
        if (float(d3>>4)>frame)   d |=0x20; else d |= 0x10;
        if (float(d4&0x0F)>frame) d |=0x08; else d |= 0x04;
        if (float(d4>>4)>frame)   d |=0x02; else d |= 0x01;
        #endif
        // line_dest_data[f++] = d;

        //p_buffer[(XscrInt+YscrInt*1872)*3] = d;         //对应     XscrInt+YscrInt*1872   (XscrInt, YscrInt).g
        tmp1 = d;
        d = 0;
        #if 1
        d |= (get_waveform_data(frame, float(e1 & 0x0f), float(d1 & 0x0F))&0x3)<<6;
        d |= (get_waveform_data(frame, float((e1 >> 4) & 0x0f), float((d1 >> 4) & 0x0f))&0x3)<<4;
        d |= (get_waveform_data(frame, float(e2 & 0x0f), float(d2 & 0x0F))&0x3)<<2;
        d |= (get_waveform_data(frame, float((e2 >> 4) & 0x0f), float((d2 >> 4) & 0x0f))&0x3)<<0;
        #else
        if (float(d1&0x0F)>frame) d |= 0x80; else d |=  0x40;
        if (float(d1>>4)>frame)   d |= 0x20; else d |=  0x10;
        if (float(d2&0x0F)>frame) d |= 0x08; else d |=  0x04;
        if (float(d2>>4)>frame)   d |= 0x02; else d |=  0x01;
        #endif
        tmp2 = d;
    }
    else
    {
        //这里24字节转成黑白图  8字节*3(RGB) ->  1字节(2灰色)
        int d1 = 0;
        for (int j = 0;j<8;j++)//for(int j = 0;j<8*3;)
        {
            y = int(floor((posTex1*8.0+float(j))/1872.0));
            x = int(floor((float(Xtex1))*8.0+float(j)));

            R = getTEXRgbByPoint(x, y, 0);
            G = getTEXRgbByPoint(x, y, 1);
            B = getTEXRgbByPoint(x, y, 2);

            Gray = int((R*299+G*587+B*114+500)/1000);
            d1 = d1<<1;
            Gray = Gray&0xFF;
            d1 = d1&0xFF;

            if (Gray>127){
                d1 |=1;
            } else {

            }
            // j +=1;
        }

        //这里设置1灰    234*2  每行
        // c = ~pic_buf[b++];
        d1 = d1&0xFF;
        c = d1;
        c= c&0xFF;
        d = 0;
        #if 0//1
        if (bool(c&0x01)) d |= 0x40;
        if (bool(c&0x02)) d |= 0x10;
        if (bool(c&0x04)) d |= 0x04;
        if (bool(c&0x08)) d |= 0x01;
        #else
        if (bool(c&0x08)) d |= 0x80; else d |= 0x40;
        if (bool(c&0x04)) d |= 0x20; else d |= 0x10;
        if (bool(c&0x02)) d |= 0x08; else d |= 0x04;
        if (bool(c&0x01)) d |= 0x02; else d |= 0x01;
        #endif
        // line_dest_data[f++] = d;

        //p_buffer[(XscrInt+YscrInt*1872)*3] = d;         //对应     XscrInt+YscrInt*1872   (XscrInt, YscrInt).g
        tmp1 = d;
        d = 0;
        #if 0//1
        if (bool(c&0x10)) d |= 0x40;
        if (bool(c&0x20)) d |= 0x10;
        if (bool(c&0x40)) d |= 0x04;
        if (bool(c&0x80)) d |= 0x01;
        #else
        if (bool(c&0x80)) d |= 0x80; else d |= 0x40;
        if (bool(c&0x40)) d |= 0x20; else d |= 0x10;
        if (bool(c&0x20)) d |= 0x08; else d |= 0x04;
        if (bool(c&0x10)) d |= 0x02; else d |= 0x01;
        #endif
        tmp2 = d;
    }
    return (tmp1<<8)|tmp2;
}
void main(void) {
    float s = outTexCoords.s;
    float t = outTexCoords.t;

    float Xgl  = 2.0*s-1.0;//屏幕X 坐标  (-1  1)
    float Ygl  =  -2.0*t + 1.0;//屏幕Y 坐标  (-1  1)
    //长宽随时变化
    float Xscr = (Xgl+1.0)/2.0*1872.0;
    float Yscr = -(Ygl-1.0)/2.0*1404.0;
    //
    int XscrInt = int(floor(Xscr));//   int(Xscr+0.5);
    int YscrInt = int(floor(Yscr));//int(Yscr+0.5);

    //从这里开始,逻辑按cpu逻辑来处理
    float pos;//int  pos;  //根据当前屏幕坐标计算出传入原图纹理数组中的按一维数组排序的数据位置，需要减去页面时序的数值990  + 对齐19
    float  posdata;

    int Xtex, Ytex;//原图纹理坐标:  根据POS计算出 在原图纹理中的取色位置坐标



    int Xtex1, Ytex1;//1404*256 *3 存放数据的纹理


    float  posTex1;

    int Gray=0, R=0, G=0, B=0;

    int x, y;


    //这里是模拟 纹理,所以是按1872*1404 修改纹理数据
    pos = float(XscrInt)*1.0+float(YscrInt)*1872.0;

    posdata = pos -990.0;
    if (pos < 990.0)
    {
        //这里放页面时序
        //   fragColor = texture(TimeSampler, outTexCoords);
        fragColor = vec4(texture(texturetimespv, vec2(s, 0)).r, texture(texturetimespv, vec2(s, 0)).g, texture(texturetimespv, vec2(s, 0)).b, 1.0);
    } else {
        if (posdata< 1404.0*256.0)//if(pos< 1404*234)                    //单位像素
        {
            Ytex1 = int(floor(posdata/256.0));
            Xtex1 = int(floor(posdata - floor(posdata/256.0)*256.0));
            if (Xtex1<19)
            {
                float Xgl1 =  float(Xtex1)/1872.0*2.0-1.0;
                float s1 = (Xgl1+1.0)/2.0;
                fragColor = vec4(texture(texturetimeline, vec2(s1, 0)).r, texture(texturetimeline, vec2(s1, 0)).g, texture(texturetimeline, vec2(s1, 0)).b, 1.0);
            } else
            {
                if (Xtex1<253)//if(Xtex1<253)
                {
                    int  tmp1 =0, tmp2=0;
                    tmp1 = getSourceImageRgb(Xtex1, Ytex1, posTex1, 4);
                    tmp2 = tmp1&0xFF;
                    tmp1 = tmp1>>8;
                    //显示不带时序的第二纹理原图
                    // fragColor =  vec4(float(tmp2)/255.0,float(tmp1)/255.0,texture(texture1, outTexCoords).b,1.0);
                    #if 0//1
                    fragColor = texture(texture1, outTexCoords);
                    #else
                    float Xgl2 =  float(Xtex1)/1872.0*2.0-1.0;
                    float s2 = (Xgl2+1.0)/2.0;
                    fragColor =  vec4(float(tmp2)/255.0, float(tmp1)/255.0, texture(texturetimeline, vec2(s2, 0)).b, 1.0);//这里用的是单行时序纹理
                    #endif


                } else {
                    // fragColor = texture(TimeSampler, outTexCoords);

                    float Xgl3 =  float(Xtex1)/1872.0*2.0-1.0;
                    float s3 = (Xgl3+1.0)/2.0;
                    fragColor =  vec4(texture(texturetimeline, vec2(s3, 0)).r, texture(texturetimeline, vec2(s3, 0)).g, texture(texturetimeline, vec2(s3, 0)).b, 1.0);//这里用的是单行时序纹理
                }
            }
        } else {
            //   fragColor = texture(TimeSampler, outTexCoords);
            fragColor =  vec4(0.0, 0.0, 0.0, 1.0);
        }
    }
}