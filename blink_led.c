#include "blink_led.h"

/**
  @brief         Uses ARM dsp math to turn LED on/off.
  @param[in]     angle  input value in radians.
  @return        LED state (0=off, 1=on)
 */

uint8_t blink(float angle)
{
  uint8_t led_state = 0;
  if (arm_sin_f32(angle) > 0)
  {
    led_state = 1;
  }
  else
  {
    led_state = 0;
  }

  return led_state;
}