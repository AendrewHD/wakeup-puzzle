# WakeUp Puzzle

iPhone alarm that cannot be snoozed: stopping it forces a puzzle. Uses Apple's AlarmKit (iOS 26+), so alarms ring through silent mode and Focus, and the alert is mirrored to a paired Apple Watch. No third-party libraries.

## How "no snooze" works
1. Alarm rings. Only button is Stop.
2. Stop runs `StopAlarmIntent`: opens the app, marks the puzzle as pending, schedules a new alarm in 45 s.
3. App shows the puzzle full-screen. Solving it cancels the pending alarms.
4. If you do not solve it, the next alarm rings 45 s later, again and again.

## Build and install without a Mac or paid account

Needs: free GitHub account, a Windows PC, a USB cable, iPhone on iOS 26+.

### 1. Push to GitHub (Windows PowerShell)
Install Git for Windows from git-scm.com, unzip the project, then in PowerShell:

    cd path\to\wakeup-puzzle
    git remote add origin https://github.com/YOURNAME/wakeup-puzzle.git
    git push -u origin main

Create the empty repo first on github.com (New repository, **Public** = free build minutes, no README).

### 2. Get the app file
GitHub repo > **Actions** tab > "Build unsigned IPA" > newest run (green) > **Artifacts** > `WakeUp-ipa`. Unzip it to get `WakeUp.ipa`. If the run is red, open it and send me the error text.

### 3. Install from Windows
1. Install iTunes and iCloud from apple.com (the web installers, **not** the Microsoft Store versions).
2. Install Sideloadly from sideloadly.io.
3. Plug in the iPhone, tap Trust. Drag `WakeUp.ipa` into Sideloadly, enter your Apple ID, click Start. A spare Apple ID is a good idea.
4. iPhone: Settings > Privacy & Security > Developer Mode > On (restarts the phone).
5. iPhone: Settings > General > VPN & Device Management > your Apple ID > Trust.

Free Apple ID limits: the app expires after **7 days** and must be re-installed or refreshed with Sideloadly. Max 3 sideloaded apps.

## Project layout
- `project.yml` - Xcode project definition (XcodeGen builds the `.xcodeproj` in CI)
- `App/` - Swift sources
- `.github/workflows/build.yml` - cloud build on a free GitHub Mac
- `PROTOCOL.md` - daily log
