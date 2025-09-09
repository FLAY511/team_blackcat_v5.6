#!/usr/bin/env bash
# CYBER FLAY v5.6 (SAFE) — Full features package (OSINT optimal, username check, phone lookup, JSO helper, utilities)
# SAFE edition: excludes defacement/exploit automation. Use only for legal/authorized testing & education.

set -euo pipefail
IFS=$'\n\t'

# Colors
RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'
BLU='\033[1;34m'; CYN='\033[1;36m'; MAG='\033[1;35m'; RST='\033[0m'

# Helper: detect command
has(){ command -v "$1" >/dev/null 2>&1; }

# Banner (seram hacker depan laptop)
banner(){
  clear
  cat <<'EOF'
      ______
   .-'      `-.
  /            \
 |,  .-.  .-.  ,|
 | )(_o/  \o_)( |
 |/     /\     \|
 (_     ^^     _)
  \__|IIIIII|__/
   | \IIIIII/ |
   \          /
    `--------`
EOF
  echo -e "${GRN}        CYBER FLAY v5.4${RST}"
  echo -e "${CYN}>>> TOOLS INI DIBUAT OLEH CYBER FLAY <<<${RST}\n"
}

pause(){ read -rp "Tekan Enter untuk lanjut..." _; }

# ---------------- OSINT: Optimal (domain) ----------------
osint_optimal(){
  read -rp "Masukkan domain/host (contoh: smpn2tuban.sch.id): " target
  [[ -z "$target" ]] && { echo "Domain kosong."; return; }
  echo -e "${YEL}\n=== OSINT OPTIMAL untuk: ${target} ===${RST}\n"

  echo -e "${BLU}--- WHOIS ---${RST}"
  curl -s "https://api.hackertarget.com/whois/?q=${target}" || echo "Whois gagal/terbatas"
  echo

  echo -e "${BLU}--- DNS Lookup (A/MX/NS) ---${RST}"
  curl -s "https://api.hackertarget.com/dnslookup/?q=${target}" || echo "DNS gagal"
  echo

  echo -e "${BLU}--- Resolve IP ---${RST}"
  ipaddr=""
  if has dig; then
    ipaddr=$(dig +short "$target" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)
  elif has host; then
    ipaddr=$(host "$target" 2>/dev/null | awk '/has address/ {print $4; exit}' || true)
  else
    ipaddr=$(curl -s "https://api.hackertarget.com/dnslookup/?q=${target}" | awk '/A Record/ {getline; print $1; exit}' || true)
  fi
  if [[ -n "$ipaddr" ]]; then
    echo "IP: $ipaddr"
    echo -e "${BLU}--- IP Geolocation (ipapi.co) ---${RST}"
    curl -s "https://ipapi.co/${ipaddr}/json/" || echo "Geo lookup gagal"
  else
    echo "Tidak dapat resolv IP."
  fi
  echo

  echo -e "${BLU}--- Subdomains (crt.sh) ---${RST}"
  curl -s "https://crt.sh/?q=%25.${target}&output=json" | sed 's/},{/\\n/g' | sed 's/\"//g' | tr ',' '\\n' | grep -i "${target}" | sort -u | sed '/^$/d' | sed '1,1d' || echo "(crt.sh kosong/gagal)"
  echo

  echo -e "${BLU}--- Port Scan (lightweight hackertarget) ---${RST}"
  curl -s "https://api.hackertarget.com/nmap/?q=${target}" || echo "Port scan gagal/terbatas"
  echo

  echo -e "${BLU}--- HTTP Headers (curl -I) ---${RST}"
  if curl -Is --max-time 8 "https://${target}" 2>/dev/null | sed -n '1,40p'; then :; else
    if curl -Is --max-time 8 "http://${target}" 2>/dev/null | sed -n '1,40p'; then :; else
      echo "Tidak bisa ambil header."
    fi
  fi
  echo

  echo -e "${BLU}--- Website Tech (WhatCMS demo) ---${RST}"
  curl -s "https://api.whatcms.org/?key=DEMO&url=${target}" || echo "WhatCMS gagal/terbatas"
  echo

  echo -e "${GRN}=== Selesai OSINT OPTIMAL untuk: ${target} ===${RST}"
  pause
}

