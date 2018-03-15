export DEVKITPRO=/opt/devkitpro
export PORTLIBS_PREFIX=${DEVKITPRO}/portlibs/ppc

export CPPFLAGS="-I${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib"

export PATH=/opt/devkitpro/portlibs/ppc/bin:$PATH
