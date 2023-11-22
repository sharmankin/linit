# htop
## Install
```bash
src_dir="/opt/htop"

rm -rf "${src_dir}"
case "$(grep -RPho '(?<=\bNAME=").*?(?=")' -R /etc/*-release)" in
  "Ubuntu")
        apt purge htop -y --autoremove
        rm -rf "$(which htop)"
        apt install libncursesw5-dev {autotools,libhwloc,libcap}-dev autoconf automake build-essential -y
        ;;
  "Rocky Linux")
      dnf remove -qy htop 
      dnf install {hwloc,libcap,libnl3,ncurses}-devel -yq 
      ;;
esac

git clone https://github.com/htop-dev/htop.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr --enable-unicode --enable-hwloc --enable-capabilities
make -j $(nproc)
make install
cd -
htop -V
```