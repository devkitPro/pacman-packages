. "${BASH_SOURCE%/*}"/devkitppc.sh

export PORTLIBS_PREFIX=${PORTLIBS_ROOT}/ppc

export CFLAGS="-O2 -mcpu=750 -meabi -mhard-float -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-I${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib"

export PATH=${PORTLIBS_PREFIX}/bin:$PATH
