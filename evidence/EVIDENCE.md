# Raw evidence log — dev.to comment spam deep dive
Collected 2026-09-09. Passive recon only: DNS, WHOIS, CT, HTTP headers, TCP banner.

## Redirect chain
tinyurl.com/36nsecn5
  -> 301 https://zenviapro.store/massapply?whose=yahoo
  -> 302 https://loopcv.pro/?via=md
  -> 301 https://www.loopcv.pro/?via=md
  -> 200 "AI Job Search Automation - Auto-Apply to 1,000+ Jobs"

## Cloaking test (all identical -> 302 loopcv.pro/?via=md)
curl/8.14.1 | Googlebot/2.1 | iPhone Safari 17 | no UA

## whose= parameter test (all identical -> 302 loopcv.pro/?via=md)
yahoo | gmail | outlook | devto | reddit | <empty> | XXtest
VERDICT: routing-neutral / inert

## Endpoint surface (zenviapro.store)
/                          404  "Cannot GET /"  (Express default, 139b)
/massapply                 302  -> loopcv.pro/?via=md (48b text/plain)
/massapply?whose=*&x=1     302  -> loopcv.pro/?via=md
/index.php /robots.txt /admin   404  "Not found" (9b)

## Server fingerprint
X-Powered-By: Express
Body: "Found. Redirecting to https://loopcv.pro/?via=md"

## DNS
zenviapro.store       A    50.114.206.36
zenviapro.store       MX   10 mail.beeservices.shop.
zenviapro.store       TXT  "v=spf1 mx ip4:50.114.206.36 ~all"
zenviapro.store       NS   dns1/dns2.registrar-servers.com
_dmarc.zenviapro.store TXT (none)
mail.zenviapro.store  A    (none)  <-- but is the SMTP HELO name
beeservices.shop      A    (none)
beeservices.shop      MX   10 mail.beeservices.shop.
beeservices.shop      TXT  "v=spf1 mx -all"
_dmarc.beeservices.shop TXT (none)
mail.beeservices.shop A    50.114.206.36

## WHOIS zenviapro.store
Registrar: NameCheap, Inc. (IANA 1068)
Creation:  2026-01-27T22:11:21Z
Expiry:    2027-01-27
DNSSEC:    unsigned

## TLS
subject=CN=zenviapro.store
issuer=Let's Encrypt YR1
notBefore=Jul 30 09:04:42 2026 GMT
SAN: DNS:zenviapro.store (single)
CT (crt.sh): 1 cert total for zenviapro.store; 0 for beeservices.shop

## Network (50.114.206.36)
25  OPEN   banner: "220 mail.zenviapro.store ESMTP"
443 OPEN
80/465/587/993/2525 closed or filtered
rDNS: 36.206.114.50.oh2.linveo.com
ASN: 62564 | 50.114.206.0/24 | US | arin | 2011-06-20

## Reputation
kilo check 50.114.206.36 -> disposition "unknown", confidence 0.0, ["NOT_OBSERVED"], 0 observations

## Economics (agent-calc exact intervals, all checks passed)
gross per referral  = [50,200] x [6,12]      = [300, 2400] USD
commission @25%     = [300,2400] / 4         = [75, 600]   USD
breakeven convs/yr  = [38,180] / [75,600]    = [19/300, 12/5] = [0.063, 2.4]

INPUT CAVEATS:
- 25% / $50-200 / 6-12mo are publicly reported program figures, NOT from LoopCV's own terms page.
- $38-180 annual infra cost is my own estimate (.store domain + budget hosting), not observed.

================================================================
## ROUND 2 — persona forensics (source post identified)
================================================================

## Source post
https://dev.to/copyleftdev/migrating-legacy-llm-infrastructure-to-an-ai-gateway-27hl
article_id 4547359 | published 2026-09-01T13:33:51Z | 3 comments

## The spam comment
id_code    3eeba
created_at 2026-09-09T18:25:17Z   (8 days after publication)
author     @jaylonstiedemannterry78-993  "Jaylon_Stiedemann-Terry78"
body       "Stop wasting time applying manually Let AI handle your job applications
            every single day Increase your chances of getting interviews fast
            tinyurl.com/36nsecn5"

## Account profile (dev.to public API)
user_id      3748129
joined_at    Feb 2, 2026
summary      null
location     null
website_url  null
twitter/github null
articles     NONE PUBLISHED

## Faker verification (raw.githubusercontent.com/faker-js/faker/next/src/locales/en/person/)
last_name.ts  line 408  'Stiedemann'
last_name.ts  line 417  'Terry'
first_name.ts line 2514 'Jaylon'
last_name.ts  entry count: 466
last_name.ts  lines containing a hyphen: 0    <-- so Stiedemann-Terry = TWO draws
first_name.ts entry count: 3185
=> template is custom, not stock faker.internet.username():
   {firstName}_{lastName}-{lastName}{2 digits}

