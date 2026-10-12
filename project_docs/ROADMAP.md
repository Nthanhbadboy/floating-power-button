# Floating Power Button - Implementation Roadmap

Source of truth: `app_detail.txt` (product scope) and `Ramus_CLI.txt` (external testing rules).
This roadmap is a sequencing plan only - no feature is complete until it is verified on a device (see Milestone 8).

---

## 0. Guiding Constraints

- Two functions only: **Lock Screen** and **Control Volume** (native system volume UI). No third function, no custom volume UI.
- No accounts, backend, or sync. No custom ad-frequency counter.
- Core Android functionality must be verified **before** ad/Billing work is allowed to delay it.
- Trial logic, Pro entitlement, and Ads stay in separate modules; failure in one must not break the others.
- Ramus is an **external test tool** only - never a `pubspec.yaml` or APK dependency.

---

## Milestone 1 - Project Skeleton & Floating Button (Foundation)

**Goal:** a stable overlay button that can be dragged and remembers its position.

- Create the Flutter project (Android-only target), `minSdk = 28` (required by `GLOBAL_ACTION_LOCK_SCREEN`); verify target/compile SDK.
- Minimal UI: Home screen + Settings screen (scaffolding only).
- Native/Kotlin side: foreground `Service` + `WindowManager` overlay window (`TYPE_APPLICATION_OVERLAY`).
- Gesture: tap vs. drag discrimination using `slop`; drag with `OnTouchListener` updating `LayoutParams`.
- Persist position (x, y) + screen metrics in `SharedPreferences` / `DataStore`; clamp on restore and on size/orientation/display-area change.
- Enable/disable toggle in Settings starts/stops the service deterministically.
- **Deliverable:** overlay visible, draggable, position restored after service restart and after rotation.

## Milestone 2 - Function Selection Model

**Goal:** the button reflects only the user's chosen functions.

- Settings option: `LOCK_ONLY` | `VOLUME_ONLY` | `BOTH` (persisted).
- Overlay popup/expander surfaces exactly the enabled actions; **single-function mode = one tap = unambiguous action**.
- State broadcast to the running service; overlay updates without restarting the service.
- Guardrail: no extra buttons or gestures beyond the spec.
- **Deliverable:** all three selection modes verified visually on device.

## Milestone 3 - The Two Actions

**Goal:** both functions work, or fail **honestly**.

- **Control Volume:** `AudioManager.adjustStreamVolume(STREAM_MUSIC, ADJUST_SAME, FLAG_SHOW_UI)`. Verify the native panel appears and volume is *not* changed. Handle unsupported devices safely and record the actual result.
- **Lock Screen:** `AccessibilityService` + `GLOBAL_ACTION_LOCK_SCREEN` (API 28+); declared in `res/xml/accessibility_service_config.xml` + manifest.
- Guardrail: if the service is disabled/unavailable, show a clear explanation + deep link to Settings. **Never report a false success.**
- No automatic locking, no unrelated/undocumented accessibility actions.
- **Deliverable:** both actions verified on a physical device (dev + non-dev Android version if available).

## Milestone 4 - Permissions & Service Lifecycle

**Goal:** correct behavior across permission revocation, restarts, and kill/rebuild.

- Overlay permission: rationale screen -> `ACTION_MANAGE_OVERLAY_PERMISSION` intent -> re-check on `onResume` (never assume a past grant still holds).
- Accessibility permission: in-app disclosure + manual enablement guidance (Google Play consent requirements).
- Centralized permission-state repository: single source of truth consumed by UI and service.
- On revocation: hide/stop the overlay, surface re-enable instructions; never auto-restore revoked permission(s).
- Handle: service stop, task-swipe, force-stop, device reboot, config change, and system-initiated service restart.
- **Deliverable:** all Milestone 8.1 and 8.6 integration combinations exercised at least once.

## Milestone 5 - Free Trial (24h, reactivatable)

**Goal:** time-based trial that survives restarts but not naive clock tampering.

