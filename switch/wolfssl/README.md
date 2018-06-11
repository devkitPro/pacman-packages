# switch-wolfssl

You **will** need to initialize `csrng` in your homebrew to use wolfSSL :

```
csrngInitialize();

[...]

csrngExit();
```
