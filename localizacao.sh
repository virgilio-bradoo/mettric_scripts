#!/bin/bash
ODOO_HOME=$(dirname $(dirname $(find / -name "odoo-bin" 2>/dev/null)))
echo $ODOO_HOME
mkdir -p $ODOO_HOME/custom
git clone https://github.com/bradootech/trustcode-addons $ODOO_HOME/custom/trustcode-addons
git clone https://github.com/BradooTech/odoo-brasil $ODOO_HOME/custom/odoo-brasil
git clone https://github.com/BradooDev/mettric $ODOO_HOME/custom/mettric

chown -R odoo:odoo /odoo/custom
