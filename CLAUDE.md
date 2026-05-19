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
- All visuals are **code-drawn** (Canvas primitives) — no image assets in gameplay
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
│   ├── novabolt_game.dart            # FlameGame root — bossPhase, killCount, isNewBest, isBossReward, continueWithHalfHp()
│   ├── components/
│   │   ├── player.dart               # Fighter jet; skin-aware render; progressive damage visuals; _damageTime timer
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
│   │   ├── monster_grunt.dart        # 10-phase render: phases 0/1/2 unique renderers; phases 3-9 use _renderThemed
│   │   ├── monster_tank.dart         # 10-phase render: phases 0/1/2 unique renderers; phases 3-9 use _renderThemed
│   │   ├── monster_speeder.dart      # 10-phase render: phases 0/1/2 unique renderers; phases 3-9 use _renderThemed
│   │   ├── monster_caster.dart       # Ranged; keeps 200px range; fires CasterProjectile every 2.5s; 10-phase render
│   │   ├── caster_projectile.dart    # Lime green orb (12dmg, speed 220); hits Player only
│   │   ├── monster_boss.dart         # Abstract BossMonster — fireSpecialAttack() overridable; onDie() → onBossKilled()
│   │   ├── monster_boss_dreadnought.dart    # Phase 0: purple warship; 16-shot radial special; enrages at 50% HP
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
│   └── game_over_screen.dart         # Run stats + all-time bests + NEW BEST badge; +N NOVA earned; Watch Ad → Continue
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
| Void Tyrant | 1600 | 45 | 40 | 0 | 50 | Phase 1 boss |
| Leviathan | 2400 | 35 | 45 | 0 | 60 | Phase 2 boss |
| Blood Colossus | 3200 | 25 | 52 | 0 | 70 | Phase 3 boss |
| Storm Phantom | 2000 | 65 | 38 | 0 | 55 | Phase 4 boss |
| Cosmic Behemoth | 4000 | 20 | 58 | 0 | 80 | Phase 5 boss |
| Shadow Reaper | 2800 | 55 | 48 | 0 | 65 | Phase 6 boss |
| Solar Titan | 3600 | 30 | 55 | 0 | 75 | Phase 7 boss |
| Void Emperor | 4800 | 40 | 62 | 0 | 90 | Phase 8 boss |
| Singularity | 6000 | 35 | 70 | 0 | 100 | Phase 9 boss |

### Phase Progression (cycles every 10 bosses via `bossPhase % 10`)
| Phase | Background | Enemy Theme | Boss |
|---|---|---|---|
| 0 | Deep Space (dark stars) | Organic / rocky | Dreadnought |
| 1 | Alien Planet Sky (indigo-blue gradient + puffy white clouds) | Mechanical steel | Void Tyrant |
| 2 | Blood Moon (red nebula) | Void-corrupted | Leviathan |
| 3 | Crimson Void | Deep red/black | Blood Colossus |
| 4 | Storm Nebula | Purple storm | Storm Phantom |
| 5 | Crystal Expanse | Cyan/teal | Cosmic Behemoth |
| 6 | Solar Flare | Orange/gold | Shadow Reaper |
| 7 | Galactic Core | Deep blue | Solar Titan |
| 8 | Shadow Realm | Dark purple | Void Emperor |
| 9 | Singularity | White/black event horizon | Singularity |

- `effectiveLevel = currentLevel + bossPhase × 8` for HP/speed scaling
- XP per kill multiplied by `1 + bossPhase × 0.25`
- After boss 10 the cycle repeats from phase 0 (visuals reset) but difficulty keeps compounding

