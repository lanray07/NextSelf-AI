from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

from generate_marketing_assets import add_glow, device_frame, draw_text, font, rounded_rect


ROOT = Path(__file__).resolve().parent
SOURCES = ROOT / "humanized-sources"
OUT = ROOT / "humanized-premium"
OUT.mkdir(parents=True, exist_ok=True)


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    image = image.convert("RGB")
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize((int(image.width * scale), int(image.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - size[0]) // 2
    top = (resized.height - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1]))


def cinematic_base(source: Path, size: tuple[int, int]) -> Image.Image:
    base = cover(Image.open(source), size).convert("RGBA")
    blur = base.filter(ImageFilter.GaussianBlur(2))
    base = Image.blend(base, blur, 0.12)
    overlay = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay, "RGBA")
    d.rectangle((0, 0, size[0], size[1]), fill=(0, 0, 0, 86))
    d.rectangle((0, 0, size[0], int(size[1] * 0.44)), fill=(0, 0, 0, 92))
    add_glow(overlay, (int(size[0] * 0.82), int(size[1] * 0.2)), (39, 156, 255), int(size[0] * 0.34), 115)
    add_glow(overlay, (int(size[0] * 0.18), int(size[1] * 0.86)), (255, 215, 112), int(size[0] * 0.24), 70)
    base.alpha_composite(overlay)
    return base


def draw_brand(d: ImageDraw.ImageDraw, x: int, y: int, scale: float = 1.0) -> None:
    badge = int(42 * scale)
    rounded_rect(d, (x, y, x + badge, y + badge), int(12 * scale), (255, 255, 255, 28), (255, 216, 112, 120), 2)
    d.text((x + int(58 * scale), y + int(4 * scale)), "NextSelf AI", font=font(int(28 * scale), "bold"), fill=(255, 255, 255, 245))
    d.text((x + int(58 * scale), y + int(38 * scale)), "Your future self is waiting.", font=font(int(16 * scale)), fill=(255, 218, 112, 215))


def compose_humanized(
    filename: str,
    size: tuple[int, int],
    source_name: str,
    headline: str,
    subhead: str,
    screen_title: str,
    mission: str,
    score: int,
    device_kind: str = "iphone",
) -> None:
    img = cinematic_base(SOURCES / source_name, size)
    d = ImageDraw.Draw(img, "RGBA")
    margin = int(size[0] * 0.07)
    top = int(size[1] * 0.055)
    scale = size[0] / 1242
    draw_brand(d, margin, top, max(0.9, scale))
    title_size = int(size[0] * (0.071 if device_kind == "iphone" else 0.055))
    body_size = int(size[0] * (0.028 if device_kind == "iphone" else 0.023))
    y = top + int(size[1] * 0.09)
    draw_text(d, (margin, y), headline, font(title_size, "black"), (255, 255, 255, 255), int(size[0] * 0.78), int(8 * scale))
    draw_text(d, (margin, y + int(size[1] * 0.15)), subhead, font(body_size), (232, 238, 255, 225), int(size[0] * 0.72), int(10 * scale))

    if device_kind == "iphone":
        frame_w = int(size[0] * 0.58)
        frame_h = int(frame_w * 2.05)
        x = int(size[0] * 0.36)
        y2 = size[1] - frame_h - int(size[1] * 0.035)
    else:
        frame_w = int(size[0] * 0.66)
        frame_h = int(frame_w * 1.36)
        x = int(size[0] * 0.29)
        y2 = size[1] - frame_h - int(size[1] * 0.05)

    shadow = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow, "RGBA")
    sd.rounded_rectangle((0, 0, frame_w, frame_h), radius=82, fill=(0, 0, 0, 205))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    img.alpha_composite(shadow, (x + 20, y2 + 26))
    frame = device_frame((frame_w, frame_h), device_kind, screen_title, "Meet the person you're becoming.", score, mission)
    img.alpha_composite(frame, (x, y2))
    img.convert("RGB").save(OUT / filename, quality=95)


