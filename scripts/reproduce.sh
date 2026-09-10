#!/usr/bin/env bash
# Re-runs every passive observation in evidence/raw/. Read-only: DNS, WHOIS,
# Certificate Transparency, HTTP headers, one TCP banner grab, DEV's public API.
# Nothing is authenticated, exploited, or written to any third-party system.
set -euo pipefail

TARGET_DOMAIN=zenviapro.store
TARGET_PATH=/massapply
TARGET_IP=50.114.206.36
SIBLING_DOMAIN=beeservices.shop
SHORTENER=https://tinyurl.com/36nsecn5
ARTICLE_ID=4547359
ACCOUNT=jaylonstiedemannterry78-993
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36'

hr() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

hr "1. Unmask the shortener (headers only, redirect refused)"
curl -sS -I --max-time 20 -A "$UA" "$SHORTENER" | grep -iE '^HTTP/|^location:|^x-robots-tag:'

hr "2. Full redirect chain"
curl -sS --max-time 25 -L -D - -o /dev/null -A "$UA" \
  "https://$TARGET_DOMAIN$TARGET_PATH?whose=yahoo" \
  | grep -iE '^HTTP/|^location:|^x-powered-by:'

hr "3. Cloaking test — identical output means the operator fingerprints nobody"
for ua in "curl/8.14.1" \
          "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" \
          "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Safari/604.1" \
          ""; do
  printf '  %-68s -> ' "${ua:-<none>}"
  curl -sS --max-time 20 -o /dev/null -w '%{http_code} %{redirect_url}\n' \
    -A "$ua" "https://$TARGET_DOMAIN$TARGET_PATH?whose=yahoo"
done

hr "4. whose= parameter — identical output means the parameter is inert"
for w in yahoo gmail outlook devto reddit '' XXtest; do
  printf '  %-10s -> ' "${w:-<empty>}"
  curl -sS --max-time 20 -o /dev/null -w '%{http_code} %{redirect_url}\n' \
    -A "$UA" "https://$TARGET_DOMAIN$TARGET_PATH?whose=$w"
done

hr "5. Endpoint surface"
for p in "" "massapply" "robots.txt" "admin"; do
  printf '  /%-12s -> ' "$p"
  curl -sS --max-time 20 -o /dev/null \
    -w '%{http_code} [%{content_type}] %{size_download}b\n' -A "$UA" "https://$TARGET_DOMAIN/$p"
done

hr "6. DNS"
for d in "$TARGET_DOMAIN" "$SIBLING_DOMAIN" "mail.$SIBLING_DOMAIN" "mail.$TARGET_DOMAIN"; do
  for t in A MX TXT; do
    v=$(dig +short "$d" "$t" @1.1.1.1 | tr '\n' ' ')
    [ -n "$v" ] && printf '  %-26s %-4s %s\n' "$d" "$t" "$v"
  done
done
echo "  (mail.$TARGET_DOMAIN having no A record is the stale-HELO finding)"

hr "7. TLS certificate"
echo | timeout 20 openssl s_client -connect "$TARGET_IP:443" -servername "$TARGET_DOMAIN" 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

hr "8. SMTP banner and capabilities"
# The EHLO reply echoes YOUR OWN rDNS back at you — run this from a VPS, not home.
timeout 20 bash -c "exec 3<>/dev/tcp/$TARGET_IP/25
  head -1 <&3; printf 'EHLO example.com\r\n' >&3; timeout 6 cat <&3" 2>/dev/null \
  | sed -E 's/Nice to meet you, .*/Nice to meet you, [your rDNS - redact before publishing]/'

hr "9. The spam comment, via DEV's public API"
curl -sS --max-time 25 -H 'Accept: application/json' \
  "https://dev.to/api/comments?a_id=$ARTICLE_ID" \
  | jq -r '.. | objects | select(has("id_code"))
      | "\(.created_at)  @\(.user.username)"'

hr "10. The account"
curl -sS --max-time 25 -H 'Accept: application/json' \
  "https://dev.to/api/users/by_username?url=$ACCOUNT" \
  | jq '{username,name,joined_at,summary,location,github_username}'

hr "11. Faker verification"
base=https://raw.githubusercontent.com/faker-js/faker/next/src/locales/en/person
curl -sSL --max-time 30 "$base/last_name.ts"  -o /tmp/ln.ts
curl -sSL --max-time 30 "$base/first_name.ts" -o /tmp/fn.ts
printf '  Stiedemann  last_name.ts  line %s\n' "$(grep -n "'Stiedemann'" /tmp/ln.ts | cut -d: -f1)"
printf '  Terry       last_name.ts  line %s\n' "$(grep -n "'Terry'" /tmp/ln.ts | cut -d: -f1)"
printf '  Jaylon      first_name.ts line %s\n' "$(grep -n "'Jaylon'" /tmp/fn.ts | cut -d: -f1)"
printf '  surname entries: %s | surnames containing a hyphen: %s\n' \
  "$(grep -oE "'[A-Za-z']+'" /tmp/ln.ts | wc -l)" "$(grep -c -- '-' /tmp/ln.ts)"
echo "  zero hyphens => 'Stiedemann-Terry' is two draws => custom template"

printf '\n\033[1mDone.\033[0m Compare against evidence/raw/.\n'
