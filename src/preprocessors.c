/*! \file preprocessors.c
\brief Macros in C

    Macros have an important characteristic. If you write something in macros, they will be replaced by other lines of
    code before the compilation phase, and finally, you'll have a flat long piece of code without any modularity at compile
    time. Of course, you have the modularity in your mind and probably in your macros, but it is not present in your final
    binaries. This is exactly where using macros can start to cause design issues. Software design tries to package similar
    algorithms and concepts in several manageable and reusable modules, but macros try to make everything linear and flat.
    So, when you are using macros as some logical building blocks within your software design, the information regarding
    them can be lost after the preprocessing phase, as part of the final translation units.

    \important If a macro can be written as a C function, then you should write a C function instead!

*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * \brief Here ABC is not a variable
 *
 * `#define` to define `#undef` for undefine
 */
#define ABC 5

/**
 * \brief ADD is not function
 *
 * Since function-like macros can accept input arguments, they can mimic C functions. In other words, instead of putting
 * a frequently used logic into a C function, you can name that logic as a function-like macro and use that macro
 * instead.
 *
 * This way, the macro occurrences will be replaced by the frequently used logic, as part of the preprocessing phase,
 * and there is no need to introduce a new C function. We will discuss this more and compare the two approaches.
 *
 * Macros only exist before the compilation phase. This means that the compiler, theoretically, doesn't know anything
 * about the macros. This is a very important point to remember if you are going to use macros instead of functions. The
 * compiler knows everything about a function because it is part of the C grammar and it is parsed and being kept in the
 * parse tree. But a macro is just a C preprocessor directive only known to the preprocessor itself.
 * @param a
 * @param b
 */
#define ADD(a, b) a + b

/**
 * Modern C compilers are aware of C preprocessor directives. Despite the common belief that they don't know anything
 * about the preprocessing phase, they actually do. The modern C compilers know about the source before entering the
 * preprocessing phase.
 *
 * Macro definition which yields an undeclared identifier error
 */
#define CODE printf("%d\n", i);

/**
 * While expanding the macro, the `#` operator turns the parameter into its string form surrounded by a pair of
 * quotation marks. For example, in the preceding code, the `#` operator used before the NAME parameter turns it into
 * "copy" in the preprocessed code.
 *
 * The `##` operator has a different meaning. It just concatenates the parameters to other elements in the macro
 * definition and usually forms variable names.
 *
 * @param NAME
 */
#define CMD(NAME)                                                                                                      \
    char NAME##_cmd[256] = "";                                                                                         \
    strcpy(NAME##_cmd, #NAME);

#define VERSION "2.3.4"
/**
 * Variadic macros which can accept a variable number of input arguments.
 *
 * @param format
 */
#define LOG_ERROR(format, ...) fprintf(stderr, format, __VA_ARGS__)

/**
 * \brief Conditionals
 *
 * \note
 \code{.c}
     #ifdef
     #ifndef
     #else
     #elif
     #endif
\endcode

\note Macros can be defined using -D options passed to the compilation command.
\code{.sh}
gcc -DCONDITION -E main.c
\endcode
 *
 *
 */
#define CONDITION
int main() {
    int x = 2;
    int y = ABC;
    int z = x + y;

    printf("%d + %d = %d\n", x, y, z);

    z = ADD(x, y);
    printf("%d + %d = %d\n", x, y, z);

    // CODE

    if (1 == 1) {
        LOG_ERROR("Invalid number of arguments for version %s\n.", VERSION);
    }
    if (1 == 1) {
        LOG_ERROR("%s is a wrong param at index %d for version %s.", "Sth", 1, VERSION);
    }

#ifdef CONDITION
    int i = 0;
    i++;
#endif
    printf("i = %d", i);
    return 0;
}
