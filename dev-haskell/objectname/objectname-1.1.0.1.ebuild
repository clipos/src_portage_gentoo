# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.4.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

MY_PN="ObjectName"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Explicitly handled object names"
HOMEPAGE="https://github.com/svenpanne/ObjectName"
SRC_URI="https://hackage.haskell.org/package/${MY_P}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-haskell/transformers-0.2:=[profile?] <dev-haskell/transformers-0.6:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.10
"

S="${WORKDIR}/${MY_P}"
