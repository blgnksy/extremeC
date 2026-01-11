#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "helpers.h"

/**
 * The Single UNIX Specification includes two functions that allow applications to seek
 * and perform I/O atomically: pread and pwrite.
 * \code
 * ssize_t pread(int fd, void *buf, size_t count, off_t offset);
 * ssize_t pwrite(int fd, const void *buf, size_t count, off_t offset);
 * \endcode
 *
 * An existing file descriptor is duplicated by either of the following functions:
 * \code
 * int dup(int fd);
 * int dup2(int fd, int fd2);
 * \endcode
 * The new file descriptor returned by dup is guaranteed to be the lowest-numbered
 * available file descriptor. With dup2, we specify the value of the new descriptor with the
 * fd2 argument. If fd2 is already open, it is first closed. If fd equals fd2, then dup2 returns
 * fd2 without closing it. Otherwise, the FD_CLOEXEC file descriptor flag is cleared for fd2,
 * so that fd2 is left open if the process calls exec. The offset is shared.
 *
 * \snippet src/0003_2_atomic_read_write.c dupvsdup2
 * @section file_table_relationships Kernel Data Structures for Open Files
 *
 * The kernel maintains three data structures to manage open files:
 * 1. **Process File Descriptor Table**: Unique to each process. Entries index into the global file table.
 * 2. **Global File Table**: Shared by all processes. Contains file status flags, current offset, and a pointer to the
 * v-node table entry.
 * 3. **V-node Table**: One entry per active file. Contains file type, pointers to functions, and the i-node (file
 * metadata).
 *
 * @startuml
 * package "Process Table (FD Table)" {
 *   [FD 3 (Open file A)] as FD3
 *   [FD 4 (dup FD 3)] as FD4
 *   [FD 5 (Open file A again)] as FD5
 * }
 *
 * package "Global File Table" {
 *   [File Table Entry 1\nOffset: 128] as FT1
 *   [File Table Entry 2\nOffset: 0] as FT2
 * }
 *
 * package "V-node Table" {
 *   [V-node (File A)] as VN1
 * }
 *
 * FD3 --> FT1
 * FD4 --> FT1 : Shared Offset
 * FD5 --> FT2 : Independent Offset
 *
 * FT1 --> VN1
 * FT2 --> VN1
 * @enduml
 */
int main() {
    int fd1, fd2, fd3;
    char *buffer;
    buffer = (char *) malloc(12);
    strcpy(buffer, "Hello World");
    fd1 = open("file.txt", O_WRONLY | O_CREAT, 0644);
    pwrite(fd1, buffer, strlen(buffer), 0);
    close(fd1);

    fd1 = open("file.txt", O_RDONLY);
    //! [dupvsdup2]
    fd2 = dup(fd1);

    strcpy(buffer, "");
    pread(fd2, buffer, 12, 0);
    printf("Buffer read from %d: %s\n", fd2, buffer);

    fd3 = dup2(fd1, 3);

    strcpy(buffer, "");
    pread(fd3, buffer, 12, 0);
    printf("Buffer read from %d: %s\n", fd3, buffer);
    //! [dupvsdup2]
    close(fd1);
    close(fd2);
    close(fd3);
}
