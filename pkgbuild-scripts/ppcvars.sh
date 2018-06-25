export DEVKITPRO=/opt/devkitpro
export PORTLIBS_PREFIX=${DEVKITPRO}/portlibs/ppc

export TOOL_PREFIX=powerpc-eabi-

export CFLAGS="-O2 -mcpu=750 -meabi -mhard-float"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-DGEKKO -I ${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib"

export PATH=/opt/devkitpro/portlibs/ppc/bin:$PATH
