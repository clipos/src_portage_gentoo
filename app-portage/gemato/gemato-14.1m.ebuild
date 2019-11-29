# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# pyblake2 & pysha3 are broken with pypy3
PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7} pypy )
PYTHON_REQ_USE='threads(+)'
inherit distutils-r1

MY_PV=${PV%m}+multiprocessing
MY_P=${PN}-${MY_PV/+/-}

DESCRIPTION="Stand-alone Manifest generation & verification tool"
HOMEPAGE="https://github.com/mgorny/gemato"
SRC_URI="https://github.com/mgorny/gemato/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~amd64-linux ~x86-linux"
IUSE="+blake2 bzip2 +gpg lzma sha3 test tools"
RESTRICT="!test? ( test )"

MODULE_RDEPEND="
	blake2? ( $(python_gen_cond_dep 'dev-python/pyblake2[${PYTHON_USEDEP}]' python{2_7,3_5} pypy{,3}) )
	bzip2? ( $(python_gen_cond_dep 'dev-python/bz2file[${PYTHON_USEDEP}]' python2_7 pypy) )
	gpg? ( app-crypt/gnupg )
	lzma? ( $(python_gen_cond_dep 'dev-python/backports-lzma[${PYTHON_USEDEP}]' python2_7 pypy) )
	sha3? ( $(python_gen_cond_dep 'dev-python/pysha3[${PYTHON_USEDEP}]' python{2_7,3_5} pypy{,3}) )"

RDEPEND="${MODULE_RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND=">=dev-python/setuptools-34[${PYTHON_USEDEP}]
	test? ( ${MODULE_RDEPEND} )"

S=${WORKDIR}/${MY_P}

python_test() {
	esetup.py test
}

python_install_all() {
	distutils-r1_python_install_all

	if use tools; then
		exeinto /usr/share/gemato
		doexe utils/*.{bash,py}
	fi
}

pkg_postinst() {
	elog "The multiprocessing support in gemato may cause the process to hang."
	elog "Please see https://bugs.gentoo.org/647964 for more details."
}
