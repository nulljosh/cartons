# Cartons loop handoff (2026-10-26, early morning)

## What the loop is
The Cartons side of the App Store rejection. Apple rejected 1.0.0 on iPhone and Mac under guideline 4.3(a), spam, and both appeals are out. The loop now waits on Apple's reply. Each tick: check Resolution Center for an answer (`asc web review show` once web sign-in works, or Safari when the CLI hangs), report what Apple said, and act only on Joshua's yes.

Rules for every tick:
- Never submit to App Review or reply to Apple without Joshua's yes.
- Never put a real tracking number or Joshua's address in code, tests, screenshots, the web page, the store text or any file in this repo. Test numbers come from UPS's sample pages.
- Run `git status` first. Another session may be mid-edit, so stage only the files this tick changed, by exact path.
- A push deploys nothing on the web. Deploy the Worker with `npx wrangler deploy` when web files change.

## Where things stand
- 1.0.0 is REJECTED on iPhone and on Mac under guideline 4.3(a), spam. The reasons are read.
- The Mac appeal went out 2026-10-25. The iPhone thread had no reply, so the same appeal went in on 2026-10-26 from Joshua's signed-in Safari.
- Nothing else is in flight for 1.0.0. Waiting on Apple.
- The 1.1 store text is done in nine languages and sits on main as `metadata/<locale>.json`. None of it has been submitted.
- Repo `nulljosh/cartons`, folder `~/Documents/Code/cartons`. App Store record 6825115360, bundle `com.nulljosh.carton`, SKU `carton`. Web at cartons.jaybulb.com.

## Next, in order
1. Check Resolution Center for Apple's reply on both platforms and copy it into roadmap.md, not into the store text.
2. If Apple stays vague, decide with Joshua whether to build 1.1. Validate it first. Resubmit only on his yes.
3. Built for 1.1 but not in a build yet: Tuck in the empty Packages list with its Add button, a "Checked" time on each package, a friendly error when UPS does not answer, Mac keys on onboarding, the "It's here" celebration with Archive, haptics, status-change notifications, Tuck as an alternate icon, the landing parallax pass, and the Apache 2.0 license.
4. v3 widgets, then the v4 share sheet, then the roadmap in order.

## Restart prompt
```
Read docs/LOOP-HANDOFF.md in ~/Documents/Code/cartons, then check Resolution Center for Apple's reply to the 4.3(a) appeal on Cartons 1.0.0, iOS and macOS. Report what Apple said and change nothing else. Never submit to App Review or reply to Apple without Joshua's yes.
```
