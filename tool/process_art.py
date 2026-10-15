#!/usr/bin/env python3
"""Deja una imagen generada (ChatGPT u otra) lista para el juego.

Recorta al centro a la proporción de la pieza, la escala al tamaño exacto,
la comprime y la guarda con el nombre que busca ArtCatalog.

    python3 tool/process_art.py <imagen> <tipo> <id> [--focus 0.0-1.0]

Tipos: scene, event (1080×1920 JPG), story (1680×720 JPG), ending
(1080×1350 JPG), npc (768×768 PNG),
feature (1024×500 JPG), key_iphone (1290×2796 JPG), key_ipad (2048×2732 JPG),
icon (1024×1024 PNG). --focus mueve el recorte vertical (0 = arriba,
0.5 = centro, 1 = abajo); útil para no cortar la cabeza de un retrato.
Ver docs/ART_PROMPTS.md §11.
"""
import argparse
import os
import sys

from PIL import Image

KINDS = {
    'scene': ('assets/art/scenes/{id}.jpg', (1080, 1920)),
    'event': ('assets/art/events/{id}.jpg', (1080, 1920)),
    'story': ('assets/art/story/{id}.jpg', (1680, 720)),
    'ending': ('assets/art/endings/{id}.jpg', (1080, 1350)),
    'npc': ('assets/art/npcs/{id}.png', (768, 768)),
    'feature': ('assets/store/feature_graphic.jpg', (1024, 500)),
    'key_iphone': ('assets/store/key_art_iphone.jpg', (1290, 2796)),
    'key_ipad': ('assets/store/key_art_ipad.jpg', (2048, 2732)),
    'icon': ('assets/store/icon_painted.png', (1024, 1024)),
}


def crop_to(img, w, h, focus):
    """Recorta a la proporción w:h; el recorte vertical sigue a focus."""
    src_w, src_h = img.size
    target = w / h
    if src_w / src_h > target:  # sobra ancho: recorte centrado
        new_w = round(src_h * target)
        left = (src_w - new_w) // 2
        return img.crop((left, 0, left + new_w, src_h))
    new_h = round(src_w / target)  # sobra alto
    top = round((src_h - new_h) * focus)
    return img.crop((0, top, src_w, top + new_h))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('image')
    ap.add_argument('kind', choices=KINDS)
    ap.add_argument('id', nargs='?', default='')
    ap.add_argument('--focus', type=float, default=0.5)
    a = ap.parse_args()
    pattern, (w, h) = KINDS[a.kind]
    if '{id}' in pattern and not a.id:
        sys.exit(f'Falta el id para {a.kind}')
    out = pattern.format(id=a.id)
    img = Image.open(a.image).convert('RGB')
    if img.width < w * 0.9 and img.height < h * 0.9:
        print(f'Aviso: la imagen ({img.width}×{img.height}) es chica para {w}×{h}')
    img = crop_to(img, w, h, max(0.0, min(1.0, a.focus))).resize(
        (w, h), Image.LANCZOS)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    if out.endswith('.png'):
        img.save(out, optimize=True)
    else:
        img.save(out, quality=82, optimize=True, progressive=True)
    print(f'{out}  {w}×{h}  {os.path.getsize(out) // 1024} KB')


if __name__ == '__main__':
    main()
