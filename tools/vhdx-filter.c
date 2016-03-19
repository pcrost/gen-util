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

    fprintf(stderr, "intercepting open of: %s\n", pathname);

    if (memcmp(&pathname[strlen(pathname) - 5], ".vhdx", 5) &&
        memcmp(&pathname[strlen(pathname) - 6], ".vhd.c", 6)) {
        fprintf(stderr, "normal open: %s\n", pathname);
        return DO_OPEN(pathname, flags, mode);
    }

    fprintf(stderr, "%s'ing: %s\n", COMMAND, pathname);

    int outpipefd[2];

    pipe(outpipefd);

    if (fork() == 0) {
        close(outpipefd[0]);
        dup2(outpipefd[1], STDOUT_FILENO);

        dup2(DO_OPEN(pathname, flags, mode), STDIN_FILENO);

        execlp(COMMAND, COMMAND, NULL);
        perror(COMMAND);
        abort();
    }
    close(outpipefd[1]);
    return outpipefd[0];
}
