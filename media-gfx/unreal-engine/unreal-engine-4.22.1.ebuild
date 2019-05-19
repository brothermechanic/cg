
EAPI=7

inherit xdg pax-utils

# Package is 3 Gib smaller with "strip" but it's skipped because it takes a long time and generates many warnings
# RESTRICT="fetch strip staticlibs network-sandbox"
RESTRICT="strip staticlibs network-sandbox"

DESCRIPTION="A 3D game engine by Epic Games which can be used non-commercially for free."
HOMEPAGE="https://www.unrealengine.com/"
RELEASE="UnrealEngine-${PV}-release"
TOOLCHAIN_VERSION=v13_clang-7.0.1-centos7
SRC_URI="${RELEASE}.tar.gz
	http://cdn.unrealengine.com/Toolchain_Linux/native-linux-${TOOLCHAIN_VERSION}.tar.gz -> ${TOOLCHAIN_VERSION}.tar.gz"

LICENSE="UnrealEngine"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=sys-devel/clang-8.0.0
	>=dev-lang/mono-5.20.1.19
	app-text/dos2unix
	dev-util/cmake
	dev-vcs/git"
RDEPEND="${DEPEND}
	dev-libs/icu
	media-libs/libsdl2
	dev-lang/python
	>=sys-devel/lld-8.0.0
	x11-misc/xdg-user-dirs
	x11-terms/xterm"

PATCHES=(
	"${FILESDIR}/ignore-clang-install.patch"
	"${FILESDIR}/use-system-mono.patch"
	"${FILESDIR}/recompile-version-selector.patch"
	"${FILESDIR}/clang-80-support.patch"
	"${FILESDIR}/html5-build.patch"
)

S="${WORKDIR}/${RELEASE}"

#pkg_nofetch() {
#	einfo "Please download ${A} from https://github.com/EpicGames"
#	einfo "The archive should then be placed into your DISTDIR directory."
#}

src_unpack() {
	unpack ${RELEASE}.tar.gz
	local TOOLCHAIN_ROOT="Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64/"
	mkdir -p "${S}/${TOOLCHAIN_ROOT}" || die
	pushd "${S}/${TOOLCHAIN_ROOT}" || die
	unpack ${TOOLCHAIN_VERSION}.tar.gz
	popd || die
}

src_prepare() {
	default
	export TERM=xterm

	echo "Copy cache"
	cp -r /usr/portage/distfiles/${RELEASE} ${WORKDIR}

	cp ${FILESDIR}/UE4Editor.desktop UE4Editor.desktop || die
	sed -i "5c\Path=/opt/${PN}/Engine/Binaries/Linux/" UE4Editor.desktop || die
	sed -i "6c\Exec=\'/opt/${PN}/Engine/Binaries/Linux/UE4Editor\' %F" UE4Editor.desktop || die
	cp "${FILESDIR}/Makefile" Makefile
	sed -i -e "s|http://cdn.unrealengine.com/dependencies|https://cdn.unrealengine.com/dependencies|g" Engine/Build/Commit.gitdeps.xml || die
	sed -i -e "s|http://cdn.unrealengine.com/dependencies|https://cdn.unrealengine.com/dependencies|g" Engine/Source/Programs/GitDependencies/DependencyManifest.cs || die
	addpredict /etc/mono/registry
	for event in /dev/input/event* ; do
		addpredict "${event}"
	done
	pax-mark m Engine/Extras/GDBPrinters/UE4Printers.py

	echo "Running setup"
	./Setup.sh

	echo "generating project files"
	./GenerateProjectFiles.sh -makefile

	cp Engine/Source/Programs/UnrealVS/Resources/Preview.png UE4Editor.png || die
}

src_compile() {
	emake -j1
	sed -ri 's|(..*)-makefile.*|\1-projectfiles "$@"|' Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh || die
	sed -ri '/(..*)make.*/,+1d' Setup.sh || die
}

src_install() {
	local dir=/opt/${PN}
	insinto /usr/share/applications
	doins UE4Editor.desktop
	insinto /usr/share/licenses/UnrealEngine
	doins LICENSE.md
	# fperms a+x Engine/Binaries/DotNET/IOS/IPhonePackager.exe
	insinto /usr/share/pixmaps
	doins UE4Editor.png
	dodir ${dir}/Engine
	dodir ${dir}/Engine/DerivedDataCache # editor needs this
	dodir ${dir}/Engine/Intermediate # editor needs this, but not the contents
	dodir ${dir}/Engine/Source # the source cannot be redistributed, but seems to be needed to compile c++ projects
	insinto ${dir}/Engine
	doins -r Engine/Binaries
	doins -r Engine/Build
	doins -r Engine/Config
	doins -r Engine/Content
	doins -r Engine/Documentation
	doins -r Engine/Extras
	doins -r Engine/Plugins
	doins -r Engine/Programs
	doins -r Engine/Saved
	doins -r Engine/Shaders
	# these folders needs to be writable, otherwise there is a segmentation fault when starting the editor
	# fperms -R a+rwX ${dir}/Engine
	insinto ${dir}
	# content
	doins -r FeaturePacks
	doins -r Samples
	doins -r Templates
	# build scripts, used by some plugins (CLion)
	doins GenerateProjectFiles.sh Setup.sh
	doins .ue4dependencies
}
