#!/usr/bin/env python3
"""Harden the generated Godot HTML shell for landscape mobile touch play."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD_DIR = ROOT / "build" / "web"
INDEX_PATH = BUILD_DIR / "index.html"

HEAD_MARKUP = r'''
<meta name="theme-color" content="#171513">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<style>
  html, body {
    width: 100%;
    height: 100%;
    margin: 0;
    overflow: hidden;
    overscroll-behavior: none;
    background: #171513;
    touch-action: none;
    -webkit-user-select: none;
    user-select: none;
    -webkit-touch-callout: none;
  }
  canvas {
    touch-action: none !important;
    -webkit-user-select: none;
    user-select: none;
    -webkit-touch-callout: none;
  }
  #mobile-rotate-notice {
    position: fixed;
    inset: 0;
    z-index: 2147483647;
    display: none;
    align-items: center;
    justify-content: center;
    padding: 32px;
    box-sizing: border-box;
    background: #171513;
    color: #f1ebdd;
    text-align: center;
    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", sans-serif;
  }
  #mobile-rotate-notice strong {
    display: block;
    margin-bottom: 12px;
    font-size: 24px;
    font-weight: 700;
  }
  #mobile-rotate-notice span {
    font-size: 16px;
    line-height: 1.6;
    color: #d4ccbd;
  }
  #mobile-touch-hint {
    position: fixed;
    left: 50%;
    top: max(12px, env(safe-area-inset-top));
    z-index: 2147483646;
    transform: translateX(-50%);
    max-width: calc(100vw - 32px);
    padding: 10px 16px;
    border: 1px solid rgba(241, 235, 221, 0.48);
    background: rgba(23, 21, 19, 0.88);
    color: #f1ebdd;
    font: 600 14px/1.4 system-ui, -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", sans-serif;
    text-align: center;
    pointer-events: none;
    opacity: 1;
    transition: opacity 240ms ease;
  }
  #mobile-touch-hint.hidden {
    opacity: 0;
  }
  @media (orientation: portrait) and (max-width: 900px) {
    #mobile-rotate-notice { display: flex; }
    #mobile-touch-hint { display: none; }
  }
</style>
'''

BODY_MARKUP = r'''
<div id="mobile-rotate-notice" role="status" aria-live="polite">
  <div>
    <strong>휴대폰을 가로로 돌려주세요</strong>
    <span>가로 화면에서 버튼과 대화창을 터치해 플레이할 수 있습니다.</span>
  </div>
</div>
<div id="mobile-touch-hint">화면과 버튼을 터치해서 진행하세요</div>
<script>
  (() => {
    const hint = document.getElementById('mobile-touch-hint');
    const hideHint = () => hint?.classList.add('hidden');
    window.addEventListener('pointerdown', hideHint, { once: true, passive: true });
    window.setTimeout(hideHint, 4500);
    document.addEventListener('contextmenu', (event) => event.preventDefault());
    document.addEventListener('touchmove', (event) => {
      if (event.target instanceof HTMLCanvasElement) event.preventDefault();
    }, { passive: false });
  })();
</script>
'''


def main() -> None:
    if not INDEX_PATH.is_file():
        raise RuntimeError(f"Missing Godot Web entry point: {INDEX_PATH}")

    html = INDEX_PATH.read_text(encoding="utf-8")
    if "mobile-rotate-notice" not in html:
        if "</head>" not in html:
            raise RuntimeError("Generated Godot HTML has no closing </head> tag")
        html = html.replace("</head>", HEAD_MARKUP + "\n</head>", 1)
        html, count = re.subn(
            r"(<body(?:\s[^>]*)?>)",
            r"\1" + BODY_MARKUP,
            html,
            count=1,
            flags=re.IGNORECASE,
        )
        if count != 1:
            raise RuntimeError("Generated Godot HTML has no <body> tag")

    INDEX_PATH.write_text(html, encoding="utf-8")
    (BUILD_DIR / ".nojekyll").write_text("", encoding="utf-8")
    (BUILD_DIR / "404.html").write_text(html, encoding="utf-8")

    verified = INDEX_PATH.read_text(encoding="utf-8")
    required = (
        "mobile-rotate-notice",
        "mobile-touch-hint",
        "touch-action: none",
        "휴대폰을 가로로 돌려주세요",
    )
    missing = [marker for marker in required if marker not in verified]
    if missing:
        raise RuntimeError(f"Postprocessed HTML is missing markers: {missing}")

    print("MOBILE_WEB_POSTPROCESS_OK")


if __name__ == "__main__":
    main()
