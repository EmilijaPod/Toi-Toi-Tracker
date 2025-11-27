#!/bin/bash
set -e

echo ">>> [1/6] Instaliuojami reikiami failai..."
# Išjungti interaktyvius klausimus instaliacijos metu
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq python3-pip sshpass git jq gnupg wget lsb-release

# OpenNebula
wget -q -O- https://downloads.opennebula.org/repo/repo.key | apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | tee /etc/apt/sources.list.d/opennebula.list
apt-get update -qq
apt-get install -y -qq opennebula-tools

# Ansible
python3 -m pip install --break-system-packages ansible pyone jmespath passlib
ansible-galaxy collection install community.general community.docker community.postgresql --force

# Tikriname ar egzistuoja ssh raktas, jei ne, kuriamas naujas.
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" -q
fi

# Failų paskirstymas pagal norimą struktūrą
echo ">>> [2/6] Failų paruošimas..."
mkdir -p /root/Ansible/roles/webserver/files/html
cp -r /root/Web/* /root/Ansible/roles/webserver/files/html/ 2>/dev/null || true
cp /root/Misc/*.png /root/Ansible/roles/webserver/files/html/ 2>/dev/null || true
cp /root/Misc/*.jpg /root/Ansible/roles/webserver/files/html/ 2>/dev/null || true
cp /root/Misc/nginx.conf /root/Ansible/roles/webserver/files/ 2>/dev/null || true
cp /root/Misc/lamp_build.sh /root/Ansible/roles/webserver/files/ 2>/dev/null || true
mkdir -p /root/Ansible/roles/database/files
cp /root/Misc/data.sql /root/Ansible/roles/database/files/ 2>/dev/null || true
mkdir -p /root/Ansible/roles/client/files
cp /root/Misc/ClientDocker /root/Ansible/roles/client/files/ 2>/dev/null || true
cd /root/Ansible


echo "========================================================"
echo ">>> [3/6] Kuriamos mašinos (Per Ansible)"
echo "========================================================"

# Paprašome Vault slaptažodžio
echo "DĖMESIO: Įveskite VAULT slaptažodį:"
read -s VAULT_PASS_INPUT
echo "$VAULT_PASS_INPUT" > .vault_pass_tmp
echo ""

# 1. DB VM
echo ">>> [DATABASE] Prašome įvesti DB kūrėjo prisijungimus:"
read -p "DB User: " DB_USER
read -s -p "DB Pass: " DB_PASS
echo ""
echo ">>> Leidžiame Ansible (create_db)..."
# Paleidžiame Ansible playbook tik su create_db tag'u
ansible-playbook site.yml --tags create_db --vault-password-file .vault_pass_tmp \
    -e "db_user_one=$DB_USER db_pass_one=$DB_PASS"

# 2. Web VM
echo ""
echo ">>> [WEBSERVER] Prašome įvesti Web kūrėjo prisijungimus:"
read -p "Web User: " WEB_USER
read -s -p "Web Pass: " WEB_PASS
echo ""
echo ">>> Leidžiame Ansible (create_web)..."
ansible-playbook site.yml --tags create_web --vault-password-file .vault_pass_tmp \
    -e "web_user_one=$WEB_USER web_pass_one=$WEB_PASS"

# 3. Client VM
echo ""
echo ">>> [CLIENT] Prašome įvesti Client kūrėjo prisijungimus:"
read -p "Client User: " CLI_USER
read -s -p "Client Pass: " CLI_PASS
echo ""
echo ">>> Leidžiame Ansible (create_client)..."
ansible-playbook site.yml --tags create_client --vault-password-file .vault_pass_tmp \
    -e "client_user_one=$CLI_USER client_pass_one=$CLI_PASS"


# 4. IP GAVIMAS
echo ""
echo ">>> [4/6] Surenkami IP adresai (Inventory generavimui)..."
# OpenNebula API nustatymas
export ONE_XMLRPC="https://grid5.mif.vu.lt/cloud3/RPC2"

# Funkcija gauti IP pagal VM vardą ir kūrėją
get_ip_by_name() {
    local NAME=$1
    local USER=$2
    local PASS=$3

    # Randame ID
    local ID=$(onevm list --user "$USER" --password "$PASS" --endpoint "$ONE_XMLRPC" --csv | grep "$NAME" | awk -F',' '{print $1}' | head -1)

    if [ -z "$ID" ]; then echo "ERROR_NO_ID"; return; fi

    # Laukiamo IP
    for i in {1..20}; do
        local INFO=$(onevm show "$ID" --user "$USER" --password "$PASS" --endpoint "$ONE_XMLRPC")
        # Ieškome PRIVATE_IP (nes vidinis tinklas)
        local IP=$(echo "$INFO" | grep -oP '(PRIVATE_IP|ETH0_IP|IP)\s*=\s*"\K[^"]+' | head -1)
        if [ -n "$IP" ]; then echo "$IP"; return; fi
        sleep 3
    done
    echo "ERROR_TIMEOUT"
}

echo ">>> Ieškoma db-vm..."
DB_IP=$(get_ip_by_name "db-vm" "$DB_USER" "$DB_PASS")
echo ">>> DB IP: $DB_IP"

echo ">>> Ieškoma web-vm..."
WEB_IP=$(get_ip_by_name "web-vm" "$WEB_USER" "$WEB_PASS")
echo ">>> Web IP: $WEB_IP"

echo ">>> Ieškoma client-vm..."
CLI_IP=$(get_ip_by_name "client-vm" "$CLI_USER" "$CLI_PASS")
echo ">>> Client IP: $CLI_IP"

# 5. INVENTORY
echo ">>> [5/6] Generuojamas inventory.ini..."
cat > inventory.ini <<EOF
[db_servers]
$DB_IP ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[web_servers]
$WEB_IP ansible_ssh_common_args='-o StrictHostKeyChecking=no' db_ip=$DB_IP

[client_vms]
$CLI_IP ansible_ssh_common_args='-o StrictHostKeyChecking=no' web_ip=$WEB_IP
EOF

# 6. KONFIGŪRACIJA
echo ">>> [6/6] Laukiama SSH ir pradedama konfigūracija..."
echo ">>> Laukiama 1min..."
sleep 60

echo ">>> Konfigūracija..."
ansible-playbook -i inventory.ini site.yml --skip-tags provision --vault-password-file .vault_pass_tmp

# Ištriname slaptažodį
rm .vault_pass_tmp

echo ">>> Baigta!"
