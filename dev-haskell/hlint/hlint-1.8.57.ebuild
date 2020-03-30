# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.3.6.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal elisp-common

DESCRIPTION="Source code suggestions"
HOMEPAGE="http://community.haskell.org/~ndm/hlint/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="emacs"

RDEPEND=">=dev-haskell/cpphs-1.11:=[profile?]
	>=dev-haskell/haskell-src-exts-1.14:=[profile?] <dev-haskell/haskell-src-exts-1.15:=[profile?]
	>=dev-haskell/hscolour-1.17:=[profile?]
	>=dev-haskell/transformers-0.0:=[profile?]
	>=dev-haskell/uniplate-1.5:=[profile?]
	>=dev-lang/ghc-6.10.4:=
	emacs? ( >=app-editors/emacs-23.1:* )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6.0.3
"

SITEFILE="60${PN}-gentoo.el"

src_configure() {
	local threaded_flag=""
	if $(ghc-supports-threaded-runtime); then
		threaded_flag="--flags=threaded"
	else
		threaded_flag="--flags=-threaded"
	fi
	cabal_src_configure \
		$threaded_flag
}

src_compile() {
	cabal_src_compile

	use emacs && elisp-compile data/hs-lint.el
}

src_install() {
	cabal_src_install

	if use emacs; then
		elisp-install ${PN} data/*.el data/*.elc || die "elisp-install failed."
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	doman data/hlint.1
}

pkg_postinst() {
	ghc-package_pkg_postinst
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
