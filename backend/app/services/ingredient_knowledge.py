INGREDIENT_RISKS = {
    # === KOMEDOJENİK (yağlı/akne cilt için riskli) ===
    "Isopropyl Myristate": {
        "oily": {"level": "avoid", "reason": "Yüksek komedojenik, gözenek tıkar"},
        "dry": {"level": "caution", "reason": "Kuru ciltte komedojenik olabilir"},
    },
    "Coconut Oil": {
        "oily": {"level": "avoid", "reason": "Komedojenik, yağlı ciltte riskli"},
        "dry": {"level": "caution", "reason": "Kuru ciltte tıkayıcı olabilir"},
    },
    "Myristyl Myristate": {
        "oily": {"level": "avoid", "reason": "Komedojenik, gözenek tıkar"},
    },
    "Acetylated Lanolin": {
        "oily": {"level": "avoid", "reason": "Komedojenik, yağlı ciltte riskli"},
    },
    "Lanolin": {
        "oily": {"level": "caution", "reason": "Hafif komedojenik, yağlı ciltte dikkat"},
        "dry": {"level": "hero", "reason": "Yoğun nemlendirici, kuru cilt için ideal"},
    },
    "Mineral Oil": {
        "oily": {"level": "caution", "reason": "Tıkayıcı, yağlı ciltte gözenek sorunu"},
        "dry": {"level": "hero", "reason": "Nem bariyeri oluşturur, kuru cilt korur"},
    },
    "Paraffinum Liquidum": {
        "oily": {"level": "caution", "reason": "Tıkayıcı, yağlı ciltte komedojenik"},
        "dry": {"level": "hero", "reason": "Nem kaybını önler, kuru cilt korur"},
    },

    # === KURUTUCU / İRİTAN ===
    "Alcohol Denat.": {
        "oily": {"level": "caution", "reason": "Fazla kurutup yağ üretimini artırabilir"},
        "dry": {"level": "avoid", "reason": "Kurutucu, kuru ciltte bariyeri zayıflatır"},
        "sensitive": {"level": "avoid", "reason": "Tahriş edici, hassas ciltte riskli"},
    },
    "SD Alcohol": {
        "oily": {"level": "caution", "reason": "Fazla kurutup yağ üretimini artırabilir"},
        "dry": {"level": "avoid", "reason": "Kurutucu, kuru ciltte tahriş edici"},
    },
    "Isopropyl Alcohol": {
        "dry": {"level": "avoid", "reason": "Kurutucu, cilt bariyerini bozar"},
        "sensitive": {"level": "avoid", "reason": "Tahriş edici, hassas ciltte riskli"},
    },
    "Sodium Lauryl Sulfate": {
        "dry": {"level": "avoid", "reason": "Sert yüzey aktif, cildi kurutur"},
        "sensitive": {"level": "avoid", "reason": "Tahriş edici, hassas ciltte riskli"},
    },
    "Sodium Laureth Sulfate": {
        "dry": {"level": "caution", "reason": "Kurutucu, kuru ciltte dikkatli kullanım"},
        "sensitive": {"level": "caution", "reason": "Hafif tahriş edici, hassas ciltte dikkat"},
    },

    # === ALERJEN / HASSASİYET ===
    "Parfum": {
        "oily": {"level": "caution", "reason": "Yağlı ciltte tahriş ve hassasiyet riski"},
        "dry": {"level": "caution", "reason": "Kuru ciltte tahriş edici olabilir"},
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte tahriş riski"},
    },
    "Limonene": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },
    "Linalool": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },
    "Citral": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },
    "Citronellol": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },
    "Geraniol": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },
    "Coumarin": {
        "sensitive": {"level": "avoid", "reason": "Alerjen, hassas ciltte reaksiyon riski"},
    },

    # === HERO — YAĞLI CİLT ===
    "Niacinamide": {
        "oily": {"level": "hero", "reason": "Yağ ve akne kontrolü sağlar"},
        "dry": {"level": "hero", "reason": "Bariyer güçlendirir, nemlendirir"},
        "sensitive": {"level": "hero", "reason": "Yatıştırır, bariyer onarır"},
    },
    "Zinc PCA": {
        "oily": {"level": "hero", "reason": "Yağ dengeleme ve akne karşıtı"},
    },
    "Salicylic Acid": {
        "oily": {"level": "hero", "reason": "Gözenek temizler, akneyi azaltır"},
    },
    "Retinol": {
        "oily": {"level": "hero", "reason": "Hücre yeniler, gözenek sıkılaştırır"},
    },
    "Retinyl Palmitate": {
        "oily": {"level": "hero", "reason": "Hücre yeniler, yağ dengesi sağlar"},
    },
    "Kaolin": {
        "oily": {"level": "hero", "reason": "Fazla yağı emer, matlaştırır"},
    },
    "Tea Tree Oil": {
        "oily": {"level": "hero", "reason": "Antibakteriyel, akne karşıtı"},
    },
    "Squalane": {
        "oily": {"level": "hero", "reason": "Hafif nemlendirici, tıkamaz"},
        "dry": {"level": "hero", "reason": "Nemlendirir, cilt bariyerini destekler"},
    },

    # === HERO — KURU CİLT ===
    "Glycerin": {
        "dry": {"level": "hero", "reason": "Nem çeker, cildi yumuşatır"},
    },
    "Panthenol": {
        "dry": {"level": "hero", "reason": "Yatıştırır, nemlendirir, bariyer onarır"},
        "sensitive": {"level": "hero", "reason": "Yatıştırır, bariyer onarır"},
    },
    "Ceramide": {
        "dry": {"level": "hero", "reason": "Bariyer onarır, nemi hapseder"},
    },
    "Ceramide NP": {
        "dry": {"level": "hero", "reason": "Bariyer onarır, nemi hapseder"},
    },
    "Butyrospermum Parkii Butter": {
        "dry": {"level": "hero", "reason": "Yoğun nemlendirir, bariyer korur"},
    },
    "Hyaluronic Acid": {
        "dry": {"level": "hero", "reason": "Yoğun nem çeker, cildi doldurur"},
    },
    "Sodium Hyaluronate": {
        "dry": {"level": "hero", "reason": "Yoğun nem çeker, cildi doldurur"},
    },
    "Allantoin": {
        "dry": {"level": "hero", "reason": "Yatıştırır, kuru cildi onarır"},
        "sensitive": {"level": "hero", "reason": "Yatıştırır, hassas cildi onarır"},
    },
    "Tocopherol": {
        "dry": {"level": "hero", "reason": "Antioksidan, cilt bariyerini korur"},
        "sensitive": {"level": "hero", "reason": "Antioksidan, yatıştırıcı"},
    },
    "Urea": {
        "dry": {"level": "hero", "reason": "Nemlendirir, kuru cilt pullanmasını önler"},
    },
    "Bisabolol": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, hassas cilt tahrişini azaltır"},
    },
    "Centella Asiatica": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, hassas cilt onarımı"},
    },
    "Aloe Barbadensis": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, nemlendirir"},
    },
    "Madecassoside": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, kollajen üretimini destekler"},
    },
    "Beta-Glucan": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, bağışıklık destekler"},
    },
    "Azelaic Acid": {
        "sensitive": {"level": "hero", "reason": "Tahriş azaltır, kızarıklığı giderir"},
        "oily": {"level": "hero", "reason": "Akne karşıtı, leke açıcı"},
    },
    "Zinc Oxide": {
        "sensitive": {"level": "hero", "reason": "Yatıştırır, koruyucu bariyer oluşturur"},
    },
}


