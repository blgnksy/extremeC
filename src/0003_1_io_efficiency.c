#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "helpers.h"


#define BUFFSIZE 4096

/**
 * It reads from standard input and writes to standard output. The program doesn’t close the input file or output file.
 * Instead, the program uses the feature of the UNIX kernel that closes all open file descriptors in a process when that
 * process terminates.
 *
 * Increasing beyond file system's block size might cause little performance gain.
 *
 * @return 0 on success, -1 on error
 */
int main() {
    int n;
    char buf[BUFFSIZE];

    while ((n = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
        if (write(STDOUT_FILENO, buf, n) != n)
            exit_sys("write error");
    if (n < 0)
        exit_sys("read error");

    exit(0);
}
