__EMPTY           =
DIRSEP            = /$(__EMPTY)
OBJEXT            = .o
SHEXT             = .so

PREFIX            = $(DIRSEP)usr$(DIRSEP)local
LUA_VERSION       = 5.1
LUA_DIR           = $(PREFIX)
LUA_BINDIR        = $(LUA_DIR)$(DIRSEP)bin
LUA_INCSUBDIR     = include
LUA_INCDIR        = $(LUA_DIR)$(DIRSEP)$(LUA_INCSUBDIR)
LUA_LIBSUBDIR     = lib
LUA_LIBDIR        = $(LUA_DIR)$(DIRSEP)$(LUA_LIBSUBDIR)
LUA_BASENAME      = lua
LUA               = $(LUA_BINDIR)$(DIRSEP)$(LUA_BASENAME)
INSTALL_CMOD      = $(LUA_LIBDIR)$(DIRSEP)lua$(DIRSEP)$(LUA_VERSION)

LUAFILEKEY_SRC    = lua-filekey.c
LUAFILEKEY_OBJ    = lua-filekey$(OBJEXT)

SRC               = $(LUAFILEKEY_SRC)
OBJ               = $(LUAFILEKEY_OBJ)

OUTNAME           = lua-filekey
OUT               = $(OUTNAME)$(SHEXT)

CC                = cc
CCONLY            = -c
CCFPIC            = -fPIC
CCDEBINFO         =
CCSTD             =
CCPEDANTIC        =
CCOPT             = -O2
CCWARN            = -Wall -Wextra
CFLAGS            = $(CCFPIC) $(CCDEBINFO) $(CCSTD) $(CCPEDANTIC) $(CCOPT) $(CCWARN)
CFLAGS_EXTRA      =
CCOUT             = -o $(__EMPTY)
CCINCLUDE         = -I
INCLUDES          = $(CCINCLUDE)$(LUA_INCDIR)

LD                = $(CC)
SHFLAGS           = -shared
LDFLAGS           = $(SHFLAGS)
LDFLAGS_EXTRA     =
LDOUT             = $(CCOUT)

RM                = rm
RMFLAGS           = -f

INSTALL           = install
INSTALL_PFLAG     = -p
INSTALL_DATAMOD   = -m 0644
INSTALL_EXEMOD    = -m 0755

MKDIR             = mkdir
MKDIRFLAGS        = -p

TESTFILE          = test-file.lua
TESTLINKFILE      = test-link.lua
TESTOUTPUT        = o.txt

all: lib

lib: $(OUT)

$(OUT): $(OBJ)
	$(LD) $(LDFLAGS) $(LDFLAGS_EXTRA) $(LDOUT)$(OUT) $(LUAFILEKEY_OBJ)

$(LUAFILEKEY_OBJ): $(LUAFILEKEY_SRC)
	$(CC) $(CCONLY) $(CFLAGS) $(CFLAGS_EXTRA) $(INCLUDES) $(CCOUT)$(LUAFILEKEY_OBJ) $(LUAFILEKEY_SRC)

create-install-dir:
	-$(MKDIR) $(MKDIRFLAGS) $(INSTALL_CMOD)

install: create-install-dir
	$(INSTALL) $(INSTALL_PFLAG) $(INSTALL_EXEMOD) $(OUT) $(INSTALL_CMOD)

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

