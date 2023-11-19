# Node.JS
## Install
>`sudo update-crypto-policies --set FUTURE`\
> `sudo update-crypto-policies --set LEGACY`\
> `sudo update-crypto-policies --set DEFAULT`\
> `sudo update-crypto-policies --set DEFAULT:SHA1`
```bash
VERSION=21

sudo dnf install https://rpm.nodesource.com/pub_${VERSION}.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf module disable nodejs -y

# temporary disable GPG key check
sudo sed -r '/gpgcheck/s/1/0/' -i /etc/yum.repos.d/nodesource-nodistro.repo

sudo dnf upgrade --refresh -y

sudo dnf install nodejs yarn -y # nsolid

sudo dnf check-update
```