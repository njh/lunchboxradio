#!/bin/sh

cd $1 && \
exec ./configure \
  --prefix=/usr/ \
  --enable-shared \
  --disable-a52 \
  --disable-aa \
  --disable-arts \
  --disable-atmo \
  --disable-audioscrobbler \
  --disable-avcodec \
  --disable-avformat \
  --disable-bda \
  --disable-bonjour \
  --disable-caca \
  --disable-cdda \
  --disable-cddax \
  --disable-cmml \
  --disable-cyberlink \
  --disable-daap \
  --disable-dbus \
  --disable-dbus-control \
  --disable-dc1394 \
  --disable-dca \
  --disable-dirac \
  --disable-dshow \
  --disable-dta \
  --disable-dv \
  --disable-dvb \
  --disable-dvbpsi \
  --disable-dvdnav \
  --disable-dvdread \
  --disable-esd \
  --disable-fb \
  --disable-fluidsynth \
  --disable-freetype \
  --disable-fribidi \
  --disable-glide \
  --disable-glx \
  --disable-gme \
  --disable-gnomevfs \
  --disable-goom \
  --disable-growl \
  --disable-hal \
  --disable-hd1000v \
  --disable-httpd \
  --disable-imgresample \
  --disable-jack \
  --disable-kate \
  --disable-libcddb \
  --disable-libcdio \
  --disable-libmpeg2 \
  --disable-libproxy \
  --disable-libtar \
  --disable-lua \
  --disable-mad \
  --disable-mkv \
  --disable-mod \
  --disable-musicbrainz \
  --disable-ncurses \
  --disable-nls \
  --disable-notify \
  --disable-opencv \
  --disable-opengl \
  --disable-opie \
  --disable-oss \
  --disable-pda \
  --disable-png \
  --disable-portaudio \
  --disable-postproc \
  --disable-pulse \
  --disable-pvr \
  --disable-qt4 \
  --disable-qte \
  --disable-quicktime \
  --disable-remoteosd \
  --disable-schroedinger \
  --disable-screen \
  --disable-sdl \
  --disable-sdl-image \
  --disable-shout \
  --disable-skins2 \
  --disable-smb \
  --disable-sout \
  --disable-switcher \
  --disable-swscale \
  --disable-telx \
  --disable-telepathy \
  --disable-twolame \
  --disable-update-check \
  --disable-upnp \
  --disable-v4l \
  --disable-v4l2 \
  --disable-vcd \
  --disable-vcdx \
  --disable-visual \
  --disable-vlm \
  --disable-wxwidgets \
  --disable-x11 \
  --disable-x264 \
  --disable-xinerama \
  --disable-xvideo \
  --disable-zvbi \
  --enable-alsa \
  --enable-faad \
  --enable-flac \
  --enable-id3tag \
  --enable-libxml2 \
  --enable-mad \
  --enable-mmx \
  --enable-mpc \
  --enable-ogg \
  --enable-osc \
  --enable-real \
  --enable-realrtsp \
  --enable-speex \
  --enable-taglib \
  --enable-vorbis