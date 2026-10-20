
__EMPTY      =
DIRSEP       = \$(__EMPTY)
MAIN_SRC     = main.c
MAIN_OBJ     = main.o
OBJ          = $(MAIN_OBJ)
OUT          = .$(DIRSEP)app.exe

SystemDrive  = c:
WINDIR       = $(SystemDrive)$(DIRSEP)windows
System32     = $(WINDIR)$(DIRSEP)system32
SHELL        = $(System32)$(DIRSEP)cmd.exe
PROGRAMFILES = $(SystemDrive)$(DIRSEP)program files

WINAPI_LIBS  = -lcrypt32

PREFIX       = $(PROGRAMFILES)$(DIRSEP)openssl
MULTILIB     = lib
INCSUBDIR    = include
INCDIR       = $(PREFIX)$(DIRSEP)$(INCSUBDIR)
LIBDIR       = $(PREFIX)$(DIRSEP)$(MULTILIB)
SSL_LIB      = -lssl
CRYPTO_LIB   = -lcrypto

CC           = cc
CCONLY       = -c
CCOUT        = -o $(__EMPTY)
INCLUDES     = "-I$(INCDIR)"
CFLAGS       = -O2 -Wall -Wextra

LD           = $(CC)
LDOUT        = $(CCOUT)
LIBS         = "-L$(LIBDIR)" $(SSL_LIB) $(CRYPTO_LIB) $(WINAPI_LIBS)

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


