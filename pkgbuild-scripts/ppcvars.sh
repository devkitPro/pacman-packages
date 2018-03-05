export PORTLIBS_PREFIX=/opt/devkitpro/portlibs
export PATH=${PORTLIBS_PREFIX}/bin:$PATH

export CPPFLAGS="-I${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PRIX}/lib"

