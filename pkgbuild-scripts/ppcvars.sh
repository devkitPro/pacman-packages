export DEVKITPRO=/opt/devkitpro
export PORTLIBS_PREFIX=${DEVKITPRO}/portlibs/ppc

export CPPFLAGS="-I${PORTLIBS_PREFIX}/ppc/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/ppc/lib"

export PATH=/opt/devkitpro/portlibs/ppc/bin:$PATH
