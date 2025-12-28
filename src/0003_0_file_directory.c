/**
 * \file 0003_0_file_directory.c
 *
 * @brief operations on file and directory
 */

#include <stdio.h>
#include <limits.h>
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include "helpers.h"

/**
 * \code char *getcwd (char *__buf, size_t __size)\endcode : Get the pathname of the current working directory,
   and put it in SIZE bytes of BUF.
 *
 * \code int chdir(const char *path)\endcode : Changes the current working directory.
 *
 * \code DIR *opendir (const char *__name)\endcode : Open a directory stream on NAME.
   Return a DIR stream on the directory, or NULL if it could not be opened.
 *
 * \code struct dirent *readdir (DIR *__dirp)\endcode: Read a directory entry from DIRP.  Return a pointer to a `struct
   dirent' describing the entry, or NULL for EOF or error
 *
 * \code int open(const char *path, int flags, ...) \endcode Opens a file and return 0 for success, -1 for error.
 * \code int openat(int fd, const char *path, int oflag, ..., mode_t mode  ); \endcode is thread safe `open`.
 *
 * \code off_t lseek(int fd, off_t offset, int whence); \endcode Reposition read/write file offset. 
 * Returns the resulting offset location as measured in bytes from the beginning of the file. 
 * On error, the value (off_t) -1 is returned and errno is set to indicate the error.
 * 
 * \code ssize_t read(int fd, void *buf, size_t count); \endcode attempts to read up to COUNT bytes from file descriptor FD into the buffer starting at BUF.
 * Returns the number of bytes read on success, or -1 on error. returns 0 on EOF. 
 * 
 * @return
 */
int main(int argc, char **argv)
{
    printf("%d is the number of arguments.\n", argc);
    char buf[PATH_MAX];

    if (getcwd(buf, PATH_MAX) == NULL)
        exit_sys("%s - getcwd", argv[0]);

    puts(buf);

    chdir(".");

    if (getcwd(buf, PATH_MAX) == NULL)
        exit_sys("%s - getcwd", argv[0]);

    puts(buf);

    DIR *dp;
    struct dirent *dirp;

    if ((dp = opendir(".")) == NULL)
        exit_sys(" %s - can’t open  %s", argv[0], argv[1]);
    while ((dirp = readdir(dp)) != NULL)
        printf("%s\n", dirp->d_name);
    closedir(dp);

    int fd = open("..", O_RDONLY);
    if (fd == -1)
        exit_sys("%s - open %s", argv[0], buf);

    fd = openat(fd, "CMakeLists.txt", O_RDONLY);
    if (fd == -1)
        exit_sys("%s - openat %s", argv[0], buf);


    off_t  currpos;
    currpos = lseek(fd, 0, SEEK_CUR);
    printf("Current POS is %ld!!! errno %d -> %s\n", currpos, errno, strerror(errno));

    if (lseek(STDIN_FILENO, 0, SEEK_CUR) == -1)
        printf("cannot seek\n");
    else
        printf("seek OK\n");
    
    char readBuf[64];
    ssize_t result;

    while ((result = read(fd, readBuf, 64)) > 0) {
        readBuf[result] = '\0';
        printf("%s", readBuf);
    }

    if (result == -1)
        exit_sys("%s - read", argv[0]);

    close(fd);

    return 0;
}

