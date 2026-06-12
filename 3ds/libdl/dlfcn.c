#include "dlfcn.h"

#include <stddef.h>

static dl_open g_open;
static dl_error g_error;
static dl_sym g_sym;
static dl_close g_close;

void dl_setfn(dl_open new_open, dl_error new_error, dl_sym new_sym, dl_close new_close)
{
  g_open = new_open;
  g_error = new_error;
  g_sym = new_sym;
  g_close = new_close;
}

void *dlopen(const char *module, int flag)
{
  return g_open ? g_open(module, flag) : NULL;
}

char *dlerror(void)
{
  return g_error ? g_error() : "";
}

void *dlsym(void *handle, const char *name)
{
  return g_sym ? g_sym(handle, name) : NULL;
}

int dlclose(void *handle)
{
  return g_close ? g_close(handle) : 0;
}
