#!/bin/bash
set -e
 
echo "----------------------------------------------------"
echo ">>> [1/3] APLINKOS TIKRINIMAS"
echo "----------------------------------------------------"
# Sinchronizuojame sistemos laiką, kad nebūtų klaidų su apt
sudo timedatectl set-ntp true 2>/dev/null || true
# Sinchronizuojame hw laikrodį su sistemos laiku
sudo hwclock --hctosys 2>/dev/null || true
 
# Pilnas įrankių diegimas
if ! command -v onevm &> /dev/null; then
    echo ">>>Diegiama OpenNebula..."
 
    # Ištriname sena konfiguracija jei ji egzistuoja
    sudo rm -f /etc/apt/sources.list.d/opennebula.list
 
    # Atnaujiname ir įdiegiame reikiamas programas
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y gnupg
	wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
    echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | sudo tee /etc/apt/sources.list.d/opennebula.list
    sudo apt update
    sudo apt-get install opennebula-tools -y
fi
# -------------------------------------------
 
if [ ! -f ~/.ssh/id_rsa ]; then
    echo ">>> Generuojamas naujas raktas..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
fi
 
echo "----------------------------------------------------"
echo ">>> [2/3] PRISIJUNGIMO DUOMENYS"
echo "----------------------------------------------------"
read -p "Username: " CUSER
read -s -p "Password: " CPASS
echo ""
ENDPOINT="https://grid5.mif.vu.lt/cloud3/RPC2"
 
echo "----------------------------------------------------"
echo ">>> [3/3] KURIAMA MAŠINA"
echo "----------------------------------------------------"
 
# Skaitome SSH raktą ir escapiname kabutes
PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
# Pakeičiame kabutes į escapintas kabutes, kad tiktų komandinei eilutei
PUB_KEY_ESCAPED=$(echo "$PUB_KEY" | sed 's/"/\\"/g')
 
echo ">>> SSH raktas bus įkeliamas"
 
OUTPUT=$(onetemplate instantiate "2273" \
    --user "$CUSER" \
    --password "$CPASS" \
    --endpoint "$ENDPOINT" \
    --name "ansible-vm" \
    --memory 2048 --cpu 1 --vcpu 1 \
    --nic "VNET2:NETWORK_UNAME=oneadmin" \
    --context "SSH_PUBLIC_KEY=\"$PUB_KEY_ESCAPED\",NETWORK=YES" 2>&1) || true
 
# Tikriname, ar komandos išvestyje yra tekstas VM ID dėl sukurimo
if [[ "$OUTPUT" == *"VM ID:"* ]]; then
    # Iškerpame VM ID iš išvesties (trečias žodis)
    VM_ID=$(echo "$OUTPUT" | cut -d ' ' -f 3)
    echo ">>> VM sukurta. ID: $VM_ID"
 
    echo ">>> Laukiama IP..."
    for i in {1..40}; do
        sleep 3
	# Gauname informaciją apie VM iš OpenNebula
        INFO=$(onevm show "$VM_ID" --user "$CUSER" --password "$CPASS" --endpoint "$ENDPOINT")
 
        # Bandome surasti IP adresą naudodami regex (ieškome PRIVATE_IP, ETH0_IP.)
        IP=$(echo "$INFO" | grep -oP '(PRIVATE_IP|PUBLIC_IP|ETH0_IP|IP)\s*=\s*"\K[^"]+' | head -1)
 
        if [ -z "$IP" ]; then
             IP=$(echo "$INFO" | grep -m1 "IP=" | cut -d'=' -f2 | tr -d '" ')
        fi
	# Tas pats tik paprastesnis būdas jei nesuveiktų
        if [ -n "$IP" ]; then
            echo ""
            echo "================================================================"
            echo ">>> GAUTAS IP: $IP"
            echo ">>> Palaukite 30s ir paleiskite: ./Deploy.sh"
            echo "================================================================"
            exit 0
        fi
        echo -n "."
    done
else
    echo ">>> KLAIDA! Mašina nesusikūrė."
    echo ">>> OPENNEBULA:"
    echo "$OUTPUT"
    exit 1
fi
