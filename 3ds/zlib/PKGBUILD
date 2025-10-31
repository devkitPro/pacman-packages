
# Maintainer: WinterMute <davem@devkitpro.org>
pkgname=3ds-zlib
pkgver=1.3.1
pkgrel=1
pkgdesc='Deflate compression method library'
arch=('any')
url='http://www.zlib.net'
license=('zlib')
options=(!strip libtool staticlibs)
source=("${url}/zlib-$pkgver.tar.xz")
makedepends=('dkp-toolchain-vars')
groups=('3ds-portlibs')

build() {
  cd zlib-$pkgver

  source /opt/devkitpro/3dsvars.sh

  CHOST=arm-none-eabi \
    ./configure --prefix="${PORTLIBS_PREFIX}" --static
  make libz.a # only build library, no programs

  # libminizip
  cd contrib/minizip
  autoreconf --force --verbose --install
  CFLAGS="${CFLAGS} -DUSE_FILE32API"
  ./configure --prefix="${PORTLIBS_PREFIX}" --host=arm-none-eabi \
    --disable-shared --enable-static
  make
}

package() {
  cd zlib-$pkgver

  source /opt/devkitpro/3dsvars.sh

  make DESTDIR="$pkgdir" install
  # license
  install -d "$pkgdir"${PORTLIBS_PREFIX}/licenses/$pkgname
  tail -n 31 README > "$pkgdir"${PORTLIBS_PREFIX}/licenses/$pkgname/LICENSE
  # remove useless stuff
  rm -r "$pkgdir"${PORTLIBS_PREFIX}/share

  # libminizip
  cd contrib/minizip
  make DESTDIR="$pkgdir" install
}
sha256sums=('38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32')
