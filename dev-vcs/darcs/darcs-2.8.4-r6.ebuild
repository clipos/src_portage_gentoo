# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# ebuild generated by hackport 0.3.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit eutils haskell-cabal bash-completion-r1

DESCRIPTION="a distributed, interactive, smart revision control system"
HOMEPAGE="http://darcs.net/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS="alpha amd64 ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc test"

RDEPEND="=dev-haskell/extensible-exceptions-0.1*:=[profile?]
		>=dev-haskell/hashed-storage-0.5.6:=[profile?]
		<dev-haskell/hashed-storage-0.6:=[profile?]
		>=dev-haskell/haskeline-0.6.3:=[profile?]
		<dev-haskell/haskeline-0.8:=[profile?]
		=dev-haskell/html-1.0*:=[profile?]
		=dev-haskell/mmap-0.5*:=[profile?]
		>=dev-haskell/mtl-1.0:=[profile?]
		<dev-haskell/mtl-2.3:=[profile?]
		>=dev-haskell/parsec-2.0:=[profile?]
		<dev-haskell/parsec-3.2:=[profile?]
		=dev-haskell/random-1.0*:=[profile?]
		>=dev-haskell/regex-compat-0.95.1:=[profile?]
		>=dev-haskell/tar-0.3:=[profile?]
		<dev-haskell/tar-0.5:=[profile?]
		>=dev-haskell/terminfo-0.3:=[profile?] <dev-haskell/terminfo-0.5:=[profile?]
		>=dev-haskell/text-0.11.0.6:=[profile?]
		>=dev-haskell/utf8-string-0.3.6:=[profile?] <dev-haskell/utf8-string-0.4:=[profile?]
		>=dev-haskell/vector-0.7:=[profile?]
		>=dev-haskell/zlib-0.5.1.0:=[profile?]
		<dev-haskell/zlib-0.6.0.0:=[profile?]
		>=dev-lang/ghc-6.10.4:=
		net-misc/curl"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.8
		doc? ( virtual/latex-base
			|| (	dev-tex/latex2html[png]
				dev-tex/latex2html[gif]
			)
		)
		test? ( >=dev-haskell/cmdlib-0.2.1[profile?]
				<dev-haskell/cmdlib-0.4[profile?]
				=dev-haskell/findbin-0.0*[profile?]
				>=dev-haskell/quickcheck-2.3
				>=dev-haskell/shellish-0.1.3[profile?]
				<dev-haskell/shellish-0.2[profile?]
				>=dev-haskell/test-framework-0.4.0[profile?]
				>=dev-haskell/test-framework-hunit-0.2.2[profile?]
				>=dev-haskell/test-framework-quickcheck2-0.2.8[profile?]
		)
		"

src_prepare() {
	rm "${S}/tests/add_permissions.sh" || die "Could not rm add_permissions.sh"
	rm "${S}/tests/send-output-v1.sh" || die "Could not rm send-output-v1.sh"
	rm "${S}/tests/send-output-v2.sh" || die "Could not rm send-output-v2.sh"
	rm "${S}/tests/utf8.sh" || die "Could not rm utf8.sh"

	epatch "${FILESDIR}"/${P}-ghc-7.8-part-1.patch
	epatch "${FILESDIR}"/${P}-ghc-7.8-part-2.patch
	epatch "${FILESDIR}"/${P}-fix-nonatomic-global.patch
	epatch "${FILESDIR}"/${P}-issue2364.patch
	epatch "${FILESDIR}"/${P}-issue2364-part-2.patch

	cabal_chdeps \
		'text       >= 0.11.0.6 && < 0.12.0.0' 'text       >= 0.11.0.6' \
		'terminfo == 0.3.*' 'terminfo >= 0.3 && < 0.5' \
		'array      >= 0.1 && < 0.5' 'array >= 0.1 && <0.6' \
		'process    >= 1.0.0.0 && < 1.2.0.0' 'process    >= 1.0.0.0 && < 1.3' \
		'unix >= 1.0 && < 2.7' 'unix >=1.0 && <2.8' \
		'base >= 4.5 && < 4.7' 'base >= 4.5 && < 4.8' \
		'ghc >= 6.10 && < 7.8' 'ghc >= 6.10' \
		'mtl          >= 1.0 && < 2.2' 'mtl          >= 1.0 && < 2.3'
}

src_configure() {
	# checking whether ghc supports -threaded flag
	# Beware: http://www.haskell.org/ghc/docs/latest/html/users_guide/options-phases.html#options-linker
	# contains: 'The ability to make a foreign call that does not block all other Haskell threads.'
	# It might have interactivity impact.

	threaded_flag=""
	if $(ghc-getghc) --info | grep "Support SMP" | grep -q "YES"; then
		threaded_flag="--flags=threaded"
		einfo "$P will be built with threads support"
	else
		threaded_flag="--flags=-threaded"
		einfo "$P will be built without threads support"
	fi

	# Use curl for net stuff to avoid strict version dep on HTTP and network
	cabal_src_configure \
		--flags=curl \
		--flags=-http \
		--flags=color \
		--flags=terminfo \
		--flags=mmap \
		--flags=force-char8-encoding \
		$threaded_flag \
		$(cabal_flag test)
}

src_test() {
	# run cabal test from haskell-cabal
	haskell-cabal_src_test || die "cabal test failed"
}

src_install() {
	cabal_src_install
	newbashcomp "${S}/contrib/darcs_completion" "${PN}"

	# fixup perms in such an an awkward way
	mv "${ED}/usr/share/man/man1/darcs.1" "${S}/darcs.1" || die "darcs.1 not found"
	doman "${S}/darcs.1" || die "failed to register darcs.1 as a manpage"
}

pkg_postinst() {
	ghc-package_pkg_postinst

	ewarn "NOTE: in order for the darcs send command to work properly,"
	ewarn "you must properly configure your mail transport agent to relay"
	ewarn "outgoing mail.  For example, if you are using ssmtp, please edit"
	ewarn "${EPREFIX}/etc/ssmtp/ssmtp.conf with appropriate values for your site."
}
