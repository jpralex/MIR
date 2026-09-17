"""
Recorta las imágenes clínicas del cuadernillo de imágenes.

Cada página del cuadernillo suele traer 2-4 imágenes con su
etiqueta "Imagen N" encima. Este script no intenta adivinar la
posición automáticamente (la maquetación en "folleto" hace que el
orden de las imágenes en cada página física no sea secuencial): en su
lugar, defines a mano una ventana aproximada (x0,y0,x1,y1 en píxeles,
sobre un render a 150dpi) por cada imagen tras mirar el PDF, y el
script ajusta el recorte al contenido no blanco dentro de esa ventana.

Requiere: pip install pdf2image pillow numpy  (o usa `pdftoppm` de
poppler-utils para generar los PNG de cada página y solo usa PIL/numpy
aquí).

Uso:
  1. pdftoppm -png -r 150 Imagenes.pdf pagina
  2. Mira cada pagina-NN.png y anota la ventana aproximada de cada imagen.
  3. Rellena WINDOWS abajo y ejecuta: python3 4_extract_images.py
"""
from PIL import Image
import numpy as np
import os

PAGES_DIR = "imgpages"       # carpeta con pagina-01.png, pagina-02.png, ...
OUT_DIR = "images_out"
# page_number -> [(etiqueta, (x0, y0, x1, y1)), ...]
WINDOWS = {
    # 3: [("1", (1240, 150, 2481, 900)), ("2", (1240, 950, 2481, 1700))],
}


def nonwhite_bbox(arr, thresh=245):
    mask = (arr < thresh).any(axis=2)
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def crop_tight(img, box, pad=8):
    arr = np.array(img.crop(box))
    bb = nonwhite_bbox(arr)
    if bb is None:
        return img.crop(box)
    x0, y0, x1, y1 = bb
    w, h = box[2] - box[0], box[3] - box[1]
    x0, y0 = max(0, x0 - pad), max(0, y0 - pad)
    x1, y1 = min(w, x1 + pad), min(h, y1 + pad)
    return img.crop((box[0] + x0, box[1] + y0, box[0] + x1, box[1] + y1))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for page_num, items in WINDOWS.items():
        img = Image.open(f"{PAGES_DIR}/pagina-{page_num:02d}.png").convert("RGB")
        for label, box in items:
            crop_tight(img, box).save(f"{OUT_DIR}/imagen_{label}.png")
    print("listo")


if __name__ == "__main__":
    main()
