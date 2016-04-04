#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdint.h>
#include <errno.h>

typedef int (*open_f_type)(const char *pathname, int flags, ...);

extern int __O_CREAT__;

#define DO_OPEN(pathname, flags, mode) ({                           \
    open_f_type orig_open = (open_f_type)dlsym(RTLD_NEXT, "open");  \
    int __ret__;                                                    \
    if (flags & __O_CREAT__) {                                      \
        __ret__ = orig_open(pathname, flags, mode);                 \
    } else {                                                        \
        __ret__ = orig_open(pathname, flags);                       \
    }                                                               \
    __ret__;                                                        \
})

#define COMMAND "hash-for"

int open(const char *pathname, int flags, mode_t mode)
{

    int fd = DO_OPEN(pathname, flags, mode);
    int open_errno = errno;

    fprintf(stderr, "intercepting open of: %s\n", pathname);

    if ((memcmp(&pathname[strlen(pathname) - 5], ".vhdx" , 5) &&
         memcmp(&pathname[strlen(pathname) - 6], ".vhd.c", 6) &&
         memcmp(&pathname[strlen(pathname) - 3], ".vx"   , 3) &&
         memcmp(&pathname[strlen(pathname) - 4], ".v.c"  , 4) &&
         memcmp(&pathname[strlen(pathname) - 2], ".x"    , 2)
        ) || fd == -1) {
        fprintf(stderr, "normal open: %s\n", pathname);
        errno = open_errno;
        return fd;
    }

    fprintf(stderr, "%s'ing: %s\n", COMMAND, pathname);

    int outpipefd[2];

    pipe(outpipefd);

    if (fork() == 0) {
        close(outpipefd[0]);
        dup2(outpipefd[1], STDOUT_FILENO);

        dup2(fd, STDIN_FILENO);

        execlp(COMMAND, COMMAND, NULL);
        perror(COMMAND);
        abort();
    }
    close(outpipefd[1]);
    return outpipefd[0];
}
