#!/bin/bash

#Parameters to APT
sh -c 'echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf'
sh -c 'echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf'

# Update Server
set -x; \
    apt update \
    && apt full-upgrade -y \
    && cat ubuntu/utilitarios | apt-get install -y 
locale-gen pt_BR.UTF-8

# Install Dependencies SO
set -x; \
    cat ubuntu/apt | xargs  apt install -y

pip install --upgrade pip
pip install --upgrade setuptools
cat ubuntu/pip | xargs pip install

# Install PostgreSQL Server

if [ $INSTALL_DB == "Sim" ]; then
set -x; \
    apt-get install postgresql -y
su postgres -c "createuser -s odoo" 2> /dev/null || true
su postgres -- psql -c "ALTER USER postgres WITH PASSWORD '123';"
su postgres -- psql -c "DROP ROLE odoo;"
su postgres -- psql -c "CREATE ROLE odoo LOGIN ENCRYPTED PASSWORD 'md5f7b7bca97b76afe46de6631ff9f7175c' NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION"
sed -i s/"listen_addresses = 'localhost'"/"listen_addresses = ''"/g /etc/postgresql/9.5/main/postgresql.conf
sed -i s/"local   all             all                                     ident"/"local   all             all                                     trust"/g /etc/postgresql/9.5/main/pg_hba.conf
sed -i s/"32            ident"/"32            md5"/g /etc/postgresql/9.5/main/pg_hba.conf
fi

# Criando usuario odoo no SO
adduser --system --quiet --shell=/bin/bash --home=/odoo --gecos 'ODOO' --group odoo
#The user should also be added to the 'ers group.
adduser odoo 

# Criando diretorio para arquivos de log
mkdir /var/log/odoo
chown odoo:odoo /var/log/odoo

# Install ODOO
git clone -b 10.0 https://github.com/odoo/odoo /odoo/odoo-server --depth 1

#Alterando a permissão da pasta do Odoo
chown -R odoo:odoo /odoo/

# Config File Odoo
#Adiciona o odoo-server.conf
cat <<EOF > /etc/odoo-server.conf
[options]
; This is the password that allows database operations:
; admin_passwd = admin
db_host = False
db_port = False
db_user = odoo
db_password = False
addons_path = /odoo/odoo-server/addons
log_db = False
log_db_level = warning
log_handler = :INFO
log_level = info
logfile = /var/log/odoo/odoo-server.log
xmlrpc_port = 8069
EOF
chown odoo:odoo /etc/odoo-server.conf

# Adding ODOO as a deamon (initscript)
cp ubuntu/odoo-server /etc/init.d/
chmod 755 /etc/init.d/odoo-server
chown root: /etc/init.d/odoo-server
