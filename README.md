# 🐸 Frogger in MIPS Assembly

A simple version of the classic *Frogger* game built entirely in **MIPS Assembly**, designed to run in the [MARS MIPS Simulator](https://github.com/dpetersanderson/MARS).  

This was a fun and challenging low-level programming project with sound, animation, keyboard input, and visual display — all built from the ground up!

---

## 🎮 Features

✅ Easy features:
- Sound effects (beep, horn, organ, victory jingle)  
- Rows moving at different speeds  
- Player lives counter  
- Death animation  
- Retry / Game Over screen  

✅ Hard feature:
- Randomly appearing ghosts that cause collisions  

---

## 📦 Requirements

- [MARS MIPS Simulator 4.5](https://dpetersanderson.github.io/) — download and run the `.jar` file using Java  
- Java (JRE or JDK) installed on your system

---

## 🚀 How to Play

### 1. Download MARS
- [Download MARS 4.5 here](https://dpetersanderson.github.io/)
- Run it by double-clicking the `.jar` file (Java required)

### 2. Open the Game
- Open MARS → `File` → `Open` → select `frogger.asm`

### 3. Set Up Graphics and Input

#### Open the Bitmap Display:
- `Tools` → `Bitmap Display`
- Use these settings:
  - Unit Width (pixels): `8`
  - Unit Height (pixels): `8`
  - Display Width (pixels): `256`
  - Display Height (pixels): `256`
  - Base Address: `0x10008000`
- Click `Connect to MIPS`

#### Open the Keyboard MMIO:
- `Tools` → `Keyboard and Display MMIO Simulator`
- Click `Connect to MIPS`

### 4. Run the Game
- Press `Assemble` (or `F3`)
- Then click `Go` (or press `F5`) to start the game!

---

## 🕹️ Controls

- `W` – Move up  
- `A` – Move left  
- `S` – Move down  
- `D` – Move right  
- `R` – Restart game after "Game Over"

---

## 📸 Preview

*(Include a screenshot or short GIF here if you have one!)*

---

## 🧠 Built With
- MIPS Assembly
- MARS Simulator
- A lot of patience and pixel math 😄

---

## 📜 License

MIT License — feel free to use or build upon this!

---

## 💬 Got questions?

Feel free to open an issue or reach out!

