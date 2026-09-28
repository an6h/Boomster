# 🚀 Boomster

Boomster is a small Windows script (`boomster.bat`) that gives your game more power. 🎮
It waits for your game to start, boosts your PC, and puts everything back to normal when the game ends.

---

## 🧠 What it does

When it sees one of your games running, it will:

- ⚡ Switch the power plan from **Balanced** to **High performance**
- 🧹 Close the apps you listed (optional)
- 🛠️ Stop the services you listed (optional)
- 🗂️ Close **explorer.exe** (taskbar and desktop) to free memory
- 🧠 Deeply clear your RAM with **RAMMap**

When the game ends, it undoes everything. 🔄

---

## ✅ Before you run it the first time

1. 📥 **Get RAMMap** from Microsoft Sysinternals.
   - Put `RAMMap64.exe` here: `C:\Tools\Sysinternals\RAMMap64.exe`
   - Or keep it somewhere else and change this line in the file:
     `set "RAMMAP=C:\Tools\Sysinternals\RAMMap64.exe"`
2. ✏️ **Open `boomster.bat` in Notepad** (right-click → Edit).
3. 🎮 **Add your games** (see the next section).
4. 🛠️ **Add processes and services** if you want (see the next section).
5. 💾 **Save** the file.
6. ▶️ **Double-click** `boomster.bat`.
   - Windows asks for permission (UAC). Click **Yes**. 🔐
   - The window opens **minimized**. That is normal. 👍

> 💡 Tip: If you leave the process and service lists empty, Boomster still changes the power plan, closes explorer, and clears RAM.

---

## ➕ Where to add games, processes and services

Open the file in Notepad and find the **CONFIG** part. There are three lists.

### 🎮 Games

```bat
set "GAMELIST=eldenring.exe cs2.exe RDR2.exe"
```

- Write the game's **.exe name**.
- Put a **space** between names.
- Not sure of the name? Start the game, open **Task Manager → Details tab**, and look for it. 🔍
- Add another one without touching the line:
  ```bat
  set "GAMELIST=%GAMELIST% Overwatch.exe"
  ```

### 🧹 Processes (apps to close)

```bat
set "PROCESSLIST=OneDrive.exe Discord.exe"
```

- Same rules: **.exe names**, separated by spaces.
- These apps are **not reopened** later. Open them yourself if you need them. 🖱️

### 🛠️ Services (things to stop)

```bat
set "SERVICELIST=SysMain WSearch"
```

- Use the **service name**, not the display name.
- Find it: press `Win + R` → type `services.msc` → double-click a service → read **Service name**. 🔎
- Services that were running get **started again** after the game. ✅

> ✍️ If a name has a space in it, put it in quotes, like `"My Game.exe"`.

---

## ▶️ How it works (step by step)

1. 🔐 It asks for admin rights and restarts itself **minimized**.
2. 👀 It checks every few seconds if one of your games is running.
3. 🎯 When it finds one, it starts the boost.
4. ⚡ Power plan → High performance.
5. 🧹 Closes your listed apps. (It never closes the game itself.)
6. 🛠️ Stops your listed services.
7. 🗂️ Closes explorer.
8. 🧠 Clears RAM.
9. ⏳ It waits until the game closes **or** you press Enter.
10. 🔄 Everything goes back to normal, then the script ends.

---

## 🛑 How to stop it

### 🤖 Automatic
- Just close your game. Boomster notices and reverts everything by itself. ✅

### 🖐️ Manual
1. Press `Alt + Tab` to find the Boomster window. 🪟
   - There is no taskbar while the game runs, so `Alt + Tab` is the way.
2. Click on it and press **Enter**. ⏎
3. Everything goes back to normal. 🎉

> 🧯 If you close the window with the **X** instead, Boomster can't undo anything. See the next section.

---

## 🆘 If something looks wrong

- 🖥️ **No taskbar or desktop?**
  Press `Ctrl + Shift + Esc` → **File → Run new task** → type `explorer.exe` → OK.
- ⚡ **Still on High performance?**
  Open **Control Panel → Power Options** and pick **Balanced**.
- 🛠️ **A service is still off?**
  Open `services.msc`, find it, and click **Start**.
- 🧠 **RAMMap shows a license window?**
  Open `RAMMap64.exe` once by hand and click **Agree**.

---

## ⚠️ Be careful

- 🚫 **Never add anti-cheat** programs or services (like `vgc`, `vgk`, `EasyAntiCheat`, `BEService`). Your game may not start, or you could get banned.
- 🚫 **Don't add game launchers** (like `steam.exe`) to the process list. Closing them can close your game.
- 🚫 **Don't stop** audio, network, or Windows Defender services.
- 📌 Boomster runs **once**. Start it again next time you play.

---

Happy gaming! 🎮🔥
