export DEVKITPRO=/opt/devkitpro
export PORTLIBS_PREFIX=${DEVKITPRO}/portlibs/switch
export PATH=$PORTLIBS_PREFIX/bin:$PATH

export TOOL_PREFIX=aarch64-none-elf-

export CFLAGS="-g -O2 -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIC -ftls-model=local-exec"
export CPPFLAGS="-I ${PORTLIBS_PREFIX}/include -isystem ${DEVKITPRO}/libnx/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib -L${DEVKITPRO}/libnx/lib"
export LIBS="-lnx"
