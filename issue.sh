initialdir="/tmp";

cd "$initialdir";

cachedir="${initialdir}/my-cache";
installdir="${initialdir}/usr";
luarocksv="3.13.0";
luarocksd="${cachedir}/luarocks-${luarocksv}";
lfsv="1_9_0";
lfsd="${cachedir}/luafilesystem-${lfsv}";
platform="$(uname)";
platform=$(echo "$platform" | tr '[:upper:]' '[:lower:]');
make_prog="make";
if [ "$platform" = "darwin" ]; then
    platform="macosx";
fi
if [ "$platform" = "macos" ]; then
    platform="macosx";
fi
if [ "$platform" = "freebsd" ]; then
    platform="my-bsd";
    make_prog="gmake";
fi
if [ "$platform" = "openbsd" ]; then
    platform="my-bsd";
    make_prog="gmake";
fi
if [ "$platform" = "netbsd" ]; then
    platform="my-bsd";
    make_prog="gmake";
fi
tabchar=$(printf "\t");
has_wget=1
has_curl=1

wget_path=$(command -v wget);
if [ $? != 0 ]; then
    has_wget=0;
fi

curl_path=$(command -v curl);
if [ $? != 0 ]; then
    has_curl=0;
fi

if [ "${has_wget}x${has_curl}" = "0x0" ]; then
    echo "Failed to find wget or curl";
    exit 1;
fi

download_tarball () {
    if [ "$has_wget" = "1" ]; then
        env -C "$2" \
            "${wget_path}" "$1";
    elif [ "$has_curl" = "1" ]; then
        env -C "$2" \
            "${curl_path}" -L -O "$1";
    else
        echo "This never hit this condition";
        exit 1;
    fi
}

if [ ! -d "$cachedir" ]; then
	echo "Creating cache dir ...";
	mkdir -p "$cachedir";
fi

if [ -d "$installdir" ]; then
	echo "Cleaning the install directory ...";
	rm -rf "$installdir";
fi

if [ -d "${luarocksd}" ]; then
	echo "Cleaning luarocks directory ...";
	rm -rf "$luarocksd";
fi

if [ -d "${lfsd}" ]; then
	echo "Cleaning luafilesystem directory ...";
	rm -rf "$lfsd";
fi

if [ ! -f "${cachedir}/luarocks-${luarocksv}.tar.gz" ]; then
	echo "Downloading LuaRocks ${luarocksv} ...";
	download_tarball "https://luarocks.org/releases/luarocks-${luarocksv}.tar.gz" "$cachedir";

	if [ $? != 0 ]; then
		echo "Failed to download LuaRocks ${luarocksv}";
		exit 1;
	fi
fi

tar -C "$cachedir" -xf "${cachedir}/luarocks-${luarocksv}.tar.gz";

if [ $? != 0 ]; then
	echo "Failed to extract LuaRocks ${luarocksv} tarball";
	exit 1;
fi

echo "Setting fs_use_modules to false on LuaRocks ${luarocksv} cfg";
case "$platform" in
    macosx|my-bsd)
        sed \
            -e "s/fs_use_modules = true/fs_use_modules = false/g" \
            -i "" \
            "${luarocksd}/src/luarocks/core/cfg.lua"
        ;;
    *)
        sed \
            -e "s/fs_use_modules = true/fs_use_modules = false/g" \
            -i \
            "${luarocksd}/src/luarocks/core/cfg.lua"
        ;;
esac

if [ $? != 0 ]; then
	echo "Failed to set fs_use_modules to false on LuaRocks ${luarocksv} cfg";
	exit 1;
fi

if [ ! -f "${cachedir}/v${lfsv}.tar.gz" ]; then
	echo "Downloading luafilesystem ${lfsv} ...";
	download_tarball "https://github.com/lunarmodules/luafilesystem/archive/refs/tags/v${lfsv}.tar.gz" "$cachedir";

	if [ $? != 0 ]; then
		echo "Failed to download luafilesystem ${lfsv}";
		exit 1;
	fi
fi

tar -C "$cachedir" -xf "${cachedir}/v${lfsv}.tar.gz";

if [ $? != 0 ]; then
	echo "Failed to extract luafilesystem ${lfsv} tarball";
	exit 1;
fi

