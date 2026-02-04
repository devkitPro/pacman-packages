source ${DEVKITPRO}/devkitppc.sh

export PORTLIBS_PPC=${PORTLIBS_ROOT}/ppc
export PORTLIBS_WIIU=${PORTLIBS_ROOT}/wiiu
export PORTLIBS_PREFIX=${PORTLIBS_WIIU}
DKP_PATH=${PORTLIBS_WIIU}/bin:${PORTLIBS_PPC}/bin:${DKP_PATH}

export CFLAGS="-mcpu=750 -meabi -mhard-float -O2 -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-DESPRESSO -D__WIIU__ -D__WUT__ -I${PORTLIBS_WIIU}/include -I${PORTLIBS_PPC}/include -I${DEVKITPRO}/wut/include"
export LDFLAGS="-L${PORTLIBS_WIIU}/lib -L${PORTLIBS_PPC}/lib -L${DEVKITPRO}/wut/lib -specs=${DEVKITPRO}/wut/share/wut.specs"
export LIBS="-lwut -lm"

PATH=${PATH}:${DKP_PATH}
unset DKP_PATH
