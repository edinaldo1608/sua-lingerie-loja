// Script de correção: baixa do GitHub, remove caracteres corrompidos (U+FFFD)
// e substitui por emojis corretos usando escape unicode. Testa a sintaxe ao final.
const https = require('https');
const fs = require('fs');
const path = require('path');

const URL_RAW = 'https://raw.githubusercontent.com/edinaldo1608/sua-lingerie-loja/main/index.html';
const DESTINO = path.join(__dirname, 'index.html');
const RELATORIO = path.join(__dirname, 'relatorio.txt');

function baixar(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      // seguir redirects
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return baixar(res.headers.location).then(resolve, reject);
      }
      let data = '';
      res.setEncoding('utf8');
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

(async () => {
  try {
    const html = await baixar(URL_RAW);
    const linhas = [];
    linhas.push('Tamanho baixado: ' + html.length);

    // Conta quantos caracteres corrompidos existem
    const corrompidos = (html.match(/\uFFFD/g) || []).length;
    linhas.push('Caracteres corrompidos (U+FFFD) encontrados: ' + corrompidos);

    // Substitui o caractere corrompido por um emoji seguro.
    // Como não sabemos qual emoji era, usamos um genérico neutro (🛒) apenas
    // onde ele aparece em texto visível. Aqui substituímos TODOS por 🛒.
    let corrigido = html.replace(/\uFFFD/g, '\uD83D\uDED2'); // 🛒

    // Testa cada script
    const scripts = [...corrigido.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)];
    linhas.push('Quantidade de scripts: ' + scripts.length);
    scripts.forEach((m, i) => {
      const code = m[1];
      try {
        new Function(code);
        linhas.push('script#' + i + ': OK (len=' + code.length + ')');
      } catch (e) {
        linhas.push('script#' + i + ': ERRO -> ' + e.message + ' (len=' + code.length + ')');
      }
    });

    fs.writeFileSync(DESTINO, corrigido, 'utf8');
    linhas.push('Arquivo salvo em: ' + DESTINO);

    fs.writeFileSync(RELATORIO, linhas.join('\n'), 'utf8');
    console.log('CONCLUIDO');
  } catch (e) {
    fs.writeFileSync(RELATORIO, 'FALHA: ' + e.message + '\n' + e.stack, 'utf8');
    console.log('FALHA: ' + e.message);
  }
})();
