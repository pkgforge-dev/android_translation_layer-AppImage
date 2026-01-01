#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern char **environ;

static int should_rewrite_argv0(const char *argv0) {
    if (!argv0) return 0;
    if (strncmp(argv0, "/tmp/.mount_", 11) == 0) return 1;
    if (strstr(argv0, "/.mount_") != NULL) return 1;
    return 0;
}

static char *const *rewrite_argv0(char *const argv[], const char *new0) {
    if (!argv || !argv[0] || !new0 || !*new0) return (char *const *)argv;

    size_t n = 0;
    while (argv[n]) n++;

    char **copy = (char **)calloc(n + 1, sizeof(char *));
    if (!copy) return (char *const *)argv;

    for (size_t i = 0; i < n; i++) copy[i] = argv[i];
    copy[0] = (char *)new0;
    copy[n] = NULL;
    return (char *const *)copy;
}

static void free_rewritten_argv(char *const *maybe_copy, char *const original[]) {
    if ((void *)maybe_copy != (void *)original) free((void *)maybe_copy);
}

typedef int (*execve_fn)(const char *filename, char *const argv[], char *const envp[]);

int execve(const char *filename, char *const argv[], char *const envp[]) {
    static execve_fn real_execve = NULL;
    if (!real_execve) real_execve = (execve_fn)dlsym(RTLD_NEXT, "execve");

    const char *appimage = getenv("APPIMAGE");
    char *const *argv2 = (char *const *)argv;

    if (appimage && should_rewrite_argv0(argv ? argv[0] : NULL)) {
        argv2 = rewrite_argv0(argv, appimage);
    }

    int r = real_execve(filename, (char *const *)argv2, envp);

    free_rewritten_argv(argv2, argv);
    return r;
}

int execv(const char *path, char *const argv[]) {
    return execve(path, argv, environ);
}

typedef int (*execvp_fn)(const char *file, char *const argv[]);

int execvp(const char *file, char *const argv[]) {
    static execvp_fn real_execvp = NULL;
    if (!real_execvp) real_execvp = (execvp_fn)dlsym(RTLD_NEXT, "execvp");

    const char *appimage = getenv("APPIMAGE");
    char *const *argv2 = (char *const *)argv;

    if (appimage && should_rewrite_argv0(argv ? argv[0] : NULL)) {
        argv2 = rewrite_argv0(argv, appimage);
    }

    int r = real_execvp(file, (char *const *)argv2);

    free_rewritten_argv(argv2, argv);
    return r;
}

typedef int (*posix_spawn_fn)(pid_t *pid, const char *path,
                              const posix_spawn_file_actions_t *file_actions,
                              const posix_spawnattr_t *attrp,
                              char *const argv[], char *const envp[]);

int posix_spawn(pid_t *pid, const char *path,
                const posix_spawn_file_actions_t *file_actions,
                const posix_spawnattr_t *attrp,
                char *const argv[], char *const envp[]) {
    static posix_spawn_fn real_posix_spawn = NULL;
    if (!real_posix_spawn) real_posix_spawn = (posix_spawn_fn)dlsym(RTLD_NEXT, "posix_spawn");

    const char *appimage = getenv("APPIMAGE");
    char *const *argv2 = (char *const *)argv;

    if (appimage && should_rewrite_argv0(argv ? argv[0] : NULL)) {
        argv2 = rewrite_argv0(argv, appimage);
    }

    int r = real_posix_spawn(pid, path, file_actions, attrp, (char *const *)argv2, envp);

    free_rewritten_argv(argv2, argv);
    return r;
}

typedef int (*posix_spawnp_fn)(pid_t *pid, const char *file,
                               const posix_spawn_file_actions_t *file_actions,
                               const posix_spawnattr_t *attrp,
                               char *const argv[], char *const envp[]);

int posix_spawnp(pid_t *pid, const char *file,
                 const posix_spawn_file_actions_t *file_actions,
                 const posix_spawnattr_t *attrp,
                 char *const argv[], char *const envp[]) {
    static posix_spawnp_fn real_posix_spawnp = NULL;
    if (!real_posix_spawnp) real_posix_spawnp = (posix_spawnp_fn)dlsym(RTLD_NEXT, "posix_spawnp");

    const char *appimage = getenv("APPIMAGE");
    char *const *argv2 = (char *const *)argv;

    if (appimage && should_rewrite_argv0(argv ? argv[0] : NULL)) {
        argv2 = rewrite_argv0(argv, appimage);
    }

    int r = real_posix_spawnp(pid, file, file_actions, attrp, (char *const *)argv2, envp);

    free_rewritten_argv(argv2, argv);
    return r;
}
