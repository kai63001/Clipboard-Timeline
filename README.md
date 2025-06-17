# Clipboard-Timeline

Tiny, private clipboard history for macOS
Swift · AppKit · SQLite

---
<img src="Screenshot%202568-06-18%20at%2001.56.28.png" width="30%" />

### ✨ Features

* **Unlimited history** – each copy is saved with text preview, app source, and timestamp
* **Instant search** – type in the menu bar popup to filter results as you type
* **Pin to top** – keep frequent snippets one click away
* **Smart deduplication** – identical copies collapse into one entry
* **Keyboard first** – ⌥⌘V opens the list, ↑/↓ to navigate, ⏎ to paste
* **Launch at login** – set-and-forget utility; uses <1 MB RAM when idle
* **On-disk encryption (optional)** – AES-256 for the SQLite file

---

### 🛠  Tech stack

| Layer        | Tech                              |
| ------------ | --------------------------------- |
| UI / Menubar | **AppKit** + SwiftUI snippets     |
| Clipboard    | NSPasteboard listeners (run loop) |
| Storage      | **SQLite3**       |
| Persistence  | Codable models → migrations       |

