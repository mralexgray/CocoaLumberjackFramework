# CocoaLumberjackFramework

A Framework distribution of [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack)
for iOS and OS X.

# Motivation

The advantage of a framework distribution is that you only have to build it once.
A nested project or directly including the code (*shudder*) always builds everything
for a fresh build (e.g. after a clean).

A disadvantage is that you can't change the code of the Framework directly if you want
to. You also can't browse the source files to set breakpoints. But you *can* step into
the Framework functions. This makes debugging a little more difficult.

# Procedure

This is a general description of how this was achieved.

1.  Create directory
2.  Add standard .gitignore
3.  Add License file (e.g. the MIT License)
4.  Add standard rakefile and rakefile.config
5.  Add existing project as submodule in Frameworks folder
    e.g. Frameworks/CocoaLumberjack
6.  If the project has a license, create a License folder and copy it in there.
    e.g. License/CocoaLumberjack.txt
7.  Create an empty Static iOS Framework project with a proper name
8.  Copy CocoaLumberjack.xcodeproj and CocoaLumberjack folder to the directory
9.  Open CocoaLumberjack.xcodeproj
10.  Rename static iOS target to CocoaLumberjackStaticIOS
11.  `Build Settings` for CocoaLumberjackStaticIOS  
    Architecture: If you want to support the iPhone 3G, add armv6  
    Build Active Architecture Only: Yes for Debug  
    Strip Debug Symbols During Copy: No  
    Strip Style: Non-Global Symbols  
    iOS Deployment Target: Choose appropriate deployment target like iOS 4.0  
    Dead Code Stripping: No  
    Private Headers Folder Path: `$(PRODUCT_NAME)PrivateHeaders`  
    Product Name: `$(PROJECT_NAME)`  
    Public Headers Folder Path: `$(PRODUCT_NAME)Headers`  
12. Validate Project Settings
13. Add references for source and header files to project.
    This can be achieved by simply dragging the appropriate files into the project.
14. `Build Phases` for CocoaLumberjackStaticIOS  
    Add \*.m files to `Compile Sources`  
    Add a `Copy Headers` build phase  
    Add \*.h files to `Copy Headers` and make them Public  
15. Add a reference for all license files by for example dragging it into the
    `Supporting Files` folder.
16. `Copy Files` build phase of CocoaLumberjackStaticIOS  
    Add License file  
    Subpath: ${PRODUCT_NAME}Resources
17. Add `Run Script` phase
18. Rename phase to `Prepare Framework`
19. Insert script

        set -e
    
        mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Headers"
        mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Resources"
        
        # Link the "Current" version to "A"
        /bin/ln -sfh "${FRAMEWORK_VERSION}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/Current"
        /bin/ln -sfh Versions/Current/Headers "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Headers"
        /bin/ln -sfh Versions/Current/Resources "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Resources"
        /bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
        
        # The -a ensures that the headers maintain the source modification date so that we don't constantly
        # cause propagating rebuilds of files that import these headers.
        /bin/cp -a "${TARGET_BUILD_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Headers"
        
        /bin/cp -a "${TARGET_BUILD_DIR}/${PROJECT_NAME}Resources/" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Resources"

20. Manage Schemes
21. Rename CocoaLumberjack to CocoaLumberjackStaticIOS and make it Shared
22. Add `Aggregate Target` with the name CocoaLumberjackIOS
23. Manage Schemes and make CocoaLumberjackIOS Shared
24. `Build Settings` of CocoaLumberjackIOS:  
    Product Name: $(PROJECT_NAME)
25. `Build Phases` of CocoaLumberjackIOS:  
    Make CocoaLumberjackStaticIOS a `Target Dependency`
26. Add `Run Script` phase
27. Rename phase to `Build Framework`
28. Insert script

        set -e
        set +u
        # Avoid recursively calling this script.
        if [[ $SF_MASTER_SCRIPT_RUNNING ]]
        then
            exit 0
        fi
        set -u
        export SF_MASTER_SCRIPT_RUNNING=1
        
        SF_TARGET_NAME=${PROJECT_NAME}
        SF_EXECUTABLE_PATH="lib${SF_TARGET_NAME}.a"
        SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"
        
        # The following conditionals come from
        # https://github.com/kstenerud/iOS-Universal-Framework
        
        if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
        then
            SF_SDK_PLATFORM=${BASH_REMATCH[1]}
        else
            echo "Could not find platform name from SDK_NAME: $SDK_NAME"
            exit 1
        fi
        
        if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
        then
            SF_SDK_VERSION=${BASH_REMATCH[1]}
        else
            echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
            exit 1
        fi
        
        if [[ "$SF_SDK_PLATFORM" = "iphoneos" ]]
        then
            SF_OTHER_PLATFORM=iphonesimulator
        else
            SF_OTHER_PLATFORM=iphoneos
        fi
        
        if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$SF_SDK_PLATFORM$ ]]
        then
            SF_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${SF_OTHER_PLATFORM}"
        else
            echo "Could not find platform name from build products directory: $BUILT_PRODUCTS_DIR"
            exit 1
        fi
        
        # Build the other platform.
        xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${SF_OTHER_PLATFORM}${SF_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" $ACTION
        
        # Smash the two static libraries into one fat binary and store it in the .framework
        lipo -create "${BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" -output "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"
        
        # Copy the binary to the other architecture folder to have a complete framework in both.
        cp -a "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"

29. Add Target `Cocoa Framework` with name `CocoaLumberjackOSX`
30. Manage Schemes and make CocoaLumberjackOSX Shared
31. Delete `CocoaLumberjackOSX` folder
32. `Build Settings` for CocoaLumberjackOSX  
    Info.plist File: Clear Entry  
    Installation Directory: @executable_path/../Frameworks  
    OS X Deployment Target: Choose appropriate. E.g. OS X 10.6  
    Skip Install: Yes  
    Remove GCC_PREFIX_HEADER  
    Remove GCC_PRECOMPILE_PREFIX_HEADER  
33. `Build Phases` for CocoaLumberjackOSX  
    Add *.m files to `Compile Sources`  
    Add *.h files to `Copy Headers` and make them Public  
34. Add licenses to `Copy Bundle Resources` phase
35. Done.
