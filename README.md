# Brick — DIY App Blocker

A personal-use iOS app that blocks distracting apps when you tap your phone against an NFC tag. Tap again to unblock.

Inspired by [Brick](https://getbrick.app/).

## Disclaimer

This is a personal learning project. It is not affiliated with, endorsed by, or intended to compete with Brick LLC or their product. Not intended for commercial use or distribution.

## Requirements

- Mac with Xcode 15+
- Apple Developer Program membership ($99/year) — required for Family Controls
- iPhone XS or newer running iOS 16+
- NFC tag (NTAG215 or NTAG216)

## Setup

1. Clone the repo
2. Open `Brick/Brick.xcodeproj` in Xcode
3. Select your Apple Developer team in Signing & Capabilities for all three targets (Brick, ShieldConfiguration, ShieldAction)
4. Add the **Family Controls** and **Near Field Communication Tag Reading** capabilities to the Brick target
5. Set the build target to your iPhone
6. Build and run (Cmd+R)

## Programming Your NFC Tag

1. In the app, tap the gear icon and select "Program NFC Tag"
2. Hold a blank NTAG215/216 near the top of your iPhone
3. The app writes `brick://toggle` to the tag
4. Done — this tag is now your Brick

## How It Works

1. Tap your phone on the Brick (NFC tag)
2. iPhone reads `brick://toggle` and opens the app
3. The app toggles the lock state
4. When locked, selected apps are shielded via Apple's Screen Time API (ManagedSettings)
5. Tap the Brick again to unlock

You get 5 emergency unbricks if you don't have access to your Brick. Once they're used, the only way to unlock is the physical tap.
