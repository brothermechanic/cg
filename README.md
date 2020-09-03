### CG Overlay
Computer Graphics ebuilds for media packages  

This page has user manual for gentoo beginners  
https://blendersworks.wordpress.com/


### How add CG Overlay to your gentoo-based:  

    update external overlays list  
    # eselect repository list  
    [68]  cg # (https://github.com/brothermechanic/cg)  
    select "cg"  
    # eselect repository add cg git https://github.com/brothermechanic/cg  
    update cg  
    # emerge --sync cg  

This blender addons installs to system subdirectory  
${BLENDER_ADDONS_DIR}  
You can set it to make.conf before  
Please, set it to PreferencesFilePaths.scripts_directory  
More info you can find at page  
https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path  

you can support me by  
paypal      brothermechanic@gmail.com  
yandexmoney 410013585907940  
thank you!  
