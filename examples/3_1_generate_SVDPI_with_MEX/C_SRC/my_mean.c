//Copyright 2024 The MathWorks, Inc.

/* Include files */
#include "my_mean.h"

/* This is a custom mean function that returns output by value */

/* Function Definitions */
double my_mean(const double x[17])
{
  double y;
  int k;
  y = x[0];
  for(k = 0; k < 16; k++) {
    y += x[k + 1];
  }
  y /= 17.0;
  return y;
}
