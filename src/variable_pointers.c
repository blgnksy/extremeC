/*! \file variable_pointers.c
\brief Variable Pointers in C

* The concept of a variable pointer, or for short pointer, is one of the most fundamental concepts in C.
*
*
* All four can be used to define a pointer.
\code{.c}
    int* ptr = 0;

    int * ptr = 0;

    int *ptr = 0;

    char* ptr = NULL;
\endcode

\note It is crucial to remember that pointers must be initialized upon declaration. If you don't want to store any
valid memory address while declaring them, don't leave them uninitialized. Make it null by assigning 0 or NULL! Do this
otherwise you may face a fatal bug! A null pointer is not pointing to a valid memory address. Therefore, dereferencing a null pointer must be avoided because it is considered as an undefined behavior, which usually leads to a crash.
*
*n int pointer has the same size as a char pointer, but they have different arithmetic step sizes. int* usually has a 4-byte arithmetic step size and char* has a 1-byte arithmetic step size. Therefore, incrementing an integer pointer makes it move forward by 4 bytes in the memory (adds 4 bytes to the current address), and incrementing a character pointer makes it move forward by only 1 byte in the memory.

\code{.c}
int var = 1;
int* int_ptr = NULL; // nullify the pointer
int_ptr = &var;
char* char_ptr = NULL;
char_ptr = (char*)&var;
printf("Before arithmetic: int_ptr: %u, char_ptr: %u\n",
      (unsigned int)int_ptr, (unsigned int)char_ptr);
int_ptr++;    // Arithmetic step is usually 4 bytes
char_ptr++;   // Arithmetic step in 1 byte
printf("After arithmetic: int_ptr: %u, char_ptr: %u\n",
      (unsigned int)int_ptr, (unsigned int)char_ptr);

Before arithmetic: int_ptr: 3932338348, char_ptr: 3932338348
After arithmetic:  int_ptr: 3932338352, char_ptr: 3932338349
\endcode

*
* Danpling Pointer
* The issue of dangling pointers is a very famous one. A pointer usually points to an address to which there is a variable allocated. Reading or modifying an address where there is no variable registered is a big mistake and can result in a crash or a segmentation fault situation. Segmentation fault is a scary error that every C/C++ developer should have seen it at least once while working on code. This situation usually happens when you are misusing pointers. You are accessing places in memory that you are not allowed to.
*
\code{.c}
#include <stdio.h>
int* create_an_integer(int default_value) {
  int var = default_value;
  return &var;
}
int main() {
  int* ptr = NULL;
  ptr = create_an_integer(10);
  printf("%d\n", *ptr);
  return 0;
}
\endcode
*
* We have included a new header file, stdlib.h, and we are using two new functions, malloc and free. The simple explanation is like this: the created integer variable inside the create_an_integer function is not a local variable anymore. Instead, it is a variable allocated from the Heap memory and its lifetime is not limited to the function declaring it. Therefore, it can be accessed in the caller (outer) function.
\code{.c}
#include <stdio.h>
#include <stdlib.h>
int* create_an_integer(int default_value) {
  int* var_ptr = (int*)malloc(sizeof(int));
  *var_ptr = default_value;
  return var_ptr;
}
int main() {
  int* ptr = NULL;
  ptr = create_an_integer(10);
  printf("%d\n", *ptr);
  free(ptr);
  return 0;
}
\endcode
*
*
*/

#include <stdio.h>
int main() {
    int var = 100;
    int *ptr = 0;

    ptr = &var;
    *ptr = 200;

    printf("%d\n", *ptr);

    printf("Size of int pointer %lu\n", sizeof(int*));
    printf("Size of char pointer %lu\n", sizeof(char*));

    return 0;
}
