# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=(python2_7)

inherit linux-info python-single-r1 toolchain-funcs

DESCRIPTION="User-space front-end for Ftrace"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/rostedt/trace-cmd.git"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://git.kernel.org/pub/scm/linux/kernel/git/rostedt/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://git.kernel.org/pub/scm/linux/kernel/git/rostedt/trace-cmd.git/snapshot/${PN}-v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-v${PV}"
fi

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
IUSE="doc gtk python udis86"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="python? ( ${PYTHON_DEPS} )
	udis86? ( dev-libs/udis86 )
	gtk? (
		${PYTHON_DEPS}
		dev-python/pygtk:2[${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	python? (
		virtual/pkgconfig
		dev-lang/swig
	)
	gtk? ( virtual/pkgconfig )
	doc? ( app-text/asciidoc )"

CONFIG_CHECK="
	~TRACING
	~FTRACE
	~BLK_DEV_IO_TRACE"

PATCHES=(
	"${FILESDIR}"/${PN}-2.7-makefile.patch
)

pkg_setup() {
	linux-info_pkg_setup
	use python && python-single-r1_pkg_setup
}

src_configure() {
	MAKEOPTS+=" prefix=/usr libdir=$(get_libdir) CC=$(tc-getCC) AR=$(tc-getAR)"

	if use python; then
		MAKEOPTS+=" PYTHON_VERS=${EPYTHON//python/python-}"
		MAKEOPTS+=" python_dir=$(python_get_sitedir)/${PN}"
	else
		MAKEOPTS+=" NO_PYTHON=1"
	fi

	use udis86 || MAKEOPTS+=" NO_UDIS86=1"
}

src_compile() {
	emake all_cmd
	use doc && emake doc
	use gtk && emake -j1 gui
}

src_install() {
	default
	use doc && emake DESTDIR="${D}" install_doc
	use gtk && emake DESTDIR="${D}" install_gui
}
