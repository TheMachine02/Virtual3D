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
void generateConvolve();
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
    generateConvolve();
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

void generateConvolve()
{
    ofstream out;
    out.open("lightmap.inc");
	if (!(out.good())) {
		cout << "Can't open output file" << std::endl;
		return;
	}

//    unsigned char convolveTable[8192];
    int i,j;
    int intensity=0;
    unsigned char red,blue,green;
    out <<".db ";
    for(j=0;j<16;j++)
    {
        for(i=0;i<256;i++)
        {
            red=min(((xlibc_palette[i*4]*intensity)/255),255);
            green=min(((xlibc_palette[i*4+1]*intensity)/255),255);
            blue=min(((xlibc_palette[i*4+2]*intensity)/255),255);
 //           convolveTable[j*256+i]=subPixel(red,green,blue);
        out << (int)subPixel(red,green,blue);
        if(i!=255) out << ",";
        }
        if(j!=15) out << "\n.db ";
        intensity+=17;
    }
}
