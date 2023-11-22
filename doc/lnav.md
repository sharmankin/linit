# lnav
## Install
```bash
src_dir="/opt/lnav"

rm -rf "${src_dir}"

case "$(grep -RPho '(?<=\bNAME=").*?(?=")' -R /etc/*-release)" in
  "Ubuntu")
        sudo apt purge lnav --autoremove
        rm -f "$(which lnav 2>/dev/null)"
        sudo apt install {libncurses,libreadline,libsqlite3,libcurlpp,libpcre2,libghc-curl}-dev -y
        ;;
  "Rocky Linux")
        dnf remove lnav -yq
        dnf install {libcurl,pcre2,sqlite,ncurses,readline,zlib,bzip2,libarchive,wireshark}-devel -yq
      ;;
esac

git clone https://github.com/tstack/lnav.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr
make -j $(nproc)
make install
cd -
lnav -V
```