- States: `NOT_ACTIVATED | ACTIVE | EXPIRED` (+ cached Pro flag).
- Activation is **explicit only**; timestamps: `firstActivatedAt`, `activatedAt`, `expiresAtEpochMs`.
- Reactivation = new 24h window from the activation moment, unlimited, never automatic, never stacked; **never gated on an ad being served**.
- Expiry: lock trial-only functions; Settings and reactivation stay reachable.
- Persistence: `SharedPreferences`/`DataStore`, sanitized on read (missing/invalid/corrupt -> treat as not activated).
- Anti-clock-rollback: best-effort signal (e.g. monotonic elapsed-time anchor / max-observed wall clock). No backend - do not claim absolute protection.
- **Deliverable:** all 7 required trial states in app_detail 4.4 tested; accelerated/simulated time tests clearly labelled as such.

## Milestone 6 - AdMob Interstitial (Settings entry only)

**Goal:** ads at exactly one point, and never blocking the app.

- Google Mobile Ads SDK; interstitial loaded + shown **only** on intentional Settings entry.
- Check `isLoaded()` before `show()`; handle load failure / show failure / SDK errors -> Settings still opens normally.
- Rebuild / foreground / config-change debounce so an ad cannot trigger repeatedly.
- Hard guards: **no ads on the overlay or over other apps; none at action time; none blocking Settings.**
- Billing/Ad failures must never break trial activation or core functionality.
- AdMob account-side frequency capping (<=1 impression/user/day) configured **in AdMob**, not in code.
- Test ad unit IDs for dev, real IDs only in release; ad config isolated from core logic.
- **Deliverable:** section 8.5 checklist verified with test ads.

## Milestone 7 - Pro (Google Play Billing, one-time)

**Goal:** Pro granted only from verified purchase state; verified claims only.

- Play Billing Library integration, one-time in-app product, connection + retry handling.
- Purchase states: `PURCHASED` -> grant; `PENDING` / `CANCELED` / `FAILED` / not-owned -> no grant.
- Acknowledge purchases per Play policy; `queryPurchases` on startup for restore.
- Cache the verified state for fast startup, but **always verify with Play**; no false Pro, no forced repurchase.
- Pro effects: no ads, no trial expiry, functions available; Pro does **not** grant overlay/Accessibility permissions.
- Debug-only override for local core-functionality testing; must be absent/disabled in release builds.
- **Deliverable:** pending / canceled / failed / success / restore cases tested where the test infra supports it; otherwise marked BLOCKED.

## Milestone 8 - Verification, Hardening & Release Readiness

**Goal:** evidence, not compilation.

- `flutter analyze` + unit tests for the trial state machine, position clamping, ad/billing guards, and permission-state logic.
- Build debug + release APK; confirm **no Ramus, no test keys, no test ad IDs in release**.
- Run the Ramus workflow (Ramus_CLI section 3): inspect -> env check -> build -> install -> execute -> evidence -> compare -> report.
- Produce the test report with `PASS / FAIL / BLOCKED / NOT TESTED` + evidence paths + environment; explicitly separate **confirmed** vs **unverified**.
- Device-check matrix: lock screen, volume UI, overlay, permissions, reboot persistence, no-ads-over-overlay.
- Final policy review: AccessibilityService disclosure/consent, ad placement, Play Billing; note the remaining AdMob/Play console configuration steps.
- Definition of Done per app_detail section 9; do not declare release-ready from source completion or a build.

---

## Dependency Order

```
M1 skeleton/overlay -> M2 selection model -> M3 actions -> M4 permissions/lifecycle
      -> M5 trial -> M6 ads -----v
                                  --> M8 verification & release
      -> M7 Pro/Billing ---------^
```

M6 and M7 both depend on M4+M5 and are independent of each other; they must not block the M1-M4 device verification.

## Key Risks

| Risk | Mitigation |
| --- | --- |
| `GLOBAL_ACTION_LOCK_SCREEN` unsupported (API < 28) | `minSdk = 28`; runtime capability check + honest failure message |
| OEM/version differences in overlay & volume UI | Test 2+ Android versions; record actual behavior, never assume |
| Accessibility approval risk on Google Play | Tight scope (only the lock-screen global action), clear disclosure/consent, documented rationale |
| Clock manipulation of the trial | Best-effort anchors only, no backend; disclose the limitation |
| Ad/Billing SDK failure breaking core flows | Isolate modules, defensive wrappers, ad unavailable -> Settings opens normally |

## Next Step

Begin Milestone 1: scaffold the Flutter project and the overlay service, then verify the button is visible, draggable, and position-restored on a real device before adding any other feature.