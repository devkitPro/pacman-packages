#ifndef __DLFCN_H__
#define __DLFCN_H__

#define RTLD_LAZY 0
#define RTLD_NOW 1
#define RTLD_GLOBAL 2
#define RTLD_LOCAL 3

/* Defines a dlfcn.h compatible API. */
void *dlopen(const char *module, int flag);
char *dlerror(void);
void *dlsym(void *handle, const char *name);
int dlclose(void *handle);

/* Add a custom API to change builtin functions with user-provided ones.
 * This is useful to expand dlfcn to something working when needed (e.g LuaJIT FFI).
 */
typedef void *(*dl_open)(const char *, int);
typedef char *(*dl_error)(void);
typedef void *(*dl_sym)(void *, const char *);
typedef int (*dl_close)(void *);

void dl_setfn(dl_open open, dl_error error, dl_sym sym, dl_close close);

#endif /* __DLFCN_H__ */
