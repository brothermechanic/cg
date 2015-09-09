 # Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="DB-API 2.0 interface for SQLite 3.x"
HOMEPAGE="https://github.com/ghaering/pysqlite"
SRC_URI="https://github.com/ghaering/pysqlite/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 ppc ~amd64"
IUSE=""
DEPEND=">=dev-db/sqlite-3.3.8:3"
RDEPEND=${DEPEND}

PYTHON_MODULES="pysqlite2"

src_prepare() {
	distutils-r1_src_prepare

	# Enable support for loadable sqlite extensions.
	sed -e "/define=SQLITE_OMIT_LOAD_EXTENSION/d" -i setup.cfg || die "sed setup.cfg failed"

	# Fix encoding.
	sed -e "s/\(coding: \)ISO-8859-1/\1utf-8/" -i lib/{__init__.py,dbapi2.py} || die "sed lib/{__init__.py,dbapi2.py} failed"

	# Workaround to make tests work without installing them.
	sed -e "s/pysqlite2.test/test/" -i lib/test/__init__.py || die "sed lib/test/__init__.py failed"
}

src_test() {
	cd lib

	testing() {
		python_execute PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" -c "from test import test; import sys; sys.exit(test())"
	}
	python_execute_function testing
}

src_install() {
	rm -r ${WORKDIR}/pysqlite-2.8.1-python2_7/lib/pysqlite2/test || die
	distutils-r1_src_install

	rm -r "${ED}usr/pysqlite2-doc"
}
