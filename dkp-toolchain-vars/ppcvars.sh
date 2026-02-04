source ${DEVKITPRO}/devkitppc.sh

export PORTLIBS_PREFIX=${PORTLIBS_ROOT}/ppc
DKP_PATH=${PORTLIBS_PREFIX}/bin:${DKP_PATH}

export CFLAGS="-O2 -mcpu=750 -meabi -mhard-float -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-I${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib"

PATH=${PATH}:${DKP_PATH}
unset DKP_PATH
