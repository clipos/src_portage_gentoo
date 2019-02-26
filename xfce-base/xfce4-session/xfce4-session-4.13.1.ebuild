# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils

DESCRIPTION="A session manager for the Xfce desktop environment"
HOMEPAGE="https://docs.xfce.org/xfce/xfce4-session/start"
SRC_URI="https://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="nls policykit systemd +xscreensaver"

COMMON_DEPEND="x11-apps/iceauth
	>=x11-libs/gtk+-3.20:3=
	x11-libs/libSM:=
	x11-libs/libwnck:3=
	x11-libs/libX11:=
	>=xfce-base/libxfce4util-4.12:=
	>=xfce-base/libxfce4ui-4.12.1:=[gtk3(+)]
	>=xfce-base/xfconf-4.12:=
	policykit? ( >=sys-auth/polkit-0.102:= )"
RDEPEND="${COMMON_DEPEND}
	x11-apps/xrdb
	nls? ( x11-misc/xdg-user-dirs )
	xscreensaver? ( || (
		>=x11-misc/xscreensaver-5.26
		>=x11-misc/xlockmore-5.43
		x11-misc/slock
		x11-misc/alock[pam]
	) )"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

REQUIRED_USE="systemd? ( policykit )"

PATCHES=(
	"${FILESDIR}"/${PN}-4.10.1-alock_support_to_xflock4.patch
# TODO: this patch needs updating for the new version, and finding
# upstream bug.
#	"${FILESDIR}"/${PN}-4.12.1-light-locker_support_to_xflock4.patch

	# fix building with no dbus dependency
	# https://bugs.gentoo.org/667440
	"${FILESDIR}"/xfce4-session-4.13.1-kill-dbus-includes.patch
)

src_configure() {
	local myconf=(
		$(use_enable policykit polkit)
		--with-xsession-prefix="${EPREFIX}"/usr
	)

	econf "${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die

	local sessiondir=/etc/X11/Sessions
	echo startxfce4 > "${T}"/Xfce4 || die
	exeinto ${sessiondir}
	doexe "${T}"/Xfce4
	dosym Xfce4 ${sessiondir}/Xfce
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
