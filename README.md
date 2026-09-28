# 🚀 Boomster

**Boomster** is a lightweight Windows game-mode script that automatically applies a few system tweaks when one of your configured games starts.

It watches for your games in the background and, when one is detected, it:

* ⚡ Switches Windows to **High performance**
* 🧹 Closes configured background processes
* 🛠️ Stops configured Windows services
* 🗂️ Stops `explorer.exe` to free its resources
* 🧠 Clears several RAM lists using **RAMMap**
* 🔄 Restores the system when the game closes

No launcher, installer, or permanent service is required. It's just a `.bat` file.

---

## ✨ Features

### 🎮 Automatic game detection

Boomster continuously checks whether one of the games in `GAMELIST` is running.

By default, it checks every **5 seconds**.

```bat
set "POLL_SECONDS=5"
```

The first detected game becomes the active game for that session.

---

### ⚡ High Performance power plan

When a game is detected, Boomster switches Windows from the configured Balanced power plan to **High performance**.

It uses the Windows `powercfg` command and attempts to recreate the High performance scheme if Windows has hidden or removed it.

After the game ends, Boomster switches back to the configured Balanced plan.

---

### 🧹 Close background processes

You can optionally specify applications that should be closed while gaming.

```bat
set "PROCESSLIST=OneDrive.exe Discord.exe"
```

Boomster forcefully terminates each configured process using `taskkill`.

The detected game itself is excluded from this process list automatically.

**Important:** processes closed by Boomster are **not automatically reopened** when the game ends.

---

### 🛠️ Stop Windows services

You can optionally specify Windows services to stop during gameplay.

```bat
set "SERVICELIST=SysMain WSearch"
```

Use the **service name**, not its display name.

Boomster records which configured services were running before the boost and only starts those services again when reverting.

Services that were already stopped remain stopped.

---

### 🗂️ Stop Windows Explorer

When the boost starts, Boomster terminates:

```text
explorer.exe
```

This removes the Windows desktop and taskbar while the game is running.

Explorer is automatically started again when Boomster reverts the changes.

> **Tip:** If you need to access the Boomster window while Explorer is stopped, use `Alt + Tab`.

---

### 🧠 RAM cleanup with RAMMap

Boomster can use Microsoft's **RAMMap64.exe** to clear several Windows memory lists.

The configured RAMMap path is:

```bat
set "RAMMAP=C:\Tools\Sysinternals\RAMMap64.exe"
```

The script currently clears these RAMMap lists:

```bat
set "RAMFLAGS=-Ew -Es -Em -Et -E0"
```

If RAMMap is not found at the configured location, Boomster skips the RAM cleanup instead of stopping the entire script.

---

## 📋 Requirements

Boomster is designed for **Windows** and requires:

* Windows
* Administrator privileges
* `boomster.bat`
* **RAMMap64.exe** for RAM cleanup

RAMMap is optional. The script will still perform the other configured actions if RAMMap is unavailable.

---

## ⚙️ Configuration

All configuration is located near the top of `boomster.bat` under the `CONFIG` section.

Open the file with a text editor such as Notepad.

### 🔧 Basic settings

```bat
set "RAMMAP=C:\Tools\Sysinternals\RAMMap64.exe"
set "PLAN_BALANCED=381b4222-f694-41f0-9685-ff5bb260df2e"
set "PLAN_HIGH=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
set "POLL_SECONDS=5"
```

| Setting         | Purpose                             |
| --------------- | ----------------------------------- |
| `RAMMAP`        | Path to `RAMMap64.exe`              |
| `PLAN_BALANCED` | Balanced power-plan GUID            |
| `PLAN_HIGH`     | High performance power-plan GUID    |
| `POLL_SECONDS`  | How often Boomster checks for games |

---

## 🎮 Adding games

Find:

```bat
set "GAMELIST=eldenring.exe cs2.exe RDR2.exe"
```

Replace the example games with the executable names of your own games.

For example:

```bat
set "GAMELIST=game1.exe game2.exe game3.exe"
```

The executable name can usually be found in:

**Task Manager → Details**

If an executable name contains spaces, wrap it in quotes.

Example:

```bat
set "GAMELIST=game.exe "My Game.exe""
```

---

## 🧹 Adding processes to close

Find:

```bat
set "PROCESSLIST="
```

Then add the processes you want Boomster to close:

```bat
set "PROCESSLIST=OneDrive.exe Discord.exe"
```

