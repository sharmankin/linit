# lnav
## Install
```bash
dnf remove lnav -yq
dnf install {libcurl,pcre2,sqlite,ncurses,readline,zlib,bzip2,libarchive,wireshark}-devel -yq
src_dir="/opt/lnav"
git clone https://github.com/tstack/lnav.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr
make -j $(nproc)
make install
cd -
lnav -V
```