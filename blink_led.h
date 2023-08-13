#ifndef BLINK_LED_H
#define BLINK_LED_H

#if defined(TEST_COMPILE)
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#else // defined(TEST_COMPILE)
#include "stm32f4xx.h"
#include "arm_math.h"
#endif // defined(TEST_COMPILE)

uint8_t blink(float time);

#endif // BLINK_LED_H