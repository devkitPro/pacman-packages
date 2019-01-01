. "${BASH_SOURCE%/*}"/devkita64.sh

export PORTLIBS_PREFIX=${DEVKITPRO}/portlibs/switch
export PATH=$PORTLIBS_PREFIX/bin:$PATH

export CFLAGS="-O2 -ffunction-sections -fdata-sections -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIC -ftls-model=local-exec"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-D__SWITCH__ -I${PORTLIBS_PREFIX}/include -isystem${DEVKITPRO}/libnx/include"
export LDFLAGS="-march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIC -ftls-model=local-exec -L${PORTLIBS_PREFIX}/lib -L${DEVKITPRO}/libnx/lib"
export LIBS="-lnx"
