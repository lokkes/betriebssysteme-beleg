# Betriebssysteme I – Beleg BS1

## Script: `s85511.sh`

### Description
This Bash script retrieves the HTTPS certificate of a given host or IP address, or a list of hosts/IPs from a file, and calculates the remaining validity of the certificate in **days, hours, and minutes**.  
The script optionally accepts a reference date to calculate remaining validity as of that date. If no date is provided, the current date is used.

---

### Usage

```bash
./s85511.sh <Rechnername/IP-Adress> [Datum: TT-MM-JJJJ]

