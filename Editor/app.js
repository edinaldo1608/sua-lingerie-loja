/* =========================================================
   Editor de Imagens — lógica principal
   Tudo roda no navegador, sem servidor.
   ========================================================= */

const $ = (id) => document.getElementById(id);

// Elementos
const canvas      = $('canvas');
const ctx         = canvas.getContext('2d');
const drop        = $('drop');
const canvasWrap  = $('canvasWrap');
const canvasHolder= $('canvasHolder');
const cropBox     = $('cropBox');
const fileInput   = $('fileInput');
const statusEl    = $('status');
const formatoSel  = $('formato');

// Sliders e controles
const ctrl = {
  brilho:     $('brilho'),
  contraste:  $('contraste'),
  saturacao:  $('saturacao'),
  desfoque:   $('desfoque'),
  sepia:      $('sepia'),
  cinza:      $('cinza'),
  inverter:   $('inverter'),
  largura:    $('largura'),
  altura:     $('altura'),
  proporcao:  $('proporcao'),
};

const labels = {
  brilho:    $('vBrilho'),
  contraste: $('vContraste'),
  saturacao: $('vSaturacao'),
  desfoque:  $('vDesfoque'),
  sepia:     $('vSepia'),
};

// Estado
let original = null;       // imagem original (Image)
let ajustes = ajustesIniciais();
let hist = [];             // pilha de estados (ImageData / dataURL)
let redo = [];
let pronto = false;

function ajustesIniciais(){
  return { brilho:0, contraste:0, saturacao:0, desfoque:0, sepia:0, cinza:false, inverter:false };
}

/* ---------- Abrir imagem ---------- */

function abrirArquivo(file){
  if (!file || !file.type.startsWith('image/')) {
    setStatus('⚠️ Arquivo não é uma imagem.');
    return;
  }
  const reader = new FileReader();
  reader.onload = (e) => carregarImagem(e.target.result);
  reader.readAsDataURL(file);
}

function carregarImagem(src){
  const img = new Image();
  img.onload = () => {
    original = img;
    canvas.width  = img.naturalWidth;
    canvas.height = img.naturalHeight;
    ctx.drawImage(img, 0, 0);

    await_habilitaControles(true);
    drop.hidden = true;
    canvasWrap.hidden = false;

    hist = [ canvas.toDataURL() ];
    redo = [];
    ajustes = ajustesIniciais();
    sincronizarControles();
    atualizarTamanhoCampos();
    setStatus(`✅ Imagem carregada: ${img.naturalWidth} × ${img.naturalHeight}px`);
    atualizarBotoes();
  };
  img.onerror = () => setStatus('❌ Não foi possível abrir a imagem.');
  img.src = src;
}

/* ---------- Aplicar ajustes (render) ---------- */

function render(){
  if (!original) return;
  const w = canvas.width, h = canvas.height;
  const tmp = document.createElement('canvas');
  tmp.width = w; tmp.height = h;
  const tctx = tmp.getContext('2d');
  tctx.drawImage(original, 0, 0, w, h);

  // filtros via CSS filter
  const filtro =
    `brightness(${100 + ajustes.brilho}%) ` +
    `contrast(${100 + ajustes.contraste}%) ` +
    `saturate(${100 + ajustes.saturacao}%) ` +
    `sepia(${ajustes.sepia}%) ` +
    `blur(${ajustes.desfoque}px) ` +
    `${ajustes.cinza ? 'grayscale(100%) ' : ''}` +
    `${ajustes.inverter ? 'invert(100%) ' : ''}`;

  ctx.clearRect(0, 0, w, h);
  ctx.filter = filtro.trim();
  ctx.drawImage(tmp, 0, 0);
  ctx.filter = 'none';

  // desfoque "vaza" as bordas — recorta uma moldura se preciso
  if (ajustes.desfoque > 0) {
    const d = ajustes.desfoque;
    ctx.clearRect(0, 0, w, d);
    ctx.clearRect(0, h - d, w, d);
    ctx.clearRect(0, 0, d, h);
    ctx.clearRect(w - d, 0, d, h);
  }
}

function pushHistorico(){
  hist.push(canvas.toDataURL());
  if (hist.length > 30) hist.shift();
  redo = [];
  atualizarBotoes();
}

/* ---------- Ações ---------- */

