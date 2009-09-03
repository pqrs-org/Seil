#!/bin/sh

basedir=`dirname $0`

check_find() {
    pattern="$1"

    if [ `grep -c "$pattern" $f` -ne 1 ]; then
        echo "[ERROR] No pattern: $pattern"
        exit 1
    fi
}

check_noexist() {
    pattern="$1"

    if [ `grep -c "$pattern" $f` -ne 0 ]; then
        echo "[ERROR] Appear pattern: $pattern"
        exit 1
    fi
}

for f in `find $basedir/../* -name 'project.pbxproj'`; do
    echo "Check $f"

    check_find 'objectVersion = 46'
    check_find 'ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";'
    check_find 'GCC_ENABLE_OBJC_GC = supported;'
    check_find 'GCC_TREAT_WARNINGS_AS_ERRORS = YES;'
    check_find 'GCC_WARN_64_TO_32_BIT_CONVERSION = YES;'
    check_find 'GCC_WARN_ABOUT_MISSING_NEWLINE = YES;'
    check_find 'GCC_WARN_ABOUT_MISSING_PROTOTYPES = YES;'
    check_find 'GCC_WARN_ABOUT_RETURN_TYPE = YES;'
    check_find 'GCC_WARN_CHECK_SWITCH_STATEMENTS = YES;'
    check_find 'GCC_WARN_MISSING_PARENTHESES = YES;'
    check_find 'GCC_WARN_SHADOW = YES;'
    check_find 'GCC_WARN_SIGN_COMPARE = YES;'
    check_find 'GCC_WARN_UNINITIALIZED_AUTOS = YES;'
    check_find 'GCC_WARN_UNUSED_FUNCTION = YES;'
    check_find 'GCC_WARN_UNUSED_LABEL = YES;'
    check_find 'GCC_WARN_UNUSED_VALUE = YES;'
    check_find 'GCC_WARN_UNUSED_VARIABLE = YES;'
    check_find 'SDKROOT = macosx10.6;'
    check_find 'VALID_ARCHS = "i386 x86_64";'

    check_noexist 'GCC_WARN_PROTOTYPE_CONVERSION'
done
