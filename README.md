<div align="center">

<img src="crest_white.png" alt="BLACKHOUND crest" width="200">

<br>

<img src="wordmark.png" alt="BLACKHOUND" width="480">


**A one-file OSINT hunting rig.** 2717 open-source recon tools across 24 lanes — clone, install, and run any of them right inside the console. Nothing is downloaded until *you* call it.

![tools](https://img.shields.io/badge/tools-2717-b31217?style=for-the-badge) ![lanes](https://img.shields.io/badge/lanes-24-3a3a3a?style=for-the-badge) ![platform](https://img.shields.io/badge/platform-Windows-1f6feb?style=for-the-badge) ![license](https://img.shields.io/badge/license-MIT-2ea043?style=for-the-badge)

<sub>crafted by <b>Oreo</b></sub>

</div>

---

## ✨ Features

- **2717 tools in one file.** The whole catalogue is embedded in `blackhound.bat` — no database, no setup, nothing to install just to browse.
- **Run anything in-console.** Pick a tool → it clones the repo, builds a private virtual-env, installs its deps, and runs it — then cleans up after itself.
- **Auto-help.** On load it shows the tool's own commands (its `--help`) or its README, so you don't have to know the tool beforehand.
- **Web engines that always work.** Face search (Yandex, FaceCheck, PimEyes) and reverse-image tools open straight in your browser — no build, no failures.
- **3 themes** (crimson / amber / cyan), a live **doctor**, full-text search, and a braille-dotted banner.

---

## 📋 Requirements

| you need | for |
|----------|-----|
| **Windows** + a terminal | the launcher (best in **Windows Terminal**) |
| **git** | cloning tools |
| **Python 3.12** *(recommended)* | running Python tools — newer 3.13/3.14 lack prebuilt wheels for many deps |
| node / go / cargo *(optional)* | the handful of JS / Go / Rust tools |

Press **`D`** inside BLACKHOUND to see what's installed and your Python version.
**Tip:** install **Python 3.12** — brand-new versions (3.14) can't build a lot of tools' dependencies, and BLACKHOUND will auto-prefer 3.12 when it's present.

---

## 🚀 Quick start

Double-click **`blackhound.bat`**, or from a terminal:

```bat
blackhound.bat
```

Then: open a lane (`1`–`24`) → **`R <n>`** to run a tool → follow the prompts.

> **SmartScreen / antivirus** may warn about a `.bat` that downloads and runs code — that's expected for a tool like this. It's all in the one readable file.

---

## 🎛️ Console

| key | what it does |
|:---:|:-------------|
| `1`–`24` | open a lane and list its tools |
| `S` *term* | search every tool name + description |
| `I` *n* | info card for tool *n* |
| `R` *n* | download + run tool *n* in-console |
| `D` | doctor — what's installed + your Python version |
| `Q` | quit |

At a tool's args prompt: type its arguments to run, **`?`** for its commands, **`r`** for its README, **`q`** to finish (and delete it).

---

## ⚙️ How `R n` works

1. Clones the repo into `tools\<id>`
2. Builds a private venv and installs deps (Python), or `npm install` / `go build` / `cargo`
3. Auto-shows the tool's commands, then runs it with your arguments — in the console
4. Deletes the tool when you finish, so nothing piles up

**Web tools** (face / image search) skip all that and just open in your browser.

> ⚠️ `R n` **downloads and executes third-party code from GitHub.** Only run tools you trust.

---

## 🐧 Linux-only tools

A chunk of the catalogue is written for **Linux** — the tools call Unix-only
functions (like `os.geteuid`) or shell out to Linux programs (`nmap`, `tor`,
`sslyze`, `masscan`). Those **cannot build or run on Windows**, no matter which
Python you have — it's the tool being Linux-native, not a BLACKHOUND bug. If a
tool fails with `os.geteuid`, "command not found", or a `.sh` entrypoint, it's
one of these.

To use them, run them inside **WSL** (real Ubuntu Linux, on Windows):

**1. Install WSL** — one time, needs admin + a reboot:

```powershell
wsl --install
```

Reboot when it prompts. You now have **Ubuntu** in the Start menu.

**2. Run the tool inside Ubuntu.** Grab the repo URL from its info card in
BLACKHOUND (`I <n>`), open **Ubuntu**, then:

```bash
sudo apt update && sudo apt install -y git python3-venv nmap   # + whatever it needs
git clone <the tool's repo url>
cd <tool-folder>
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt          # or:  pip install .
python3 <entry>.py --help
```

`apt install` is how you get the external programs (`nmap`, `tor`, …) these tools
depend on — that's exactly why they need Linux.

> The Windows launcher already handles every **Windows-runnable** tool
> automatically (it even downloads its own Python 3.12). WSL is the home the
> Linux-only ones were built for. *Running them straight from BLACKHOUND — auto
> WSL setup + a Linux run-engine — is planned for a future update.*

---

## 🎨 Themes

Change one line near the top of `blackhound.bat`:

```bat
set "THEME=crimson"     ::  crimson | amber | cyan
```

---

## 🗂️ Lanes

<details><summary><b>All 24 lanes — 2717 tools</b> (click to expand)</summary>

| # | lane | tools |
|:-:|:-----|:-----:|
| `01` | General OSINT | 357 |
| `02` | Domain / DNS | 303 |
| `03` | Recon | 232 |
| `04` | Username | 223 |
| `05` | Network | 208 |
| `06` | IP / Geo | 183 |
| `07` | Social Media | 139 |
| `08` | Metadata | 136 |
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
| `22` | People ID | 12 |
| `23` | Crypto | 8 |
| `24` | Corporate | 5 |

</details>

Top tools: **Yandex-Face-Search**, **FaceCheck-ID**, **PimEyes**, **Lenso-AI**, **Google-Images**, **TinEye**.

---

## ⚖️ Use responsibly

BLACKHOUND is for **authorised** security research, CTFs, and investigating targets you have permission to investigate. These tools query third parties about **real people** — accounts, emails, phones, faces, IPs. Face-searching or tracking a private individual without consent can be **illegal** (GDPR, Illinois BIPA, and similar laws). **You** are responsible for how you use it.

---

## 📄 License

**MIT** — see [`LICENSE`]((https://github.com/Le-Oreo/BlackHound/blob/main/License)). Free to use, fork, and share; keep the credit; no warranty.

BLACKHOUND is a **launcher** — it does not include or redistribute the tools it lists. Each tool is cloned from its own public GitHub repository and belongs to its author under its own license.

<div align="center"><sub><b>BLACKHOUND</b> · by Oreo</sub><