def compose_subscription_humanized() -> None:
    size = (1242, 2688)
    img = cinematic_base(SOURCES / "source-01-reflection.png", size)
    d = ImageDraw.Draw(img, "RGBA")
    margin = 86
    draw_brand(d, margin, 96)
    draw_text(d, (margin, 210), "Premium plans, clear value.", font(78, "black"), max_width=900)
    draw_text(d, (margin, 410), "Simple subscription tiers for deeper coaching, voice journaling, reports, avatars, and themes.", font(32), (232, 238, 255, 220), 880)
    plans = [
        ("Free", "Limited", "Basic missions and limited AI messages"),
        ("Premium Monthly", "GBP 9.99", "Unlimited AI coaching and voice journaling"),
        ("Premium Yearly", "GBP 79.99", "Premium access with best yearly value"),
        ("Elite Monthly", "GBP 19.99", "Advanced personalities, reports, avatars, themes"),
    ]
    y = 650
    for name, price, detail in plans:
        rounded_rect(d, (margin, y, size[0] - margin, y + 270), 36, (0, 0, 0, 116), (92, 164, 255, 120), 2)
        d.text((margin + 40, y + 38), name, font=font(38, "bold"), fill=(255, 255, 255, 255))
        d.text((margin + 40, y + 98), price, font=font(35, "bold"), fill=(255, 216, 112, 255))
        draw_text(d, (margin + 40, y + 155), detail, font(27), (232, 238, 255, 215), 840)
        y += 315
    rounded_rect(d, (margin, 2265, size[0] - margin, 2535), 34, (0, 0, 0, 126), (255, 216, 112, 120), 2)
    d.text((margin + 36, 2302), "Wellness scope", font=font(32, "bold"), fill=(255, 216, 112, 255))
    draw_text(d, (margin + 36, 2360), "NextSelf AI is for wellness and personal growth. It is not therapy, diagnosis, medical advice, addiction treatment, crisis support, or healthcare.", font(25), (238, 241, 250, 220), 950)
    img.convert("RGB").save(OUT / "humanized-subscription-review.png", quality=95)


def main() -> None:
    iphone = [
        ("humanized-iphone-01-dashboard.png", "source-01-reflection.png", "Meet the person you're becoming.", "A deeply personal dashboard for identity, consistency, and daily transformation.", "Today", "Write one future-self paragraph", 86),
        ("humanized-iphone-02-future-self.png", "source-04-future-self.png", "Talk with future-you.", "Future-self conversations that turn doubt into one practical next step.", "Future Self", "Ask future-you what matters today", 89),
        ("humanized-iphone-03-voice-journal.png", "source-03-voice-journal.png", "Voice journal the real moments.", "Capture thoughts, wins, setbacks, and goals with AI reflection summaries.", "Voice Journal", "Record a two-minute reflection", 82),
        ("humanized-iphone-04-discipline.png", "source-02-discipline.png", "Build discipline gently.", "Daily missions designed to create identity evidence, not pressure.", "Missions", "Complete one focused action", 79),
        ("humanized-iphone-05-analytics.png", "source-01-reflection.png", "See your growth story.", "Premium analytics reveal consistency, score trends, and strongest habits.", "Growth", "Review your strongest pattern", 91),
        ("humanized-iphone-06-comeback.png", "source-03-voice-journal.png", "Come back without shame.", "When streaks break, reset with a clear plan and the next easy win.", "Comeback", "Choose your reset mission", 76),
    ]
    for filename, source_name, headline, subhead, screen_title, mission, score in iphone:
        compose_humanized(filename, (1242, 2688), source_name, headline, subhead, screen_title, mission, score, "iphone")

    ipad = [
        ("humanized-ipad-01-command-center.png", "source-01-reflection.png", "A premium command center for becoming.", "Missions, journal themes, score trends, and future-self guidance across a spacious iPad canvas.", "Dashboard", "Review today's transformation plan", 88),
        ("humanized-ipad-02-journal.png", "source-03-voice-journal.png", "Reflection with room to breathe.", "Voice journaling, transcripts, summaries, and recurring themes designed for clarity.", "Voice Journal", "Turn reflection into momentum", 84),
        ("humanized-ipad-03-future-self.png", "source-04-future-self.png", "Future-self coaching, expanded.", "Conversation, identity cards, milestone reflections, and progress reviews in one elegant space.", "Future Self", "Ask future-you for advice", 92),
        ("humanized-ipad-04-discipline.png", "source-02-discipline.png", "Discipline that feels human.", "Daily missions, comeback plans, and progress signals without a spreadsheet feel.", "Missions", "Protect one promise today", 86),
    ]
    for filename, source_name, headline, subhead, screen_title, mission, score in ipad:
        compose_humanized(filename, (2048, 2732), source_name, headline, subhead, screen_title, mission, score, "ipad")

    compose_subscription_humanized()


if __name__ == "__main__":
    main()
