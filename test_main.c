#include <stdio.h>
#include "Unity/unity.h"

// constructor and deconstructor for unity test suite
void setUp (void) {} /* Is run before every test, put unit init calls here. */
void tearDown (void) {} /* Is run after every test, put unit clean-up calls here. */


void test_dummy(void)
{
  TEST_ASSERT_EQUAL_UINT8_MESSAGE(0xA5, 0xA3+0x02, "Double define does not work!");
}

int main(int argc, char* args[])
{
  (void)argc;
  (void)args;

  UNITY_BEGIN();

  RUN_TEST(test_dummy);

  return UNITY_END();
}