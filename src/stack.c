/* \file stack.c
 *
 * Stack memory has limited size
 *
 * Process starts filling the stack from bottom to top
 *
 * Automatic memory management (auto allocation/deallocation)
 *
 * Every stack variable has a scope
 *
 */

#include <stdio.h>
/** There is a problem here. Function returns a pointer's address which is just in
 * function scope. Whenever main function tries to deference it, it is going to be
 * undefined behaviour. So we don't know what would happen.
 *
 * It is usually a common  practice to pass the pointers addressing the variables
 * in the current scope to other functions but not the other way around, because
 * as long as the current scope is valid, the variables are there. Further function
 * calls only put more stuff on top of the Stack segment, and the current scope
 * won't be finished before them.
 *
 * Note that the above statement is not a good practice regarding concurrent programs
 * because in the future, if another concurrent task wants to use the received pointer
 * addressing a variable inside the current scope, the current scope might have
 * vanished already.
 *
 * @return pointer to integer
 */
int * get_integer() {
    int var = 10;
    return &var;
}
int main(int argc, char** argv) {
    int* ptr = get_integer();
    printf("%d\n", *ptr);
    *ptr = 5;
    printf("%d\n", *ptr);
    return 0;
}



