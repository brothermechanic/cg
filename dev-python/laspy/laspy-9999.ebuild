# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Laspy is a python library for reading, modifying and creating LAS LiDAR files"
HOMEPAGE="https://pypi.org/project/laspy/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 x86"
	RESTRICT="mirror"
fi

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		sci-libs/pdal
		sci-geosciences/laszip
		dev-python/numpy[${PYTHON_USEDEP}]
    	dev-python/pyproj[${PYTHON_USEDEP}]
	)
"

RDEPEND="
	>=sci-geosciences/laszip-0.2.1
	dev-python/lazrs[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
    dev-python/pyproj[${PYTHON_USEDEP}]
    dev-python/requests[${PYTHON_USEDEP}]
	dev-python/typer[${PYTHON_USEDEP}]
    dev-python/rich[${PYTHON_USEDEP}]
"

LICENSE="BSD"
SLOT="0"

distutils_enable_tests pytest
distutils_enable_sphinx docs dev-python/sphinx-rtd-theme dev-python/sphinx-autoapi

src_prepare() {
	export SETUPTOOLS_SCM_PRETEND_VERSION=${PV/9999/2\.4\.1}
	printf '%s\n' "${PV}" > VERSION || die

	distutils-r1_src_prepare
}


src_test() {
	local EPYTEST_DESELECT=(
		tests/test_common.py::test_rw_all_set_one[las0]
		tests/test_common.py::test_rw_all_set_one[las1]
		tests/test_common.py::test_rw_all_set_one[las2]
		tests/test_common.py::test_rw_all_set_one[las3]
		tests/test_common.py::test_rw_all_set_one[las4]
		tests/test_common.py::test_rw_all_set_one[las5]
		tests/test_common.py::test_rw_all_set_one[las6]
		tests/test_common.py::test_las_data_getitem_indices
		tests/test_common.py::test_las_data_getitem_slice
		tests/test_creation.py::test_xyz
		tests/test_extrabytes.py::test_extra_bytes_with_spaces_in_name
		tests/test_field_views.py::test_sub_field_view_behaves_like_array
		tests/test_header.py::test_number_of_points_return_is_updated[all_las_but_1_40]
		tests/test_header.py::test_number_of_points_return_is_updated[all_las_but_1_41]
		tests/test_header.py::test_nb_points_return_1_4
		tests/test_laspy.py::LasWriterTestCase::test_overflow_return_num
		tests/test_mmap.py::test_mmap
		tests/test_modif_1_2.py::test_classification_change[las0-False]
		tests/test_modif_1_2.py::test_classification_change[las0-True]
		tests/test_modif_1_2.py::test_classification_change[las1-False]
		tests/test_modif_1_2.py::test_classification_change[las1-True]
		tests/test_modif_1_2.py::test_synthetic_change[las0-False]
		tests/test_modif_1_2.py::test_synthetic_change[las0-True]
		tests/test_modif_1_2.py::test_synthetic_change[las1-False]
		tests/test_modif_1_2.py::test_synthetic_change[las1-True]
		tests/test_modif_1_2.py::test_key_point_change[las0-False]
		tests/test_modif_1_2.py::test_key_point_change[las0-True]
		tests/test_modif_1_2.py::test_key_point_change[las1-False]
		tests/test_modif_1_2.py::test_key_point_change[las1-True]
		tests/test_modif_1_2.py::test_withheld_changes[las0-False]
		tests/test_modif_1_2.py::test_withheld_changes[las0-True]
		tests/test_modif_1_2.py::test_withheld_changes[las1-False]
		tests/test_modif_1_2.py::test_withheld_changes[las1-True]
		tests/test_modif_1_4.py::test_classification
		tests/test_modif_1_4.py::test_intensity
		tests/test_reading_1_4.py::test_manually_reading_evlrs[/data/1_4_w_evlr.las-None]
		tests/test_reading_1_4.py::test_manually_reading_evlrs[/data/1_4_w_evlr.laz-LazBackend.Lazrs]
		tests/test_reading_1_4.py::test_manually_reading_evlrs[/data/1_4_w_evlr.laz-LazBackend.LazrsParallel]
		laspy/lasdata.py::laspy.lasdata.LasData.xyz
		laspy/point/record.py::laspy.point.record.PackedPointRecord
		docs/basic.rst::basic.rst
	)
	distutils-r1_src_test
}
