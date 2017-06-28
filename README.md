# WiFi-autopwner
WiFi-autopwner: script to automate searching and auditing Wi-Fi networks with weak security

# WiFi-autopwner performs:
- searching Open Wi-Fi network
- searching and cracking Wi-Fi network with WEP encryption
- searching WPS enabled Wi-Fi networks and Pixie Dust Attack against them
- collecting handshakes from every Wi-Fi network in range
- revealling WPA-PSK password from known WPS PIN
- online brute-force WPA-PSK password

You can use any of this action just typing the number of item in menu, or start them all. They all have timeouts so you’ll never be stuck.

# Fix for Reaver Errors: WARNING: Failed to associate with

WiFi-autopwner has built-in fix for permanent error “Reaver Errors: WARNING: Failed to associate with” (as described <a href="http://miloserdov.org/?p=29">here</a>), so you can try this method if your Wi-Fi adapter is not able to perform Bruteforce PIN attacks.
Bruteforce PIN attack does not have timeout and it is not included in automate audit.

# Dependencies
- Aircrack suite
- Reaver
- Pixiewps
- Pyrit
- zizzania
- iw
- WPA supplicant

# Installation WiFi-autopwner
git clone https://github.com/Mi-Al/WiFi-autopwner.git

# Using WiFi-autopwner
sudo bash wifi-autopwner.sh