function girar(graus){
  if (!original) return;
  const w = canvas.width, h = canvas.height;

  // Gera a imagem girada em um canvas novo
  const tmp = document.createElement('canvas');
  const girado = (graus === 90 || graus === -90 || graus === 270);
  tmp.width  = girado ? h : w;
  tmp.height = girado ? w : h;
  const tctx = tmp.getContext('2d');
  tctx.translate(tmp.width / 2, tmp.height / 2);
  tctx.rotate(graus * Math.PI / 180);
  tctx.drawImage(canvas, -w / 2, -h / 2);

  // Vira a nova "original" para os ajustes continuarem funcionando
  const nova = new Image();
  nova.onload = () => {
    original = nova;
    canvas.width = tmp.width; canvas.height = tmp.height;
    render();
    pushHistorico();
    atualizarTamanhoCampos();
    setStatus(`🔄 Girado ${graus > 0 ? 'horário' : 'anti-horário'} 90°`);
  };
  nova.src = tmp.toDataURL();
}

function espelhar(horizontal){
  if (!original) return;
  const w = canvas.width, h = canvas.height;
  const tmp = document.createElement('canvas');
  tmp.width = w; tmp.height = h;
  const tctx = tmp.getContext('2d');
  tctx.translate(horizontal ? w : 0, horizontal ? 0 : h);
  tctx.scale(horizontal ? -1 : 1, horizontal ? 1 : -1);
  tctx.drawImage(canvas, 0, 0);

  const nova = new Image();
  nova.onload = () => {
    original = nova;
    render();
    pushHistorico();
    setStatus(horizontal ? '↔ Espelhado horizontalmente' : '↕ Espelhado verticalmente');
  };
  nova.src = tmp.toDataURL();
}

function redimensionar(){
  if (!original) return;
  const nw = parseInt(ctrl.largura.value, 10);
  const nh = parseInt(ctrl.altura.value, 10);
  if (!nw || !nh || nw < 1 || nh < 1) { setStatus('⚠️ Tamanho inválido.'); return; }

  const tmp = document.createElement('canvas');
  tmp.width = nw; tmp.height = nh;
  const tctx = tmp.getContext('2d');
  tctx.imageSmoothingQuality = 'high';
  tctx.drawImage(canvas, 0, 0, nw, nh);

  const nova = new Image();
  nova.onload = () => {
    original = nova;
    canvas.width = nw; canvas.height = nh;
    render();
    pushHistorico();
    setStatus(`📐 Redimensionado para ${nw} × ${nh}px`);
  };
  nova.src = tmp.toDataURL();
}

/* ---------- Recorte ---------- */

let recortando = false;
let crop = { x:0, y:0, w:0, h:0 };

function iniciarRecorte(){
  if (!original) return;
  recortando = true;
  $('btnCrop').hidden = true;
  $('btnCropCancel').hidden = false;
  $('btnCropApply').hidden = false;

  // Caixa inicial = 60% do centro
  const r = canvas.getBoundingClientRect();
  const w = r.width, h = r.height;
  crop.w = w * 0.6; crop.h = h * 0.6;
  crop.x = (w - crop.w) / 2; crop.y = (h - crop.h) / 2;
  posicionarCrop();
  cropBox.hidden = false;
  setStatus('✂️ Arraste a área e depois clique em "Aplicar recorte".');
}

function posicionarCrop(){
  cropBox.style.left   = crop.x + 'px';
  cropBox.style.top    = crop.y + 'px';
  cropBox.style.width  = crop.w + 'px';
  cropBox.style.height = crop.h + 'px';
}

function cancelarRecorte(){
  recortando = false;
  cropBox.hidden = true;
  $('btnCrop').hidden = false;
  $('btnCropCancel').hidden = true;
  $('btnCropApply').hidden = true;
  setStatus('Recorte cancelado.');
}

function aplicarRecorte(){
  if (!recortando) return;
  const r = canvas.getBoundingClientRect();
  const escalaX = canvas.width / r.width;
  const escalaY = canvas.height / r.height;

  const sx = Math.round(crop.x * escalaX);
  const sy = Math.round(crop.y * escalaY);
  const sw = Math.round(crop.w * escalaX);
  const sh = Math.round(crop.h * escalaY);
  if (sw < 2 || sh < 2) { setStatus('⚠️ Área muito pequena.'); return; }

  const tmp = document.createElement('canvas');
  tmp.width = sw; tmp.height = sh;
  tmp.getContext('2d').drawImage(canvas, sx, sy, sw, sh, 0, 0, sw, sh);

  const nova = new Image();
  nova.onload = () => {
    original = nova;
    canvas.width = sw; canvas.height = sh;
    cancelarRecorte();
    render();
    pushHistorico();
    atualizarTamanhoCampos();
    setStatus(`✂️ Recortado para ${sw} × ${sh}px`);
  };
  nova.src = tmp.toDataURL();
}

