# Novabolt — Project Handoff

## What This Is
A cross-platform (iOS + Android) space-themed arena survival game built with **Flutter + Flame engine**.
The player pilots a fighter jet against waves of enemies. Left joystick moves, right joystick aims and fires.
Killing enemies earns XP; leveling up shows a card upgrade picker. A Supercharge bar fills as enemies die —
activate for a screen-wide Nova attack. Boss fights every 10 levels — 10 unique bosses cycle with increasing
difficulty. Enemy visuals, backgrounds, and boss attacks transform through 10 phases as bosses are defeated.
AdMob ads are live. A NOVA coin economy lets players spend on ship skins, shield skins, and Nova beam colours.

**GitHub**: https://github.com/Samsimus12/novabolt

## How to Run
```bash
flutter pub get
cd ios && pod install && cd ..   # after adding plugins
flutter run -d "Samsimus"        # physical iPhone (preferred)
# Hot reload: r  |  Hot restart: R  |  Quit: q
# NOTE: after native changes (pods, Info.plist) always do a full flutter run, not hot reload
# NOTE: if you get "Error connecting to service protocol / Connection reset by peer",
#       the app likely installed fine — unplug/replug USB and retry
```

## Tech Stack
- **Flutter** (Dart, SDK `^3.11.5`) — cross-platform framework
- **Flame 1.37.0** — 2D game engine; game loop, collision detection, camera, joystick
- **flame_audio 2.12.1** — BGM (Menu.wav, Fighting.wav, Fighting 2.wav, Flying.wav, Flying 2.wav, Boss Battle.wav, Boss Battle 2.wav) in `assets/`
- **google_mobile_ads 5.3.1** — AdMob rewarded + interstitial ads
- **app_tracking_transparency 2.0.6** — ATT permission prompt (must fire before AdMob init on iOS)
- **shared_preferences** — persists coins, owned items, selected skin/shield/nova, best stats
- **flutter_launcher_icons** (dev) — generates all iOS + Android icon sizes from `assets/icon/icon.png`
- **flutter_native_splash** (dev) — generates native launch screens from `assets/splash/splash.png`
- All visuals are **code-drawn** (Canvas primitives) — no image assets in gameplay (see sprite note below)
- **NOT Expo/EAS** — Flutter/Dart ecosystem only

---

## File Structure

