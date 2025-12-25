/**
 * \file 0002_0_uid_gid.c
 * @brief How to get uid and gid
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

/**
 * getuid and getgid are defined in `unistd.h`. The user is the owner of calling function.
 *
 * > UID <- /etc/passwd
 * > GID <- /etc/passwd
 * > username:x:UID:GID:...
 *
 * > Supplementary Groups <- /etc/group
 * > audio:x:29:alice,bob
 * > docker:x:999:alice
 *
 * > Most system supports 16 supplementary groups
 * > It comes from kernel \code gid_t groups[NGROUPS_MAX]; \endcode
 * > Current linux \code #define NGROUPS_MAX    65536 \endcode in `limits.h`
 *
 * @return
 */
int
main(void)
{
    printf("uid = %d, gid = %d\n", getuid(), getgid());
    exit(0);
}