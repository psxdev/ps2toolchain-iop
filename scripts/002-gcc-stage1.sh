#!/bin/bash
# gcc-3.2.3-stage1.sh by AKuHAK
# Based on gcc-3.2.2-stage1.sh by Naomi Peori (naomi@peori.ca)

## Download the source code.
REPO_URL="https://github.com/fjtrujy/gcc.git"
REPO_FOLDER="gcc"
BRANCH_NAME="iop-v9.2.0"
if test ! -d "$REPO_FOLDER"; then
	git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd $REPO_FOLDER || exit 1
else
	cd $REPO_FOLDER && git fetch origin && git reset --hard origin/${BRANCH_NAME} || exit 1
fi

OSVER=$(uname)
## Apple needs to pretend to be linux
if [ ${OSVER:0:6} == Darwin ]; then
	TARG_XTRA_OPTS="--build=i386-linux-gnu --host=i386-linux-gnu"
elif [ ${OSVER:0:10} == MINGW64_NT ]; then
	TARG_XTRA_OPTS="--build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32"
else
	TARG_XTRA_OPTS=""
fi

## Determine the maximum number of processes that Make can work with.
if [ ${OSVER:0:5} == MINGW ]; then
	PROC_NR=$NUMBER_OF_PROCESSORS
elif [ ${OSVER:0:6} == Darwin ]; then
	PROC_NR=$(sysctl -n hw.ncpu)
else
	PROC_NR=$(nproc)
fi

echo "Building with $PROC_NR jobs"

## For each target...
for TARGET in "iop"; do
	## Create and enter the build directory.
	rm -rf build-$TARGET-stage1 && mkdir build-$TARGET-stage1 && cd build-$TARGET-stage1 || { exit 1; }

	## Configure the build.
	if [ ${OSVER:0:6} == Darwin ]; then
		CC=/usr/bin/gcc CXX=/usr/bin/g++ LD=/usr/bin/ld CFLAGS="-O0 -ansi -Wno-implicit-int -Wno-return-type" ../configure --quiet --prefix="$PS2DEV/$TARGET" --target="$TARGET" --enable-languages="c" --with-newlib --without-headers $TARG_XTRA_OPTS || { exit 1; }
	else
		../configure --quiet --prefix="$PS2DEV/$TARGET" --target="$TARGET" --enable-languages="c" --with-newlib --without-headers $TARG_XTRA_OPTS || { exit 1; }
	fi

	## Compile and install.
	make --quiet clean && make --quiet -j $PROC_NR CFLAGS="$CFLAGS -O2" LDFLAGS="$LDFLAGS -s" && make --quiet install && make --quiet clean || { exit 1; }

	## Exit the build directory.
	cd .. || { exit 1; }

	## End target.
done
