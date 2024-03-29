#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <bitset>
#include <climits>
#include <cstdlib>
#include <string>
#include <cmath>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

using namespace std;

unsigned char subPixel(unsigned char red, unsigned char green,unsigned char blue);
void generate_convolve();
void generate_sinus();
void generate_inverse();
void generate_log();
void generate_mipmap();

int main(int argc, char* argv[])
{
	generate_sinus();
	generate_convolve();
	generate_inverse();
	generate_log();
	generate_mipmap();
}

void generate_mipmap()
{
	ofstream out;
	out.open("mip.asm");
	if(!(out.good()))
	{
		cout << "Can't open output file" << std::endl;
		return;
	}

	int i;
	// level 1
	for(i=0;i<256;i++)
		out << " db " << (i>>1) + 128 << "\n";
	for(i=0;i<256;i++)
		out << " db " << (i>>1) + 128 << "\n";
	out << "\n";
	
	// level 2
	for(i=0;i<256;i++)
		out << " db " << (i>>2) + 64 << "\n";
	for(i=0;i<256;i++)
		out << " db " << (i>>2) + 192 << "\n";
	out << "\n";
	
	// level 3
	for(i=0;i<256;i++)
		out << " db " << (i>>3) + 96 << "\n";
	for(i=0;i<256;i++)
		out << " db " << (i>>3) + 160 << "\n";
	out << "\n";
	
	// level 4
	for(i=0;i<256;i++)
		out << " db " << (i>>4) + 112 << "\n";
	for(i=0;i<256;i++)
		out << " db " << (i>>4) + 144 << "\n";
}
	
void generate_log()
{
	ofstream out;
	out.open("log.asm");
	if(!(out.good()))
	{
		cout << "Can't open output file" << std::endl;
		return;		
	}
	
	float a=0.0f;
	
	for(int i=0;i<256;i++)
	{
		out << " db ";
		out << (int)round(log2(a)/2.0f);
		out << "\n";
		a += 1.0f;
	}
}

void generate_sinus()
{
	ofstream out;
	out.open("sin.asm");
	if (!(out.good())) {
		cout << "Can't open output file" << std::endl;
		return;
	}

	for(double angle=0.0f;angle<256.0f;angle+=1.0f)
	{
		out << " dw ";
		out << (int)round(sin(angle*M_PI/512.0f)*16384.0f);
		out << "\n";
	}
}

void generate_inverse()
{
	ofstream out;
	out.open("inverse.asm");
	if (!(out.good())) {
		cout << "Can't open output file" << std::endl;
		return;
	}
	
	for(double inverse=0.0f;inverse<322.0f;inverse+=1.0f)
	{
		out << " dw ";
		out << (int)round(65536.0f/inverse);
		out << "\n";
	}
	
	
}

