boost: LIBS += -lboost_serialization
expat: LIBS += -lexpat
expat: PKGCONFIG -= expat
INCLUDEPATH += $$PWD
INCLUDEPATH += $$PWD/libs/OpenFX/include
INCLUDEPATH += $$PWD/libs/OpenFX_extensions
INCLUDEPATH += $$PWD/libs/OpenFX/HostSupport/include
INCLUDEPATH += $$PWD/libs/SequenceParsing
INCLUDEPATH += /usr/include/eigen3
shiboken {
        PKGCONFIG -= shiboken
        INCLUDEPATH += /usr/include/shiboken
        LIBS += -lshiboken-python2.7
}
pyside {
        PKGCONFIG -= pyside
        INCLUDEPATH += /usr/include/PySide
        INCLUDEPATH += /usr/include/PySide/QtCore
        INCLUDEPATH += /usr/include/PySide/QtGui
        INCLUDEPATH += /usr/include/PySide/QtOpenGL
        LIBS += -lpyside-python2.7
}


