#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <bitset>
#include <climits>
#include <cstdlib>
#include <string>
#include <math.h>
#include "lodepng/lodepng.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>


#define DITHER 1
#define ALPHA  2
#define COMPRESS 128

using namespace std;

typedef unsigned int uint;
void convertTexturePage(string filename, string outname, unsigned char option);
unsigned char subPixelDither(unsigned int x,unsigned int y,unsigned char red, unsigned char green, unsigned char blue);
int closest_rg(unsigned int c);
int closest_b(unsigned int c);
unsigned int subPixelDitherAlpha(unsigned int x,unsigned int y,unsigned char red, unsigned char green, unsigned char blue,unsigned char alpha);
unsigned int subPixelAlpha(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha);
unsigned char subPixel(unsigned char red, unsigned char green,unsigned char blue);
//4,8,4
const int red_boost=256; //4
const int blue_boost=256; //8
const int green_boost=256; //4

typedef struct optimal_t {
    size_t bits;
    int offset;
    int len;
} Optimal;

Optimal *optimize(unsigned char *input_data, size_t input_size);

unsigned char *compress(Optimal *optimal, unsigned char *input_data, size_t input_size, size_t *output_size, long *delta);

uint8_t *output_data;
size_t output_index;
size_t bit_index;
int bit_mask;
long diff;

int main(int argc, char* argv[])
{
///   arg = name
///   arg = -C : colors
    const char *filename=NULL;
    const char *outputname=NULL;
    unsigned char option=0;

    if(argc<2)
    {
        ///print the usage
		printf("Usage : \n");
		printf("texconv filename [-d(ithering)][-a(lpha)][-c(ompress)]\n");
        printf("Options : \n");
        printf("-dithering : dither the texture\n");
		printf("-alpha : output alpha information\n");
		printf("-compress : output a zx7 compressed file\n");
        return false;
    }

    int arg=0;
    while(arg<argc)
    {
        if(argv[arg][0]=='-'||argv[arg][0]=='/')
        {
            switch(toupper(argv[arg][1]))
            {
            case 'D':
                option|=DITHER;
                break;
            case 'A':
                option|=ALPHA;
                break;
			case 'C':
				option|=COMPRESS;
				break;
		case 'O':
			outputname=argv[arg];
			break;
            default:
                printf("Unrecognized argument %s\n",argv[arg]);
            }
        }
        else
        {
            filename=argv[arg];
        }
        arg++;
    }
        if(filename==NULL){
	printf("No input file has been set\n");
	return false;
	}
	if(outputname==NULL){
	    printf("No output file has been set\n");
	return false;
	}
	
	string outname = outputname;
	outname = outname.substr(3);
	convertTexturePage(filename, outname, option);
}

int closest_rg(unsigned int c) {
  return (c >> 5 << 5);
}
int closest_b(unsigned int c) {
  return (c >> 6 << 6);
}
static const int bayer[64]={
    1,9,3,11,
    13,5,15,7,
    4,12,2,10,
    16,8,14,6
};
unsigned char subPixelDither(unsigned int x,unsigned int y,unsigned char red, unsigned char green, unsigned char blue)
{
   unsigned int threshold_id = ((y & 3) << 2) + (x & 3);
   /*red=closest_rg(min(bayer[threshold_id]/2+red,255));
   blue=closest_b(min(bayer[threshold_id]+blue,255));
   green=closest_rg(min(bayer[threshold_id]/2+green,255));*/
   red=min(bayer[threshold_id]/2+red,255);
   blue=min(bayer[threshold_id]/2+blue,255);
   green=min(bayer[threshold_id]/2+green,255);
   return subPixel(red,green,blue);
}
unsigned int subPixelAlpha(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha)
{
    ///alpha*color+(1-alpha)*framebuffer
    ///colorfinal=alpha*color , alphale final=1-alpha
    red=(min((int)red,255)*alpha)/255;
    green=(min((int)green,255)*alpha)/255;
    blue=(min((int)blue,255)*alpha)/255;
    alpha=floor(15.0f-alpha/17.0f);
    return (((red>>5)<<5)|((blue>>6)<<3)|(green>>5))*256+alpha;
}
unsigned int subPixelDitherAlpha(unsigned int x,unsigned int y,unsigned char red, unsigned char green, unsigned char blue,unsigned char alpha)
{
   unsigned int threshold_id = ((y & 3) << 2) + (x & 3);
   red=min(bayer[threshold_id]/2+red,255);
   blue=min(bayer[threshold_id]/2+blue,255);
   green=min(bayer[threshold_id]/2+green,255);
   return subPixelAlpha(red,green,blue,alpha);
}
/*unsigned char subPixel(unsigned char red, unsigned char green,unsigned char blue)
{
    //return (min((int)(red+8),255)>>5)<<5 | ((min((int)(blue+16),255)>>6)<<3) | (min((int)(green+8),255)>>5);
    return ((int)roundf(red*7.0/255.0)<<5) | ((int)roundf(blue*3.0/255.0)<<3) | ((int)roundf(green*7.0/255.0));
}*/