# ---------------- Username checker (single check per site) ----------------
username_check(){
  read -rp "Masukkan username panjang (contoh: Cyber Flay atau flay123): " user
  [[ -z "$user" ]] && { echo "Username kosong."; return; }
  # prefer variant without spaces for most sites
  user_nosp=$(echo "$user" | tr -d ' ')
  echo -e "${YEL}Memeriksa username: '${user}' (varian: ${user_nosp})${RST}"
  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/125 Safari/537.36"

  sites=(
"instagram.com" "twitter.com" "tiktok.com/@" "github.com" "gitlab.com" "reddit.com/user" "facebook.com"
"pinterest.com" "medium.com/@" "stackoverflow.com/users" "quora.com/profile" "tumblr.com" "flickr.com/people"
"vimeo.com" "soundcloud.com" "open.spotify.com/user" "steamcommunity.com/id" "discord.com/users" "t.me"
"linkedin.com/in" "snapchat.com/add" "vk.com" "twitch.tv" "dailymotion.com" "about.me" "producthunt.com/@" 
"hackerone.com" "kaggle.com" "goodreads.com" "last.fm/user" "wattpad.com/user" "archive.org/details" "trello.com"
"notion.so" "canva.com" "dribbble.com" "behance.net" "deviantart.com" "slideshare.net" "tripadvisor.com/Profile"
"booking.com" "myanimelist.net/profile" "crunchyroll.com" "roblox.com/users" "patreon.com"
  )

  for s in "${sites[@]}"; do
    if [[ "$s" == *"/@"* || "$s" == *"/user" || "$s" == *"/users" || "$s" == *"/id" || "$s" == *"/in" || "$s" == *"/profile" || "$s" == *"/people" || "$s" == *"/add" || "$s" == *"/Profile" ]]; then
      url="https://${s}${user_nosp}"
    else
      url="https://${s}/${user_nosp}"
    fi
    code=$(curl -A "$UA" -m 8 -s -L -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$code" =~ ^(200|301|302)$ ]]; then
      echo -e "${GRN}[+] DITEMUKAN: ${url}${RST}"
    else
      echo -e "${RED}[-] TIDAK: ${url}${RST}"
    fi
  done
  pause
}

# ---------------- Phone lookup (many platforms, best-effort free) ----------------
phone_lookup(){
  read -rp "Masukkan nomor (contoh +6281234567890 atau 081234567890): " number
  [[ -z "$number" ]] && { echo "Nomor kosong."; return; }
  # normalize to +62... and 0...
  n_plus=$(echo "$number" | sed 's/^0/+62/; s/[^0-9+]//g')
  n_zero=$(echo "$number" | sed 's/^+62/0/; s/[^0-9]//g')
  echo -e "${YEL}Mencari nomor: ${n_plus} (varian 0: ${n_zero})${RST}"

  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/125 Safari/537.36"

  platforms=(
"https://wa.me/${n_plus}" 
"https://t.me/+${n_plus}" 
"https://www.truecaller.com/search/${n_plus}" 
"https://www.facebook.com/search/top?q=${n_plus}" 
"https://www.reddit.com/search/?q=${n_plus}" 
"https://pastebin.com/search?q=${n_plus}" 
"https://search.strikepoint.io/?q=${n_plus}" 
"https://www.google.com/search?q=${n_plus}" 
  )

  for p in "${platforms[@]}"; do
    echo -e "${BLU}-- Checking: ${p} --${RST}"
    code=$(curl -A "$UA" -m 8 -s -o /dev/null -w "%{http_code}" "$p" || echo "000")
    if [[ "$code" =~ ^(200|301|302)$ ]]; then
      echo -e "${GRN}[+] POSSIBLE: ${p}${RST}"
    else
      echo -e "${RED}[-] Not found (or blocked): ${p}${RST}"
    fi
    sleep 1
  done

  echo -e "${GRN}Selesai pencarian nomor. Untuk hasil mendalam, gunakan tools berbayar/API resmi.${RST}"
  pause


  echo
  read -rp "Jalankan DEEP SCAN 50+ situs juga? (y/N): " deepans
  if [[ "$deepans" == "y" || "$deepans" == "Y" ]]; then
    phone_lookup_plus
  fi
}

# ---------------- JSO helper ----------------
jso_helper(){
  clear
  echo -e "${YEL}=== PEMBUATAN JSO (Helper) ===${RST}"
  read -rp "Tekan ENTER untuk membuka editor pembuatan HTML (haxor.my.id)..." _
  if has termux-open-url; then termux-open-url "https://haxor.my.id"; elif has xdg-open; then xdg-open "https://haxor.my.id"; else echo "Buka manual: https://haxor.my.id"; fi
  read -rp "Setelah selesai, ketik 'lanjutkan' untuk paste HTML (atau Enter batal): " L
  if [[ "$L" != "lanjutkan" ]]; then echo "Dibatalkan"; pause; return; fi
  echo "Tempel HTML kamu (akhiri CTRL+D):"
  tmp="$(mktemp)"; cat > "$tmp"
  read -rp "Nama output (tanpa ekstensi) [hasil]: " out; [[ -z "$out" ]] && out="hasil"
  mv "$tmp" "${out}.jso"
  echo -e "${GRN}[+] File dibuat: $(pwd)/${out}.jso${RST}"
  pause
}

# ---------------- Menu Lain ----------------
menu_lain(){
  while true; do
    clear
    echo -e "${BLU}===== MENU LAIN (Utilities) =====${RST}"
    echo "1) Cek Cuaca (wttr.in)"
    echo "2) Kalkulator (bc)"
    echo "3) Nama Hacker Random"
    echo "4) Chat AI (web)"
    echo "5) Base64 Encode/Decode"
    echo "6) Hash (MD5/SHA256)"
    echo "7) Password Generator"
    echo "8) IP Public"
    echo "9) Speedtest (if installed)"
    echo "10) Kalender"
    echo "0) Kembali"
    read -rp "Pilih (0-10): " U
    case "$U" in
      1) read -rp "Kota: " k; curl -s "wttr.in/${k}?format=3"; pause ;;
      2) echo "Ketik 'quit' untuk keluar"; while read -rp "expr> " e; do [[ "$e" == "quit" ]] && break; echo "$e" | bc; done; pause ;;
      3) arr=("DarkGhost" "CyberNinja" "ShadowX" "NullByte" "RootKing" "HexFlay" "AnonMaster"); echo "Nama: ${arr[$RANDOM % ${#arr[@]}]}"; pause ;;
      4) if has termux-open-url; then termux-open-url "https://chat.openai.com"; else echo "Buka: https://chat.openai.com"; fi; pause ;;
      5) read -rp "Teks: " t; echo "Encode: $(echo -n "$t" | base64)"; echo "Decode: $(echo -n "$t" | base64 -d 2>/dev/null)"; pause ;;
      6) read -rp "Teks: " t; echo "MD5: $(echo -n "$t"|md5sum|awk '{print $1}')"; echo "SHA256: $(echo -n "$t"|sha256sum|awk '{print $1}')"; pause ;;
      7) openssl rand -base64 12; pause ;;
      8) curl -s ifconfig.me || echo "Gagal ambil IP publik"; pause ;;
      9) if has speedtest-cli; then speedtest-cli; elif has speedtest; then speedtest; else echo "Install speedtest via pkg install speedtest"; fi; pause ;;
      10) cal; pause ;;
      0) break ;;
      *) echo "Pilihan tidak valid"; pause ;;
    esac
  done
}

