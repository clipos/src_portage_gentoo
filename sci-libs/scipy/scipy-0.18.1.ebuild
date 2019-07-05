# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} )
PYTHON_REQ_USE="threads(+)"

DOC_PV=${PV}

inherit fortran-2 distutils-r1 flag-o-matic multiprocessing toolchain-funcs

DESCRIPTION="Scientific algorithms library for Python"
HOMEPAGE="https://www.scipy.org/"
SRC_URI="
	mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz
	doc? (
		https://docs.scipy.org/doc/${PN}-${DOC_PV}/${PN}-html-${PV}.zip -> ${PN}-${DOC_PV}-html.zip
		https://docs.scipy.org/doc/${PN}-${DOC_PV}/${PN}-ref-${PV}.pdf -> ${PN}-${DOC_PV}-ref.pdf
	)"

LICENSE="BSD LGPL-2"
SLOT="0"
IUSE="doc sparse test"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

CDEPEND="
	>=dev-python/numpy-1.10[lapack,${PYTHON_USEDEP}]
	sci-libs/arpack:0=
	virtual/cblas
	virtual/lapack
	sparse? ( sci-libs/umfpack:0= )"
DEPEND="${CDEPEND}
	dev-lang/swig
	>=dev-python/cython-0.22[${PYTHON_USEDEP}]
	virtual/pkgconfig
	doc? ( app-arch/unzip )
	test? (	dev-python/nose[${PYTHON_USEDEP}] )"
RDEPEND="${CDEPEND}
	dev-python/pillow[${PYTHON_USEDEP}]"

DOCS=( HACKING.rst.txt THANKS.txt )

DISTUTILS_IN_SOURCE_BUILD=1

PATCHES=(
	"${FILESDIR}"/${PN}-0.12.0-blitz.patch
	"${FILESDIR}"/${PN}-0.12.0-restore-sys-argv.patch
)

src_unpack() {
	default
	if use doc; then
		unzip -qo "${DISTDIR}"/${PN}-${DOC_PV}-html.zip -d html || die
	fi
}

pc_incdir() {
	$(tc-getPKG_CONFIG) --cflags-only-I $@ | \
		sed -e 's/^-I//' -e 's/[ ]*-I/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libdir() {
	$(tc-getPKG_CONFIG) --libs-only-L $@ | \
		sed -e 's/^-L//' -e 's/[ ]*-L/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libs() {
	$(tc-getPKG_CONFIG) --libs-only-l $@ | \
		sed -e 's/[ ]-l*\(pthread\|m\)\([ ]\|$\)//g' \
		-e 's/^-l//' -e 's/[ ]*-l/,/g' -e 's/[ ]*$//' \
		| tr ',' '\n' | sort -u | tr '\n' ',' | sed -e 's|,$||'
}

python_prepare_all() {
	# scipy automatically detects libraries by default
	export {FFTW,FFTW3,UMFPACK}=None
	use sparse && unset UMFPACK
	# the missing symbols are in -lpythonX.Y, but since the version can
	# differ, we just introduce the same scaryness as on Linux/ELF
	[[ ${CHOST} == *-darwin* ]] \
		&& append-ldflags -bundle "-undefined dynamic_lookup" \
		|| append-ldflags -shared
	[[ -z ${FC}  ]] && export FC="$(tc-getFC)"
	# hack to force F77 to be FC until bug #278772 is fixed
	[[ -z ${F77} ]] && export F77="$(tc-getFC)"
	export F90="${FC}"
	export SCIPY_FCONFIG="config_fc --noopt --noarch"
	append-fflags -fPIC

	local libdir="${EPREFIX}"/usr/$(get_libdir)
	cat >> site.cfg <<-EOF || die
		[blas]
		include_dirs = $(pc_incdir cblas)
		library_dirs = $(pc_libdir cblas blas):${libdir}
		blas_libs = $(pc_libs cblas blas)
		[lapack]
		library_dirs = $(pc_libdir lapack):${libdir}
		lapack_libs = $(pc_libs lapack)
	EOF

	# Drop hashes to force rebuild of cython based .c code
	rm cythonize.dat || die

	distutils-r1_python_prepare_all
}

python_compile() {
	${EPYTHON} tools/cythonize.py || die
	distutils-r1_python_compile \
		$(usex python_targets_python3_5 "" "-j $(makeopts_jobs)") \
		${SCIPY_FCONFIG}
}

python_test() {
	# fails with bdist_egg. should it be fixed in distutils-r1 eclass?
	distutils_install_for_testing ${SCIPY_FCONFIG}
	cd "${TEST_DIR}" || die "no ${TEST_DIR} available"
	"${PYTHON}" -c \
		'import numpy as np; print("relaxed strides checking:", np.ones((10,1),order="C").flags.f_contiguous)' \
		|| die
	# https://github.com/scipy/scipy/issues/5426
	"${EPYTHON}" -c \
		"import scipy, sys; r = scipy.test('fast', verbose=2, raise_warnings='release'); sys.exit(0 if r.wasSuccessful() else 1)" \
		|| die "Tests fail with ${EPYTHON}"
#	"${EPYTHON}" -c \
#		"import scipy, sys; r = scipy.test('fast',verbose=2); sys.exit(0 if r.wasSuccessful() else 1)" \
#		|| die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	use doc && \
		local DOCS=( "${DISTDIR}"/${PN}-${DOC_PV}-ref.pdf ) \
		local HTML_DOCS=( "${WORKDIR}"/html/. )
	distutils-r1_python_install_all
}

python_install() {
	distutils-r1_python_install ${SCIPY_FCONFIG}
}

pkg_postinst() {
	elog "You might want to set the variable SCIPY_PIL_IMAGE_VIEWER"
	elog "to your prefered image viewer. Example:"
	elog "\t echo \"export SCIPY_PIL_IMAGE_VIEWER=display\" >> ~/.bashrc"
}
