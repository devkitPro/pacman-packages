PORTLIBS_PREFIX=/opt/devkitpro/portlibs/3ds
PATH=$PORTLIBS_PREFIX/bin:$PATH

export CFLAGS="-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -O2 -mword-relocations -ffunction-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-D_3DS -I $PORTLIBS_PREFIX/include -I $DEVKITPRO/libctru/include"
export LDFLAGS="-L$PORTLIBS_PREFIX/lib -L$DEVKITPRO/libctru/lib"
export LIBS="-lctru"
