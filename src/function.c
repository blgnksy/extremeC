/*! \file function.c
 *
 * In C and many other programming languages that are influenced by C, functions return only one value.
 *
 *  In object-oriented languages such as C++ and Java, functions (which are usually called methods) can also throw an exception, which is not the case for C.
 *
 *  functions are always blocking in C.
 *
 *  Opposite to a blocking function, we can have a non-blocking function. When calling a non-blocking function, the caller doesn't wait for the function to finish and it can continue its execution. In this scheme, there is usually a callback mechanism which is triggered when the called (or callee) function is finished. A non-blocking function can also be referred to as an asynchronous function or simply an async function. Since we don't have async functions in C, we need to implement them using multithreading solutions.
 *
 *  In event-oriented programming, actual function calls happen inside an event loop, and proper callbacks are triggered upon the occurrence of an event. Frameworks such as libuv and libev promote this way of coding, and they allow you to design your software around one or several event loops.
 *
*/

#include <stdio.h>
/** As you see, the value of the pointer is not changed after the function call. a = &b didn't change
 * We have only pass-by-value in C.There is no reference in C, so there is no pass-by-reference either. Everything is
copied into the function's local variables, and you cannot read or modify them after leaving a function.
\code{.c}
int b = 9;
*a = 5;
a = &b;
\endcode
\code{.bash}
Value before call: 3
Pointer before function call: 0x7ffdd0f489ec
Value after call: 5
Pointer after function call: 0x7ffdd0f489ec
\endcode
 * @param a Pointer
 */
void func(int* a) {
    int b = 9;
    *a = 5;
    a = &b;
}

/** Having function pointers is another super feature of the C programming language.
 *
 * func_ptr is a function pointer. It can only point to a specific class of functions that match its signature. The
 * signature limits the pointer to only point to functions that accept two integer arguments and return an integer
 * result.
 *
 * The first thing that comes to mind is polymorphism and virtual functions. In fact, this is the only way to support
 * polymorphism in C.
 *
 *
 * @param a
 * @param b
 * @return
 */
int sum(int a, int b) {
    return a + b;
}


typedef int bool_t;
/** It is usually advised to define a new type alias for function pointers.
 *
 */
typedef bool_t (*less_than_func_t)(int, int);

/**
 *
 * @param a
 * @param b
 * @return
 */
bool_t less_than(int a, int b) {
    return a < b ? 1 : 0;
}
bool_t less_than_modular(int a, int b) {
    return (a % 5) < (b % 5) ? 1 : 0;
}

int main() {
    int x = 3;
    int* xptr = &x;
    printf("Value before call: %d\n", x);
    printf("Pointer before function call: %p\n", (void*)xptr);
    func(xptr);
    printf("Value after call: %d\n", x);
    printf("Pointer after function call: %p\n", (void*)xptr);

    int (*func_ptr)(int, int);
    func_ptr = NULL;
    func_ptr = &sum;
    int result = func_ptr(5, 4);
    printf("Sum: %d\n", result);

    return 0;
}