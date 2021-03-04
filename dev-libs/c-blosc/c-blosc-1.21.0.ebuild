# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Blocking, shuffling and lossless compression library"
HOMEPAGE="http://www.blosc.org/"
SRC_URI="https://github.com/Blosc/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"

SLOT="0/1"
KEYWORDS="amd64"

IUSE="cpu_flags_x86_sse2 cpu_flags_x86_avx2 fuzzers +lz4 +snappy static-libs +shared-libs benchmarks test zlib zstd"

RDEPEND="
	lz4? ( app-arch/lz4 )
	snappy? ( app-arch/snappy )
	zlib? ( sys-libs/zlib )
	zstd? ( app-arch/zstd )"
DEPEND="${RDEPEND}"

RESTRICT="mirror"

DOCS=( README.md RELEASE_NOTES.rst THOUGHTS_FOR_2.0.txt ANNOUNCE.rst )

src_prepare() {
	cmake_src_prepare
	# remove bundled libs
	rm -rf internal-complibs || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_STATIC=$(usex static-libs)
		-DBUILD_SHARED=$(usex shared-libs)
		-DBUILD_TESTS=$(usex test)
		-DBUILD_BENCHMARKS=$(usex benchmarks)
		-DBUILD_FUZZERS=$(usex fuzzers)
		-DDEACTIVATE_SSE2=$(usex !cpu_flags_x86_sse2)
		-DDEACTIVATE_AVX2=$(usex !cpu_flags_x86_avx2)
		-DDEACTIVATE_LZ4=$(usex !lz4)
		-DDEACTIVATE_SNAPPY=$(usex !snappy)
		-DDEACTIVATE_ZLIB=$(usex !zlib)
		-DDEACTIVATE_ZSTD=$(usex !zstd)
		-DPREFER_EXTERNAL_LZ4=ON
		#-DPREFER_EXTERNAL_SNAPPY=ON # snappy is always external
		-DPREFER_EXTERNAL_ZLIB=ON
		-DPREFER_EXTERNAL_ZSTD=ON
	)
	cmake_src_configure
}
