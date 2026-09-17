"""
Extrae el texto del PDF del cuadernillo de examen (enunciados) respetando
las dos columnas de cada página, para poder parsear las preguntas en orden.
Requiere: pip install pdfplumber

Uso: python3 1_extract_exam_text.py Examen_MIR_XXXX.pdf salida.txt
"""
import sys
import pdfplumber


def main(pdf_path: str, out_path: str) -> None:
    lines = []
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages):
            w, h = page.width, page.height
            mid = w / 2
            left = page.crop((0, 0, mid, h))
            right = page.crop((mid, 0, w, h))
            lines.append(f"===== PAGE {i + 1} LEFT =====")
            lines.append(left.extract_text() or "")
            lines.append(f"===== PAGE {i + 1} RIGHT =====")
            lines.append(right.extract_text() or "")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Escrito {out_path}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
