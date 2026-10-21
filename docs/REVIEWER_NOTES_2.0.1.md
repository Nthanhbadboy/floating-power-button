# Notes for the AppGallery review team — v2.0.1

**App:** Power & Volume - Lock Screen & Sound Control
**Developer:** NGUYEN MINH THANH
**Contact:** alphaplusthanh82@gmail.com
**Privacy Policy:** https://power-volume-privacy.vercel.app/privacy-policy.html
(English / Vietnamese / Simplified Chinese 简体中文）

## What changed in response to the previous review

1. **Privacy Policy pop-up on first launch** — Install the app fresh and open
   it: a non-dismissible pop-up asks the user to read and agree to the
   Privacy Policy and Terms of Service. The main screen cannot be used (and
   no service/permission/ad runs) until **Agree** is tapped; Decline exits.
2. **Simplified Chinese Privacy Policy** — Available online at the URL above
   (`#zh` section) and inside the app: footer → Privacy Policy → **中文** tab.
3. **Identity in the Privacy Policy** — The policy names the
   Developer (**NGUYEN MINH THANH**), the App (**Power & Volume - Lock Screen
   & Sound Control**) and the contact email, matching AppGallery Connect.
4. **Foreground Service consent** — The "Keep-Alive Foreground Service" switch
   (Permissions & Keep-Alive Settings) is **OFF by default**. Turning it on
   shows an explanation dialog first; the service and its persistent
   "Power & Volume Active" notification (LOCK / VOLUME actions) start only
   after the user taps **Enable**. No service starts automatically on
   install or first launch. If (and only if) the user leaves the switch
   ON, the service may resume after a device reboot or an app update;
   turning the switch OFF stops it and prevents any resume. The app also
   adds two Quick Settings tiles (Lock Screen / Volume) and launcher
   long-press shortcuts, imported from the previous PC build.

## How to test the main features
- **Lock Screen:** enable Accessibility Service (row 1 in "Permissions &
  Keep-Alive Settings"), then tap the red **LOCK SCREEN** card.
- **Volume Panel:** tap the blue **VOLUME PANEL** card — no permission needed.
- **Background guide:** the "Device-Specific Background Guide" card
  auto-detects the device brand (Huawei/Xiaomi/Samsung/OPPO/Vivo) and gives
  step-by-step keep-alive instructions with a shortcut button into the
  OEM battery settings.
- No account or login is required. The app collects no personal data.
