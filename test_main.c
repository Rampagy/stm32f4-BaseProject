#include <stdio.h>
#include "Unity/unity.h"
#include "blink_led.h"

// constructor and deconstructor for unity test suite
void setUp (void) {} /* Is run before every test, put unit init calls here. */
void tearDown (void) {} /* Is run after every test, put unit clean-up calls here. */


void test_blink(void)
{
  for (float angle = 0.0f; angle < 2*3.14159f; angle += 0.314159f)
  {
    char failed_message[50];
    (void)sprintf(failed_message, "Failed at angle: %f", (double)angle);
    TEST_ASSERT_EQUAL_UINT8_MESSAGE(angle < 3.14159f ? 1U : 0U, blink(angle), failed_message);
  }
}

int main(int argc, char* args[])
{
  (void)argc;
  (void)args;

  UNITY_BEGIN();

  RUN_TEST(test_blink);

  return UNITY_END();
}