### XP & Level-Up
- **Threshold**: `60 + 40 × level` (linear)
- **Per-kill XP**: `xpValue × (1 + level ~/ 7) × (1 + bossPhase × 0.25)`
- **Picks per level-up**: 1 pick normally; 20% chance of a "Lucky Draw" (2 picks); boss kill always gives 3 picks ("BOSS REWARD" — red header in UI)
- Bonus HP cards (20% chance each) auto-applied before showing selectable cards
- Weapon upgrade cap is level 10 (`upgradeLevel < 10` in `upgrade_cards.dart`)
- Card title shows `upgradeLevel + 1` (the level you're upgrading *to*); `applyUpgrade()` increments `upgradeLevel` and multiplies damage × 1.3

### Ship Damage Visuals (`player.dart`)
Progressive overlays drawn inside the rotated canvas block — rotate with the ship:
- **< 75% HP**: Two hairline cracks on fuselage
- **< 50% HP**: Two more cracks + dark smoke cloud from right engine
- **< 25% HP**: Left wing scorched (dark overlay) + orange fire from left engine
- **< 10% HP**: Pulsing red danger glow over whole ship + both engines on fire (sine-wave pulse via `_damageTime`)

### Force Field Upgrade Visual (`weapon_sword_aura.dart`)
- Base: 3 gold dots orbiting the 70px ring clockwise
- Each upgrade beyond level 1 adds one pale-gold ball counter-orbiting at 65% radius (1.5× speed)
- At level 10: 3 outer dots + 9 inner balls

### Boss Music
- `AudioManager.playBoss()` crossfades from game track to a random boss track (`Boss Battle.wav` or `Boss Battle 2.wav`)
- `AudioManager.playGame()` called after boss kill — crossfades back to a random game track
- Crossfade: 20 steps × 75ms fade out, swap track, fade in; `_fadeGeneration` counter cancels any in-progress fade

### AdMob Ads
- **iOS App ID**: `ca-app-pub-7289760521218684~5384220043`
- **Rewarded** (iOS `…/2091997829`): "Watch Ad → Continue (50% HP)"; once per run
- **Interstitial** (iOS `…/6268642442`): shown on return to menu
- Music pauses on ad show, resumes on dismiss; both ads auto-preload after dismiss

### NOVA Coins & Shop
- **Earning**: `level × 10` NOVA per run, awarded on game-over exit
- **Ship Skins** (6): Gold Fighter (free), Ice Falcon (300), Flame Hawk (500), Shadow Viper (700), Solar Flare (900), Void Phantom (1200)
- **Shield Skins** (4): Energy Barrier (free, cyan), Plasma Guard (250, orange), Void Ward (500, purple), Gold Guard (750, gold)
- **Nova Beam** (4): Cyan Beam (free), Inferno (350, red-orange), Void Pulse (650, magenta), Eclipse (950, gold)

---

## Key Technical Decisions & Gotchas

1. **Camera origin**: `camera.viewfinder.anchor = Anchor.topLeft` — world == screen coords. Don't change or all spawn positions break.

2. **ATT before AdMob**: `main.dart _initialize()` requests `AppTrackingTransparency` permission before calling `AdManager.instance.init()`. If you skip this order, iOS won't show the ATT prompt and Apple will reject the app (happened in v1.0 review).

3. **Weapons as Player children**: Weapon `render()` is in Player local space — draw at `(size.x/2, size.y/2)` for center. Damage overlays in `player.dart` must also be inside `canvas.save()/restore()` to rotate with the ship.

4. **HomingBolt skips `super.update()`**: Handles own movement so fixed-direction Projectile.update() doesn't override steering.

5. **ExplosiveBolt/FrostShard/BossProjectile don't call `super.onCollisionStart()`**: Override completely. BossProjectile only responds to `Player`.

6. **Boss death hook**: `Monster._die()` calls `onDie()` virtual. `BossMonster.onDie()` calls `game.onBossKilled()`.

7. **Multi-pick overlay trick**: `overlays.remove('LevelUp')` then `overlays.add('LevelUp')` forces Flutter rebuild with fresh cards.

8. **`Projectile.lifetime` is public**: Renamed from `_lifetime` so `HomingBolt` can increment it without `super.update()`.

9. **flame_audio path fix**: `FlameAudio.updatePrefix('assets/')` — flame_audio defaults to `assets/audio/` which breaks since audio files are directly in `assets/`.

10. **AdManager interstitial fallthrough**: If no interstitial is loaded, `showInterstitialAd()` calls `onDismissed` immediately so the menu transition is never blocked.

11. **Background re-init**: `onBossKilled()` and `restart()` both remove and re-add `StarBackground` so the phase-correct background is shown immediately.

12. **Bundle IDs**: iOS `com.sammorrison.novabolt` (Runner target + RunnerTests), Android `com.sammorrison.novabolt`.

13. **isUpgradeable on Weapon**: `WeaponExplosiveBolt` sets `isUpgradeable = false`; `generateUpgradeCards()` skips it in the upgrade pool after first pick.

14. **`fireSpecialAttack()` is public on BossMonster**: Renamed from `_fireSpecialAttack` (library-private) so subclasses (e.g. `MonsterBossSingularity`) can override it.

15. **10-phase monster visuals**: All 4 monster types use `bossPhase % 10` in their `render()` switch. Phases 0, 1, and 2 each have a unique hand-drawn renderer (`_renderOrganic`, `_renderMechanical`, `_renderVoid`); phases 3-9 use compact const color tables + `_renderThemed()`. Previously phase 0 was incorrectly falling through to `_renderThemed` — fixed in commit `c9b426a`.

16. **audioplayers 6.6.0**: `FlameAudio.bgm.audioPlayer` is non-nullable — no null checks needed. `setVolume(double)` is the correct API (no named parameter).

17. **`isBossReward` flag**: Set on `NovaboltGame` by `_showLevelUp(isBossKill: true)`. Read by `level_up_screen.dart` to show red "BOSS REWARD!" header and red pick counter. Cleared in `resumeFromLevelUp()` and `restart()`.

---

## App Store

- **iOS**: v1.0 rejected 2026-05-08 (Guideline 2.1 — ATT prompt not appearing). Fixed ATT order, submitted build `1.0.0 (2)` on 2026-05-09. **Approved and live as of 2026-05-12.**
- To submit a new build: bump `version` in `pubspec.yaml` (e.g. `1.0.0+3`), run `flutter build ipa --release`, upload via Transporter, then select the new build in App Store Connect and resubmit.
- **Privacy policy**: `docs/privacy.html` — enable GitHub Pages (main branch, /docs folder) so `https://samsimus12.github.io/novabolt/privacy.html` is live.
- **Android**: not yet submitted.

### ATT Reset for Testing
1. Settings → Privacy & Security → Tracking → turn "Allow Apps to Request to Track" **ON**
2. Delete Novabolt from the device
3. Reinstall via `flutter run -d "Samsimus"`

---

## What's Left

| Priority | Feature | Notes |
|---|---|---|
| Done | **iOS App Store** | Live as of 2026-05-12 |
| High | **Android Play Store** | AAB 1.0.0+3 in internal testing as of 2026-05-12; promote to production once approved (~2026-05-18) |
| Stashed | **Camera-follow / larger world** | `git stash list` → "camera-follow world expansion (WIP)"; needs more work before it feels right |
