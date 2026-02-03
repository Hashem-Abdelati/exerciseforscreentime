# Exercise for Screen Time

I doom scroll a lot, I want a limit thats benficial to me — so I started building this.

**Exercise for Screen Time** is an iOS app that makes you earn social media time with exercise. It’s still in the beginner/MVP stage, but the core idea works.

## What it does
- **1 pushup = 1 minute** of allowed screen time  
- Uses the **front camera + Apple Vision pose detection** to count pushups  
- Uses a **Shortcuts Automation** (free workaround until I pay for apple developer pro :( hopefully soon) to redirect you away from TikTok/Instagram unless you have minutes in your “time bank”

## Why the Shortcuts workaround?
iOS doesn’t let third-party apps truly block other apps for free (real Screen Time shielding needs special entitlements). So for now, this project uses Shortcuts to create friction:

- If you open TikTok/Instagram with **0 minutes**, it bounces you back to the workout screen.
- If you have **minutes**, it “spends” them in **1-minute chunks**.

## Status
Beginner build / MVP. Still improving:
- pushup detection accuracy + thresholds
- UI polish
- plank mode + more exercises
- better “use-time” enforcement flows

## Quick summary
If you want to scroll, you pay in pushups.
