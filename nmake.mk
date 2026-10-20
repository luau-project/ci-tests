
__EMPTY      =
DIRSEP       = \$(__EMPTY)
MAIN_SRC     = main.c
MAIN_OBJ     = main.obj
OBJ          = $(MAIN_OBJ)
OUT          = .$(DIRSEP)app.exe

SystemDrive  = c:
WINDIR       = $(SystemDrive)$(DIRSEP)windows
System32     = $(WINDIR)$(DIRSEP)system32
SHELL        = $(System32)$(DIRSEP)cmd.exe
PROGRAMFILES = $(SystemDrive)$(DIRSEP)program files

WINAPI_LIBS  = crypt32.lib

PREFIX       = $(PROGRAMFILES)$(DIRSEP)openssl
MULTILIB     = lib
INCSUBDIR    = include
INCDIR       = $(PREFIX)$(DIRSEP)$(INCSUBDIR)
LIBDIR       = $(PREFIX)$(DIRSEP)$(MULTILIB)
SSL_LIB      = libssl.lib
CRYPTO_LIB   = libcrypto.lib

CC           = cl /nologo
CCONLY       = /c
CCOUT        = /Fo
INCLUDES     = "/I$(INCDIR)"
CFLAGS       = /MD /O2 /W3

LD           = link /nologo
LDOUT        = /OUT:
LIBS         = "/LIBPATH:$(LIBDIR)" $(SSL_LIB) $(CRYPTO_LIB) $(WINAPI_LIBS)

RM           = del
RMFLAGS      = /Q

all: application

application: $(OUT)

$(OUT): $(OBJ)
	$(LD) $(LDFLAGS) $(LDOUT)$(OUT) $(OBJ) $(LIBS)

$(MAIN_OBJ): $(MAIN_SRC)
	$(CC) $(CCONLY) $(CFLAGS) $(INCLUDES) $(CCOUT)$(MAIN_OBJ) $(MAIN_SRC)

test:
	$(OUT)

clean-$(MAIN_OBJ):
	-$(RM) $(RMFLAGS) $(MAIN_OBJ)

clean-obj: clean-$(MAIN_OBJ)

clean-out:
	-$(RM) $(RMFLAGS) $(OUT)

clean: clean-out clean-obj