// Interação de arrastar/redimensionar a caixa de recorte
function ativarInteracaoCrop(){
  let modo = null, ini = null;

  const iniciar = (e, m) => {
    if (!recortando) return;
    modo = m;
    const t = e.touches ? e.touches[0] : e;
    const r = canvasHolder.getBoundingClientRect();
    ini = {
      px: t.clientX, py: t.clientY,
      cx: crop.x, cy: crop.y, cw: crop.w, ch: crop.h, r
    };
    e.preventDefault();
  };

  const mover = (e) => {
    if (!modo || !recortando) return;
    const t = e.touches ? e.touches[0] : e;
    const dx = t.clientX - ini.px, dy = t.clientY - ini.py;
    const R = ini.r;
    const min = 30;

    if (modo === 'move') {
      crop.x = clamp(ini.cx + dx, 0, R.width - crop.w);
      crop.y = clamp(ini.cy + dy, 0, R.height - crop.h);
    } else {
      let x1 = ini.cx, y1 = ini.cy, x2 = ini.cx + ini.cw, y2 = ini.cy + ini.ch;
      if (modo.includes('w')) x1 = clamp(ini.cx + dx, 0, x2 - min);
      if (modo.includes('e')) x2 = clamp(ini.cx + ini.cw + dx, x1 + min, R.width);
      if (modo.includes('n')) y1 = clamp(ini.cy + dy, 0, y2 - min);
      if (modo.includes('s')) y2 = clamp(ini.cy + ini.ch + dy, y1 + min, R.height);
      crop.x = x1; crop.y = y1; crop.w = x2 - x1; crop.h = y2 - y1;
    }
    posicionarCrop();
    e.preventDefault();
  };

  const soltar = () => { modo = null; };

  cropBox.addEventListener('mousedown', (e) => iniciar(e, 'move'));
  cropBox.addEventListener('touchstart', (e) => iniciar(e, 'move'), {passive:false});
  document.querySelectorAll('.handle').forEach(h => {
    const classe = [...h.classList].find(c => ['nw','ne','sw','se'].includes(c));
    h.addEventListener('mousedown', (e) => { e.stopPropagation(); iniciar(e, classe); });
    h.addEventListener('touchstart', (e) => { e.stopPropagation(); iniciar(e, classe); }, {passive:false});
  });

  window.addEventListener('mousemove', mover);
  window.addEventListener('touchmove', mover, {passive:false});
  window.addEventListener('mouseup', soltar);
  window.addEventListener('touchend', soltar);
}

/* ---------- Desfazer / Refazer ---------- */

function desfazer(){
  if (hist.length <= 1) return;
  redo.push(hist.pop());
  aplicarDataURL(hist[hist.length - 1]);
  atualizarBotoes();
  setStatus('↶ Desfeito');
}

function refazer(){
  if (!redo.length) return;
  const url = redo.pop();
  hist.push(url);
  aplicarDataURL(url);
  atualizarBotoes();
  setStatus('↷ Refeito');
}

function aplicarDataURL(url){
  const img = new Image();
  img.onload = () => {
    original = img;
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    ajustes = ajustesIniciais();
    sincronizarControles();
    render();
    atualizarTamanhoCampos();
  };
  img.src = url;
}

/* ---------- Salvar ---------- */

function salvar(){
  if (!original) return;
  const fmt = formatoSel.value;
  const mime = 'image/' + fmt;
  const ext = fmt === 'jpeg' ? 'jpg' : fmt;

  canvas.toBlob((blob) => {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `editada-${Date.now()}.${ext}`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    setStatus(`💾 Imagem salva (${fmt.toUpperCase()})`);
  }, mime, 0.92);
}

/* ---------- Controles ---------- */