```
lib/
├── main.dart                          # NovaboltApp — ATT prompt → AdMob init → menu/game; AnimatedSwitcher fade
├── ads/
│   └── ad_manager.dart               # Singleton; loads/shows rewarded + interstitial; pauses/resumes music
├── audio/
│   └── audio_manager.dart            # Singleton; playMenu/playGame/playBoss; crossfades between tracks; _fadeGeneration for cancellation
├── coins/
│   └── coin_manager.dart             # Singleton; persists totalCoins, ownedItems, selectedSkin/shieldSkin/novaTheme
├── stats/
│   └── stats_manager.dart            # Singleton; persists bestLevel, bestKills via SharedPreferences
├── game/
│   ├── novabolt_game.dart            # FlameGame root — bossPhase, killCount, isNewBest, isBossReward, playTimeSeconds, continueWithHalfHp()
│   ├── components/
│   │   ├── player.dart               # Fighter jet; skin-aware render; progressive damage visuals; _damageTime timer; _skinSprites map
│   │   ├── weapon.dart               # Abstract Weapon — fires when aimJoystick active; isUpgradeable flag; upgradeLevel starts at 1
│   │   ├── weapon_magic_bolt.dart    # Starter (cyan #00E5FF, 15dmg, 2/sec)
│   │   ├── weapon_spread_shot.dart   # 3-bolt fan (gold #F4A800)
│   │   ├── weapon_rapid_fire.dart    # 4/sec (orange #FF6B35)
│   │   ├── weapon_homing_bolt.dart   # Steers 3rad/s (purple #9B59B6)
│   │   ├── weapon_sword_aura.dart    # 70px melee ring; +1 counter-orbiting inner ball per upgrade level
│   │   ├── weapon_explosive_bolt.dart# AoE 80px (#FF8C00); isUpgradeable=false — won't re-appear after picked
│   │   ├── weapon_frost_shard.dart   # Slows 40% for 2s (ice #88D8F0)
│   │   ├── projectile.dart           # Base Projectile; `lifetime` is public (used by HomingBolt)
│   │   ├── monster.dart              # Abstract Monster — hit flash, slowFactor, updateMovement() hook
│   │   ├── monster_grunt.dart        # 10-phase render; phase 0 tries _sprite (Sprite?), falls back to canvas
│   │   ├── monster_tank.dart         # 10-phase render; phase 0 sprite-first pattern
│   │   ├── monster_speeder.dart      # 10-phase render; phase 0 sprite-first pattern
│   │   ├── monster_caster.dart       # Ranged; phase 0 sprite-first + _renderBarrel() drawn on top; fires every 2.5s
│   │   ├── caster_projectile.dart    # Lime green orb (12dmg, speed 220); hits Player only
│   │   ├── monster_boss.dart         # Abstract BossMonster — fireSpecialAttack() overridable; onDie() → onBossKilled()
│   │   ├── monster_boss_dreadnought.dart    # Phase 0: purple warship; sprite-first; 16-shot radial special; enrages at 50% HP
│   │   ├── monster_boss_void_tyrant.dart    # Phase 1: crimson warship; 3-shot spread; enrages at 40% HP
│   │   ├── monster_boss_leviathan.dart      # Phase 2: cyan sea beast; 24-shot slow radial special
│   │   ├── monster_boss_blood_colossus.dart # Phase 3: crimson giant; 24 large-projectile radial
│   │   ├── monster_boss_storm_phantom.dart  # Phase 4: X-pattern (4 groups of 4 at 90° intervals)
│   │   ├── monster_boss_cosmic_behemoth.dart# Phase 5: blue titan; 32 ultra-slow massive projectiles
│   │   ├── monster_boss_shadow_reaper.dart  # Phase 6: twin streams (10 forward fan + 10 backward fan)
│   │   ├── monster_boss_solar_titan.dart    # Phase 7: dual alternating rings (inner 12 + outer 12 offset)
│   │   ├── monster_boss_void_emperor.dart   # Phase 8: purple emperor; 28 super-fast projectiles
│   │   ├── monster_boss_singularity.dart    # Phase 9: always fires 360° radially; 40-shot white special
│   │   ├── boss_projectile.dart      # Extends Projectile; hits Player only
│   │   ├── shield_pickup.dart        # Dropped by monsters; restores 50 shield HP
│   │   ├── health_pickup.dart        # Dropped by monsters; heals 30 HP; 8s lifetime
│   │   ├── supercharge_laser.dart    # World Component (priority 4) — beam color from CoinManager.selectedNovaTheme
│   │   ├── death_particles.dart      # 10 dots burst, fade over 0.45s
│   │   ├── background.dart           # 10-phase backgrounds cycling via bossPhase % 10; re-added on boss kill
│   │   └── hud.dart                  # HP/shield bar, NOVA bar, XP bar, Lvl badge, boss bar
│   ├── systems/
│   │   ├── wave_system.dart          # Spawn timers; effectiveLevel = currentLevel + bossPhase*8; routes to 10 boss types
│   │   ├── xp_system.dart            # Linear threshold: 60 + 40×level; reset() on restart
│   │   └── supercharge_system.dart   # chargeMultiplier, depleteMultiplier, damageMultiplier; ValueNotifier state
│   └── data/
│       ├── monster_data.dart         # MonsterStats for all 10 boss types + 4 regular enemy types
│       ├── nova_mode.dart            # 11 NovaMode enum values with displayName/inheritTitle/inheritDescription
│       ├── weapon_data.dart          # WeaponStats stub (unused)
│       └── upgrade_cards.dart        # Card pool: 6 weapons + 6 stat buffs (incl. Nova Overload); bonus HP cards
├── screens/
│   ├── loading_screen.dart           # Cold boot splash UI only — init happens in main.dart _initialize()
│   ├── main_menu_screen.dart         # Animated background; PLAY + SHOP; coin balance top-left
│   ├── shop_screen.dart              # Ship skins + shield skins + Nova beam colours; ad-for-coins banner
│   ├── game_controls_overlay.dart    # Back + Pause; NOVA button; "PAUSED" red glow overlay
│   ├── level_up_screen.dart          # Card picker; bonus HP cards + inherited Nova banner; BOSS REWARD label
│   ├── game_over_screen.dart         # Run stats (level · kills · time) + all-time bests + NEW BEST badge; +N NOVA; Watch Ad → Continue
│   └── countdown_overlay.dart        # 3-2-1 GET READY overlay shown over frozen game after second-chance ad
scripts/
└── generate_sprites.py              # PixelLab API script — generates PNG sprites for ships + phase-0 enemies
assets/
├── sprites/                         # Generated PNGs (11 files): player_{default,ice,flame,shadow,solar,void}.png
│                                    #   + enemy_{grunt,speeder,tank,caster,boss_dreadnought}.png
```

