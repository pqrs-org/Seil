#!/bin/sh

find ../../* \
    \( -name '*.[ch]pp' -o -name '*.[mh]' \) \
    -type f \
    ! -ipath '*/Pods/*' \
    ! -ipath '*/build/*' \
    ! -ipath '*/kext/*/*include/*' \
    ! -ipath '*/src/bridge/output/*' \
    \
    | xargs clang-format -i
