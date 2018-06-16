# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils scons-utils git-r3

DESCRIPTION="A advanced, feature packed, multi-platform 2D and 3D game engine."
HOMEPAGE="http://www.godotengine.org"

EGIT_REPO_URI="https://github.com/godotengine/godot.git"
KEYWORDS=""

LICENSE="MIT"
SLOT="0"
IUSE="+freetype +llvm +openssl +png pulseaudio theora udev +vorbis +xml"

DEPEND="
		>=app-arch/bzip2-1.0.6-r6
		>=app-arch/lz4-0_p120
		>=app-arch/xz-utils-5.0.8
		>=dev-libs/json-c-0.11-r1
		>=media-libs/alsa-lib-1.0.28
		>=media-libs/flac-1.3.1-r1
		>=media-libs/libogg-1.3.1
		>=media-libs/libsndfile-1.0.25-r1
		>=media-libs/mesa-10.2.8[gles2]
		>=net-libs/libasyncns-0.8-r3
		>=sys-apps/attr-2.4.47-r1
		>=sys-apps/tcp-wrappers-7.6.22-r1
		>=sys-apps/util-linux-2.25.2-r2
		>=sys-devel/gcc-4.6.4:*[cxx]
		>=sys-libs/gdbm-1.11
		>=sys-libs/glibc-2.20-r2
		>=sys-libs/libcap-2.22-r2
		>=sys-libs/zlib-1.2.8-r1
		>=x11-libs/libX11-1.6.2
		>=x11-libs/libXcursor-1.1.14
		>=x11-libs/libXinerama-1.1.3
		freetype? ( >=media-libs/freetype-2.5.3-r1:2 )
		llvm? ( >=sys-devel/llvm-3.6.0 )
		openssl? ( >=dev-libs/openssl-1.0.1j:0 )
		png? ( >=media-libs/libpng-1.6.16:0= )
		pulseaudio? ( >=media-sound/pulseaudio-5.0-r7 )
		theora? ( media-libs/libtheora )
		udev? ( virtual/udev )
		virtual/glu
		vorbis? ( >=media-libs/libvorbis-1.3.4 )
		xml? ( >=dev-libs/expat-2.1.0-r3 )"

RDEPEND="${DEPEND}"

src_configure() {
	MYSCONS=(
		CC="$(tc-getCC)"
		builtin_zlib=no
		builtin_libpng=no
		builtin_freetype=no
		builtin_openssl=$(usex !openssl)
		colored=yes
		tools=yes
		platform=x11
		freetype=$(usex freetype)
		openssl=$(usex openssl)
		png=$(usex png)
		pulseaudio=$(usex pulseaudio)
		theora=$(usex theora)
		udev=$(usex udev)
		use_llvm=$(usex llvm)
		vorbis=$(usex vorbis)
		xml=$(usex xml)
	)
}

src_compile() {
	escons "${MYSCONS[@]}"
}

src_install() {
	newicon icon.svg ${PN}.svg
	dobin bin/godot.*
	if [[ "${ARCH}" == "amd64" ]]; then
		if use llvm; then
			make_desktop_entry godot.x11.tools.64.llvm Godot
			with_desktop_entry=1
		else
			make_desktop_entry godot.x11.tools.64 Godot
			with_desktop_entry=1
		fi
	fi

	if [[ "${ARCH}" == "x86" ]]; then
		if use llvm; then
			make_desktop_entry godot.x11.tools.32.llvm Godot
			with_desktop_entry=1
		else
			make_desktop_entry godot.x11.tools.32 Godot
			with_desktop_entry=1
		fi
	fi

	if ! [[ "${with_desktop_entry}" == "1" ]]; then
		elog "Couldn't detect running architecture to create a desktop file."
	fi
}
