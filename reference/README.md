# reference/ — original cp-pos UI screenshots (match these 100%)

These are screenshots of the **live original** Apps Script app. Your Flutter UI must match them pixel-for-pixel (colors, spacing, layout, Thai wording). The customer flow is the priority, but home/login/ops must match too.

Live original (for re-checking any screen):
`https://script.google.com/macros/s/AKfycbwC1ID8_dbDnvLwZQ-bL__SdDtvnu7-5mG-U981IPS5EDUbpOsZFmp3EEm1ijfkiHUZUQ/exec?page=home`
Swap `page=` to `home | order | kitchen | staff | cashier | operations | admin`. Staff pages: PIN `zaq1234`.

## Files
- `orig-home.jpg` — home portal: centered white card, red rounded brand mark `ผ`, red eyebrow "MODERN THAI VITALITY", bold "Phius Order", muted "Phius Thai Kitchen", 2-col portal grid (รวมงานหน้าร้าน featured / หน้าครัว / พนักงาน / แคชเชียร์ / ผู้ดูแล) each with emoji + title + subtitle, hint "หน้าลูกค้าต้องเปิดผ่าน QR ประจำโต๊ะ", footer.
- `orig-login-kitchen.jpg` — login card: back link, brand, role icon 🔥, eyebrow "KITCHEN DISPLAY SYSTEM", h1 "หน้าครัว", desc, PIN field, red "เข้าสู่ระบบ" button, hint "PIN เริ่มต้น: zaq1234".
- `orig-kitchen-board.jpg` — kitchen: header + user chip + logout, 4 summary cards (โต๊ะเปิดอยู่/ออเดอร์ใหม่/กำลังทำ/พร้อมเสิร์ฟ), 3-column kanban (ออเดอร์ใหม่/กำลังทำ/พร้อมเสิร์ฟ) with "✓ ยังไม่มีรายการ" empty state, plus the force-change-PIN modal ("ตั้ง PIN ใหม่ก่อนเริ่มงาน").

## ⚠️ Known defect to FIX
The current Flutter home renders as a **blank/black screen** (see the old `phius-home-portal.png`). That is wrong — it must look like `orig-home.jpg`: warm off-white background `#FBF7F0`, centered card, red accents. Background must be `PhiusTokens.bg`, not black/dark. Check the theme (`scaffoldBackgroundColor`) and that the home route actually builds the portal widget. Fix this as part of the T10 parity pass (or sooner if you touch home again).

Background is ALWAYS warm off-white `#FBF7F0` (`--bg`), never dark. If any screen renders dark, the theme/Scaffold background is wrong.