function sincronizarControles(){
  ctrl.brilho.value = ajustes.brilho;
  ctrl.contraste.value = ajustes.contraste;
  ctrl.saturacao.value = ajustes.saturacao;
  ctrl.desfoque.value = ajustes.desfoque;
  ctrl.sepia.value = ajustes.sepia;
  ctrl.cinza.checked = ajustes.cinza;
  ctrl.inverter.checked = ajustes.inverter;

  labels.brilho.textContent = ajustes.brilho;
  labels.contraste.textContent = ajustes.contraste;
  labels.saturacao.textContent = ajustes.saturacao;
  labels.desfoque.textContent = ajustes.desfoque;
  labels.sepia.textContent = ajustes.sepia;
}

function atualizarTamanhoCampos(){
  ctrl.largura.value = canvas.width;
  ctrl.altura.value  = canvas.height;
}

function atualizarBotoes(){
  const temImg = !!original;
  ['btnRotL','btnRotR','btnFlipH','btnFlipV','btnCrop','btnReset','btnResize','btnSalvar']
    .forEach(id => $(id).disabled = !temImg);
  ctrl.largura.disabled = ctrl.altura.disabled = ctrl.proporcao.disabled = !temImg;
  formatoSel.disabled = !temImg;
  $('btnUndo').disabled = hist.length <= 1;
  $('btnRedo').disabled = redo.length === 0;
}

function await_habilitaControles(v){ /* compat: nada a fazer, atualizarBotoes cuida */ }

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const setStatus = (t) => statusEl.textContent = t;

/* ---------- Eventos ---------- */

$('btnAbrir').addEventListener('click', () => fileInput.click());
fileInput.addEventListener('change', (e) => { if (e.target.files[0]) abrirArquivo(e.target.files[0]); });

drop.addEventListener('click', () => fileInput.click());
['dragenter','dragover'].forEach(ev =>
  document.addEventListener(ev, (e) => { e.preventDefault(); drop.classList.add('over'); })
);
['dragleave','drop'].forEach(ev =>
  document.addEventListener(ev, (e) => { e.preventDefault(); drop.classList.remove('over'); })
);
document.addEventListener('drop', (e) => {
  const f = e.dataTransfer.files[0];
  if (f) abrirArquivo(f);
});

// Sliders de ajuste
['brilho','contraste','saturacao','desfoque','sepia'].forEach(k => {
  ctrl[k].addEventListener('input', () => {
    ajustes[k] = parseInt(ctrl[k].value, 10);
    labels[k].textContent = ajustes[k];
    render();
  });
  ctrl[k].addEventListener('change', () => pushHistorico());
});

ctrl.cinza.addEventListener('change', () => { ajustes.cinza = ctrl.cinza.checked; render(); pushHistorico(); });
ctrl.inverter.addEventListener('change', () => { ajustes.inverter = ctrl.inverter.checked; render(); pushHistorico(); });

// Redimensionar com proporção
ctrl.largura.addEventListener('input', () => {
  if (!ctrl.proporcao.checked || !original) return;
  const prop = original.naturalHeight / original.naturalWidth;
  ctrl.altura.value = Math.round(ctrl.largura.value * prop);
});
ctrl.altura.addEventListener('input', () => {
  if (!ctrl.proporcao.checked || !original) return;
  const prop = original.naturalWidth / original.naturalHeight;
  ctrl.largura.value = Math.round(ctrl.altura.value * prop);
});

$('btnRotL').addEventListener('click', () => girar(-90));
$('btnRotR').addEventListener('click', () => girar(90));
$('btnFlipH').addEventListener('click', () => espelhar(true));
$('btnFlipV').addEventListener('click', () => espelhar(false));
$('btnResize').addEventListener('click', redimensionar);

$('btnCrop').addEventListener('click', iniciarRecorte);
$('btnCropCancel').addEventListener('click', cancelarRecorte);
$('btnCropApply').addEventListener('click', aplicarRecorte);

$('btnUndo').addEventListener('click', desfazer);
$('btnRedo').addEventListener('click', refazer);
$('btnSalvar').addEventListener('click', salvar);

$('btnReset').addEventListener('click', () => {
  if (!original) return;
  ajustes = ajustesIniciais();
  sincronizarControles();
  render();
  pushHistorico();
  setStatus('↺ Ajustes restaurados.');
});

// Atalhos de teclado
document.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'z') {
    e.preventDefault();
    e.shiftKey ? refazer() : desfazer();
  }
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 's') {
    e.preventDefault();
    if (original) salvar();
  }
});

ativarInteracaoCrop();
atualizarBotoes();
