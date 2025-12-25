/** \file 0001_0_error_handling.c
 * @brief Error Handling
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <locale.h>
#include <stdarg.h>

/**
 * Handles the exit. Provide the executable name (UNIX Convention)
 * \code exit_sys("%s - locale", argv[0]); \endcode
 * @param format
 * @param ...
 */
void exit_sys(const char *format, ...)
{
    va_list ap;

    va_start(ap, format);
    vfprintf(stderr, format, ap);
    fprintf(stderr, ": %s\n", strerror(errno));

    va_end(ap);

    exit(EXIT_FAILURE);
}

/**
 * errno is defined `errno.h`
 *
 * > Passing the name of the program—argv[0] to `perror` function is a standard convention in the UNIX System.
 *
 * > `perror` function prints the error message set in `errno`.
 *
 * > `strerror` function prints the error string.
 *
 * > Set locale for using different languages \code setlocale(LC_ALL, "tr_TR.UTF-8" \endcode
 *
 * \code
 * fprintf(stderr, "EACCES: %s\n", strerror(EACCES));
 * errno = ENOENT;
 * perror(argv[0]);
 * \endcode
 *
 * @param argc
 * @param argv
 * @return
 */
int
main(int argc, char *argv[])
{
    if (setlocale(LC_ALL, "tr_TR.UTF-8") == NULL) {
        fprintf(stderr, "Can not set locale!\nERROR:  %s\n", strerror(errno));
        perror(argv[0]);
        //exit(EXIT_FAILURE);
        exit_sys("%s - locale", argv[0]);
    }

    fprintf(stderr, "EACCES: %s\n", strerror(EACCES));
    errno = ENOENT;
    perror(argv[0]);
    exit_sys("access");
    return 0;
}