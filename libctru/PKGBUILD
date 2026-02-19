# Maintainer: Dave Murphy <davem@devkitpro.org>

pkgname=('libctru')
pkgver=2.7.0
pkgrel=1
pkgdesc="Nintendo 3DS userland library."
arch=('any')
license=('custom')
url="http://github.com/devkitPro/${pkgname}"
options=(!strip libtool staticlibs)
source=(
  ${pkgname}-${pkgver}.tar.gz::${url}/archive/v${pkgver}.tar.gz
)
depends=('devkitARM')

groups=('3ds-dev')

build() {

  cd ${srcdir}/${pkgname}-${pkgver}/libctru
  make

}

package() {

  cd ${srcdir}/libctru-${pkgver}/libctru
  make -j DESTDIR=$pkgdir install

}

sha256sums=('c0b8a5048e15a0ae02772e6db0188f5571e8c26d064d7962212a40681f0d18b3')