---

## Implemented Features

### Enemy Stats (base values — scale with level)
| Monster | HP | Speed | Contact Dmg | XP | Charge | Spawns |
|---|---|---|---|---|---|---|
| Grunt | 30 | 80 | 10 | 10 | 5 | Always |
| Speeder | 18 | 210 | 7 | 5 | 3 | Lvl 3+, 35–50% of regular |
| Tank | 160 | 45 | 18 | 30 | 15 | Lvl 5+, 15s→7s timer |
| Caster | 40 | 55 | 6 | 20 | 7 | Lvl 7+, 15% of regular |
| Dreadnought | 800 | 30 | 28 | 0 | 30 | Phase 0 boss |
| (remaining 9 bosses scale up to Singularity 6000 HP) | | | | | | |

### Phase Progression (`bossPhase % 10`)
| Phase | Background | Enemy Theme | Boss |
|---|---|---|---|
| 0 | Deep Space | Organic / rocky | Dreadnought |
| 1 | Alien Planet Sky | Mechanical steel | Void Tyrant |
| 2 | Blood Moon | Void-corrupted | Leviathan |
| 3–9 | (see CLAUDE.md history for full table) | | |

- `effectiveLevel = currentLevel + bossPhase × 8` for scaling
- XP per kill × `1 + bossPhase × 0.25`

### XP & Level-Up
- **Threshold**: `60 + 40 × level`; **Lucky Draw** (20% chance → 2 picks); **Boss kill** → 3 picks ("BOSS REWARD")
- Weapon upgrade cap level 10; damage × 1.3 per upgrade

### Game-Over Screen
- Shows **Level · Kills · Play time** (m:ss, excludes pauses — tracked via `NovaboltGame._playTimeSeconds` accumulated in `update()`)
- Best stats row; NOVA coins earned; Watch Ad → Continue (once per run)
- After ad: game-over overlay closes, **CountdownOverlay** shows 3-2-1 "GET READY" over frozen game world, then `resumeEngine()`

### Ship Damage Visuals (`player.dart`)
- < 75% HP: hairline cracks; < 50%: smoke; < 25%: fire + scorched wing; < 10%: pulsing red glow (sine-wave via `_damageTime`)

### Force Field Upgrade (`weapon_sword_aura.dart`)
- Base: 3 gold dots orbiting 70px ring; each upgrade adds 1 counter-orbiting inner ball at 65% radius

### AdMob / Coins / Shop
- Rewarded ad → Continue at 50% HP (once); interstitial on menu return; music pauses on ad, resumes on dismiss
- 6 ship skins, 4 shield skins, 4 Nova beam colours — see `coin_manager.dart` for IDs and prices

---

## Key Technical Decisions & Gotchas