# ---------------- Dark Web (info) ----------------
darkweb_info(){
  clear
  echo -e "${RED}== DARK WEB (EDUKASI) ==${RST}"
  echo "- Link informasional (mirror). Untuk akses .onion yang sebenarnya gunakan Tor/Orbot."
  read -rp "Tekan Enter untuk buka Hidden Wiki (info)..." _
  if has termux-open-url; then termux-open-url "https://thehiddenwiki.org/"; elif has xdg-open; then xdg-open "https://thehiddenwiki.org/"; else echo "Buka manual: https://thehiddenwiki.org/"; fi
  pause
}

# ---------------- About ----------------
about_menu(){
  clear
  banner
  echo "Versi: v9 (SAFE)"
  echo "Author: FLAY"
  echo "Gunakan hanya untuk tujuan legal/edukasi/bug bounty."
  pause
}

# ---------------- Main ----------------

# ==============================
# Phone Lookup PLUS (50+ sites)
# ==============================
phone_lookup_plus() {
  clear
  echo -e "${BLU}=== PHONE LOOKUP (DEEP 50+) ===${RST}"
  read -rp "Masukkan nomor (contoh 08123456789 atau +628123456789): " n
  if [[ -z "$n" ]]; then echo "Nomor kosong."; pause; return; fi

  # Normalisasi nomor: raw, +62 (ID), dan internasional generik (+)
  raw="$n"
  n_clean="$(echo "$n" | tr -cd '0-9+')"
  if [[ "$n_clean" =~ ^0[0-9]+$ ]]; then
    n_id="+62${n_clean#0}"
  elif [[ "$n_clean" =~ ^\+ ]]; then
    n_id="$n_clean"
  else
    n_id="+$n_clean"
  fi

  # Variasi untuk query: dengan +, tanpa +, dan dipisah spasi
  n_plus="$(echo "$n_id" | sed 's/^+/%2B/')"
  n_no_plus="$(echo "$n_id" | sed 's/^+//')"
  n_spaced="$(echo "$n_no_plus" | sed 's/\\([0-9]\\)/\\1 /g' | sed 's/ $//')"

  has_curl=0
  if has curl; then has_curl=1; fi

  # Daftar 60+ target (search endpoints / profil publik)
  targets=(
    "WhatsApp|https://wa.me/$n_no_plus"
    "Telegram|https://t.me/$n_no_plus"
    "Truecaller|https://www.truecaller.com/search/id/$n_no_plus"
    "Facebook Search|https://www.facebook.com/search/top?q=$n_plus"
    "Reddit Search|https://www.reddit.com/search/?q=$n_plus"
    "Instagram Search|https://www.instagram.com/explore/search/keyword/?q=$n_plus"
    "TikTok Search|https://www.tiktok.com/search?q=$n_plus"
    "Twitter/X Search|https://x.com/search?q=$n_plus"
    "LinkedIn Search|https://www.linkedin.com/search/results/all/?keywords=$n_plus"
    "Pinterest Search|https://www.pinterest.com/search/pins/?q=$n_plus"
    "YouTube Search|https://www.youtube.com/results?search_query=$n_plus"
    "Google|https://www.google.com/search?q=%22$n_no_plus%22"
    "Google (with +)|https://www.google.com/search?q=%22$n_id%22"
    "Bing|https://www.bing.com/search?q=%22$n_no_plus%22"
    "DuckDuckGo|https://duckduckgo.com/?q=%22$n_no_plus%22"
    "Yahoo|https://search.yahoo.com/search?p=%22$n_no_plus%22"
    "Yandex|https://yandex.com/search/?text=%22$n_no_plus%22"
    "NomerO|https://nomero.com/id/number/$n_no_plus"
    "SyncMe|https://sync.me/search/?number=$n_no_plus"
    "Eyecon|https://eyecon-app.com/search/$n_no_plus"
    "Whoscall (ID)|https://whoscall.com/id-ID/number/$n_no_plus"
    "Who-Called|https://www.who-called-this.com/number/$n_no_plus"
    "Numlookup|https://www.numlookup.com/$n_no_plus"
    "SpamCalls|https://www.spamcalls.net/en/number/$n_no_plus"
    "PhoneInfoga (GitHub)|https://github.com/sundowndev/phoneinfoga?q=$n_plus"
    "OpenCorporates|https://opencorporates.com/companies?utf8=✓&q=$n_plus"
    "Gravatar|https://en.gravatar.com/site/check/$n_no_plus"
    "LeakCheck|https://leakcheck.io/search?query=$n_plus"
    "HaveIBeenPwned|https://haveibeenpwned.com/"
    "Dehashed|https://www.dehashed.com/search?query=$n_plus"
    "ScamCallFighters|https://www.scamcallfighters.com/search/?s=$n_no_plus"
    "ScamNumbers|https://scamnumbers.info/search.php?q=$n_no_plus"
    "Tellows (ID)|https://www.tellows.co.id/num/$n_no_plus"
    "TelGuarder (ID)|https://www.telguarder.com/id/number/$n_no_plus"
    "Telefonterror|https://www.telefonterror.de/num/$n_no_plus"
    "WhoCallsMe|https://whocallsme.com/Phone-Number.aspx/$n_no_plus"
    "Kompoller|https://www.koppler.com/phone/$n_no_plus"
    "Signal (Deep Link)|https://signal.me/#p/$n_no_plus"
    "LINE (search)|https://line.me/R/nv/search?keyword=$n_plus"
    "Viber|viber://add?number=$n_no_plus"
    "Skype|skype:$n_no_plus?call"
    "IMO|https://imo.im/s/$n_no_plus"
    "WeChat (search)|https://www.google.com/search?q=site%3Aweixin.qq.com+$n_plus"
    "Snapchat|https://story.snapchat.com/search/$n_no_plus"
    "Quora|https://www.quora.com/search?q=$n_plus"
    "Medium|https://medium.com/search?q=$n_plus"
    "GitHub Search|https://github.com/search?q=$n_plus"
    "GitLab Search|https://gitlab.com/search?search=$n_plus"
    "StackOverflow|https://stackoverflow.com/search?q=$n_plus"
    "StackExchange|https://stackexchange.com/search?q=$n_plus"
    "Keybase|https://keybase.io/search?q=$n_plus"
    "Pastebin Search|https://pastebin.com/search?q=$n_plus"
    "Ghostbin Search|https://www.google.com/search?q=site%3Aghostbin.com+$n_plus"
    "PublicWWW|https://publicwww.com/websites/%22$n_no_plus%22/"
    "Censys|https://search.censys.io/search?resource=hosts&q=$n_plus"
    "Shodan|https://www.shodan.io/search?query=$n_plus"
    "ZoomInfo|https://www.zoominfo.com/p/$n_no_plus"
    "Apollo.io|https://app.apollo.io/#/people?finderTabs=People&query=$n_plus"
    "RocketReach|https://rocketreach.co/advanced-search?keyword=$n_plus"
    "Hunter.io|https://hunter.io/search/$n_no_plus"
  )

  printf "%-25s | %-7s | %s\\n" "Platform" "Status" "URL"
  printf "%-25s-+-%-7s-+-%s\\n" "$(printf '%.0s-' {1..25})" "$(printf '%.0s-' {1..7})" "$(printf '%.0s-' {1..50})"

  for item in "${targets[@]}"; do
    name="${item%%|*}"
    url="${item#*|}"

    status="SKIP"
    if [[ $has_curl -eq 1 ]]; then
      code=$(curl -m 8 -A "Mozilla/5.0" -s -o /dev/null -w "%{http_code}" -L "$url" || echo "000")
      status="$code"
    fi
    printf "%-25s | %-7s | %s\\n" "$name" "$status" "$url"
  done

  echo
  echo "Keterangan: Status HTTP hanya indikator. Banyak situs butuh login/JS, jadi cek manual via URL di atas bila perlu."
  pause
}


