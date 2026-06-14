import os
import platform
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

def extract_text_from_image(image: Image.Image) -> str:
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
    return text.strip()
