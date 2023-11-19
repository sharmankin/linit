# htop
## Install
```bash
dnf remove -qy htop
dnf install {hwloc,libcap,libnl3,ncurses}-devel -yq
src_dir="/opt/htop"
git clone https://github.com/htop-dev/htop.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr --enable-unicode --enable-hwloc --enable-capabilities
make -j $(nproc)
make install
cd -
htop -V
```