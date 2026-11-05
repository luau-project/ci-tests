__EMPTY           =
DIRSEP            = \$(__EMPTY)
OBJEXT            = .obj
SHEXT             = .dll
IMPLIBEXT         = .lib
SystemDrive       = c:
WINDIR            = $(SystemDrive)$(DIRSEP)windows
System32          = $(WINDIR)$(DIRSEP)system32
SHELL             = $(System32)$(DIRSEP)cmd.exe

PREFIX            = $(SystemDrive)$(DIRSEP)lua
LUA_VERSION       = 5.1
LUA_VERSION_NODOT = $(LUA_VERSION:.=)
LUA_DIR           = $(PREFIX)
LUA_BINDIR        = $(LUA_DIR)$(DIRSEP)bin
LUA_INCSUBDIR     = include
LUA_INCDIR        = $(LUA_DIR)$(DIRSEP)$(LUA_INCSUBDIR)
LUA_LIBSUBDIR     = lib
LUA_LIBDIR        = $(LUA_DIR)$(DIRSEP)$(LUA_LIBSUBDIR)
LUA_BASENAME      = lua
LUA               = $(LUA_BINDIR)$(DIRSEP)$(LUA_BASENAME)
LUA_LIB_SUFFIX    = $(LUA_VERSION_NODOT)
LUA_LIB           = lua$(LUA_LIB_SUFFIX)$(IMPLIBEXT)
INSTALL_CMOD      = $(LUA_LIBDIR)$(DIRSEP)lua$(DIRSEP)$(LUA_VERSION)

LUAFILEKEY_SRC    = lua-filekey.c
LUAFILEKEY_OBJ    = lua-filekey$(OBJEXT)

SRC               = $(LUAFILEKEY_SRC)
OBJ               = $(LUAFILEKEY_OBJ)

OUTNAME           = lua-filekey
OUT               = $(OUTNAME)$(SHEXT)

CC                = cl
CCNOLOGO          = /nologo
CCONLY            = /c
CCFPIC            =
CCDEBINFO         =
CCSTD             =
CCPEDANTIC        =
CCMTTHREAD        = /MD
CCOPT             = /O2
CCWARN            = /W3
CFLAGS            = $(CCFPIC) $(CCDEBINFO) $(CCSTD) $(CCPEDANTIC) $(CCMTTHREAD) $(CCOPT) $(CCWARN)
CFLAGS_EXTRA      =
CCOUT             = /Fo$(__EMPTY)
CCINCLUDE         = /I
INCLUDES          = $(CCINCLUDE)$(LUA_INCDIR)

LD                = link
LDNOLOGO          = /nologo
SHFLAGS           = /DLL
LDFLAGS           = $(SHFLAGS)
LDFLAGS_EXTRA     =
LDLIBPATHFLAG     = /LIBPATH:$(__EMPTY)
LDLINKFLAG        =
LDOUT             = /OUT:$(__EMPTY)
LIBS              = $(LDLIBPATHFLAG)$(LUA_LIBDIR) $(LDLINKFLAG)$(LUA_LIB)

RM                = del
RMFLAGS           = /Q

INSTALL           = copy
INSTALL_FLAGS     = /Y

MKDIR             = mkdir
MKDIRFLAGS        =

TESTFILE          = test-file.lua
TESTLINKFILE      = test-link.lua
TESTOUTPUT        = o.txt

all: lib

lib: $(OUT)

$(OUT): $(OBJ)
	$(LD) $(LDNOLOGO) $(LDFLAGS) $(LDFLAGS_EXTRA) $(LDOUT)$(OUT) $(LUAFILEKEY_OBJ) $(LIBS)

$(LUAFILEKEY_OBJ): $(LUAFILEKEY_SRC)
	$(CC) $(CCNOLOGO) $(CCONLY) $(CFLAGS) $(CFLAGS_EXTRA) $(INCLUDES) $(CCOUT)$(LUAFILEKEY_OBJ) $(LUAFILEKEY_SRC)

create-install-dir:
	-$(MKDIR) $(MKDIRFLAGS) $(INSTALL_CMOD)

install:
	$(INSTALL) $(INSTALL_FLAGS) $(OUT) $(INSTALL_CMOD)

uninstall:
	-$(RM) $(RMFLAGS) $(INSTALL_CMOD)$(DIRSEP)$(OUT)

clean-$(LUAFILEKEY_OBJ):
	-$(RM) $(RMFLAGS) $(LUAFILEKEY_OBJ)

clean-obj: clean-$(LUAFILEKEY_OBJ)

clean-out:
	-$(RM) $(RMFLAGS) $(OUT)

clean-test-output:
	-$(RM) $(RMFLAGS) $(TESTOUTPUT)

clean: clean-obj clean-out clean-test-output

test: test-file test-linkfile

test-file:
	$(LUA) $(TESTFILE)

test-linkfile:
	$(LUA) $(TESTLINKFILE)

