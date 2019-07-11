#include "dlfcn.h"

#include <stddef.h>

static dl_open open = NULL;
static dl_error error = NULL;
static dl_sym sym = NULL;
static dl_close close = NULL;

void dl_setfn(dl_open new_open, dl_error new_error, dl_sym new_sym, dl_close new_close)
{
  open = new_open;
  error = new_error;
  sym = new_sym;
  close = new_close;
}

void *dlopen(const char *module, int flag)
{
  return open ? (*open)(module, flag) : NULL;
}

char *dlerror(void)
{
  return error ? (*error)() : "";
}

void *dlsym(void *handle, const char *name)
{
  return sym ? (*sym)(handle, name) : NULL;
}

int dlclose(void *handle)
{
  return close ? (*close)(handle) : 0;
}
