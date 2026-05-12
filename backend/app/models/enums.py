from enum import Enum

class SkinType(str, Enum):
    COMBINATION = "COMBINATION"
    OILY = "OILY"
    DRY = "DRY"
    NORMAL = "NORMAL"
    SENSITIVE = "SENSITIVE"

class RiskLevel(str, Enum):
    SAFE = "SAFE"
    CAUTION = "CAUTION"
    AVOID = "AVOID"