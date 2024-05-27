. ${DEVKITPRO}/devkitppc.sh

export PORTLIBS_PREFIX=${PORTLIBS_ROOT}/gamecube
export PORTLIBS_PPC=${PORTLIBS_ROOT}/ppc
export PORTLIBS_CUBE=${PORTLIBS_PREFIX}

export CFLAGS="-O2 -mogc -mcpu=750 -meabi -mhard-float -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-D__GAMECUBE__ -I${DEVKITPRO}/libogc/include -I${PORTLIBS_CUBE}/include -I${PORTLIBS_PPC}/include"
export LDFLAGS="-L${PORTLIBS_CUBE}/lib -L${PORTLIBS_PPC}/lib"

export PATH=${PORTLIBS_CUBE}/bin:${PORTLIBS_PPC}/bin:$PATH