## Namespace size (agent-calc exact, all checks passed)
3185 x 466 = 1484210
1484210 x 466 = 691641860
691641860 x 100 = 69,164,186,000 distinct personas

## Username collision test
jaylonstiedemannterry78       -> HTTP 404 (does NOT exist)
jaylonstiedemannterry78-993   -> HTTP 200
jaylonstiedemannterry         -> HTTP 404
=> the "-993" is dev.to's own normalization suffix, NOT evidence of a prior collision.

## Avatar
https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/user/profile_image/3748129/
  0fbbddf5-d683-4c45-8be2-18533e629704.png
PNG 400x400, 8-bit gray+alpha (mode LA), no metadata keys.
Content: Victorian-era scientific engraving of a wombat. Public-domain line art.
Not a face, not a GAN portrait, not a default monogram. Saved as wombat-avatar.png

## Spam sweep across all 30 copyleftdev articles
Pattern: tinyurl|zenviapro|applying manually|job application|bit.ly|cutt.ly|shorturl|loopcv
RESULT: exactly 1 hit (4547359 / 3eeba). Not a mass blast against this author.

## SMTP capabilities (50.114.206.36:25)
220 mail.zenviapro.store ESMTP
250-PIPELINING
250-8BITMIME
250 SMTPUTF8
=> NO STARTTLS, NO AUTH. Minimal cleartext MTA.
(NOTE: the EHLO response echoes the *connecting client's* rDNS. Redacted here --
 it was my own residential IP, not operator infrastructure. Do not publish that line.)

## Look-alike domain check (NOT related - different infra)
zenvypro.online -> 23.227.38.32 (Shopify), ns13.domaincontrol.com
zenvypro.com    -> 92.249.46.136, nebula.dns-parking.com (Hostinger parking)
zenviapro.com / .online / .shop -> do not resolve
=> No sibling redirector domains found beyond beeservices.shop.

## Provisioning timeline
2026-01-27  zenviapro.store registered
2026-02-02  dev.to account created            (+6 days)
2026-07-30  first TLS certificate issued      (+184 days)
2026-09-09  spam comment posted               (+41 days)
=> coordinated procurement burst, then ~6 months dormancy before activation.
   Sloppy at the application layer, disciplined at the account-aging layer.

================================================================
## ROUND 3 — GitHub attribution hunt
================================================================

## Direct IOC searches (gh search code) — ALL ZERO HITS
36nsecn5          -> no hits
50.114.206.36     -> no hits
zenviapro.store   -> no hits
beeservices.shop  -> no hits
=> the operator has published nothing to GitHub.

## PhishDestroy destroylist (202,659 curated phishing/scam domains)
https://raw.githubusercontent.com/phishdestroy/destroylist/HEAD/list.txt
zenviapro.store    -> 0 matches
beeservices.shop   -> 0 matches
loopcv.pro         -> 0 matches
only zenvia* entry -> zenviacapitalltd.org (unrelated financial scam)
=> SECOND independent source agreeing with kilo's NOT_OBSERVED.

## FALSE POSITIVE (documented deliberately)
phishdestroy/namesilo-evidence data/new/2025/10/2025-10-17.txt contains:
  zenviaetc.info zenviahub.info zenviapro.info zenvias.info zenviatime.info zenviazone.info
All six share the IDENTICAL Cloudflare NS pair: asa.ns.cloudflare.com + harley.ns.cloudflare.com
=> genuinely ONE operator... but NOT ours:
  cluster: NameSilo   / Cloudflare DNS / Cloudflare proxy / .info
  ours:    Namecheap  / registrar-servers.com / Linveo direct / .store
  real brand zenvia.com uses dana+lex.ns.cloudflare.com (also unrelated)
CONCLUSION: shared label only. Both ride the real Zenvia (Brazilian CPaaS) brand name.
LESSON: a matching name is not a matching operator.

## LoopCV affiliate tokens published on GitHub (ecosystem context)
Ramas68/LoopCV-Promo-Codes          README.md  -> ?via=abdul     (repo created 2025-04-09)
diaodiaozhuye/awesome-ai-startups   data/products/loopcv.json -> ?via=toolify
heukshow/aicity-os                  .../loopcv.html -> ?via=sang-kwon
Method: gh search code 'loopcv.pro' --limit 100, then raw-fetch each hit and
        grep -oiE "loopcv\.pro/?\?[a-z]+=[A-Za-z0-9_-]+"
=> tokens in the wild are NAMES (abdul, toolify, sang-kwon). Ours is `md` — opaque.
   The only deliberate opsec in the whole campaign is on the token that gets paid.

## Also searched, no useful results
dev.to / forem comment-automation tooling repos -> only unrelated "devtools" projects
