PKG_CONFIG?=pkg-config
WAYLAND_PROTOCOLS!=$(PKG_CONFIG) --variable=pkgdatadir wayland-protocols
WAYLAND_SCANNER!=$(PKG_CONFIG) --variable=wayland_scanner wayland-scanner

CC=gcc
PKGS="wlroots-0.18" wayland-server xkbcommon
CFLAGS_PKG_CONFIG!=$(PKG_CONFIG) --cflags $(PKGS)
CFLAGS+=$(CFLAGS_PKG_CONFIG)
LIBS!=$(PKG_CONFIG) --libs $(PKGS)

all: tnwlserver

# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header $(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

build/main.o: src/*.c xdg-shell-protocol.h
	$(CC) -c $< -g -Werror $(CFLAGS) -I. -DWLR_USE_UNSTABLE -o $@
tnwlserver: build/*.o
	$(CC) $^ $> -g -Werror $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@

	#clean:
	#rm -f tinywl tinywl.o xdg-shell-protocol.h

LIBS_CLIENT=-lwayland-client -lrt
client: wayland-client.c xdg-shell-protocol.c pool.c
	$(CC) $^ -o client $(CFLAGS) $(LIBS_CLIENT)

.PHONY: all clean
