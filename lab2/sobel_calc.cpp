#include "opencv2/imgproc/imgproc.hpp"
#include "sobel_alg.h"
#include "arm_neon.h"
using namespace cv;

/*******************************************
 * Model: grayScale
 * Input: Mat img
 * Output: None directly. Modifies a ref parameter img_gray_out
 * Desc: This module converts the image to grayscale
 ********************************************/
void grayScale(Mat& img, Mat& img_gray_out, int div, int half)
{
  // div == 1 --> Multithread Division
  uint16_t rows;
  int offset;

  if (div == 1) {
    if (half == 1) {
      offset = ((IMG_HEIGHT * IMG_WIDTH * 3) / 2);
    } else {
      offset = 0;
    }
    rows = img.rows/2;  
  } else {
    offset = 0;
    rows = img.rows;
  }

  int num8x16 = rows * img.cols / 16;
  uint8x16x3_t intlv_rgb;
  uint8x16_t temp_r, temp_g, temp_b, temp_x, temp_y;
  for (int i=0; i < num8x16; i++) {
    intlv_rgb = vld3q_u8(img.data + 3*16*i + offset);
    temp_b = intlv_rgb.val[0];
    temp_g = intlv_rgb.val[1];
    temp_r = intlv_rgb.val[2];
    temp_b = vshrq_n_u8(temp_b, 3);
    temp_g = vshrq_n_u8(temp_g, 1);
    temp_r = vshrq_n_u8(temp_r, 2);
    temp_x = vaddq_u8(temp_b, temp_g);
    temp_y = vaddq_u8(temp_x, temp_r);
    vst1q_u8(img_gray_out.data + 16*i + offset/3, temp_y);
  }
}

/*******************************************
 * Model: sobelCalc
 * Input: Mat img_in
 * Output: None directly. Modifies a ref parameter img_sobel_out
 * Desc: This module performs a sobel calculation on an image. It first
 *  converts the image to grayscale, calculates the gradient in the x
 *  direction, calculates the gradient in the y direction and sum it with Gx
 *  to finish the Sobel calculation
 ********************************************/
void sobelCalc(Mat& img_gray, Mat& img_sobel_out, int div, int half, Mat& img_outx, Mat& img_outy, uchar* local_dat)
{
  // div == 1 --> Multithread Division
  uint16_t rows, cols;
  int offset;
  cols = img_gray.cols;

  if (div == 1) {
    rows = img_gray.rows/2;  
    if (half == 1) {
      offset = rows - 1;
    } else {
      offset = 0;
    }
  } else {
    offset = 0;
    rows = img_gray.rows;
  }
  
  // Apply Sobel filter to black & white image
  unsigned short sobel;

  //  Calculate the x convolution
  for (int i=(1 + offset); i<(rows + offset); i++) {
    for (int j=1; j<cols; j++) {
      sobel = abs(local_dat[IMG_WIDTH*(i-1) + (j-1)] -
		  local_dat[IMG_WIDTH*(i+1) + (j-1)] +
		  2*local_dat[IMG_WIDTH*(i-1) + (j)] -
		  2*local_dat[IMG_WIDTH*(i+1) + (j)] +
		  local_dat[IMG_WIDTH*(i-1) + (j+1)] -
		  local_dat[IMG_WIDTH*(i+1) + (j+1)]);

      sobel = (sobel > 255) ? 255 : sobel;
      img_outx.data[IMG_WIDTH*(i-offset) + (j)] = sobel;
    }
  }
  
  // Calc the y convolution
  for (int i=(1 + offset); i<(rows + offset); i++) {
    for (int j=1; j<cols; j++) {
      sobel = abs(local_dat[IMG_WIDTH*(i-1) + (j-1)] -
      local_dat[IMG_WIDTH*(i-1) + (j+1)] +
      2*local_dat[IMG_WIDTH*(i) + (j-1)] -
      2*local_dat[IMG_WIDTH*(i) + (j+1)] +
      local_dat[IMG_WIDTH*(i+1) + (j-1)] -
      local_dat[IMG_WIDTH*(i+1) + (j+1)]);

      sobel = (sobel > 255) ? 255 : sobel;
      img_outy.data[IMG_WIDTH*(i-offset) + j] = sobel;
      
    }
  }

  // Combine the two convolutions into the output image
  for (int i=(1 + offset); i<(rows + offset); i++) {
    for (int j=1; j<cols; j++) {
      sobel = img_outx.data[IMG_WIDTH*(i-offset) + j] +
	            img_outy.data[IMG_WIDTH*(i-offset) + j];
      sobel = (sobel > 255) ? 255 : sobel;
      img_sobel_out.data[IMG_WIDTH*(i) + j] = sobel;
    }
  }
}
