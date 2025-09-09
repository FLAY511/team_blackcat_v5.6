# 🕵️‍♂️ Team BlackCat v5.6 (SAFE Edition)

**Team BlackCat v5.4** adalah kumpulan **OSINT Tools** berbasis Bash untuk Termux/Linux.  
Dibuat untuk tujuan **edukasi, investigasi publik, bug bounty, dan penelitian keamanan**.  
Versi ini adalah **SAFE edition** → tidak mengandung exploit/deface, hanya informasi publik.

---

## ✨ Fitur Utama

### 🔍 OSINT
1. **OSINT Optimal (Domain)**  
   - WHOIS Lookup  
   - DNS Record Lookup  
   - Resolve IP + GeoIP Lookup  
   - Subdomain Finder (crt.sh)  
   - Port Scan (hackertarget API)  
   - HTTP Headers Grabber  
   - CMS Detector (WhatCMS demo)  

2. **Username Checker**  
   - Cek username di puluhan platform populer (IG, Twitter/X, GitHub, Reddit, FB, TikTok, LinkedIn, dsb.)

3. **Phone Lookup**  
   - Cari informasi nomor telepon di beberapa platform (WA, Telegram, Truecaller, Facebook, Google, dll.)  
   - **Deep Scan (50+ situs)**  

4. **Email Lookup (50+ situs)** 🆕  
   - Pencarian email di lebih dari 50 sumber:  
     - Search engine (Google, Bing, Yahoo, Yandex, DuckDuckGo)  
     - Leak database (LeakCheck, HaveIBeenPwned, Dehashed, BreachDirectory, Scylla, Intelx.io)  
     - Social media (Facebook, Twitter, LinkedIn, Instagram, TikTok, YouTube, Reddit, dll.)  
     - Paste sites (Pastebin, Ghostbin, PublicWWW)  
     - Cyber intel (Censys, Shodan)  
     - People search (ZoomInfo, Apollo.io, RocketReach, Pipl, Whitepages, Spokeo, dsb.)  
     - Email tools (Hunter.io, EmailRep, Clearbit, EmailSherlock, EmailHippo, dll.)  

### 🛠 Utilities
- Cek Cuaca (wttr.in)  
- Kalkulator (bc)  
- Nama Hacker Random  
- Chat AI (link ke ChatGPT)  
- Base64 Encode/Decode  
- Hash Generator (MD5, SHA256)  
- Password Generator  
- IP Publik  
- Speedtest  
- Kalender  

### 🌐 Edukasi
- **Dark Web Info** → link edukasi (The Hidden Wiki)  
- **JSO Helper** → buat file `.jso` dari HTML  

---

## 📥 Cara Install

```bash
pkg update && pkg upgrade -y
pkg install git curl python whois dnsutils openssl bc -y
git clone https://github.com/FLAY511/team_blackcat_v5.4.git
cd team_blackcat_v5.4
chmod +x team_blackcat_v5.4.sh
```

---

## 🚀 Cara Menjalankan

```bash
./team_blackcat_v5.4.sh
```

Akan muncul menu utama:
```
[1] OSINT - Domain
[2] Username Checker
[3] Phone Lookup
[4] JSO Helper
[5] Utilities
[6] Dark Web Info
[7] About
[8] Email Lookup (50+)
```

---

## ⚠️ Disclaimer
- Tools ini dibuat hanya untuk **edukasi, bug bounty, dan investigasi legal**.  
- **Dilarang keras** digunakan untuk aktivitas ilegal / merugikan orang lain.  
- Gunakan secara **bijak dan bertanggung jawab**.  

---

## 👨‍💻 Author
**CYBER FLAY**  
Versi: `v5.6 (SAFE Edition)`
