# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6,3_7} )

inherit distutils-r1

DESCRIPTION="A script for cloning a non-relocatable virtualenv"
HOMEPAGE="https://github.com/edwardgeorge/virtualenv-clone"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
