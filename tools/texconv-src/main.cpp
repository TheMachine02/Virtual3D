#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <bitset>
#include <climits>
#include <cstdlib>
#include <string>
#include <math.h>
#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>


#define DITHER 1
#define ALPHA  2
#define COMPRESS 4

using namespace std;

typedef unsigned int uint;
void convertTexturePage(string filename, unsigned char option);
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
    string filename;
    unsigned char option=0;

    if(argc<2)
    {
        ///print the usage
        printf("Options : \n");
        printf("-D : dither the texture\n");
        return false;
    }

    int arg=0;

    while(arg<argc)
    {
        if(argv[arg][0]=='-'||argv[arg][0]=='/')
        {
            switch(argv[arg][1])
            {
            case 'D':
                option=option|DITHER;
                break;
            case 'A':
                option=option|ALPHA;
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

    convertTexturePage(filename, option);
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
    alpha=(unsigned char)floor(15.0-((float)alpha/17));
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

void convertTexturePage(string filename, unsigned char option)
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
  if(image.size()!=(256*256*4))
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

      switch(option)
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

    long delta;
    Optimal *opt;
    uint8_t *ret = NULL;
    size_t outsize;
    opt = optimize(texture, 65536);
    ret = compress(opt, texture, 65536, &outsize, &delta);
    free(opt);

    if(ret==NULL)
    {
        std::cout << "Unable to generate this image" << std::endl;
        return;
    }
    if(outsize>65535){
        std::cout << "Unable to generate this image" << std::endl;
        return;
    }

    out << ".db ";
    for(unsigned int j=0;j<outsize;j++)
    {
        out << (int)ret[j];
        if(j!=(outsize-1)) out <<",";
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



/*
 * (c) Copyright 2012 by Einar Saukas. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of its author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */



#define MAX_OFFSET  2176  /* range 1..2176 */
#define MAX_LEN    65536  /* range 2..65536 */


void *safe_malloc(size_t n) {
    void* p = malloc(n);
    return p;
}

void *safe_calloc(size_t n, size_t m) {
    void* p = calloc(n, m);
    return p;
}

void *safe_realloc(void *a, size_t n) {
    void* p = realloc(a, n);
    return p;
}


void read_bytes(int n, long *delta) {
   diff += n;
   if (diff > *delta) {
       *delta = diff;
   }
}

void write_byte(int value) {
    output_data[output_index++] = value;
    diff--;
}

void write_bit(int value) {
    if (!bit_mask) {
        bit_mask = 128;
        bit_index = output_index;
        write_byte(0);
    }
    if (value > 0) {
        output_data[bit_index] |= bit_mask;
    }
    bit_mask >>= 1;
}

void write_elias_gamma(int value) {
    int i;

    for (i = 2; i <= value; i <<= 1) {
        write_bit(0);
    }
    while ((i >>= 1) > 0) {
        write_bit(value & i);
    }
}

unsigned char *compress(Optimal *optimal, uint8_t *input_data, size_t input_size, size_t *output_size, long *delta) {
    size_t input_index;
    size_t input_prev;
    int offset1;
    int mask;
    int i;

    if (!optimal || !input_data) {
        return NULL;
    }

    /* calculate and allocate output buffer */
    input_index = input_size-1;
    *output_size = (optimal[input_index].bits+18+7)/8;
    output_data = (uint8_t*)safe_malloc(*output_size);

    /* initialize delta */
    diff = *output_size - input_size;
    *delta = 0;

    /* un-reverse optimal sequence */
    optimal[input_index].bits = 0;
    while (input_index > 0) {
        input_prev = input_index - (optimal[input_index].len > 0 ? optimal[input_index].len : 1);
        optimal[input_prev].bits = input_index;
        input_index = input_prev;
    }

    output_index = 0;
    bit_mask = 0;

    /* first byte is always literal */
    write_byte(input_data[0]);
    read_bytes(1, delta);

    /* process remaining bytes */
    while ((input_index = optimal[input_index].bits) > 0) {
        if (optimal[input_index].len == 0) {

            /* literal indicator */
            write_bit(0);

            /* literal value */
            write_byte(input_data[input_index]);
            read_bytes(1, delta);

        } else {

            /* sequence indicator */
            write_bit(1);

            /* sequence length */
            write_elias_gamma(optimal[input_index].len-1);

            /* sequence offset */
            offset1 = optimal[input_index].offset-1;
            if (offset1 < 128) {
                write_byte(offset1);
            } else {
                offset1 -= 128;
                write_byte((offset1 & 127) | 128);
                for (mask = 1024; mask > 127; mask >>= 1) {
                    write_bit(offset1 & mask);
                }
            }
            read_bytes(optimal[input_index].len, delta);
        }
    }

    /* sequence indicator */
    write_bit(1);

    /* end marker > MAX_LEN */
    for (i = 0; i < 16; i++) {
        write_bit(0);
    }
    write_bit(1);

    return output_data;
}


int elias_gamma_bits(int value) {
    int bits;

    bits = 1;
    while (value > 1) {
        bits += 2;
        value >>= 1;
    }
    return bits;
}

int count_bits(int offset, int len) {
    return 1 + (offset > 128 ? 12 : 8) + elias_gamma_bits(len-1);
}

Optimal* optimize(unsigned char *input_data, size_t input_size) {
    size_t *min;
    size_t *max;
    size_t *matches;
    size_t *match_slots;
    Optimal *optimal;
    size_t *match;
    int match_index;
    int offset;
    size_t len;
    size_t best_len;
    size_t bits;
    size_t i;

    /* allocate all data structures at once */
    min = (size_t*)safe_calloc(MAX_OFFSET+1, sizeof(size_t));
    max = (size_t*)safe_calloc(MAX_OFFSET+1, sizeof(size_t));
    matches = (size_t*)safe_calloc(256*256, sizeof(size_t));
    match_slots = (size_t*)safe_calloc(input_size, sizeof(size_t));
    optimal = (Optimal*)safe_calloc(input_size, sizeof(Optimal));

    /* first byte is always literal */
    optimal[0].bits = 8;

    /* process remaining bytes */
    for (i = 1; i < input_size; i++) {

        optimal[i].bits = optimal[i-1].bits + 9;
        match_index = input_data[i-1] << 8 | input_data[i];
        best_len = 1;
        for (match = &matches[match_index]; *match != 0 && best_len < MAX_LEN; match = &match_slots[*match]) {
            offset = i - *match;
            if (offset > MAX_OFFSET) {
                *match = 0;
                break;
            }

            for (len = 2; len <= MAX_LEN; len++) {
                if (len > best_len) {
                    best_len = len;
                    bits = optimal[i-len].bits + count_bits(offset, len);
                    if (optimal[i].bits > bits) {
                        optimal[i].bits = bits;
                        optimal[i].offset = offset;
                        optimal[i].len = len;
                    }
                } else if (max[offset] != 0 && i+1 == max[offset]+len) {
                    len = i-min[offset];
                    if (len > best_len) {
                        len = best_len;
                    }
                }
                if (i < offset+len || input_data[i-len] != input_data[i-len-offset]) {
                    break;
                }
            }
            min[offset] = i+1-len;
            max[offset] = i;
        }
        match_slots[i] = matches[match_index];
        matches[match_index] = i;
    }

    /* save time by releasing the largest block only, the O.S. will clean everything else later -- um what dude I need all the mem I can have*/
    free(match_slots);
    free(matches);
    free(min);
    free(max);

    return optimal;
}

#include "lodepng.cpp"
