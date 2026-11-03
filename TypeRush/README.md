# TypeRush

<video src="https://github.com/user-attachments/assets/f2a8e280-ccb6-4f9f-8a97-369ddf8c81b1" width="960" controls playsinline></video>

[Watch the 1080p demo](vids/typerush.mp4)

TypeRush - Typing Challenge (CSC336 Lab Mid)
Run: open index.html in any browser (no install, no libraries).
Files: index.html (screens) | style.css (dark neon theme) | script.js (all logic)

Modes: Bubbles, KeyMagnet. Home screen cards have name, description, difficulty, Start.
Controls: Restart (same mode, new round) | Reset (back to home, all cleared) | no page reloads.
Difficulty: Bubbles -> speed, spawn rate, max bubbles, miss limit. KeyMagnet -> time limit + time allowed per key.
Key set (KeyMagnet) changes which keys appear as targets.
End: Bubbles = miss limit reached. KeyMagnet = time runs out.
State: S object is rebuilt in start(); stop() clears the single setInterval ("timer").
