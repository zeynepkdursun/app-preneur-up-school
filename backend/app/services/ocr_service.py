import os
import platform
import re
import pytesseract
from PIL import Image, ImageFilter, ImageEnhance

system = platform.system()

if system == "Windows":
    import subprocess
    result = subprocess.run(["where", "tesseract"], capture_output=True, text=True)
    if result.returncode == 0:
        pytesseract.pytesseract.tesseract_cmd = result.stdout.strip().split("\n")[0]
    else:
        common_paths = [
            r"C:\Program Files\Tesseract-OCR\tesseract.exe",
            r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
        ]
        for p in common_paths:
            if os.path.exists(p):
                pytesseract.pytesseract.tesseract_cmd = p
                break

def preprocess_image(image: Image.Image) -> Image.Image:
    image = image.convert("L")
    image = image.filter(ImageFilter.SHARPEN)
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(2.0)
    return image

_INGREDIENT_START_RE = re.compile(
    r"(?:"
    r"İçindekiler\s*[-–—/:;]+\s*Ingredients"
    r"|Ingredients\s*[-–—/:;]+\s*İçindekiler"
    r"|İçindekiler|Içindekiler|Icindekiler|ICINDEKILER"
    r"|Ingredients|INGREDIENTS"
    r"|Ingrédients|INGRÉDIENTS"
    r"|Inhaltsstoffe|Zutaten"
    r"|Ingredientes"
    r"|INCI"
    r"|Bileşenler|Bilesenler"
    r")\s*[:;]?\s*",
    re.IGNORECASE
)

_NON_INGREDIENT_RE = re.compile(
    r"(?:"
    r"Kullanım|KULLANIM"
    r"|Üretici|ÜRETİCİ|Uretici"
    r"|Son\s*[Kk]ullanma"
    r"|[Ss][Kk][Tt]\s*[:]"
    r"|Üretim|ÜRETİM"
    r"|Seri|SERİ"
    r"|Barkod|BARKOD"
    r"|Net\s*[Mm]iktar"
    r"|Menşe[iiı]|MENŞE[İI]"
    r"|Uyarı|UYARI"
    r"|Talimat|TALİMAT"
    r"|Bu\s*[üÜ]rün"
    r"|Muhafaza"
    r")\s*[:]",
    re.IGNORECASE
)


def extract_ingredients_section(raw_text: str) -> tuple[str, bool]:
    lines = raw_text.strip().splitlines()
    start = -1
    for i, line in enumerate(lines):
        if _INGREDIENT_START_RE.search(line):
            start = i
            break

    if start < 0:
        return (raw_text, True)

    end = len(lines)
    for i in range(start + 1, len(lines)):
        if _NON_INGREDIENT_RE.match(lines[i].strip()):
            end = i
            break

    return ("\n".join(lines[start:end]).strip(), False)


def extract_text_from_image(image: Image.Image) -> tuple[str, bool]:
    import subprocess
    result = subprocess.run(
        [pytesseract.pytesseract.tesseract_cmd, "--list-langs"],
        capture_output=True, text=True
    )
    available = result.stdout + result.stderr
    lang = "tur+eng" if "tur" in available else "eng"

    processed = preprocess_image(image)
    custom_config = r"--oem 3 --psm 6"
    text = pytesseract.image_to_string(processed, lang=lang, config=custom_config)
    return extract_ingredients_section(text.strip())
