# Maintainer: WinterMute <davem@devkitpro.org>
# Contributor: Elouan Martinet <exa@elou.world>

_realname=mbedtls
pkgname=3ds-${_realname}
pkgver=2.28.8
pkgrel=1
pkgdesc='An open source, portable, easy to use, readable and flexible SSL library (for Nintendo 3DS homebrew development)'
arch=('any')
url='https://tls.mbed.org/'
license=('apache')
options=(!strip libtool staticlibs)
depends=(3ds-zlib)
makedepends=('3ds-pkg-config' 'dkp-toolchain-vars')
source=( "${_realname}-${pkgver}.tar.gz::https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v${pkgver}.tar.gz"
         "mbedtls-${pkgver}.patch" )
groups=('3ds-portlibs')

sha256sums=('bdf7c5bbdc338da3edad89b2885d4f8668f9a6fffeba6ec17a60333e36dade6f'
            'a3332c2b65f69f9224e799ac6f05db4555faf76fcfaa720411068252c848b0ee')

build() {
  cd mbedtls-$pkgver

  patch -Np1 -i $srcdir/mbedtls-${pkgver}.patch

  ./scripts/config.pl set MBEDTLS_ENTROPY_HARDWARE_ALT
  ./scripts/config.pl set MBEDTLS_NO_PLATFORM_ENTROPY
  ./scripts/config.pl set MBEDTLS_CMAC_C

  ./scripts/config.pl unset MBEDTLS_SELF_TEST
  ./scripts/config.pl unset MBEDTLS_TIMING_C

  source /opt/devkitpro/3dsvars.sh

  arm-none-eabi-cmake \
    -DCMAKE_INSTALL_PREFIX=$PORTLIBS_PREFIX \
    -DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" \
    -DCMAKE_CXX_FLAGS="CFLAGS -fno-exceptions -fno-rtti" \
    -DZLIB_ROOT="$PORTLIBS_PREFIX" \
    -DENABLE_ZLIB_SUPPORT=TRUE -DENABLE_TESTING=FALSE -DENABLE_PROGRAMS=FALSE \
    .

  make

}

package() {

  cd mbedtls-$pkgver

  source /opt/devkitpro/3dsvars.sh

  make install DESTDIR="$pkgdir"

  install -d "$pkgdir"$PORTLIBS_PREFIX/licenses/$pkgname
  cp -v LICENSE "$pkgdir"$PORTLIBS_PREFIX/licenses/$pkgname 

}

sha256sums=('4fef7de0d8d542510d726d643350acb3cdb9dc76ad45611b59c9aa08372b4213'
            '84892ec63ab68804a582364d8c4bd6c8dfd0d697ed175bddcd5b7339cce35563')
