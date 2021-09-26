. "${BASH_SOURCE%/*}"/devkitarm.sh

PORTLIBS_PREFIX=${PORTLIBS_ROOT}/nds
PATH=$PORTLIBS_PREFIX/bin:$PATH

export CFLAGS="-march=armv5te -mtune=arm946e-s -O2 -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-D__NDS__ -DARM9 -I${PORTLIBS_PREFIX}/include -I${DEVKITPRO}/libnds/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib -L${DEVKITPRO}/libnds/lib"
export LIBS="-lnds9"
