#!/bin/bash
# nightly_build.sh -- build xterm from git

cd "$(dirname "$0")" || { echo "$0: Error: Initial cd $(dirname "$0") failed" ; exit 1 ; }

rm -f nightly_build.log

set -o pipefail

do_clean=no
if [ "$1" = clean ] || [ "$1" = "-clean" ]
then
  do_clean=yes
  shift
fi

# handle clean here to avoid removing the log

if [ "$1" = gitclean ] || [ "$1" = "-gitclean" ]
then
  echo "Cleaning with git..."
  git clean -dfx
  shift
fi

if [ "$1" = distclean ] || [ "$1" = "-distclean" ]
then
  if [ -f Makefile ]
  then
    echo "Cleaning with distclean..."
    make distclean
  else
    echo "$0: Warning: no Makefile, not cleaning with distclean"
  fi
  shift
fi

(
  echo "Starting nightly_build $* at $(date) in $(pwd)"
  if [ ! -f Makefile ]
  then
    # Configure with options similar to xterm.spec
    x11_app_defaults_dir=$(pkg-config --variable appdefaultdir xt)
    if [ -z "$x11_app_defaults_dir" ] ; then x11_app_defaults_dir=/usr/share/X11/app-defaults ; fi
    data_dir=/usr/share
    eval "$(rpm --eval '%set_build_flags')"
    CFLAGS=" $CFLAGS " CFLAGS=${CFLAGS/ -g / }
    ./configure \
	--prefix=/usr \
	--enable-meta-sends-esc \
	--disable-backarrow-key \
	--enable-exec-xterm \
	--enable-warnings \
	--with-app-defaults="$x11_app_defaults_dir" \
	--with-icon-theme=hicolor \
	--with-icondir="$data_dir/icons" \
	--with-utempter \
	--with-tty-group=tty \
	--disable-full-tgetent \
	--with-pcre2 \
	--enable-readline-mouse \
	"$@"
  fi
  if [ -f Makefile ]
  then
    if [ "$do_clean" = yes ]
    then
      make clean
    fi
    np=$(nproc)
    if [ -z "$np" ] ; then np=1 ; fi
    if make -j "$np"
    then
      if [ ! -x xterm ]
      then
        echo "$0: Error: make did not produce an xterm"
        exit 1
      fi
    else
      echo "$0: Error: make failed"
      exit 1
    fi
  else
    echo "$0: Error: Configure did not produce a Makefile"
    exit 1
  fi
) 2>&1 | tee nightly_build.log
