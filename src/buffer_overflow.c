/*! \file buffer_overflow.c
*
 * the str array has 10 characters, but the strcpy is writing way more than 10
 * characters to the str array. This effectively writes on the previously pushed
 * variables and stack frames, and the program jumps to  * a wrong instruction
 * after returning from the main function. And this eventually makes it impossible
 * to continue the execution.
 *
*/
#include <string.h>

int main(int argc, char** argv) {
    char str[10];
    strcpy(str, "akjsdhkhqiueryo34928739r27yeiwuyfiusdciuti7twe79ye");
    return 0;
}
