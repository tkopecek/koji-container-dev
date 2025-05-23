FROM registry.fedoraproject.org/fedora:42

RUN \
  dnf install -y --nodocs --setopt=install_weak_deps=False \
    dnf-plugins-core \
    git \
    httpd \
    mc \
    mock \
    mod_auth_gssapi \
    mod_ssl \
    postgresql-server \
    python3-cheetah \
    python3-dateutil \
    python3-defusedxml \
    python3-flake8 \
    python3-librepo \
    python3-mod_wsgi \
    python3-multilib \
    python3-psycopg2 \
    python3-pyOpenSSL \
    python3-qpid-proton \
    python3-requests \
    python3-requests-gssapi \
    python3-rpm && dnf clean all

# builder
RUN mkdir /etc/mock/koji && \
    adduser kojibuilder -G mock -s /usr/sbin/nologin && \
    echo "config_opts['use_bootstrap'] = False" >> /etc/mock/site-defaults.cfg

# hub + web
RUN rm -f /etc/httpd/conf/httpd.conf ;\
rm -f /etc/httpd/conf.d/ssl.conf ;\
ln -s /opt/cfg/certs /etc/pki/koji ;\
ln -s /opt/cfg/koji-hub /etc/koji-hub ;\
ln -s /opt/cfg/httpd.conf /etc/httpd/conf/httpd.conf ;\
ln -s /opt/cfg/kojihub.conf /etc/httpd/conf.d/kojihub.conf ;\
ln -s /opt/cfg/kojiweb.conf /etc/httpd/conf.d/kojiweb.conf ;\
ln -s /opt/cfg/ssl.conf /etc/httpd/conf.d/ssl.conf ;\
ln -s /opt/cfg/servername.conf /etc/httpd/conf.d/servername.conf ;\
ln -s /opt/cfg/kojiweb /etc/kojiweb ;\
mkdir /usr/share/koji-web ;\
ln -s /opt/koji/www/kojiweb /usr/share/koji-web/scripts ;\
ln -s /opt/koji/www/lib /usr/share/koji-web/lib ;\
ln -s /opt/koji/www/static /usr/share/koji-web/static ;\
ln -s /opt/koji/koji /usr/lib/python3.13/site-packages/koji ;\
ln -s /opt/koji/cli/koji_cli /usr/lib/python3.13/site-packages/koji_cli ;\
ln -s /opt/koji/kojihub /usr/lib/python3.13/site-packages/kojihub ;\
ln -s /opt/koji/kojihub/app /usr/share/koji-hub ;\
ln -s /opt/koji/plugins/hub /usr/lib/koji-hub-plugins

# copy additional CAs if needed
COPY ca-certs/* /etc/pki/ca-trust/source/anchors
RUN update-ca-trust
