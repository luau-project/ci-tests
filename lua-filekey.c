/*
Copyright © 2003-2010 Kepler Project.
Copyright © 2010-2022 The LuaFileSystem authors.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#if defined(_WIN32)
#if !defined(LUAFILEKEY_API)
#define LUAFILEKEY_API __declspec(dllexport)
#endif
#if defined(HAVE_REFS)
#if !defined(_WIN32_WINNT)
#define _WIN32_WINNT 0x0603
#endif
#else
#if !defined(_WIN32_WINNT)
#define _WIN32_WINNT 0x0600
#endif
#endif
#include <windows.h>
#else
#if !defined(LUAFILEKEY_API)
#define LUAFILEKEY_API __attribute__((visibility("default")))
#endif
#include <sys/stat.h>
typedef int (*lua_filekey_statfunc)(const char *, struct stat *);
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#if LUA_VERSION_NUM <= 501
/*
    luaL_testudata copied from Lua 5.4.9
    source code for compatibility reasons
*/
static void *lua_filekey_testudata (lua_State *L, int ud, const char *tname) {
  void *p = lua_touserdata(L, ud);
  if (p != NULL) {  /* value is a userdata? */
    if (lua_getmetatable(L, ud)) {  /* does it have a metatable? */
      luaL_getmetatable(L, tname);  /* get correct metatable */
      if (!lua_rawequal(L, -1, -2))  /* not the same? */
        p = NULL;  /* value is a userdata with wrong metatable */
      lua_pop(L, 2);  /* remove both metatables */
      return p;
    }
  }
  return NULL;  /* value is not a userdata with a metatable */
}
#else
#define lua_filekey_testudata luaL_testudata
#endif

/*
    C data structure
    for fileKey
*/
typedef struct tagLuaFileKey {

#if defined(_WIN32)
#if defined(HAVE_REFS)
    ULONGLONG VolumeSerialNumber;
    FILE_ID_128 FileId;
#else
    DWORD dwVolumeSerialNumber;
    DWORD nFileIndexLow;
    DWORD nFileIndexHigh;
#endif
#else
    dev_t st_dev;
    ino_t st_ino;
#endif

} LuaFileKey;

/*
    Metatable
*/
#define LUAFILEKEY_METATABLE "lua_filekey_metatable"

/*
    Push a fileKey (userdata for LuaFileKey) onto the stack
    from a file argument
*/
static int lua_filekey_push(lua_State *L, const char *file, int nofollow) {

    LuaFileKey *fileKey;

#if defined(_WIN32)
    DWORD flags;
    HANDLE handle;

#if defined(HAVE_REFS)
    FILE_ID_INFO info;

    /* clean the info memory */
    memset(&info, 0, sizeof(FILE_ID_INFO));
#else
    BY_HANDLE_FILE_INFORMATION info;

    /* clean the info memory */
    memset(&info, 0, sizeof(BY_HANDLE_FILE_INFORMATION));
#endif

    flags = FILE_FLAG_BACKUP_SEMANTICS;

    if (nofollow) {
        flags |= FILE_FLAG_OPEN_REPARSE_POINT;
    }

    handle = CreateFileA(file, FILE_READ_ATTRIBUTES,
                         FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                         NULL, OPEN_EXISTING, flags, NULL);

    if (handle == INVALID_HANDLE_VALUE) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to get a file handle");
        return 0;
    }

#if defined(HAVE_REFS)
    if (!GetFileInformationByHandleEx(handle, FileIdInfo, &info, sizeof(FILE_ID_INFO))) {
#else
    if (!GetFileInformationByHandle(handle, &info)) {
#endif
        CloseHandle(handle);
        lua_pushnil(L);
        lua_pushstring(L, "Failed to get file information by handle");
        return 0;
    }

    CloseHandle(handle);
#else
    struct stat st;
    lua_filekey_statfunc statfunc = nofollow ?
        ((lua_filekey_statfunc)&lstat) :
        ((lua_filekey_statfunc)&stat);

    /* clean stat memory */
    memset(&st, 0, sizeof(struct stat));

    if (statfunc(file, &st) == -1) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to get file stat");
        return 0;
    }
#endif

    fileKey = (LuaFileKey *)lua_newuserdata(L, sizeof(LuaFileKey));
    if (fileKey == NULL) {
        return 0;
    }

    luaL_getmetatable(L, LUAFILEKEY_METATABLE);
    lua_setmetatable(L, -2);

#if defined(_WIN32)
#if defined(HAVE_REFS)
    fileKey->VolumeSerialNumber = info.VolumeSerialNumber;
    memcpy(&(fileKey->FileId), &(info.FileId), sizeof(FILE_ID_128));
#else
    fileKey->dwVolumeSerialNumber = info.dwVolumeSerialNumber;
    fileKey->nFileIndexLow = info.nFileIndexLow;
    fileKey->nFileIndexHigh = info.nFileIndexHigh;
#endif
#else
    fileKey->st_dev = st.st_dev;
    fileKey->st_ino = st.st_ino;
#endif

    return 1;
}

static int lua_filekey_new(lua_State *L) {
    const char *file = luaL_checkstring(L, 1);
    int nofollow = lua_toboolean(L, 2);
    return (lua_filekey_push(L, file, nofollow) ? 1 : 2);
}

static int lua_filekey_eq(lua_State *L) {
    LuaFileKey *left = lua_filekey_testudata(L, 1, LUAFILEKEY_METATABLE);
    LuaFileKey *right = lua_filekey_testudata(L, 2, LUAFILEKEY_METATABLE);
    int res;
    if (left != NULL && right != NULL) {
#if defined(_WIN32)
#if defined(HAVE_REFS)
        res = left->VolumeSerialNumber == right->VolumeSerialNumber &&
              memcmp(&(left->FileId), &(right->FileId), sizeof(FILE_ID_128)) == 0;
#else
        res = left->dwVolumeSerialNumber == right->dwVolumeSerialNumber &&
              left->nFileIndexLow == right->nFileIndexLow &&
              left->nFileIndexHigh == right->nFileIndexHigh;
#endif
#else
        res = left->st_dev == right->st_dev &&
              left->st_ino == right->st_ino;
#endif
    }
    else {
        res = 0;
    }
    lua_pushboolean(L, res);
    return 1;
}

/* LuaFileKey methods */
static const struct luaL_Reg lua_filekey_funcs[] = {
    {"new", lua_filekey_new},
    {NULL, NULL}
};

/* LuaFileKey instance methods */
static const struct luaL_Reg lua_filekey_methods[] = {
    {"__eq", lua_filekey_eq},
    {NULL, NULL}
};

/* entry point */
LUAFILEKEY_API
int luaopen_filekey(lua_State *L) {

    lua_createtable(L, 0, 0); /* local M = {} */

    /* register lib methods in the M table */
#if LUA_VERSION_NUM <= 501
    luaL_register(L, NULL, lua_filekey_funcs);
#else
    luaL_setfuncs(L, lua_filekey_funcs, 0);
#endif

    luaL_newmetatable(L, LUAFILEKEY_METATABLE);

    /* register instance methods in the metatable */
#if LUA_VERSION_NUM <= 501
    luaL_register(L, NULL, lua_filekey_methods);
#else
    luaL_setfuncs(L, lua_filekey_methods, 0);
#endif

    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); /* clone the metatable */
    lua_settable(L, -3); /* metatable.__index = metatable */

    lua_setmetatable(L, -2); /* setmetatable(M, metatable) */

    return 1;
}
