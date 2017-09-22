#!/bin/bash

# Copyright (c) 2017, University of Kaiserslautern
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Author: Éder F. Zulian

source ./defaults.in
source ./util.in

toolchain=gcc-linaro-5.4.1-2017.05-i686_arm-linux-gnueabihf
toolchaintarball=$toolchain.tar.xz

wgethis=(
"$TOOLCHAINSDIR_ARM:https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/$toolchaintarball"
)

gitrepos=(
"$BENCHMARKSDIR:http://llvm.org/git/test-suite.git"
)

greetings
wgetintodir wgethis[@]
gitcloneintodir gitrepos[@]

toolchaindir=$TOOLCHAINSDIR_ARM/$toolchain
if [[ ! -d $toolchaindir ]]; then
	tar -xaf $TOOLCHAINSDIR_ARM/$toolchaintarball -C $TOOLCHAINSDIR_ARM
fi

cd $BENCHMARKSDIR/test-suite
git checkout release_50
cd SingleSource/Benchmarks/Stanford

printf "
sysroot=$toolchaindir/bin/../arm-linux-gnueabihf/libc
cc=$toolchaindir/bin/arm-linux-gnueabihf-gcc
sources = \$(wildcard *.c)
bins = \$(patsubst %%.c,%%,\$(sources))\n
all: \$(bins)
\t@echo Compilation finished\n
clean:
\trm -rf \$(bins)\n
%%: %%.c
\t\$(cc) --sysroot=\$(sysroot) --static \$< -o \$@
" > Makefile
getnumprocs np
make -j$np
