# Instrukcija paleidimui

---


1.  **Išarchyvuokite** gautą failą:

    ```bash
    unzip HelloWorld.zip
    ```

2.  **Pereikite** į projekto katalogą:

    ```bash
    cd ToitoiTracker
    ```

3.  **Teisės skripto paleidimui**:

    ```bash
    chmod +x CreateAnsible.sh Deploy.sh
    chmod +x Ansible/main.sh
    ```

---

## Paleidimas

    ```bash
    ./CreateAnsible.sh
    ```

    > Palaukite **15–30 sekundžių**, kol virtuali mašina pilnai įsijungs.

2.  **Paleiskite diegimo skriptą**:

    ```bash
    ./Deploy.sh
    ```

    * **Kai pamatysite**: "įvesti VAULT slaptažodį"
    * **Įveskite**: `test`

---

## Prisijungimas prie client-vm


1.  **Prisijunkite prie OpenNebulos** ir įjunkite **client-vm VNC**

2.  **Prisijungimas prie `client-vm`**:
    * **Username**: `admin`
    * **Password**: `test`

3.  **Paleiskite naršyklę (Firefox)**:
    * Paspauskite **Alt + F2**.
    * Įrašykite `Firefox` ir paspauskite **Enter**.
    * Palaukite, kol naršyklė įsijungs. Naudojantis **Tab** naršymui (QEMU ir pelės problemos :c ) 

4.  **Įveskite adresą** naršyklėje:

    ```
    http://webserverIp
    ```

---