void generate_convolve()
{
	uint8_t xlibc_palette[] = {
    0x00,0x00,0x00,0xFF,
    0x00,0x20,0x08,0xFF,
    0x00,0x41,0x10,0xFF,
    0x00,0x61,0x18,0xFF,
    0x00,0x82,0x21,0xFF,
    0x00,0xA2,0x29,0xFF,
    0x00,0xC3,0x31,0xFF,
    0x00,0xE3,0x39,0xFF,
    0x08,0x00,0x42,0xFF,
    0x08,0x20,0x4A,0xFF,
    0x08,0x41,0x52,0xFF,
    0x08,0x61,0x5A,0xFF,
    0x08,0x82,0x63,0xFF,
    0x08,0xA2,0x6B,0xFF,
    0x08,0xC3,0x73,0xFF,
    0x08,0xE3,0x7B,0xFF,
    0x10,0x00,0x84,0xFF,
    0x10,0x20,0x8C,0xFF,
    0x10,0x41,0x94,0xFF,
    0x10,0x61,0x9C,0xFF,
    0x10,0x82,0xA5,0xFF,
    0x10,0xA2,0xAD,0xFF,
    0x10,0xC3,0xB5,0xFF,
    0x10,0xE3,0xBD,0xFF,
    0x18,0x00,0xC6,0xFF,
    0x18,0x20,0xCE,0xFF,
    0x18,0x41,0xD6,0xFF,
    0x18,0x61,0xDE,0xFF,
    0x18,0x82,0xE7,0xFF,
    0x18,0xA2,0xEF,0xFF,
    0x18,0xC3,0xF7,0xFF,
    0x18,0xE3,0xFF,0xFF,
    0x21,0x04,0x00,0xFF,
    0x21,0x24,0x08,0xFF,
    0x21,0x45,0x10,0xFF,
    0x21,0x65,0x18,0xFF,
    0x21,0x86,0x21,0xFF,
    0x21,0xA6,0x29,0xFF,
    0x21,0xC7,0x31,0xFF,
    0x21,0xE7,0x39,0xFF,
    0x29,0x04,0x42,0xFF,
    0x29,0x24,0x4A,0xFF,
    0x29,0x45,0x52,0xFF,
    0x29,0x65,0x5A,0xFF,
    0x29,0x86,0x63,0xFF,
    0x29,0xA6,0x6B,0xFF,
    0x29,0xC7,0x73,0xFF,
    0x29,0xE7,0x7B,0xFF,
    0x31,0x04,0x84,0xFF,
    0x31,0x24,0x8C,0xFF,
    0x31,0x45,0x94,0xFF,
    0x31,0x65,0x9C,0xFF,
    0x31,0x86,0xA5,0xFF,
    0x31,0xA6,0xAD,0xFF,
    0x31,0xC7,0xB5,0xFF,
    0x31,0xE7,0xBD,0xFF,
    0x39,0x04,0xC6,0xFF,
    0x39,0x24,0xCE,0xFF,
    0x39,0x45,0xD6,0xFF,
    0x39,0x65,0xDE,0xFF,
    0x39,0x86,0xE7,0xFF,
    0x39,0xA6,0xEF,0xFF,
    0x39,0xC7,0xF7,0xFF,
    0x39,0xE7,0xFF,0xFF,
    0x42,0x08,0x00,0xFF,
    0x42,0x28,0x08,0xFF,
    0x42,0x49,0x10,0xFF,
    0x42,0x69,0x18,0xFF,
    0x42,0x8A,0x21,0xFF,
    0x42,0xAA,0x29,0xFF,
    0x42,0xCB,0x31,0xFF,
    0x42,0xEB,0x39,0xFF,
    0x4A,0x08,0x42,0xFF,
    0x4A,0x28,0x4A,0xFF,
    0x4A,0x49,0x52,0xFF,
    0x4A,0x69,0x5A,0xFF,
    0x4A,0x8A,0x63,0xFF,
    0x4A,0xAA,0x6B,0xFF,
    0x4A,0xCB,0x73,0xFF,
    0x4A,0xEB,0x7B,0xFF,
    0x52,0x08,0x84,0xFF,
    0x52,0x28,0x8C,0xFF,
    0x52,0x49,0x94,0xFF,
    0x52,0x69,0x9C,0xFF,
    0x52,0x8A,0xA5,0xFF,
    0x52,0xAA,0xAD,0xFF,
    0x52,0xCB,0xB5,0xFF,
    0x52,0xEB,0xBD,0xFF,
    0x5A,0x08,0xC6,0xFF,
    0x5A,0x28,0xCE,0xFF,
    0x5A,0x49,0xD6,0xFF,
    0x5A,0x69,0xDE,0xFF,
    0x5A,0x8A,0xE7,0xFF,
    0x5A,0xAA,0xEF,0xFF,
    0x5A,0xCB,0xF7,0xFF,
    0x5A,0xEB,0xFF,0xFF,
    0x63,0x0C,0x00,0xFF,
    0x63,0x2C,0x08,0xFF,
    0x63,0x4D,0x10,0xFF,
    0x63,0x6D,0x18,0xFF,
    0x63,0x8E,0x21,0xFF,
    0x63,0xAE,0x29,0xFF,
    0x63,0xCF,0x31,0xFF,
    0x63,0xEF,0x39,0xFF,
    0x6B,0x0C,0x42,0xFF,
    0x6B,0x2C,0x4A,0xFF,
    0x6B,0x4D,0x52,0xFF,
    0x6B,0x6D,0x5A,0xFF,
    0x6B,0x8E,0x63,0xFF,
    0x6B,0xAE,0x6B,0xFF,
    0x6B,0xCF,0x73,0xFF,
    0x6B,0xEF,0x7B,0xFF,
    0x73,0x0C,0x84,0xFF,
    0x73,0x2C,0x8C,0xFF,
    0x73,0x4D,0x94,0xFF,
    0x73,0x6D,0x9C,0xFF,
    0x73,0x8E,0xA5,0xFF,
    0x73,0xAE,0xAD,0xFF,
    0x73,0xCF,0xB5,0xFF,
    0x73,0xEF,0xBD,0xFF,
    0x7B,0x0C,0xC6,0xFF,
    0x7B,0x2C,0xCE,0xFF,
    0x7B,0x4D,0xD6,0xFF,
    0x7B,0x6D,0xDE,0xFF,
    0x7B,0x8E,0xE7,0xFF,
    0x7B,0xAE,0xEF,0xFF,
    0x7B,0xCF,0xF7,0xFF,
    0x7B,0xEF,0xFF,0xFF,
    0x84,0x10,0x00,0xFF,
    0x84,0x30,0x08,0xFF,
    0x84,0x51,0x10,0xFF,
    0x84,0x71,0x18,0xFF,
    0x84,0x92,0x21,0xFF,
    0x84,0xB2,0x29,0xFF,
    0x84,0xD3,0x31,0xFF,
    0x84,0xF3,0x39,0xFF,
    0x8C,0x10,0x42,0xFF,
    0x8C,0x30,0x4A,0xFF,
    0x8C,0x51,0x52,0xFF,
    0x8C,0x71,0x5A,0xFF,
    0x8C,0x92,0x63,0xFF,
    0x8C,0xB2,0x6B,0xFF,
    0x8C,0xD3,0x73,0xFF,
    0x8C,0xF3,0x7B,0xFF,
    0x94,0x10,0x84,0xFF,
    0x94,0x30,0x8C,0xFF,
    0x94,0x51,0x94,0xFF,
    0x94,0x71,0x9C,0xFF,
    0x94,0x92,0xA5,0xFF,
    0x94,0xB2,0xAD,0xFF,
    0x94,0xD3,0xB5,0xFF,
    0x94,0xF3,0xBD,0xFF,
    0x9C,0x10,0xC6,0xFF,
    0x9C,0x30,0xCE,0xFF,
    0x9C,0x51,0xD6,0xFF,
    0x9C,0x71,0xDE,0xFF,
    0x9C,0x92,0xE7,0xFF,
    0x9C,0xB2,0xEF,0xFF,
    0x9C,0xD3,0xF7,0xFF,
    0x9C,0xF3,0xFF,0xFF,
    0xA5,0x14,0x00,0xFF,
    0xA5,0x34,0x08,0xFF,
    0xA5,0x55,0x10,0xFF,
    0xA5,0x75,0x18,0xFF,
    0xA5,0x96,0x21,0xFF,
    0xA5,0xB6,0x29,0xFF,
    0xA5,0xD7,0x31,0xFF,
    0xA5,0xF7,0x39,0xFF,
    0xAD,0x14,0x42,0xFF,
    0xAD,0x34,0x4A,0xFF,
    0xAD,0x55,0x52,0xFF,
    0xAD,0x75,0x5A,0xFF,
    0xAD,0x96,0x63,0xFF,
    0xAD,0xB6,0x6B,0xFF,
    0xAD,0xD7,0x73,0xFF,
    0xAD,0xF7,0x7B,0xFF,
    0xB5,0x14,0x84,0xFF,
    0xB5,0x34,0x8C,0xFF,
    0xB5,0x55,0x94,0xFF,
    0xB5,0x75,0x9C,0xFF,
    0xB5,0x96,0xA5,0xFF,
    0xB5,0xB6,0xAD,0xFF,
    0xB5,0xD7,0xB5,0xFF,
    0xB5,0xF7,0xBD,0xFF,
    0xBD,0x14,0xC6,0xFF,
    0xBD,0x34,0xCE,0xFF,
    0xBD,0x55,0xD6,0xFF,
    0xBD,0x75,0xDE,0xFF,
    0xBD,0x96,0xE7,0xFF,
    0xBD,0xB6,0xEF,0xFF,
    0xBD,0xD7,0xF7,0xFF,
    0xBD,0xF7,0xFF,0xFF,
    0xC6,0x18,0x00,0xFF,
    0xC6,0x38,0x08,0xFF,
    0xC6,0x59,0x10,0xFF,
    0xC6,0x79,0x18,0xFF,
    0xC6,0x9A,0x21,0xFF,
    0xC6,0xBA,0x29,0xFF,
    0xC6,0xDB,0x31,0xFF,
    0xC6,0xFB,0x39,0xFF,
    0xCE,0x18,0x42,0xFF,
    0xCE,0x38,0x4A,0xFF,
    0xCE,0x59,0x52,0xFF,
    0xCE,0x79,0x5A,0xFF,
    0xCE,0x9A,0x63,0xFF,
    0xCE,0xBA,0x6B,0xFF,
    0xCE,0xDB,0x73,0xFF,
    0xCE,0xFB,0x7B,0xFF,
    0xD6,0x18,0x84,0xFF,
    0xD6,0x38,0x8C,0xFF,
    0xD6,0x59,0x94,0xFF,
    0xD6,0x79,0x9C,0xFF,
    0xD6,0x9A,0xA5,0xFF,
    0xD6,0xBA,0xAD,0xFF,
    0xD6,0xDB,0xB5,0xFF,
    0xD6,0xFB,0xBD,0xFF,
    0xDE,0x18,0xC6,0xFF,
    0xDE,0x38,0xCE,0xFF,
    0xDE,0x59,0xD6,0xFF,
    0xDE,0x79,0xDE,0xFF,
    0xDE,0x9A,0xE7,0xFF,
    0xDE,0xBA,0xEF,0xFF,
    0xDE,0xDB,0xF7,0xFF,
    0xDE,0xFB,0xFF,0xFF,
    0xE7,0x1C,0x00,0xFF,
    0xE7,0x3C,0x08,0xFF,
    0xE7,0x5D,0x10,0xFF,
    0xE7,0x7D,0x18,0xFF,
    0xE7,0x9E,0x21,0xFF,
    0xE7,0xBE,0x29,0xFF,
    0xE7,0xDF,0x31,0xFF,
    0xE7,0xFF,0x39,0xFF,
    0xEF,0x1C,0x42,0xFF,
    0xEF,0x3C,0x4A,0xFF,
    0xEF,0x5D,0x52,0xFF,
    0xEF,0x7D,0x5A,0xFF,
    0xEF,0x9E,0x63,0xFF,
    0xEF,0xBE,0x6B,0xFF,
    0xEF,0xDF,0x73,0xFF,
    0xEF,0xFF,0x7B,0xFF,
    0xF7,0x1C,0x84,0xFF,
    0xF7,0x3C,0x8C,0xFF,
    0xF7,0x5D,0x94,0xFF,
    0xF7,0x7D,0x9C,0xFF,
    0xF7,0x9E,0xA5,0xFF,
    0xF7,0xBE,0xAD,0xFF,
    0xF7,0xDF,0xB5,0xFF,
    0xF7,0xFF,0xBD,0xFF,
    0xFF,0x1C,0xC6,0xFF,
    0xFF,0x3C,0xCE,0xFF,
    0xFF,0x5D,0xD6,0xFF,
    0xFF,0x7D,0xDE,0xFF,
    0xFF,0x9E,0xE7,0xFF,
    0xFF,0xBE,0xEF,0xFF,
    0xFF,0xDF,0xF7,0xFF,
    0xFF,0xFF,0xFF,0xFF,
};

    ofstream out;
    out.open("lightmap.asm");
	if (!(out.good())) {
		cout << "Can't open output file" << std::endl;
		return;
	}

//    unsigned char convolveTable[8192];
    int i,j;
    int intensity=0;
    unsigned char red,blue,green;
    out <<" db ";
    for(j=0;j<32;j++)
    {
        for(i=0;i<256;i++)
        {
            red=min(((xlibc_palette[i*4]*intensity)/256),255);
            green=min(((xlibc_palette[i*4+1]*intensity)/256),255);
            blue=min(((xlibc_palette[i*4+2]*intensity)/256),255);
 //           convolveTable[j*256+i]=subPixel(red,green,blue);
        out << (int)subPixel(red,green,blue);
        if(i!=255) out << ",";
        }
        if(j!=31) out << "\n db ";
        intensity+=16;
    }
}

unsigned char subPixel(unsigned char red, unsigned char green,unsigned char blue)
{

    unsigned char res;

    res=min((red)>>5,7)<<5;
    res|=min((blue)>>6,3)<<3;
    res|=min((green)>>5,7);
    return res;
}
