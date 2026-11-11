# SaveTabs

**Keep your Safari tabs per profile – even after closing the window.**

[Deutsch](#deutsch) · [English](#english)

---

## English

Safari profiles have an annoying gap: if you close a profile window with the red ✕, all of its tabs are gone the next time you open that profile. Only quitting Safari entirely keeps them.

SaveTabs is a tiny background app that fixes this. It remembers the tabs of each profile, and when you open a new window of that profile, the tabs come back.

### Features

- Works with any number of Safari profiles, each with its own tab list
- Restores tabs when you open a new profile window (menu, ⌘N or Dock)
- Works with pinned tabs and never opens them twice
- Survives Safari restarts and Mac reboots
- No Accessibility permission needed: SaveTabs only needs permission to control Safari
- Runs invisibly, with no Dock or menu bar icon

### Requirements

- macOS with Safari 17 or later (profiles)
- Xcode Command Line Tools are **not** required. `osacompile` ships with macOS.

### Install

```bash
git clone https://github.com/<your-user>/SaveTabs.git
cd SaveTabs
./install.sh
```

Then:

1. When macOS asks **"SaveTabs wants to control Safari"**, click **Allow**.
2. In **Safari > Settings**, set **"New windows open with: Empty Page"**:
   - for the default profile under **General**
   - for every other profile under **Profiles > (profile)**
3. Optional: start it automatically under **System Settings > General > Login Items > + > SaveTabs**.

### Usage

Just use Safari. Close a profile window with ✕, open that profile again, and its tabs come back within about a second.

### Limitations

- Only **one window per profile** is remembered. Additional windows of the same profile are ignored.
- Only URLs are saved. Back/forward history and form input are not.
- SaveTabs reads the profile name from the window title (`Profile — Page title`). If a Safari update changes that format, SaveTabs stops working until it is updated.
- Every profile must open new windows with **Empty Page**. That is how SaveTabs recognizes a freshly opened window.
- Windows that are already open when SaveTabs starts never overwrite a saved tab list, to protect your data.

### Where is my data?

`~/Library/SaveTabs/tabs-<Profile>.txt` holds one URL per line. Nothing leaves your Mac.

### Uninstall

```bash
./uninstall.sh          # keeps your saved tabs
./uninstall.sh --purge  # also deletes them
```

### Troubleshooting

Set `property debugLog : true` in `SaveTabs.applescript` and run `./install.sh` again. SaveTabs then writes events to `~/Library/SaveTabs/log.txt`. The log contains only profile names and tab counts, never URLs.

---

## Deutsch

Safari-Profile haben eine nervige Lücke: Schließt du ein Profil-Fenster mit dem roten ✕, sind beim nächsten Öffnen des Profils alle Tabs weg. Nur wenn du Safari ganz beendest, bleiben sie erhalten.

SaveTabs ist eine kleine Hintergrund-App, die das behebt. Sie merkt sich die Tabs jedes Profils, und wenn du ein neues Fenster dieses Profils öffnest, sind die Tabs wieder da.

### Funktionen

- Funktioniert mit beliebig vielen Safari-Profilen, jedes mit eigener Tab-Liste
- Stellt Tabs wieder her, wenn du ein neues Profil-Fenster öffnest (Menü, ⌘N oder Dock)
- Kommt mit angepinnten Tabs klar und öffnet sie nie doppelt
- Übersteht Safari-Neustarts und Mac-Neustarts
- Braucht keine Bedienungshilfen-Freigabe, nur die Erlaubnis, Safari zu steuern
- Läuft unsichtbar, ohne Symbol im Dock oder in der Menüleiste

### Installation

```bash
git clone https://github.com/<your-user>/SaveTabs.git
cd SaveTabs
./install.sh
```

Danach:

1. Fragt macOS **„SaveTabs möchte Safari steuern“**, klick auf **Erlauben**.
2. In **Safari > Einstellungen** **„Neue Fenster öffnen mit: Leere Seite“** einstellen:
   - für das Standardprofil unter **Allgemein**
   - für jedes weitere Profil unter **Profile > (Profil)**
3. Optional: automatisch starten unter **Systemeinstellungen > Allgemein > Anmeldeobjekte > + > SaveTabs**.

### Benutzung

Benutz Safari ganz normal. Schließ ein Profil-Fenster mit ✕ und öffne das Profil wieder. Nach etwa einer Sekunde sind die Tabs zurück.

### Einschränkungen

- Pro Profil wird nur **ein Fenster** gemerkt. Weitere Fenster desselben Profils werden ignoriert.
- Gespeichert werden nur Adressen, kein Vor/Zurück-Verlauf und keine Formulareingaben.
- SaveTabs liest den Profilnamen aus dem Fenstertitel (`Profil — Seitentitel`). Ändert ein Safari-Update dieses Format, funktioniert SaveTabs erst nach einem Update wieder.
- Jedes Profil muss neue Fenster mit **Leere Seite** öffnen. Daran erkennt SaveTabs ein frisch geöffnetes Fenster.
- Fenster, die beim Start von SaveTabs schon offen sind, überschreiben nie eine gespeicherte Tab-Liste. Das schützt deine Daten.

### Wo liegen meine Daten?

In `~/Library/SaveTabs/tabs-<Profil>.txt`, eine Adresse pro Zeile. Nichts verlässt deinen Mac.

### Deinstallieren

```bash
./uninstall.sh          # gespeicherte Tabs bleiben
./uninstall.sh --purge  # löscht sie auch
```

### Fehlersuche

Setz in `SaveTabs.applescript` `property debugLog : true` und führ `./install.sh` erneut aus. SaveTabs schreibt dann Ereignisse nach `~/Library/SaveTabs/log.txt`. Das Protokoll enthält nur Profilnamen und Tab-Anzahlen, nie Adressen.

---

License: [MIT](LICENSE)