# ---------------- Email Lookup PLUS (50+ sites) ----------------
email_lookup_plus(){
  clear
  echo -e "${BLU}=== EMAIL LOOKUP (DEEP 50+) ===${RST}"
  read -rp "Masukkan email (contoh: user@example.com): " mail
  [[ -z "$mail" ]] && { echo "Email kosong."; pause; return; }

  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/125 Safari/537.36"

  targets=(
    "Google|https://www.google.com/search?q=%22$mail%22"
    "Bing|https://www.bing.com/search?q=%22$mail%22"
    "Yahoo|https://search.yahoo.com/search?p=%22$mail%22"
    "DuckDuckGo|https://duckduckgo.com/?q=%22$mail%22"
    "Yandex|https://yandex.com/search/?text=%22$mail%22"
    "LeakCheck|https://leakcheck.io/search?query=$mail"
    "HaveIBeenPwned|https://haveibeenpwned.com/account/$mail"
    "Dehashed|https://www.dehashed.com/search?query=$mail"
    "BreachDirectory|https://breachdirectory.org/search?query=$mail"
    "Scylla.so|https://scylla.so/search?q=$mail"
    "Intelx.io|https://intelx.io/?s=$mail"
    "Hunter.io|https://hunter.io/search/$mail"
    "EmailRep|https://emailrep.io/$mail"
    "Github|https://github.com/search?q=$mail"
    "Gitlab|https://gitlab.com/search?search=$mail"
    "Reddit|https://www.reddit.com/search/?q=$mail"
    "Twitter|https://x.com/search?q=$mail"
    "Facebook|https://www.facebook.com/search/top?q=$mail"
    "LinkedIn|https://www.linkedin.com/search/results/all/?keywords=$mail"
    "Instagram|https://www.instagram.com/explore/search/keyword/?q=$mail"
    "TikTok|https://www.tiktok.com/search?q=$mail"
    "YouTube|https://www.youtube.com/results?search_query=$mail"
    "Pinterest|https://www.pinterest.com/search/pins/?q=$mail"
    "Quora|https://www.quora.com/search?q=$mail"
    "Medium|https://medium.com/search?q=$mail"
    "StackOverflow|https://stackoverflow.com/search?q=$mail"
    "StackExchange|https://stackexchange.com/search?q=$mail"
    "Keybase|https://keybase.io/search?q=$mail"
    "Pastebin|https://pastebin.com/search?q=$mail"
    "Ghostbin|https://www.google.com/search?q=site%3Aghostbin.com+$mail"
    "PublicWWW|https://publicwww.com/websites/%22$mail%22/"
    "Censys|https://search.censys.io/search?resource=hosts&q=$mail"
    "Shodan|https://www.shodan.io/search?query=$mail"
    "ZoomInfo|https://www.zoominfo.com/p/$mail"
    "Apollo.io|https://app.apollo.io/#/people?finderTabs=People&query=$mail"
    "RocketReach|https://rocketreach.co/advanced-search?keyword=$mail"
    "Clearbit|https://dashboard.clearbit.com/reveal?email=$mail"
    "FullContact|https://www.fullcontact.com"
    "Pipl|https://pipl.com/search/?q=$mail"
    "Thatsthem|https://thatsthem.com/email/$mail"
    "Spokeo|https://www.spokeo.com/$mail"
    "Whitepages|https://www.whitepages.com/search/Find?email=$mail"
    "BeenVerified|https://www.beenverified.com/people/email/$mail"
    "USSearch|https://www.ussearch.com/search/email/$mail"
    "InfoTracer|https://infotracer.com/email/$mail"
    "CreepyEmail|https://www.creepyemail.com/email/$mail"
    "EmailSherlock|https://www.emailsherlock.com/search/email/$mail"
    "EmailHippo|https://tools.emailhippo.com/email/$mail"
  )

  printf "%-20s | %-7s | %s
" "Platform" "Status" "URL"
  printf "%-20s-+-%-7s-+-%s
" "$(printf '%.0s-' {1..20})" "$(printf '%.0s-' {1..7})" "$(printf '%.0s-' {1..50})"

  for item in "${targets[@]}"; do
    name="${item%%|*}"
    url="${item#*|}"
    code=$(curl -m 8 -A "$UA" -s -o /dev/null -w "%{http_code}" -L "$url" || echo "000")
    printf "%-20s | %-7s | %s
" "$name" "$code" "$url"
  done

  echo
  echo "Keterangan: Status HTTP hanya indikator. Banyak situs butuh login/JS, jadi cek manual via URL di atas bila perlu."
  pause
}


