# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Remote monitoring of processes"
HOMEPAGE="https://github.com/tibbe/ekg"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="<dev-haskell/aeson-1.1:=[profile?]
	>=dev-haskell/ekg-core-0.1:=[profile?] <dev-haskell/ekg-core-0.2:=[profile?]
	>=dev-haskell/ekg-json-0.1:=[profile?] <dev-haskell/ekg-json-0.2:=[profile?]
	<dev-haskell/network-2.7:=[profile?]
	<dev-haskell/snap-core-1.1:=[profile?]
	<dev-haskell/snap-server-1.1:=[profile?]
	<dev-haskell/text-1.3:=[profile?]
	<dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-lang/ghc-7.8.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
"
