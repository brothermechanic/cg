EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon for image pasting from system clipboard"
HOMEPAGE="https://gumroad.com/l/BmQWu"
EGIT_REPO_URI="https://github.com/b-init/ImagePaste"

LICENSE="GPL-3"

PATCHES=(
	${FILESDIR}/unbundle_bin.patch
)

src_prepare() {
	default
	rm -r "${S}"/imagepaste/clipboard/linux/bin/xclip
	rm -r "${S}"/imagepaste/clipboard/windows
	rm -r "${S}"/imagepaste/clipboard/darwin
}