# ---------------- Web Member Info (Publik) ----------------
web_member_info(){
  read -rp "Masukkan URL target (contoh: https://example.com/list): " url
  [[ -z "$url" ]] && { echo "URL kosong."; return; }
  echo -e "${YEL}
=== INFORMASI ANGGOTA / NAMA DARI: ${url} ===${RST}
"

  tmp="$(mktemp)"
  if ! curl -sL "$url" -o "$tmp"; then
    echo "Gagal ambil URL."; rm -f "$tmp"; pause; return;
  fi

  # Hapus script/style (basic), ubah tag jadi newline, bersihkan spasi
  sed -E 's/<script[^>]*>.*<\/script>//gI; s/<style[^>]*>.*<\/style>//gI' "$tmp" > "${tmp}.clean" 2>/dev/null || cp "$tmp" "${tmp}.clean"
  tr '\n' ' ' < "${tmp}.clean" | sed 's/<[^>]*>/\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' > "${tmp}.lines"

  # Cari baris dengan kata kunci NAMA atau anggota/member/user
  grep -E -i '(^| )(nama[: ]|anggota|member|user|account|profil|profile|participant|daftar)' "${tmp}.lines" | sed 's/^[ \t]*//;s/[ \t]*$//' | uniq > "${tmp}.found"

  # Jika tidak ada hasil dari kata kunci, coba ekstraksi pola "NAMA: ..." (dua kata kapital dsb.)
  if [[ ! -s "${tmp}.found" ]]; then
    grep -E -i 'NAMA[: ]+[A-Za-z0-9 .]+' "${tmp}.lines" | sed 's/^[ \t]*//;s/[ \t]*$//' | uniq > "${tmp}.found"
  fi

  echo "Daftar anggota/nama yang terdeteksi (jika ada):"
  if [[ -s "${tmp}.found" ]]; then
    nl -w2 -s'. ' "${tmp}.found"
  else
    echo "- Tidak menemukan daftar nama/anggota yang jelas pada halaman ini."
    echo "- Coba cek URL lain atau lihat manual (halaman mungkin butuh JS/login)."
  fi

  # cleanup
  rm -f "${tmp}" "${tmp}.clean" "${tmp}.lines" "${tmp}.found" 2>/dev/null || true
  echo
  pause
}

