# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.4.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Atomic bit operations on memory locations for low-level synchronization"
HOMEPAGE="http://hackage.haskell.org/package/bits-atomic"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz
	https://dev.gentoo.org/~slyfox/patches/${P}-gcc-5.patch"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( dev-haskell/hunit
		dev-haskell/quickcheck
		dev-haskell/test-framework
		dev-haskell/test-framework-hunit
		dev-haskell/test-framework-quickcheck2 )
"

src_prepare() {
	epatch "${DISTDIR}"/${P}-gcc-5.patch
	epatch "${FILESDIR}"/${P}-ghc-8.patch
}
