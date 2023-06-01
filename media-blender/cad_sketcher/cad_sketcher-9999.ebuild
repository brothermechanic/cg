EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Constraint-based sketcher addon for Blender with support a fully non-destructive workflow"
HOMEPAGE="https://makertales.gumroad.com/l/CADsketcher"
EGIT_REPO_URI="https://github.com/hlorus/CAD_Sketcher"

LICENSE="GPL-3"

RDEPEND="dev-python/slvs_py"

