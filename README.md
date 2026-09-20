<div align="center">

```
  ██████╗ ██╗      █████╗  ██████╗██╗  ██╗
  ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝
  ██████╔╝██║     ███████║██║     █████╔╝
  ██╔══██╗██║     ██╔══██║██║     ██╔═██╗
  ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
██╗  ██╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗
██║  ██║██╔═══██╗██║   ██║████╗  ██║██╔══██╗
███████║██║   ██║██║   ██║██╔██╗ ██║██║  ██║
██╔══██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝
```

# 🐺 BLACKHOUND

**One-file OSINT hunting rig** — 2711 open-source recon tools, 24 lanes, nothing installed until *you* call one.

![tools](https://img.shields.io/badge/tools-2711-b31217?style=for-the-badge) ![lanes](https://img.shields.io/badge/lanes-24-3a3a3a?style=for-the-badge) ![platform](https://img.shields.io/badge/platform-Windows-1f6feb?style=for-the-badge) ![single file](https://img.shields.io/badge/build-one%20.bat-2ea043?style=for-the-badge)

<sub>crafted by <b>Oreo</b></sub>

</div>

---

## Quick start

Double-click **`blackhound.bat`** — or from a terminal:

```bat
blackhound.bat
```

> Runs best in **Windows Terminal** (full 24-bit colour + Unicode). No dependencies to launch.

---

## Console

| key | what it does |
|:---:|:-------------|
| `1`–`24` | open a lane and list its tools |
| `S` *term* | search every tool name + description |
| `I` *n* | info card for tool number *n* |
| `R` *n* | show how to fetch + run tool number *n* |
| `D` | doctor — what's installed (git, python, node, go, cargo) |
| `Q` | quit |

---

## Themes

Change one line near the top of `blackhound.bat`:

```bat
set "THEME=crimson"     ::  crimson  |  amber  |  cyan
```

---

## Lanes

2711 tools across 24 lanes. Top hitters: **firecrawl**, **sherlock**, **worldmonitor**, **ImHex**, **sniffnet**, **gods-eye-view**.

| # | lane | tools |
|:-:|:-----|:-----:|
| `01` | General OSINT | 357 |
| `02` | Domain / DNS | 303 |
| `03` | Recon | 232 |
| `04` | Username | 223 |
| `05` | Network | 208 |
| `06` | IP / Geo | 183 |
| `07` | Social Media | 139 |
| `08` | Metadata | 134 |
| `09` | Email | 121 |
| `10` | Phone | 119 |
| `11` | Threat Intel | 116 |
| `12` | Web Extract | 100 |
| `13` | Geo / Maps | 94 |
| `14` | Web Scan | 84 |
| `15` | Dorking | 55 |
| `16` | Secrets | 55 |
| `17` | Link Graph | 52 |
| `18` | Forensics | 36 |
| `19` | Dark Web | 34 |
| `20` | Wireless | 23 |
| `21` | Breach | 22 |
| `22` | Crypto | 8 |
| `23` | People ID | 8 |
| `24` | Corporate | 5 |

---

## How `R n` works

BLACKHOUND is a **catalogue + launcher** — it never downloads or runs a third-party
tool on its own. `R n` prints the repo and the exact steps:

```bat
git clone <repo>
cd <folder>            ::  read the README
py -m venv .venv && .venv\Scripts\pip install -r requirements.txt
```

The full tool list lives at the bottom of `blackhound.bat` (lines starting with `:::`).

---

## Use responsibly

These tools query third parties about **real people** — accounts, emails, phone
numbers, IPs. Only point them at targets you're authorised to investigate.

<div align="center"><sub>BLACKHOUND · by Oreo</sub></div>
