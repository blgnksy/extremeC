#include <unistd.h>
#include "helpers.h"

/**
 * \code
 int fsync(int fd);
 int fdatasync(int fd);

 void sync(void);
 \endcode

 * `sync` syncs all data to disk and return; it does not wait for the disk writes to take place. The function sync is
normally called periodically (usually every 30 seconds) from a system daemon, often called `update`.

 * `fsync` refers only to a single file, specified by the file descriptor fd, and waits for the disk writes
 to complete before returning.

 * `fdatasync`is similar to fsync, but it affects only the data portions of a file.
 */
int main() {}
