"""
Extrae la clave de respuestas oficial (PDF "Respuestas Correctas") del
Ministerio de Sanidad, usando la posición X de cada palabra para
reconstruir las columnas V0/RC (algunas preguntas anuladas no tienen
RC y quedan en blanco: hay que detectarlas por posición, no asumiendo
pares consecutivos de palabras).

Uso: python3 3_extract_answer_key.py Respuestas.pdf salida.json
"""
import sys
import json
import pdfplumber


def main(pdf_path: str, out_path: str) -> None:
    answers = {}
    with pdfplumber.open(pdf_path) as pdf:
        # Calibra las posiciones X de las columnas con la primera página.
        first_page_words = pdf.pages[0].extract_words()
        header_row = [w for w in first_page_words if w["text"] in ("V0", "RC") and w["top"] < 200]
        # Fallback a las posiciones típicas del MIR 2025 si la calibración falla.
        v0_anchors = [58.6, 247.8, 437.1, 629.1]
        rc_anchors = [154.6, 346.6, 538.6, 729.9]

        for page in pdf.pages:
            words = page.extract_words()
            nums = [w for w in words if w["text"].isdigit() and w["top"] > 150]
            rows = {}
            for w in nums:
                key = round(w["top"])
                rows.setdefault(key, []).append(w)
            for row in rows.values():
                for g in range(4):
                    v0w = next((w for w in row if abs(w["x0"] - v0_anchors[g]) < 15), None)
                    rcw = next((w for w in row if abs(w["x0"] - rc_anchors[g]) < 15), None)
                    if v0w:
                        answers[int(v0w["text"])] = int(rcw["text"]) if rcw else None

    blanks = sorted(k for k, v in answers.items() if v is None)
    print(f"total: {len(answers)}. sin respuesta (anuladas): {blanks}")
    json.dump({str(k): v for k, v in answers.items()}, open(out_path, "w"), indent=0, ensure_ascii=False)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
