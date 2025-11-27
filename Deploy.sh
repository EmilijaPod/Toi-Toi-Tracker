#!/bin/bash
# Skriptas nusiunčia failus į sukurtą mašiną ir paleidžia instaliaciją.

read -p "Įveskite ansible-vm IP adresą: " IP

if [ -z "$IP" ]; then echo "KLAIDA: Nėra IP"; exit 1; fi

# Jungiamės kaip ROOT (nes ten įdėtas raktas)
TARGET_USER="root"

echo ">>> [1/3] Laukiama SSH..."

# Patikriname ar VM pasiekiama
echo ">>> Tikrinamas PING į $IP..."

# Siunčiame 3 ping paketus. Jei nepavyksta, išsiunčiame klaidą
if ! ping -c 3 -W 2 $IP; then
    echo ""
    echo ">>> KLAIDA: PING nepavyko!"
    echo ">>> Informacija:"
    echo "------------------------------------------------"
    echo "Jūsų IP:"
    ip -4 addr show | grep inet
    echo "------------------------------------------------"
    echo "Maršrutai:"
    ip route
    exit 1
fi
echo ">>> VM pasiekiama tinkle."

# Ciklas: bando prisijungti kas 3s
echo ">>> Laukiama SSH rakto..."
for i in {1..60}; do
    # -o StrictHostKeyChecking=no leidžia išvengti yes/no klausimo
    # -o ConnectTimeout=5 nustato 5s pertrauką prisijungimui
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $TARGET_USER@$IP "echo 'SSH ready'" &>/dev/null; then
        echo ""
        echo ">>> Prisijungta!"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

echo ">>> [2/3] Siunčiami failai..."
# Siunčiame visus 3 aplankus į /root/
scp -o StrictHostKeyChecking=no -r Ansible Web Misc $TARGET_USER@$IP:/root/

if [ $? -ne 0 ]; then
    echo ">>> SCP nepavyko."
    exit 1
fi

echo ">>> [3/3] Paleidžiame main.sh..."
# Prisijungiame per SSH ir paleidžiame main.sh skriptą pačioje ansible mašinoje
ssh -t -o StrictHostKeyChecking=no $TARGET_USER@$IP "chmod +x /root/Ansible/main.sh && /root/Ansible/main.sh"

echo ">>> Viskas baigta."
