import logging
from fastapi import APIRouter, UploadFile, File, HTTPException
from PIL import Image, UnidentifiedImageError
import io
from app.schemas.ocr import OcrResponse
from app.services.ocr_service import extract_text_from_image

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/extract", response_model=OcrResponse)
async def ocr_extract(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Dosya bir görsel değil.")

    try:
        contents = await file.read()
        if not contents:
            raise HTTPException(status_code=400, detail="Boş dosya gönderildi.")

        try:
            image = Image.open(io.BytesIO(contents))
        except UnidentifiedImageError:
            raise HTTPException(status_code=400, detail="Görsel dosyası okunamadı. Geçersiz format.")

        text = extract_text_from_image(image)

        if not text:
            raise HTTPException(status_code=422, detail="Görselden metin çıkarılamadı.")

        return OcrResponse(text=text)

    except HTTPException:
        raise
    except Exception as e:
        logger.exception("OCR beklenmeyen hata")
        raise HTTPException(status_code=500, detail=f"OCR işleme hatası: {str(e)}")
