#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>


/**
 * \code
 * int fcntl(int fd, int cmd, ... \/* arg *\/ );
 * \endcode
 * Returns: depends on cmd if OK (see following), −1 on error

 *
 *
 * Five different purposes for fcntl:
 * 1. Duplication of file descriptor (F_DUPFD) \snippet src/0003_4_fcntl.c fcntl
 * 2. Get/set file status flags (F_GETFL, F_SETFL) \snippet src/0003_4_fcntl.c fcntlfstatus
 * 3. Get/set file descriptor flags (F_GETFD, F_SETFD) \snippet src/0003_4_fcntl.c fcntlfdescriptor
 * 4. Get/set record lock (F_GETLK, F_SETLK, F_SETLKW)
 * 5. Get/set asynchrounous I/O ownership (F_GETOWN, F_SETOWN) \snippet src/0003_4_fcntl.c fcntlasyncio
 */
int main() {
    int val;
    //! [fcntl]
    int fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
    fcntl(fd, F_DUPFD, 0);
    close(fd);
    //! [fcntl]

    //! [fcntlfstatus]
    fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
    val = fcntl(fd, F_GETFL);
    printf("File status flags: %d\n", val);

    int access_mode = val & O_ACCMODE;
    if (access_mode == O_WRONLY)
        printf("Write-only\n");

    if (val & O_APPEND)
        printf("Append mode enabled\n");
    close(fd);
    //! [fcntlfstatus]

    //! [fcntlfdescriptor]
    fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
    val = fcntl(fd, F_GETFD);
    printf("File descriptor flags: %d\n", val);
    close(fd);
    //! [fcntlfdescriptor]

    //! [fcntlasyncio]
    fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
    val = fcntl(fd, F_GETOWN);
    printf("File owner: %d\n", val);
    close(fd);
    //! [fcntlasyncio]

    return 0;
}
