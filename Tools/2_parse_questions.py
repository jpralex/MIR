"""
Convierte el texto extraído por 1_extract_exam_text.py en preguntas
estructuradas (enunciado + 4 opciones), detectando los números de
pregunta 1..N en orden estricto.

IMPORTANTE: revisa siempre el resultado a mano (o con
3_sanity_checks.py) antes de usarlo: los saltos de página/columna
pueden producir errores puntuales que conviene detectar (ver el caso
real de la pregunta 161 del MIR 2025, con una errata real del propio
Ministerio que se debe conservar tal cual, no "corregir").

Uso: python3 2_parse_questions.py entrada.txt salida.json --pages 3 36 --total 210
"""
import argparse
import json
import re


def parse(content_lines, total_questions):
    questions = {}
    i = 0
    n = len(content_lines)
    expected_q = 1
    mode = "seek_q"
    cur = None
    opt_num = 0

    def is_marker(line, num):
        return re.match(rf"^{num}\.\s+\S", line.strip()) is not None

    while i < n and expected_q <= total_questions:
        line = content_lines[i].strip()
        if line == "":
            i += 1
            continue
        if mode == "seek_q":
            if is_marker(line, expected_q):
                text = re.sub(rf"^{expected_q}\.\s+", "", line)
                cur = {"number": expected_q, "stem_lines": [text], "options": {}}
                mode = "stem"
            i += 1
            continue
        if mode == "stem":
            if is_marker(line, 1):
                opt_num = 1
                cur["options"][1] = [re.sub(r"^1\.\s+", "", line)]
                mode = "options"
            else:
                cur["stem_lines"].append(line)
            i += 1
            continue
        if mode == "options":
            next_opt = opt_num + 1
            if next_opt <= 4 and is_marker(line, next_opt):
                opt_num = next_opt
                cur["options"][opt_num] = [re.sub(rf"^{next_opt}\.\s+", "", line)]
            elif is_marker(line, expected_q + 1) and opt_num >= 4:
                questions[cur["number"]] = cur
                expected_q += 1
                text = re.sub(rf"^{expected_q}\.\s+", "", line)
                cur = {"number": expected_q, "stem_lines": [text], "options": {}}
                mode = "stem"
            else:
                cur["options"][opt_num].append(line)
            i += 1
            continue

    if cur and cur["number"] not in questions:
        questions[cur["number"]] = cur

    final = {}
    for qn, q in questions.items():
        stem = " ".join(q["stem_lines"]).replace("- ", "").strip()
        opts = {k: " ".join(v).replace("- ", "").strip() for k, v in q["options"].items()}
        final[qn] = {"stem": stem, "options": opts}
    return final


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input_txt")
    ap.add_argument("output_json")
    ap.add_argument("--pages", nargs=2, type=int, required=True, help="rango de páginas con preguntas, ej: 3 36")
    ap.add_argument("--total", type=int, required=True, help="número total de preguntas a parsear")
    args = ap.parse_args()

    lines = open(args.input_txt, encoding="utf-8").read().split("\n")
    content = []
    current_page = None
    for line in lines:
        m = re.match(r"===== PAGE (\d+) (LEFT|RIGHT) =====", line)
        if m:
            current_page = int(m.group(1))
            continue
        if current_page is not None and args.pages[0] <= current_page <= args.pages[1]:
            content.append(line)

    questions = parse(content, args.total)
    missing = [q for q in range(1, args.total + 1) if q not in questions]
    print(f"parseadas: {len(questions)} / {args.total}. faltan: {missing}")
    json.dump(questions, open(args.output_json, "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
