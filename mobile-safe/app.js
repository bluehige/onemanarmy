(() => {
  'use strict';

  const PARTS = [
    './app.01.part',
    './app.02.part',
    './app.03.part',
    './app.04.part',
    './app.05.part',
    './app.06.part',
  ];

  function presentLoaderError(error) {
    const message = error instanceof Error ? error.message : String(error);
    const boot = document.getElementById('boot-screen');
    const errorScreen = document.getElementById('error-screen');
    const errorMessage = document.getElementById('error-message');
    const diagnostics = document.getElementById('error-diagnostics');
    const retry = document.getElementById('retry-button');
    const copy = document.getElementById('copy-error-button');

    if (boot) boot.hidden = true;
    if (errorScreen) errorScreen.hidden = false;
    if (errorMessage) errorMessage.textContent = `모바일 안전 모드 로더 실패: ${message}`;
    if (diagnostics) {
      diagnostics.textContent = [
        `message=${message}`,
        `stack=${error instanceof Error ? error.stack || '' : ''}`,
        `page=${location.href}`,
        `user_agent=${navigator.userAgent}`,
        `online=${navigator.onLine}`,
      ].join('\n');
    }
    retry?.addEventListener('click', () => location.reload());
    copy?.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(diagnostics?.textContent || message);
      } catch {
        if (diagnostics) diagnostics.closest('details').open = true;
      }
    });
    console.error(error);
  }

  async function loadRuntime() {
    const chunks = [];
    for (const path of PARTS) {
      const response = await fetch(new URL(path, document.baseURI), {
        cache: 'no-store',
        credentials: 'same-origin',
      });
      if (!response.ok) {
        throw new Error(`${path} 요청 실패: HTTP ${response.status}`);
      }
      chunks.push(await response.text());
    }

    const source = chunks.join('');
    if (!source.startsWith('(() => {') || !source.trimEnd().endsWith('})();')) {
      throw new Error('분할 런타임 조립 결과가 올바르지 않습니다.');
    }

    const blobUrl = URL.createObjectURL(new Blob([source], { type: 'text/javascript;charset=utf-8' }));
    try {
      await new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = blobUrl;
        script.onload = resolve;
        script.onerror = () => reject(new Error('조립된 안전 모드 런타임 실행에 실패했습니다.'));
        document.head.appendChild(script);
      });
    } finally {
      URL.revokeObjectURL(blobUrl);
    }
  }

  loadRuntime().catch(presentLoaderError);
})();
