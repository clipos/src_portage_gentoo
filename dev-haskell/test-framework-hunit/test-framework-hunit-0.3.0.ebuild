# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.3.1.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="HUnit support for the test-framework package"
HOMEPAGE="https://batterseapower.github.com/test-framework/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 ia64 ppc ppc64 sparc x86"
IUSE=""

RDEPEND=">=dev-haskell/extensible-exceptions-0.1.1:=[profile?]
		<dev-haskell/extensible-exceptions-0.2.0:=[profile?]
		>=dev-haskell/hunit-1.2:=[profile?]
		<dev-haskell/hunit-2:=[profile?]
		>=dev-haskell/test-framework-0.2.0:=[profile?]
		>=dev-lang/ghc-6.10.4:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.2.3"
