# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.4.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="A CSV parsing and encoding library"
HOMEPAGE="https://github.com/tibbe/cassava"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/attoparsec-0.10.2:=[profile?] <dev-haskell/attoparsec-0.14:=[profile?]
	<dev-haskell/blaze-builder-0.5:=[profile?]
	<dev-haskell/hashable-1.3:=[profile?]
	<dev-haskell/text-1.3:=[profile?]
	<dev-haskell/unordered-containers-0.3:=[profile?]
	<dev-haskell/vector-0.12:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( dev-haskell/hunit
		>=dev-haskell/quickcheck-2.0
		dev-haskell/test-framework
		dev-haskell/test-framework-hunit
		dev-haskell/test-framework-quickcheck2 )
"