These processes are terminated when the boost begins and are **not automatically restarted** afterward.

Only add applications that you are comfortable closing.

---

## 🛠️ Adding services to stop

Find:

```bat
set "SERVICELIST="
```

Then add Windows service names:

```bat
set "SERVICELIST=SysMain WSearch"
```

To find a service name:

1. Press `Win + R`
2. Enter `services.msc`
3. Open the service
4. Check **Service name**

Boomster only restarts services that were actually running before it stopped them.

---

## ▶️ Running Boomster

1. Configure `boomster.bat`.
2. Save the file.
3. Run `boomster.bat`.
4. Windows will request administrator permission.
5. Approve the UAC prompt.
6. Boomster starts minimized.
7. Leave it running.
8. Start one of your configured games.

Boomster will continue watching until it detects a configured game.

---

## 🔄 What happens during a session

The process is roughly:

```text
Start Boomster
      │
      ▼
Request Administrator privileges
      │
      ▼
Watch for configured games
      │
      ▼
Game detected
      │
      ├── Switch to High Performance
      ├── Close configured processes
      ├── Stop configured services
      ├── Stop Explorer
      └── Clear RAM with RAMMap
      │
      ▼
      Game is running
      │
      ├── Game closes
      │       OR
      └── Press ENTER
      │
      ▼
Restore Explorer
      │
      ▼
Switch back to Balanced
      │
      ▼
Restart services that were previously running
      │
      ▼
Back to normal
```

---

## 🛑 Stopping Boomster

### Automatic

Simply close the detected game.

Boomster checks the game's process and automatically begins the revert procedure when the game is no longer running.

### Manual

While Boomster is waiting for the game to finish:

1. Use `Alt + Tab` to switch to the Boomster window.
2. Press **Enter**.
3. Boomster will restore Explorer, switch back to Balanced, and restart services that were previously running.

### ⚠️ Don't force-close the window

Do **not** close the Boomster window using the `X` while a boost is active.

If the script is terminated before reaching its revert section, it cannot automatically restore the changes it made.

---

## 🆘 Troubleshooting

### My taskbar and desktop disappeared

That's expected while Boomster is active because it stops `explorer.exe`.

If Boomster has been terminated unexpectedly:

1. Press `Ctrl + Shift + Esc`.
2. Open **File → Run new task**.
3. Enter:

```text
explorer.exe
```

4. Press Enter.

---

### Windows is still using High performance

Open:

**Control Panel → Power Options**

and select **Balanced**.

---

### A service didn't start again

Open:

```text
services.msc
```

Find the service and start it manually.

Boomster only attempts to restart services that were detected as running before the boost.

---

### RAMMap doesn't run

Check that this file exists:

```text
C:\Tools\Sysinternals\RAMMap64.exe
```

If you installed RAMMap somewhere else, update:

```bat
set "RAMMAP=YOUR_PATH_HERE"
```

If RAMMap requires its license/EULA to be accepted, launch `RAMMap64.exe` manually once and accept it.

---

## ⚠️ Important warnings

Boomster uses administrative Windows commands to modify processes, services, Explorer, and power settings.

Be careful about what you put in the configuration lists.

### 🚫 Don't add anti-cheat software or services

Do not put anti-cheat components into `PROCESSLIST` or `SERVICELIST`.

Stopping them can prevent games from launching or interfere with their operation.

### 🚫 Don't close game launchers unnecessarily

Avoid adding launchers such as Steam to `PROCESSLIST` when your game depends on them.

Closing a launcher can also interfere with the game.

### 🚫 Don't stop critical Windows services

Do not randomly add Windows services, especially services related to:

* Networking
* Audio
* Windows security
* System functionality

Stopping the wrong service can cause Windows or your game to behave unexpectedly.

### ⚠️ Closed applications are not restored

Boomster does **not** remember and relaunch the processes in `PROCESSLIST`.

If you close Discord, OneDrive, or another application, you'll need to start it yourself afterward.

---

## 🔁 Run it again for another gaming session

Boomster is a one-shot session script.

After it detects a game, performs the boost, and reverts the changes, the script exits.

Start `boomster.bat` again the next time you want to use Game Mode.

---

## 📁 Repository

[Boomster on GitHub](https://github.com/an6h/Boomster)

---

## 📜 License

See the repository for the current license information.

---

🎮 **Boomster**

A small batch script for temporarily putting Windows into a configured gaming mode.
