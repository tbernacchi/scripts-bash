#!/bin/sh

# Exportando variaves para usar o proxy

export RSYNC_PROXY=proxy.tabajara.intranet:3130
export http_proxy=http://proxy.tabajara.intranet:3130
export https_proxy=http://proxy.tabajara.intranet:3130

# Comandos do reposync que inclusive baixam o comps.xml

###
rm /etc/yum.repos.d/centos-tabajara.repo
rm /etc/yum.repos.d/pacotes-dev-tabajara.repo
cp /var/sources/* /etc/yum.repos.d/

reposync --gpgcheck --plugins --repoid=base --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=centosplus --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=extras --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=updates --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=centos-gluster41 --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=epel --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=azure-cli --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=docker-ce --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
reposync --gpgcheck --plugins --repoid=mongo --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
#reposync --allow-path-traversal --gpgcheck --plugins --repoid=kubernetes --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/
#reposync --gpgcheck --plugins --repoid=rundeck-release-binary --newest-only --delete --downloadcomps --download-metadata --download_path=/var/www/html/repos/

cp -pr /repo/pool/* /var/www/html/repos/kubernetes/
chmod 755 /repo/repo/kubernetes -R
chown -R root:deploy /repo/repos/kubernetes

# Criando os repositorios internos

createrepo /var/www/html/repos/base/ -g comps.xml
createrepo /var/www/html/repos/centosplus/
createrepo /var/www/html/repos/extras/
createrepo /var/www/html/repos/updates/
createrepo /var/www/html/repos/epel/
createrepo /var/www/html/repos/third-party
createrepo /var/www/html/repos/centos-gluster41
createrepo /var/www/html/repos/azure-cli
createrepo /var/www/html/repos/docker-ce
createrepo /var/www/html/repos/mongo
#createrepo /var/www/html/repos/kubernetes
#createrepo /var/www/html/repos/rundeck-release-binary

rm /etc/yum.repos.d/*
