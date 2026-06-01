from __future__ import annotations

import math
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"
OUT.mkdir(parents=True, exist_ok=True)


def font(size: int, weight: str = "regular") -> ImageFont.FreeTypeFont:
    candidates = {
        "regular": [
            "C:/Windows/Fonts/segoeui.ttf",
            "C:/Windows/Fonts/arial.ttf",
        ],
        "semibold": [
            "C:/Windows/Fonts/seguisb.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ],
        "bold": [
            "C:/Windows/Fonts/segoeuib.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ],
        "black": [
            "C:/Windows/Fonts/segoeuib.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ],
    }
    for candidate in candidates.get(weight, candidates["regular"]):
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def gradient(size: tuple[int, int], colors: list[tuple[int, int, int]]) -> Image.Image:
    w, h = size
    small_w, small_h = min(320, w), min(320, h)
    img = Image.new("RGB", (small_w, small_h))
    px = img.load()
    for y in range(small_h):
        for x in range(small_w):
            t = (x / max(1, small_w - 1) * 0.35) + (y / max(1, small_h - 1) * 0.65)
            idx = min(len(colors) - 2, int(t * (len(colors) - 1)))
            local = (t * (len(colors) - 1)) - idx
            c1, c2 = colors[idx], colors[idx + 1]
            px[x, y] = tuple(int(c1[i] * (1 - local) + c2[i] * local) for i in range(3))
    return img.resize(size, Image.Resampling.BICUBIC)


def add_glow(img: Image.Image, center: tuple[int, int], color: tuple[int, int, int], radius: int, alpha: int) -> None:
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    x, y = center
    d.ellipse((x - radius, y - radius, x + radius, y + radius), fill=(*color, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(radius // 2))
    img.alpha_composite(layer)


def draw_text(
    d: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int] | tuple[int, int, int] = (255, 255, 255, 255),
    max_width: int | None = None,
    line_spacing: int = 8,
) -> int:
    x, y = xy
    if max_width is None:
        d.text((x, y), text, font=fnt, fill=fill)
        return y + d.textbbox((x, y), text, font=fnt)[3] - d.textbbox((x, y), text, font=fnt)[1]
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        attempt = f"{current} {word}".strip()
        if d.textlength(attempt, font=fnt) <= max_width or not current:
            current = attempt
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    for line in lines:
        d.text((x, y), line, font=fnt, fill=fill)
        bbox = d.textbbox((x, y), line, font=fnt)
        y += bbox[3] - bbox[1] + line_spacing
    return y


def rounded_rect(d: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1) -> None:
    d.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def human_portrait(size: tuple[int, int], accent: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = gradient(size, [(12, 14, 28), (31, 22, 52), (8, 42, 78)]).convert("RGBA")
    add_glow(img, (int(w * 0.62), int(h * 0.18)), accent, int(w * 0.5), 120)
    d = ImageDraw.Draw(img, "RGBA")
    d.ellipse((w * 0.36, h * 0.18, w * 0.64, h * 0.46), fill=(220, 190, 160, 245))
    d.rounded_rectangle((w * 0.28, h * 0.43, w * 0.72, h * 0.88), radius=int(w * 0.18), fill=(18, 24, 38, 250))
    d.arc((w * 0.25, h * 0.12, w * 0.75, h * 0.58), start=198, end=342, fill=(255, 215, 115, 185), width=max(3, w // 35))
    d.line((w * 0.38, h * 0.31, w * 0.46, h * 0.31), fill=(32, 24, 24, 180), width=max(2, w // 80))
    d.line((w * 0.54, h * 0.31, w * 0.62, h * 0.31), fill=(32, 24, 24, 180), width=max(2, w // 80))
    d.arc((w * 0.43, h * 0.33, w * 0.58, h * 0.42), start=10, end=170, fill=(130, 82, 74, 180), width=max(2, w // 90))
    return img


def device_frame(size: tuple[int, int], kind: str, screen_title: str, subtitle: str, score: int, mission: str) -> Image.Image:
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img, "RGBA")
    radius = 74 if kind == "iphone" else 46
    rounded_rect(d, (0, 0, w, h), radius, (8, 9, 15, 255), (76, 105, 180, 180), 4)
    rounded_rect(d, (18, 18, w - 18, h - 18), max(22, radius - 22), (6, 7, 12, 255), (255, 255, 255, 35), 2)
    if kind == "iphone":
        rounded_rect(d, (w // 2 - 72, 24, w // 2 + 72, 56), 18, (0, 0, 0, 230))
    else:
        rounded_rect(d, (w // 2 - 54, 16, w // 2 + 54, 28), 8, (0, 0, 0, 180))

    inset = 48 if kind == "iphone" else 60
    top = 86 if kind == "iphone" else 64
    draw_text(d, (inset, top), "NextSelf AI", font(24 if kind == "iphone" else 28, "bold"), (255, 218, 112, 255))
    y = draw_text(d, (inset, top + 46), screen_title, font(46 if kind == "iphone" else 58, "black"), max_width=w - inset * 2, line_spacing=4)
    draw_text(d, (inset, y + 8), subtitle, font(22 if kind == "iphone" else 26, "regular"), (218, 226, 255, 205), w - inset * 2, 8)

    card_y = int(h * 0.36)
    rounded_rect(d, (inset, card_y, w - inset, card_y + int(h * 0.22)), 34, (255, 255, 255, 24), (115, 157, 255, 90), 2)
    cx = inset + 112
    cy = card_y + int(h * 0.11)
    d.ellipse((cx - 72, cy - 72, cx + 72, cy + 72), outline=(42, 152, 255, 255), width=14)
    d.arc((cx - 72, cy - 72, cx + 72, cy + 72), -90, -90 + int(score * 3.6), fill=(255, 216, 112, 255), width=14)
    score_txt = str(score)
    tw = d.textlength(score_txt, font=font(44, "black"))
    d.text((cx - tw / 2, cy - 31), score_txt, font=font(44, "black"), fill=(255, 255, 255, 255))
    draw_text(d, (inset + 220, card_y + 48), "NextSelf Score", font(24 if kind == "iphone" else 30, "bold"), (255, 255, 255, 255))
    draw_text(d, (inset + 220, card_y + 88), "Identity progress, consistency, journaling, and completed missions.", font(18 if kind == "iphone" else 23), (220, 226, 255, 185), w - inset * 2 - 220)

    mission_y = card_y + int(h * 0.26)
    rounded_rect(d, (inset, mission_y, w - inset, mission_y + int(h * 0.11)), 30, (31, 74, 132, 170), (255, 255, 255, 45), 2)
    d.ellipse((inset + 30, mission_y + 36, inset + 78, mission_y + 84), fill=(68, 171, 255, 255))
    d.line((inset + 43, mission_y + 60, inset + 55, mission_y + 72, inset + 70, mission_y + 48), fill=(255, 255, 255, 255), width=5)
    draw_text(d, (inset + 105, mission_y + 30), mission, font(24 if kind == "iphone" else 30, "bold"), max_width=w - inset * 2 - 126)

    bottom_y = mission_y + int(h * 0.15)
    for i, label in enumerate(["Future Self", "Voice Journal", "AI Coach"]):
        x0 = inset + i * ((w - inset * 2 - 22) // 3 + 11)
        x1 = x0 + ((w - inset * 2 - 22) // 3)
        rounded_rect(d, (x0, bottom_y, x1, bottom_y + 96), 24, (255, 255, 255, 18), (255, 255, 255, 35), 1)
        draw_text(d, (x0 + 16, bottom_y + 28), label, font(17 if kind == "iphone" else 22, "semibold"), max_width=x1 - x0 - 28)
    return img


def compose_store_screenshot(
    filename: str,
    size: tuple[int, int],
    headline: str,
    subhead: str,
    device_kind: str,
    screen_title: str,
    mission: str,
    score: int,
) -> None:
    canvas = gradient(size, [(1, 2, 7), (8, 18, 42), (54, 24, 86), (5, 6, 13)]).convert("RGBA")
    add_glow(canvas, (int(size[0] * 0.78), int(size[1] * 0.14)), (39, 156, 255), int(size[0] * 0.35), 145)
    add_glow(canvas, (int(size[0] * 0.15), int(size[1] * 0.86)), (122, 63, 255), int(size[0] * 0.32), 115)
    d = ImageDraw.Draw(canvas, "RGBA")
    margin = int(size[0] * 0.07)
    y = int(size[1] * 0.065)
    draw_text(d, (margin, y), headline, font(int(size[0] * 0.072), "black"), (255, 255, 255, 255), int(size[0] * 0.78), 8)
    draw_text(d, (margin, y + int(size[1] * 0.145)), subhead, font(int(size[0] * 0.027), "regular"), (224, 232, 255, 210), int(size[0] * 0.74), 10)

    portrait = human_portrait((int(size[0] * 0.24), int(size[1] * 0.18)), (46, 150, 255))
    canvas.alpha_composite(portrait, (size[0] - margin - portrait.width, int(size[1] * 0.075)))

    if device_kind == "iphone":
        frame_w = int(size[0] * 0.62)
        frame_h = int(frame_w * 2.05)
    else:
        frame_w = int(size[0] * 0.76)
        frame_h = int(frame_w * 1.36)
    frame = device_frame((frame_w, frame_h), device_kind, screen_title, "Meet the person you're becoming.", score, mission)
    x = (size[0] - frame_w) // 2
    y2 = size[1] - frame_h - int(size[1] * 0.035)
    shadow = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((0, 0, frame_w, frame_h), radius=80, fill=(0, 0, 0, 180))
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    canvas.alpha_composite(shadow, (x + 18, y2 + 22))
    canvas.alpha_composite(frame, (x, y2))
    canvas.convert("RGB").save(OUT / filename, quality=95)


def compose_subscription_review() -> None:
    size = (1290, 2796)
    canvas = gradient(size, [(2, 3, 10), (11, 24, 55), (52, 22, 82), (6, 7, 14)]).convert("RGBA")
    add_glow(canvas, (980, 270), (41, 151, 255), 480, 130)
    d = ImageDraw.Draw(canvas, "RGBA")
    draw_text(d, (90, 130), "Subscription Review", font(76, "black"), max_width=1040)
    draw_text(d, (90, 235), "Clear plans, visible pricing, wellness-only scope, and restore access included.", font(34), (224, 232, 255, 210), 1010)

    plans = [
        ("Free", "Limited", ["Limited missions", "Basic journaling", "Limited AI messages"]),
        ("Premium Monthly", "£9.99", ["Unlimited AI coaching", "Voice journaling", "Future-self conversations", "Analytics"]),
        ("Premium Yearly", "£79.99", ["Best value Premium", "Progress reports", "Premium themes", "All Premium features"]),
        ("Elite Monthly", "£19.99", ["Advanced coaching personalities", "Deep reports", "Premium avatars", "Exclusive themes"]),
    ]
    y = 420
    for name, price, features in plans:
        rounded_rect(d, (90, y, 1200, y + 405), 42, (255, 255, 255, 23), (114, 157, 255, 90), 2)
        d.text((135, y + 45), name, font=font(44, "bold"), fill=(255, 255, 255, 255))
        d.text((910, y + 48), price, font=font(42, "bold"), fill=(255, 217, 112, 255))
        fy = y + 126
        for feature in features:
            d.ellipse((138, fy + 9, 168, fy + 39), fill=(65, 172, 255, 255))
            d.line((146, fy + 24, 155, fy + 33, 166, fy + 15), fill=(255, 255, 255, 255), width=4)
            d.text((185, fy), feature, font=font(30), fill=(225, 232, 255, 218))
            fy += 58
        y += 465

    rounded_rect(d, (90, 2355, 1200, 2605), 38, (255, 255, 255, 18), (255, 216, 112, 90), 2)
    draw_text(d, (130, 2395), "Wellness disclaimer", font(34, "bold"), (255, 216, 112, 255))
    draw_text(
        d,
        (130, 2450),
        "NextSelf AI is a personal growth and wellness tool. It is not therapy, diagnosis, medical advice, addiction treatment, crisis intervention, or a replacement for professional healthcare.",
        font(28),
        (232, 236, 248, 205),
        1020,
        8,
    )
    canvas.convert("RGB").save(OUT / "subscription-review.png", quality=95)


def compose_promo(filename: str, size: tuple[int, int]) -> None:
    canvas = gradient(size, [(1, 2, 8), (8, 30, 66), (72, 34, 104), (7, 7, 13)]).convert("RGBA")
    add_glow(canvas, (int(size[0] * 0.78), int(size[1] * 0.2)), (54, 164, 255), int(size[0] * 0.42), 155)
    add_glow(canvas, (int(size[0] * 0.20), int(size[1] * 0.85)), (255, 215, 112), int(size[0] * 0.28), 95)
    d = ImageDraw.Draw(canvas, "RGBA")
    margin = int(size[0] * 0.07)
    draw_text(d, (margin, int(size[1] * 0.12)), "Meet the person you're becoming.", font(int(size[0] * 0.065), "black"), max_width=int(size[0] * 0.62), line_spacing=8)
    draw_text(d, (margin, int(size[1] * 0.35)), "AI coaching, voice journaling, daily missions, comeback plans, and future-self conversations.", font(int(size[0] * 0.025)), (230, 236, 255, 212), int(size[0] * 0.55), 10)
    d.text((margin, int(size[1] * 0.79)), "NextSelf AI", font=font(int(size[0] * 0.03), "bold"), fill=(255, 216, 112, 255))
    d.text((margin, int(size[1] * 0.835)), "Your future self is waiting.", font=font(int(size[0] * 0.025)), fill=(232, 236, 255, 205))

    portrait = human_portrait((int(size[0] * 0.35), int(size[1] * 0.56)), (48, 158, 255))
    canvas.alpha_composite(portrait, (int(size[0] * 0.58), int(size[1] * 0.18)))
    frame = device_frame((int(size[0] * 0.26), int(size[0] * 0.53)), "iphone", "Future Self", "Your future self is waiting.", 86, "One focused mission today")
    canvas.alpha_composite(frame, (int(size[0] * 0.46), int(size[1] * 0.35)))
    canvas.convert("RGB").save(OUT / filename, quality=95)


def main() -> None:
    compose_store_screenshot(
        "iphone-01-dashboard.png",
        (1290, 2796),
        "Your future self, in your pocket.",
        "A premium daily dashboard for identity-based transformation.",
        "iphone",
        "Today",
        "Write one future-self paragraph",
        72,
    )
    compose_store_screenshot(
        "iphone-02-voice-journal.png",
        (1290, 2796),
        "Turn reflection into momentum.",
        "Voice journaling with live transcription and AI growth summaries.",
        "iphone",
        "Voice Journal",
        "Record a two-minute reflection",
        78,
    )
    compose_store_screenshot(
        "iphone-03-future-self.png",
        (1290, 2796),
        "Talk to the person you're becoming.",
        "Future-self conversations that motivate consistency and action.",
        "iphone",
        "Future Self",
        "Complete one focused sprint",
        84,
    )
    compose_store_screenshot(
        "ipad-01-transformation-dashboard.png",
        (2048, 2732),
        "A cinematic command center for personal growth.",
        "Track missions, journal themes, milestones, and NextSelf Score on iPad.",
        "ipad",
        "Transformation",
        "Review your growth story",
        86,
    )
    compose_store_screenshot(
        "ipad-02-analytics.png",
        (2048, 2732),
        "See the story behind your progress.",
        "Premium analytics for consistency, growth velocity, and identity levels.",
        "ipad",
        "Growth",
        "Protect tomorrow's first mission",
        91,
    )
    compose_subscription_review()
    compose_promo("promo-landscape-16x9.png", (1920, 1080))
    compose_promo("promo-square-1x1.png", (1600, 1600))


if __name__ == "__main__":
    main()
