# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.4.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="A client library for the D-Bus IPC system"
HOMEPAGE="https://john-millikin.com/software/haskell-dbus/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-haskell/cereal-0.3.4:=[profile?]
	>=dev-haskell/libxml-sax-0.7:=[profile?] <dev-haskell/libxml-sax-0.8:=[profile?]
	>=dev-haskell/network-2.2.3:=[profile?]
	>=dev-haskell/parsec-2.0:=[profile?] <dev-haskell/parsec-3.2:=[profile?]
	>=dev-haskell/random-1.0:=[profile?] <dev-haskell/random-2.0:=[profile?]
	>=dev-haskell/text-0.11.1.5:=[profile?]
	>=dev-haskell/transformers-0.2:=[profile?]
	>=dev-haskell/vector-0.7:=[profile?] <dev-haskell/vector-0.12:=[profile?]
	>=dev-haskell/xml-types-0.3:=[profile?] <dev-haskell/xml-types-0.4:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( >=dev-haskell/chell-0.4 <dev-haskell/chell-0.5
		>=dev-haskell/chell-quickcheck-0.2 <dev-haskell/chell-quickcheck-0.3
		>=dev-haskell/quickcheck-2.4 )
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-cereal-0.5.patch

	cabal_chdeps \
		'cereal >= 0.3.4 && < 0.5' 'cereal >= 0.3.4'
}
