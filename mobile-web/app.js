(() => {
  'use strict';

  const BUILD = Object.freeze({
    sourceCommit: '07ec5c4207b6425262f705a77cf691bb4740068e',
    archiveUrl: 'https://raw.githubusercontent.com/bluehige/onemanarmy/07ec5c4207b6425262f705a77cf691bb4740068e/build/windows/onemanarmy-ch01-mvp.zip',
    archiveSize: 41695843,
    archiveSha256: 'f85b2402fa8582ad6606baba1672390cd11df38ed19bb9806aaea0c906ef5a07',
    packName: 'onemanarmy_ch01.pck',
    packSize: 5737656,
    packSha256: '99fd3ecf4f0e9a07575b5f0921add950fca337585a6c9d51332ef225fcf7963d',
    runtimeCommit: '48f525a6224ee61afea2ec046fb25c3f160d78d7',
    runtimeBase: 'https://raw.githubusercontent.com/ironkid90-s/lucky5-v7/48f525a6224ee61afea2ec046fb25c3f160d78d7/src/web/public/godot-cabinet/index',
    runtimeWasmSize: 37700666,
    engineVersion: '4.6.3.stable.official.7d41c59c4',
  });

  const ui = {
    canvas: document.getElementById('canvas'),
    launchPanel: document.getElementById('launch-panel'),
    startButton: document.getElementById('start-button'),
    statusPanel: document.getElementById('status-panel'),
    statusStage: document.getElementById('status-stage'),
    statusDetail: document.getElementById('status-detail'),
    statusPercent: document.getElementById('status-percent'),
    progressFill: document.getElementById('progress-fill'),
    progressTrack: document.querySelector('.progress-track'),
    errorPanel: document.getElementById('error-panel'),
    errorMessage: document.getElementById('error-message'),
    diagnostics: document.getElementById('diagnostics'),
    copyDiagnostics: document.getElementById('copy-diagnostics'),
    retryButton: document.getElementById('retry-button'),
    gameTools: document.getElementById('game-tools'),
    fullscreenButton: document.getElementById('fullscreen-button'),
    reloadButton: document.getElementById('reload-button'),
  };

  const logLines = [];
  let fullArchive = null;
  let engine = null;
  let wakeLock = null;
  let launchStarted = false;

  function log(message, data) {
    const stamp = new Date().toISOString();
    const suffix = data === undefined
      ? ''
      : ` ${typeof data === 'string' ? data : JSON.stringify(data)}`;
    const line = `[${stamp}] ${message}${suffix}`;
    logLines.push(line);
    if (logLines.length > 160) {
      logLines.shift();
    }
    console.log(line);
  }

  function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value));
  }

  function setProgress(stage, percent, detail) {
    const safePercent = Math.round(clamp(percent, 0, 100));
    ui.statusStage.textContent = stage;
    ui.statusDetail.textContent = detail;
    ui.statusPercent.textContent = `${safePercent}%`;
    ui.progressFill.style.width = `${safePercent}%`;
    ui.progressTrack.setAttribute('aria-valuenow', String(safePercent));
  }

  function showStatus() {
    ui.launchPanel.hidden = true;
    ui.errorPanel.hidden = true;
    ui.statusPanel.hidden = false;
  }

  function hideStatus() {
    ui.statusPanel.hidden = true;
  }

  function formatBytes(bytes) {
    if (!Number.isFinite(bytes) || bytes < 0) return '0 B';
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  async function readResponseBytes(response, expectedBytes, onProgress) {
    if (!response.body || typeof response.body.getReader !== 'function') {
      const buffer = await response.arrayBuffer();
      onProgress?.(buffer.byteLength, expectedBytes || buffer.byteLength);
      return new Uint8Array(buffer);
    }

    const reader = response.body.getReader();
    const chunks = [];
    let received = 0;
    const total = expectedBytes || Number(response.headers.get('content-length')) || 0;

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      chunks.push(value);
      received += value.byteLength;
      onProgress?.(received, total);
    }

    const merged = new Uint8Array(received);
    let offset = 0;
    for (const chunk of chunks) {
      merged.set(chunk, offset);
      offset += chunk.byteLength;
    }
    return merged;
  }

  async function fetchArchiveRange(start, end, onProgress) {
    if (!Number.isInteger(start) || !Number.isInteger(end) || start < 0 || end < start || end >= BUILD.archiveSize) {
      throw new Error(`잘못된 ZIP 범위 요청입니다: ${start}-${end}`);
    }

    if (fullArchive) {
      return fullArchive.slice(start, end + 1);
    }

    const expected = end - start + 1;
    log('ZIP range fetch', { start, end, expected });
    const response = await fetch(BUILD.archiveUrl, {
      method: 'GET',
      mode: 'cors',
      cache: 'no-store',
      headers: { Range: `bytes=${start}-${end}` },
    });

    if (!response.ok) {
      throw new Error(`게임 패키지 요청 실패: HTTP ${response.status}`);
    }

    const bytes = await readResponseBytes(
      response,
      response.status === 206 ? expected : BUILD.archiveSize,
      onProgress,
    );

    if (response.status === 206) {
      if (bytes.byteLength !== expected) {
        throw new Error(`부분 다운로드 크기 불일치: ${bytes.byteLength} / ${expected}`);
      }
      return bytes;
    }

    if (response.status === 200 && bytes.byteLength === BUILD.archiveSize) {
      log('Range unsupported; cached complete ZIP', { bytes: bytes.byteLength });
      fullArchive = bytes;
      return fullArchive.slice(start, end + 1);
    }

    throw new Error(`서버가 예상하지 못한 패키지 크기를 반환했습니다: ${bytes.byteLength}`);
  }

  function findEndOfCentralDirectory(tail, tailStart) {
    const view = new DataView(tail.buffer, tail.byteOffset, tail.byteLength);
    for (let offset = tail.byteLength - 22; offset >= 0; offset -= 1) {
      if (view.getUint32(offset, true) !== 0x06054b50) continue;

      const diskNumber = view.getUint16(offset + 4, true);
      const centralDisk = view.getUint16(offset + 6, true);
      const entriesOnDisk = view.getUint16(offset + 8, true);
      const entryCount = view.getUint16(offset + 10, true);
      const centralSize = view.getUint32(offset + 12, true);
      const centralOffset = view.getUint32(offset + 16, true);
      const commentLength = view.getUint16(offset + 20, true);

      if (offset + 22 + commentLength > tail.byteLength) continue;
      if (diskNumber !== 0 || centralDisk !== 0 || entriesOnDisk !== entryCount) {
        throw new Error('분할 ZIP 패키지는 지원하지 않습니다.');
      }
      if (entryCount === 0xffff || centralSize === 0xffffffff || centralOffset === 0xffffffff) {
        throw new Error('ZIP64 패키지는 현재 모바일 로더에서 지원하지 않습니다.');
      }

      return {
        absoluteOffset: tailStart + offset,
        entryCount,
        centralSize,
        centralOffset,
      };
    }
    throw new Error('ZIP 중앙 디렉터리를 찾지 못했습니다.');
  }

  function parseCentralDirectory(bytes, targetName, entryCount) {
    const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const decoder = new TextDecoder('utf-8');
    let offset = 0;
    let parsedEntries = 0;

    while (offset + 46 <= bytes.byteLength && parsedEntries < entryCount) {
      if (view.getUint32(offset, true) !== 0x02014b50) {
        throw new Error(`ZIP 중앙 디렉터리 헤더 오류: ${offset}`);
      }

      const flags = view.getUint16(offset + 8, true);
      const compression = view.getUint16(offset + 10, true);
      const crc32 = view.getUint32(offset + 16, true);
      const compressedSize = view.getUint32(offset + 20, true);
      const uncompressedSize = view.getUint32(offset + 24, true);
      const nameLength = view.getUint16(offset + 28, true);
      const extraLength = view.getUint16(offset + 30, true);
      const commentLength = view.getUint16(offset + 32, true);
      const localHeaderOffset = view.getUint32(offset + 42, true);
      const nameStart = offset + 46;
      const nameEnd = nameStart + nameLength;

      if (nameEnd > bytes.byteLength) {
        throw new Error('ZIP 파일명 영역이 손상되었습니다.');
      }

      const name = decoder.decode(bytes.subarray(nameStart, nameEnd));
      if (name === targetName) {
        if ((flags & 0x0001) !== 0) {
          throw new Error('암호화된 게임 패키지는 실행할 수 없습니다.');
        }
        return {
          name,
          flags,
          compression,
          crc32,
          compressedSize,
          uncompressedSize,
          localHeaderOffset,
        };
      }

      offset += 46 + nameLength + extraLength + commentLength;
      parsedEntries += 1;
    }

    throw new Error(`ZIP 안에서 ${targetName} 파일을 찾지 못했습니다.`);
  }

  async function sha256Hex(bytes) {
    const exact = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    const digest = await crypto.subtle.digest('SHA-256', exact);
    return Array.from(new Uint8Array(digest), (value) => value.toString(16).padStart(2, '0')).join('');
  }

  async function extractGodotPack() {
    setProgress('게임 패키지 확인', 4, 'ZIP 메타데이터를 읽고 있습니다.');
    const tailLength = Math.min(65557, BUILD.archiveSize);
    const tailStart = BUILD.archiveSize - tailLength;
    const tail = await fetchArchiveRange(tailStart, BUILD.archiveSize - 1);
    const eocd = findEndOfCentralDirectory(tail, tailStart);
    log('ZIP EOCD parsed', eocd);

    setProgress('게임 패키지 확인', 7, '내부 파일 목록을 확인하고 있습니다.');
    const centralEnd = eocd.centralOffset + eocd.centralSize - 1;
    const central = await fetchArchiveRange(eocd.centralOffset, centralEnd);
    const entry = parseCentralDirectory(central, BUILD.packName, eocd.entryCount);
    log('Godot pack entry found', entry);

    if (entry.uncompressedSize !== BUILD.packSize) {
      throw new Error(`PCK 크기 불일치: ${entry.uncompressedSize} / ${BUILD.packSize}`);
    }

    const localHeader = await fetchArchiveRange(entry.localHeaderOffset, entry.localHeaderOffset + 29);
    const localView = new DataView(localHeader.buffer, localHeader.byteOffset, localHeader.byteLength);
    if (localView.getUint32(0, true) !== 0x04034b50) {
      throw new Error('PCK 로컬 ZIP 헤더가 손상되었습니다.');
    }

    const localNameLength = localView.getUint16(26, true);
    const localExtraLength = localView.getUint16(28, true);
    const dataOffset = entry.localHeaderOffset + 30 + localNameLength + localExtraLength;
    const dataEnd = dataOffset + entry.compressedSize - 1;

    setProgress('게임 데이터 다운로드', 10, `${formatBytes(entry.compressedSize)} 다운로드 준비`);
    const compressed = await fetchArchiveRange(dataOffset, dataEnd, (current, total) => {
      const ratio = total > 0 ? current / total : 0;
      setProgress(
        '게임 데이터 다운로드',
        10 + ratio * 34,
        `${formatBytes(current)} / ${formatBytes(total || entry.compressedSize)}`,
      );
    });

    setProgress('게임 데이터 해제', 46, `${BUILD.packName} 압축을 풀고 있습니다.`);
    let pack;
    if (entry.compression === 0) {
      pack = compressed.slice();
    } else if (entry.compression === 8) {
      if (!globalThis.fflate || typeof globalThis.fflate.inflateSync !== 'function') {
        throw new Error('압축 해제 모듈을 불러오지 못했습니다. 네트워크 연결을 확인해 주세요.');
      }
      pack = globalThis.fflate.inflateSync(compressed);
    } else {
      throw new Error(`지원하지 않는 ZIP 압축 방식입니다: ${entry.compression}`);
    }

    fullArchive = null;
    if (pack.byteLength !== BUILD.packSize) {
      throw new Error(`압축 해제 후 PCK 크기 불일치: ${pack.byteLength} / ${BUILD.packSize}`);
    }

    setProgress('게임 데이터 검증', 50, 'SHA-256 무결성 검사를 진행하고 있습니다.');
    const hash = await sha256Hex(pack);
    log('PCK SHA-256', hash);
    if (hash !== BUILD.packSha256) {
      throw new Error(`PCK 무결성 검사 실패\n예상: ${BUILD.packSha256}\n실제: ${hash}`);
    }

    setProgress('게임 데이터 검증', 54, `${formatBytes(pack.byteLength)} · 무결성 정상`);
    return pack.buffer.slice(pack.byteOffset, pack.byteOffset + pack.byteLength);
  }

  async function initializeGodot(packBuffer) {
    if (typeof globalThis.Engine !== 'function') {
      throw new Error('Godot Web 런타임을 불러오지 못했습니다. CDN 연결을 확인해 주세요.');
    }

    const missing = globalThis.Engine.getMissingFeatures({ threads: false });
    if (missing.length > 0) {
      throw new Error(`브라우저에 필요한 Web 기능이 없습니다:\n${missing.join('\n')}`);
    }

    const wasmUrl = `${BUILD.runtimeBase}.wasm`;
    const fileSizes = { [wasmUrl]: BUILD.runtimeWasmSize };

    setProgress('Godot 엔진 로딩', 56, `${BUILD.engineVersion} Web 런타임을 준비합니다.`);
    engine = new globalThis.Engine({
      executable: BUILD.runtimeBase,
      unloadAfterInit: false,
      canvas: ui.canvas,
      canvasResizePolicy: 2,
      focusCanvas: true,
      experimentalVK: true,
      fileSizes,
      onProgress: (current, total) => {
        const ratio = total > 0 ? current / total : 0;
        setProgress(
          'Godot 엔진 로딩',
          56 + ratio * 34,
          total > 0
            ? `${formatBytes(current)} / ${formatBytes(total)}`
            : 'WebAssembly 런타임을 컴파일하고 있습니다.',
        );
      },
      onPrint: (message) => log(`Godot: ${message}`),
      onPrintError: (message) => log(`Godot error: ${message}`),
      onExit: (code) => {
        log('Godot exited', { code });
        if (code !== 0) {
          showError(new Error(`게임이 종료되었습니다. 종료 코드: ${code}`));
        }
      },
    });

    await engine.init(BUILD.runtimeBase);
    setProgress('게임 탑재', 92, `${BUILD.packName}을 가상 파일 시스템에 탑재합니다.`);
    await engine.preloadFile(packBuffer, BUILD.packName);

    setProgress('게임 실행', 96, '관천과 108개의 검을 불러오고 있습니다.');
    await engine.start({
      canvas: ui.canvas,
      args: [
        '--main-pack', BUILD.packName,
        '--rendering-method', 'gl_compatibility',
        '--rendering-driver', 'opengl3',
      ],
    });

    setProgress('게임 실행', 100, '실행 완료');
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    hideStatus();
    ui.gameTools.hidden = false;
    ui.canvas.focus({ preventScroll: true });
    log('MOBILE_WEB_GAME_STARTED');
  }

  async function requestPlayMode() {
    try {
      if (!document.fullscreenElement && document.documentElement.requestFullscreen) {
        await document.documentElement.requestFullscreen({ navigationUI: 'hide' });
      }
    } catch (error) {
      log('Fullscreen request skipped', String(error));
    }

    try {
      if (screen.orientation && typeof screen.orientation.lock === 'function') {
        await screen.orientation.lock('landscape');
      }
    } catch (error) {
      log('Orientation lock skipped', String(error));
    }
  }

  async function requestWakeLock() {
    try {
      if ('wakeLock' in navigator) {
        wakeLock = await navigator.wakeLock.request('screen');
        wakeLock.addEventListener('release', () => log('Wake lock released'));
        log('Wake lock acquired');
      }
    } catch (error) {
      log('Wake lock unavailable', String(error));
    }
  }

  async function launch() {
    if (launchStarted) return;
    launchStarted = true;
    ui.startButton.disabled = true;
    ui.startButton.textContent = '실행 준비 중…';
    log('Launch requested', {
      userAgent: navigator.userAgent,
      viewport: `${window.innerWidth}x${window.innerHeight}`,
      sourceCommit: BUILD.sourceCommit,
      runtimeCommit: BUILD.runtimeCommit,
    });

    showStatus();
    setProgress('모바일 실행 준비', 1, '전체화면과 가로 모드를 설정하고 있습니다.');

    try {
      await requestPlayMode();
      requestWakeLock();
      const packBuffer = await extractGodotPack();
      await initializeGodot(packBuffer);
    } catch (error) {
      showError(error);
    }
  }

  function buildDiagnostics(error) {
    return [
      `message=${error instanceof Error ? error.message : String(error)}`,
      `stack=${error instanceof Error ? error.stack || '' : ''}`,
      `engine=${BUILD.engineVersion}`,
      `source_commit=${BUILD.sourceCommit}`,
      `runtime_commit=${BUILD.runtimeCommit}`,
      `archive=${BUILD.archiveUrl}`,
      `user_agent=${navigator.userAgent}`,
      `viewport=${window.innerWidth}x${window.innerHeight}`,
      `online=${navigator.onLine}`,
      `secure_context=${window.isSecureContext}`,
      '',
      ...logLines,
    ].join('\n');
  }

  function showError(error) {
    const normalized = error instanceof Error ? error : new Error(String(error));
    log('Launch failed', { message: normalized.message, stack: normalized.stack || '' });
    hideStatus();
    ui.launchPanel.hidden = true;
    ui.gameTools.hidden = true;
    ui.errorPanel.hidden = false;
    ui.errorMessage.textContent = normalized.message;
    ui.diagnostics.textContent = buildDiagnostics(normalized);
    launchStarted = false;
  }

  async function copyDiagnostics() {
    const text = ui.diagnostics.textContent;
    try {
      await navigator.clipboard.writeText(text);
      ui.copyDiagnostics.textContent = '복사됨';
      setTimeout(() => { ui.copyDiagnostics.textContent = '진단 복사'; }, 1500);
    } catch {
      ui.diagnostics.closest('details').open = true;
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(ui.diagnostics);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  }

  async function toggleFullscreen() {
    try {
      if (document.fullscreenElement) {
        await document.exitFullscreen();
      } else if (document.documentElement.requestFullscreen) {
        await document.documentElement.requestFullscreen({ navigationUI: 'hide' });
      }
    } catch (error) {
      log('Fullscreen toggle failed', String(error));
    }
  }

  ui.startButton.addEventListener('click', launch, { once: false });
  ui.retryButton.addEventListener('click', () => window.location.reload());
  ui.reloadButton.addEventListener('click', () => window.location.reload());
  ui.fullscreenButton.addEventListener('click', toggleFullscreen);
  ui.copyDiagnostics.addEventListener('click', copyDiagnostics);

  document.addEventListener('contextmenu', (event) => event.preventDefault());
  document.addEventListener('touchmove', (event) => {
    if (event.target === ui.canvas) event.preventDefault();
  }, { passive: false });

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible' && launchStarted && !wakeLock) {
      requestWakeLock();
    }
  });

  window.addEventListener('unhandledrejection', (event) => {
    log('Unhandled rejection', String(event.reason));
  });
  window.addEventListener('error', (event) => {
    log('Window error', event.message || 'unknown');
  });

  log('Mobile Web loader ready', BUILD);
})();