for v in 5.1.5 5.2.4 5.3.6 5.4.8 5.5.0; do
	luan="${v%.*}";
	luad="${cachedir}/lua-${v}";
	luatb="${cachedir}/lua-${v}.tar.gz";

	if [ ! -f "$luatb" ]; then
		echo "Downloading Lua ${v} tarball ...";
	    download_tarball "https://lua.org/ftp/lua-${v}.tar.gz" "$cachedir";

		if [ $? != 0 ]; then
			echo "Failed to download Lua ${v}";
			exit 1;
		fi
	fi

	if [ -d "$luad" ]; then
		echo "Cleaning Lua ${v} source directory ...";
		rm -rf "$luad";
	fi

	echo "Extracting Lua ${v} tarball ...";
	tar -C "$cachedir" -xf "$luatb";

	if [ $? != 0 ]; then
		echo "Failed to extract Lua ${v}";
		exit 1;
	fi

	if [ "$platform" = "my-bsd" ]; then
		echo "Patching Lua ${v} src/Makefile for BSD-like systems ...";
		echo "my-bsd:" >> "${luad}/src/Makefile";
		echo "${tabchar}\$(MAKE) all MYCFLAGS=\"-DLUA_USE_POSIX -DLUA_USE_READLINE -I/usr/include/edit\" MYLIBS=\"-Wl,-E -ledit\" CC=\"cc\"" >> "${luad}/src/Makefile";

		echo "Patching Lua ${v} Makefile for BSD-like systems ...";
		echo "my-bsd:" >> "${luad}/Makefile";
		echo "${tabchar}@cd src && \$(MAKE) \$@" >> "${luad}/Makefile";
	fi

	echo "Building Lua ${v} ...";
	"$make_prog" -C "$luad" clean "$platform";

	echo "Renaming lua to lua${luan} ...";
	mv "${luad}/src/lua" "${luad}/src/lua${luan}";

	echo "Renaming luac to luac${luan} ...";
	mv "${luad}/src/luac" "${luad}/src/luac${luan}";

	echo "Renaming liblua.a to liblua${luan}.a ...";
	mv "${luad}/src/liblua.a" "${luad}/src/liblua${luan}.a";

	echo "Installing Lua ${v} ...";
	"$make_prog" -C "$luad" \
		"INSTALL_TOP=${installdir}" \
		"INSTALL_INC=${installdir}/include/lua${luan}" \
		"INSTALL_MAN=${installdir}/share/lua${luan}/man/man1" \
		"TO_BIN=lua${luan} luac${luan}" \
		"TO_LIB=liblua${luan}.a" \
		install;
done

echo "Switching to LuaRocks source dir ..."
cd "$luarocksd";

echo "Configuring LuaRocks ...";
./configure "--prefix=${installdir}" "--with-lua=${installdir}";

if [ $? != 0 ]; then
	echo "Failed to configure LuaRocks";
	exit 1;
fi

echo "Building LuaRocks ...";
"$make_prog" ./build/luarocks ./build/luarocks-admin ./build/config-5.5.lua

if [ $? != 0 ]; then
	echo "Failed to build LuaRocks";
	exit 1;
fi

for v in 5.1.5 5.2.4 5.3.6 5.4.8; do
	luan="${v%.*}";

	echo "Building LuaRocks for Lua ${v} ...";
	"$make_prog" \
		"LUA_VERSION=${luan}" \
		"LUA=${installdir}/bin/lua${luan}" \
		"LUA_INCDIR=${installdir}/include/lua${luan}" \
		"./build/config-${luan}.lua";

	if [ $? != 0 ]; then
		echo "Failed to configure LuaRocks for Lua ${v}";
		exit 1;
	fi

done

echo "Installing LuaRocks ...";
"$make_prog" install;

if [ $? != 0 ]; then
	echo "Failed to install LuaRocks";
	exit 1;
fi

for v in 5.1.5 5.2.4 5.3.6 5.4.8; do
	luan="${v%.*}";

	echo "Installing LuaRocks config for Lua ${v} ...";
	"$make_prog" \
		"LUA_VERSION=${luan}" \
		"./build/config-${luan}.lua" \
		install-config;

	if [ $? != 0 ]; then
		echo "Failed to install LuaRocks config for Lua ${v}";
		exit 1;
	fi

done

cd "$initialdir";

echo "Switching to luafilesystem directory ...";
cd "$lfsd";

for v in 5.1.5 5.2.4 5.3.6 5.4.8 5.5.0; do
	luan="${v%.*}";

	echo "Building luafilesystem ${lfsv} ...";
	"${installdir}/bin/luarocks" \
		--lua-version "$luan" \
		make;

	if [ $? = 0 ]; then
		echo "luafilesystem ${lfsv} was built successfully!";
	else
		echo "Failed to build luafilesystem";
	fi
done

cd "$initialdir";

echo "Done!";