def normalize_ingredient_name(name: str) -> str:
    return name.strip().lower()


def get_structural_matches(name: str) -> list[str]:
    n = normalize_ingredient_name(name)
    results = []
    for key in INGREDIENT_RISKS:
        kn = normalize_ingredient_name(key)
        if kn == n:
            results.append(key)
        elif kn.startswith(n) or n.startswith(kn):
            results.append(key)
    return results


def get_ingredient_analysis(ingredient_name: str, skin_type: str) -> dict | None:
    raw = ingredient_name.strip()
    matches = get_structural_matches(raw)
    if not matches:
        return None

    key = matches[0]
    data = INGREDIENT_RISKS[key]
    type_info = data.get(skin_type)

    if type_info is None:
        return None

    level = type_info["level"]
    reason = type_info["reason"]

    return {"ingredient": raw, "level": level, "reason": reason}


def classify_ingredients(
    ingredient_names: list[str],
    skin_type: str,
    sensitivities: list[str],
) -> dict:
    hero = []
    caution = []
    avoid = []

    for name in ingredient_names:
        analysis = get_ingredient_analysis(name, skin_type)
        if analysis is None:
            continue
        level = analysis["level"]
        entry = {"ingredient": analysis["ingredient"], "level": level, "reason": analysis["reason"]}
        if level == "hero":
            hero.append(entry)
        elif level == "caution":
            caution.append(entry)
        elif level == "avoid":
            avoid.append(entry)

    # Hassasiyet kontrolleri: sensitivities'deki maddeler içerikte varsa avoid'a ekle
    sensitivity_map = {
        "parfum": "Parfum", "parfuem": "Parfum",
        "alkol": "Alcohol Denat.",
        "sls": "Sodium Lauryl Sulfate",
        "sles": "Sodium Laureth Sulfate",
    }

    for raw_sens in sensitivities:
        target = sensitivity_map.get(raw_sens, raw_sens.title())
        if any(a["ingredient"].lower() == target.lower() for a in avoid):
            continue
        found = False
        for name in ingredient_names:
            if name.lower() == target.lower():
                avoid.append({"ingredient": name, "level": "avoid", "reason": f"Hassasiyet: {raw_sens} içerir"})
                found = True
                break
            if not found and target.lower() in name.lower():
                avoid.append({"ingredient": name, "level": "avoid", "reason": f"Hassasiyet: {raw_sens} benzeri içerik"})
                break

    return {"hero_ingredients": hero, "caution": caution, "avoid": avoid}
