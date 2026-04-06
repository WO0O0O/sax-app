# Developer Guide: Blue Note Tuner

basic workflow

## 1. Creating the Xcode Project

1. Open **Xcode** and select **"Create a new Xcode project"**.
2. Go to the **iOS** tab, select **App**, and click **Next**.
3. Fill in your project details:
   - **Product Name**: `BlueNoteTuner` (or whatever you prefer)
   - **Organization Identifier**: e.g., `com.yourname`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
4. Click Next and save the project inside the `Music-teach` folder.

## 2. Adding AudioKit (Swift Package Manager)

1. In Xcode's menu bar at the top of your screen, click **File > Add Package Dependencies...**
2. Paste this URL into the top-right search box: `https://github.com/AudioKit/AudioKit`
3. Click **Add Package** (bottom right).
4. After it loads, do the exact same process for SoundpipeAudioKit: `https://github.com/AudioKit/SoundpipeAudioKit`

## 3. Requesting Microphone Permissions

iOS requires explicit permission to use the microphone.

1. Click your root project name (e.g., `BlueNoteTuner`) at the very top of the left sidebar.
2. Click on the your app target and navigate to the **Info** tab in the main window.
3. Hover over any item under "Custom iOS Target Properties" and click the **`+`** symbol.
4. Type exactly: `Privacy - Microphone Usage Description` (it might autocorrect slightly—ensure it matches).
5. In the **Value** column, type: `Required to hear your instrument and track pitch.`

## 4. Running and Testing

- **Which Device?** Because this app requires real-time microphone input, you should test it on a **physical iPhone or iPad**. The iOS Simulator _can_ use your Mac mic, but testing pitch detection is much more reliable on real hardware.
- **How to Run**: Plug in your iPhone with a cable. At the top-center of Xcode, switch the device dropdown from "iPhone 15 Pro (Simulator)" to your personal device.
- **Start the App**: Click the giant **Play arrow (▶)** in the top-left corner, or press `Cmd + R` on your keyboard.
- **Debugging**: If something breaks, look at the bottom right of the Xcode window—that's the **Console**. It will show errors if the app crashes.