1. **Camera origin**: `camera.viewfinder.anchor = Anchor.topLeft` — world == screen coords. Don't change.
2. **ATT before AdMob**: order in `main.dart _initialize()` is mandatory — Apple rejected v1.0 for skipping it.
3. **Weapons as Player children**: render in Player local space; draw at `(size.x/2, size.y/2)`.
4. **flame_audio path fix**: `FlameAudio.updatePrefix('assets/')` — audio files are in `assets/`, not `assets/audio/`.
5. **Flame images path fix**: `Flame.images.prefix = 'assets/'` set in `main()` before `runApp()` — required so `Sprite.load('sprites/foo.png')` resolves to `assets/sprites/foo.png` instead of Flame's default `assets/images/`.
6. **pubspec assets**: `- assets/` covers only root-level files. Subdirectories need explicit entries — `- assets/sprites/` is now listed.
7. **Sprite-first pattern** (phase-0 monsters + player): each component has a `Sprite? _sprite` loaded in `onLoad()` inside try/catch. If null (file missing or load failed), falls back silently to canvas drawing. Caster keeps `_renderBarrel()` drawn on top of its sprite.
8. **CountdownOverlay**: added to `overlayBuilderMap` in `main.dart`. `continueWithHalfHp()` adds `'Countdown'` instead of calling `resumeEngine()` directly. The overlay removes itself and calls `resumeEngine()` after the tick.
9. **HomingBolt skips `super.update()`**: handles own movement so fixed-direction Projectile.update() doesn't override steering.
10. **Boss death hook**: `Monster._die()` → `onDie()` virtual → `BossMonster.onDie()` → `game.onBossKilled()`.
11. **Multi-pick overlay trick**: `overlays.remove('LevelUp')` then `overlays.add('LevelUp')` forces Flutter rebuild with fresh cards.
12. **`isBossReward` flag**: set by `_showLevelUp(isBossKill: true)`, read by `level_up_screen.dart` for red header. Cleared in `resumeFromLevelUp()` and `restart()`.
13. **audioplayers 6.6.0**: `setVolume(double)` is the correct API (no named parameter).

---

## Sprite Work — Uncommitted, Under Consideration

The sprite integration is **not committed** and the user is considering reverting to canvas-only drawings. Current state:
- `scripts/generate_sprites.py` — PixelLab API script (pixflux model, `view: "high top-down"`, `no_background: true`). Run: `python3 scripts/generate_sprites.py --api-key KEY`. Re-generate individual sprites with `--only player_default`.
- `assets/sprites/` — 11 PNGs already generated (all 6 player skins + 5 phase-0 enemies)
- Component changes wired but **unstaged**: `player.dart`, `monster_grunt/speeder/tank/caster.dart`, `monster_boss_dreadnought.dart`, `main.dart`, `pubspec.yaml`

**To revert**: `git checkout -- lib/ pubspec.yaml` and delete `assets/sprites/` and `scripts/`.  
**To keep**: `git add lib/ pubspec.yaml assets/sprites/ scripts/ && git commit`.

---

## App Store

- **iOS**: v1.0.0 (build 3) — approved and live as of 2026-05-12
- **Android**: AAB 1.0.0+3 in internal testing as of 2026-05-12; target production ~2026-05-18
- To submit new build: bump `version` in `pubspec.yaml`, `flutter build ipa --release`, upload via Transporter
- **Bundle IDs**: iOS + Android both `com.sammorrison.novabolt`

### ATT Reset for Testing
1. Settings → Privacy & Security → Tracking → "Allow Apps to Request to Track" ON
2. Delete Novabolt, reinstall via `flutter run -d "Samsimus"`

---

## What's Left

| Priority | Feature | Notes |
|---|---|---|
| Done | **iOS App Store** | Live as of 2026-05-12 |
| High | **Android Play Store** | Internal testing; promote to production |
| Undecided | **PixelLab sprites** | Generated PNGs exist; wiring code uncommitted; may revert to canvas |
| Stashed | **Camera-follow / larger world** | `git stash list` → "camera-follow world expansion (WIP)" |