void convertTexturePage(string filename, string outname, unsigned char option)
{
    unsigned int lastindex = filename.find_last_of(".");
	if(lastindex == string::npos) return;
    string includename = filename.substr(0, lastindex)+".inc";

    ofstream out;
    out.open(includename.c_str());
	if (!(out.good())) {
		cout << "Can't open output file" << std::endl;
		return;
	}
	
	out << "include \"include/fasmg/ez80.inc\"\n";
	out << "include \"include/fasmg/tiformat.inc\"\n";
	out << "define nan 0\n";
	out << "format ti archived appvar \'";
	out << outname << "\'\n";

  std::vector<unsigned char> image; //the raw pixels
  unsigned width, height;
  //decode
  unsigned error = lodepng::decode(image, width, height, filename);
  //if there's an error, display it
  if(error){
    std::cout << "decoder error " << error << ": " << lodepng_error_text(error) << std::endl;
    return;
  }
  //the pixels are now in the vector "image", 4 bytes per pixel, ordered RGBA
  if(image.size()>(256*256*4))
  {
    std::cout << "image has wrong size" << std::endl;
    return;
  }

  size_t image_size=image.size();
  if(option&ALPHA)
    image_size/=2;

  unsigned int i=0;
  uint8_t texture[65536];

  while(i<image_size)
  {
      unsigned char red,blue,green,alpha;
      unsigned int pixel;
      red=image[i];
      green=image[i+1];
      blue=image[i+2];
      alpha=image[i+3];

      switch(option&127)
      {
      case DITHER:
        texture[i>>2]=subPixelDither((i>>2)%256, i>>10, red, green, blue);
        break;
      case ALPHA:
        pixel=subPixelAlpha(red, green, blue, alpha);
        texture[i>>2]=pixel%256;    //get back alpha
        texture[(i>>2)+32768]=pixel/256;  //get back color
        break;
      case ALPHA|DITHER:
        pixel=subPixelDitherAlpha((i>>2)%256, i>>10,red, green, blue, alpha);
        texture[i>>2]=pixel%256;    //get back alpha
        texture[(i>>2)+32768]=pixel/256;  //get back color
        break;
    default:
        texture[i>>2]=subPixel(red, green, blue);
        break;
      }
      i+=4;
  }

  
	if(option&COMPRESS) {
    long delta;
    Optimal *opt;
    uint8_t *ret = NULL;
    size_t outsize;
    opt = optimize(texture, image.size()/4);
    ret = compress(opt, texture, image.size()/4, &outsize, &delta);
    free(opt);

    if(ret==NULL || (outsize>65535)) {
        std::cout << "Unable to generate this image" << std::endl;
        return;
    }
    
    out << "db ";
    for(unsigned int j=0;j<outsize;j++) {
        out << (int)ret[j];
        if(j!=(outsize-1)) out <<",";
    }
	}
	else{

	out << "db ";
    for(unsigned int j=0;j<(image.size()/4);j++) {
        out << (int)texture[j];
        if(j!=((image.size()/4)-1)) out <<",";
    }
	}
	return;
}



unsigned char subPixel(unsigned char red, unsigned char green,unsigned char blue)
{

    unsigned char res;

    res=min((red)>>5,7)<<5;
    res|=min((blue)>>6,3)<<3;
    res|=min((green)>>5,7);
    return res;
}



#include "zx7.cpp"
#include "lodepng/lodepng.cpp"
