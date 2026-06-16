from pydantic import BaseModel

class OcrResponse(BaseModel):
    text: str
    partial_scan: bool = False
