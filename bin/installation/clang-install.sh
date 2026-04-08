#!/bin/bash
###########################################
## Tool chain install script.
##
## Written: Jordan Carlin, jcarlin@hmc.edu
## Created: April 7 2026
## Modified:
##
## Purpose: Clang/LLVM installation script
##
## A component of the CORE-V-WALLY configurable RISC-V project.
## https://github.com/openhwgroup/cvw
##
## Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University
##
## SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
##
## Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may not use this file
## except in compliance with the License, or, at your option, the Apache License version 2.0. You
## may obtain a copy of the License at
##
## https:##solderpad.org/licenses/SHL-2.1/
##
## Unless required by applicable law or agreed to in writing, any work distributed under the
## License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
## either express or implied. See the License for the specific language governing permissions
## and limitations under the License.
################################################################################################

CLANG_VERSION=22.1.3 # Last release as of April 7, 2026

set -e # break on error
# If run standalone, check environment. Otherwise, use info from main install script
if [ -z "$FAMILY" ]; then
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WALLY="$(dirname $(dirname "$dir"))"
    export WALLY
    source "${dir}"/../wally-environment-check.sh
fi

# Clang/LLVM (https://llvm.org/)
# Clang is a C/C++ compiler built on LLVM. Only the clang and lld projects are built to reduce compile time.
section_header "Installing/Updating Clang/LLVM"
STATUS="clang"
cd "$RISCV"
if check_tool_version $CLANG_VERSION; then
    CLANG_SRCDIR="llvm-project-${CLANG_VERSION}.src"
    CLANG_TARBALL="${CLANG_SRCDIR}.tar.xz"
    CLANG_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_VERSION}/${CLANG_TARBALL}"
    wget -nv --retry-connrefused $retry_on_host_error --output-document="${CLANG_TARBALL}" "$CLANG_URL"
    tar xJf "${CLANG_TARBALL}"
    rm -f "${CLANG_TARBALL}"
    cd "$RISCV"/"${CLANG_SRCDIR}"
    mkdir -p build
    cd build
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$RISCV" \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_TARGETS_TO_BUILD="RISCV" \
        ../llvm
    ninja -j "${NUM_THREADS}" 2>&1 | logger; [ "${PIPESTATUS[0]}" == 0 ]
    ninja install 2>&1 | logger; [ "${PIPESTATUS[0]}" == 0 ]
    if [ "$clean" = true ]; then
        cd "$RISCV"
        rm -rf "${CLANG_SRCDIR}"
    fi
    echo "$CLANG_VERSION" > "$RISCV"/versions/$STATUS.version # Record installed version
    echo -e "${SUCCESS_COLOR}Clang/LLVM successfully installed/updated!${ENDC}"
else
    echo -e "${SUCCESS_COLOR}Clang/LLVM already up to date.${ENDC}"
fi
