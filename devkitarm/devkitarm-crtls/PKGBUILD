
# Maintainer: Dave Murphy <davem@devkitpro.org>

pkgname=('devkitarm-crtls')
pkgver=1.2.6
pkgrel=1
pkgdesc="devkitARM crtls."
arch=('any')
license=('custom')
url="http://github.com/devkitpro/devkitarm-crtls"
options=(!strip libtool staticlibs)
source=(${pkgname}-${pkgver}.tar.gz::${url}/archive/refs/tags/v${pkgver}.tar.gz)
makedepends=('devkitARM')
groups=('gba-dev' 'gp32-dev' 'nds-dev' '3ds-dev')

build() {

  cd $srcdir/$pkgname-$pkgver
  make

}

package() {

  cd $srcdir/$pkgname-$pkgver
  make DESTDIR=$pkgdir install

}

sha256sums=('0c7b991a2a8427bca0a64db37138ecc95276eef3958a9be6da6310afd1a1066f')
