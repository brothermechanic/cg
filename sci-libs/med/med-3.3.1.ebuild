# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils flag-o-matic autotools fortran-2

DESCRIPTION="Modeling and Exchange of Data library"
HOMEPAGE="http://www.code-aster.org/outils/med/"
SRC_URI="http://files.salome-platform.org/Salome/other/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND=">=sci-libs/hdf5-1.6.4"
RDEPEND=${DEPEND}

S=${WORKDIR}/med-${PV}_SRC
#FORTRAN_STANDARD=90
FORTRAN_NEED_OPENMP=1

src_prepare() {
    epatch "${FILESDIR}/hdf5-1.10-support.patch"
    eapply_user
    eautoreconf
}

src_configure() {
	local myconf

	myconf="--docdir=/usr/share/doc/${PF} --with-f90=mpif90"
	## has been desabled, in order to compile salome-med
	#use amd64 && myconf="${myconf} --with-med_int=long"
	econf ${myconf}
}

src_install() {
	default

	rm -R "${ED}"/usr/share/doc/* "${ED}"/usr/bin/testc "${ED}"/usr/bin/testf

	use doc && \
		dohtml -r doc/index.html doc/med.css doc/html doc/jpg \
			doc/png doc/gif doc/tests

	if use examples; then
		dodir /usr/share/doc/${PF}/examples/c/.libs
		exeinto /usr/share/doc/${PF}/examples/c
		for i in `ls tests/c/*.o` ;
		do
			doexe tests/c/`basename ${i} .o` "doexe failed"
		done
		exeinto /usr/share/doc/${PF}/examples/c/.libs
		doexe  tests/c/.libs/* "doexe failed"

		dodir /usr/share/doc/${PF}/examples/f/.libs
		exeinto /usr/share/doc/${PF}/examples/f
		for i in `ls tests/f/*.o` ;
		do
			doexe tests/f/`basename ${i} .o` "doexe failed"
		done
		exeinto /usr/share/doc/${PF}/examples/f/.libs
		doexe tests/f/.libs/* "doexe failed"
	fi
}
