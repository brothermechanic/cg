### CG Overlay
Computer Graphics ebuilds overlay.

This page has user manual for gentoo beginners  
https://t.me/cgoverlay/124


### How add CG Overlay to your gentoo-based distro:
```
update external overlays list
# eselect repository list
# eselect repository enable cg
# emerge --sync cg
```
### How remove CG Overlay:
```
# eselect repository disable cg
# rm -r /var/db/repos/cg
```

Blender addons installs to system subdirectory by default:
`/usr/share/blender/scripts/`
You may set another path in make.conf before as CG_BLENDER_SCRIPTS_DIR
And, set it to PreferencesFilePaths.scripts_directory
More info you can find at page  
https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path  