main(){
  while true; do
    clear
    banner
    echo -e "${GRN}┌────────────────────────────────────────────┐${RST}"
    echo -e "${GRN}│  ${YEL}[1] OSINT - Optimal (domain)         ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[2] OSINT - Username Checker        ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[3] OSINT - Phone Lookup           ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[4] Pembuatan JSO (helper)        ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[5] Menu Lain (utilities)         ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[6] Dark Web (edu)                ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[7] About                          ${GRN}│${RST}"
        echo -e "${GRN}│  ${YEL}[9] Web Member Info (Publik)     ${GRN}│${RST}"
echo -e "${GRN}│  ${YEL}[0] Keluar                         ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[8] OSINT - Email Lookup (50+)      ${GRN}│${RST}"
    echo -e "${GRN}└────────────────────────────────────────────┘${RST}"
    read -rp "Pilih menu: " c
    case "$c" in
      1) osint_optimal ;;
      2) username_check ;;
      3) phone_lookup ;;
      4) jso_helper ;;
      5) menu_lain ;;
      6) darkweb_info ;;
      7) about_menu ;;
      8) email_lookup_plus ;;
      9) web_member_info ;;
      0) echo "Terima kasih!"; exit 0 ;;
      *) echo "Pilihan tidak valid"; pause ;;
    esac
  done
}

main
