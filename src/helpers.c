#include <errno.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "helpers.h"

void exit_sys(const char *format, ...)
{
    va_list ap;

    va_start(ap, format);
    vfprintf(stderr, format, ap);
    fprintf(stderr, ": %s\n", strerror(errno));

    va_end(ap);

    exit(EXIT_FAILURE);
}
