
# Maintainer: fincs <fincs.alt1@gmail.com>

pkgname=('citro2d')
pkgver=1.7.0
pkgrel=1
pkgdesc="Nintendo 3DS gpu 2d helper library."
arch=('any')
license=('custom')
url="http://github.com/devkitpro/${pkgname}"
options=(!strip libtool staticlibs)
source=(${pkgname}-${pkgver}.tar.gz::${url}/archive/v${pkgver}.tar.gz)
makedepends=('devkitARM')
depends=('libctru' 'citro3d')

groups=('3ds-dev')

build() {

  cd ${srcdir}/${pkgname}-${pkgver}
  catnip

}

package() {

  cd ${srcdir}/${pkgname}-${pkgver}
  DESTDIR=$pkgdir catnip install

}
sha256sums=('f311d1decb64668980b7a7a917a9b936a40025265df921e251f5f0537b94b86b')
