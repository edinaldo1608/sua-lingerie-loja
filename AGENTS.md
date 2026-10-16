# Sua Lingerie — Instruções para Agentes de IA

Este documento é a **fonte única da verdade** sobre o sistema **Sua Lingerie**. Todo agente de IA deve lê-lo integralmente antes de qualquer modificação.

---

## 🏗️ Visão Geral do Projeto

Sistema completo de e-commerce de lingerie **100% frontend** (HTML/CSS/JS puro, sem frameworks, sem backend, sem servidor). Tudo roda em arquivos locais e persiste via `localStorage`.

| Componente | Arquivo | Finalidade | localStorage key |
|---|---|---|---|
| **Site (loja)** | `Sua Lingerie - Site (novo).html` | Catálogo para clientes + carrinho → pedido via WhatsApp | `sualingerie.site.v2` |
| **App (gestão)** | `Sua Lingerie - Novo Layout.html` | PDV: estoque, vendas, caixa, clientes, relatórios | `sualingerie.v1` |
| **Editor de imagens** | `Editor/index.html` | Ajustar fotos de produtos (filtros, redimensionar, cortar) | — |
| **Script de branqueamento** | `Editor/branquear.ps1` | PowerShell: recolore tons quentes para branco em fotos | — |

📁 **Todos os arquivos** estão em `C:\Users\Edinaldo\Downloads\Sua Lingerie\`.

---

## 🛠️ Tecnologias

- **HTML5** puro — sem frameworks
- **CSS3** puro — variáveis CSS (`:root`), `grid`/`flex`, `backdrop-filter`, `aspect-ratio`, `env(safe-area-inset-*)`, media queries
- **JavaScript ES6** puro — sem jQuery, React, Vue ou qualquer biblioteca
- **localStorage** — única forma de persistência (sem backend, sem servidor)
- **Canvas API** — usada no Editor de imagens e no upload de fotos (redimensionamento para base64)

---

## 📐 Convenções de Código

### Estilo
- **Indentação**: 2 espaços (nunca tabs)
- **Nomenclatura**: `camelCase` para variáveis e funções, `UPPER_SNAKE` para constantes
- **Strings**: aspas simples `'` (preferencialmente)
- **Seletor abreviado**: `const $ = s => document.querySelector(s)` (no site); `const $ = id => document.getElementById(id)` (no Editor)
- **Escaping HTML**: função `esc()` manual

### Funções utilitárias (site)
```js
const R = v => (+v||0).toLocaleString('pt-BR', {style:'currency', currency:'BRL'});  // formata preço
const esc = s => String(s==null?'':s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));  // HTML escape
const toast = (t) => { /* exibe toast flutuante por 2.2s */ };
const save = () => localStorage.setItem(LS, JSON.stringify(CFG));  // salva config
const saveCart = () => localStorage.setItem(LS+'.cart', JSON.stringify(cart));  // salva carrinho
```

---

## 🧱 Estrutura de Dados

### Produto
```js
{
  cod: 'L001',           // código único
  nome: 'Sutiã renda',   // nome do produto
  cat: 'Sutiã',          // categoria (ex: Sutiã, Calcinha, Conjunto, Body, Camisola, Pijama, Meia, Biquíni)
  tams: ['P','M','G'],   // array de tamanhos (PP, P, M, G, GG, XG, Único, 34, 36, 38, 40, 42, 44, 46, 48...)
  cors: ['Preto','Nude'],// array de cores
  preco: 89.90,          // número, SEM formatação (usar ponto como decimal)
  estoque: 8,            // quantidade em estoque (0 = esgotado)
  img: 'data:...',       // URL da foto (pode ser URL externa OU data:image/base64)
  desc: '...',           // descrição do produto (opcional)
  _tag: 'Novidade'       // etiqueta opcional (ex: "Novo", "Promoção", "Lançamento", "Mais vendido", "Última peça", "Kit", "Verão")
}
```

### Carrinho (localStorage)
```js
[
  {
    key: 'L001|M|Preto',   // chave única = cod|tam|cor
    cod: 'L001',
    nome: 'Sutiã renda',
    preco: 89.90,
    tam: 'M',
    cor: 'Preto',
    qtd: 2,
    img: 'url...'
  }
]
```

### Configuração da Loja (localStorage key: `sualingerie.site.v2`)
```js
{
  marca: 'Sua Lingerie',
  wa: '5583988049010',     // WhatsApp (só números, com país)
  ig: 'sualingerie.jp',    // Instagram (sem @)
  msg: 'Olá! Quero fazer um pedido:',  // saudação
  tema: 'vinho',           // tema: vinho | rosa | nude | roxo | verde | preto
  produtos: [ ... ]        // array de produtos
}
```

### App de Gestão (localStorage key: `sualingerie.v1`)
```js
{
  produtos: [ ... ],  // mesma estrutura de produto
  movs: [ ... ],      // movimentações (vendas, compras)
  desp: [ ... ],      // despesas
  clientes: [ ... ],  // clientes cadastrados
  parc: [ ... ],      // parcelas a receber
  contas: [ ... ],    // contas a pagar
  saldo: 0            // saldo inicial de caixa
}
```

---

## 🔐 Sistema de Senha (Proteção do Painel Admin)

- **PIN padrão**: `1387` (constante `PIN_ADMIN` no código do site)
- **Botões ocultos**: ⚙️ (configurações) e ✏️ (editar) ficam `display: none` por padrão
- **Como revelar**: Clique **5 vezes seguidas e rápido** no **logo da loja** (canto superior esquerdo)
- **Alternativa**: Clicar no botão mesmo oculto também pede a senha
- **Recarregar a página (F5)**: os botões voltam a ficar ocultos (comportamento normal de segurança)
- **Trocar senha**: editar `const PIN_ADMIN='1387';` no código fonte do site
- **Modo edição**: ativado pelo botão ✏️ — mostra bordas tracejadas e botões de editar/excluir/reordenar nos cards de produto

---

## 🔄 Fluxo de Pedido (Site → WhatsApp → App)

1. **Cliente** monta carrinho no site → clica "Finalizar pelo WhatsApp 💬"
2. Modal pede **Nome**, **Telefone** e **Endereço**
3. Abre `wa.me/55...?text=...` com a mensagem formatada contendo:
   - Lista de itens (nome, tamanho, cor, qtd, preço)
   - Total do pedido
   - Dados do cliente
4. **Dona** copia a mensagem do WhatsApp
5. Abre o App (`Sua Lingerie - Novo Layout.html`)
6. Aba **Vender** → botão "📲 Importar pedido do site"
7. Cola a mensagem → "Registrar venda ✓"
8. App **parseia automaticamente**:
   - Cadastra/atualiza cliente
   - Registra a venda
   - Dá baixa no estoque
   - Abre o comprovante

---

## 📝 Formas de Adicionar Produtos ao Site

### 1. Lista formatada (campo "Opção 2")
```
Nome | Preço | Tamanho | Cor | Categoria | Foto(URL) | Descrição
```
- Separar com `|` (barra vertical)
- Apenas Nome e Preço são obrigatórios
- Preço pode usar vírgula ou ponto

### 2. Backup JSON do App
```json
{"produtos":[...]}
```
- Colar no campo "Opção 1" do modal de configuração

### 3. Automático (ler do App)
- Botão "↻ Ler estoque do app (automático)" no modal de configuração
- Lê da chave `sualingerie.v1` no mesmo navegador

### 4. Cadastro individual (com foto do computador)
- Botão "➕ Adicionar novo produto (com foto)" no modal de configuração
- Upload de foto → redimensionada via Canvas → convertida para base64 JPEG
- Preenche nome, preço, etiqueta, descrição, categoria, tamanhos, cores, estoque

### 5. Categorias sugeridas
- Botões de atalho (Sutiã, Calcinha, Conjunto, Body, Camisola, Pijama, Meia, Biquíni)
- Cada um adiciona 2 modelos (básico + premium) com preços e tamanhos de exemplo

---

## 🎨 Temas de Cor

Disponíveis no modal de configuração. Definidos por `data-tema` no `<html>`:

| Tema | Cor Principal | Ideal para |
|------|--------------|------------|
| `vinho` | `#7a1f3d` | Lingerie tradicional |
| `rosa` | `#d6336c` | Romântico/feminino |
| `nude` | `#a56b4e` | Elegante/neutro |
| `roxo` | `#6741d9` | Moderno |
| `verde` | `#2f7d5b` | Natureza/orgânico |
| `preto` | `#22262b` | Sofisticado |

---

## 🖼️ Editor de Imagens (`Editor/index.html`)

Editor visual completo que roda no navegador. Funcionalidades:

- **Abrir**: upload de arquivo ou drag & drop
- **Transformar**: girar 90° (horário/anti-horário), espelhar (horizontal/vertical), recortar
- **Ajustes**: brilho, contraste, saturação, desfoque, sépia, preto e branco, negativo
- **Redimensionar**: com opção de manter proporção
- **Histórico**: desfazer/refazer (até 30 estados)
- **Salvar**: PNG, JPG ou WEBP

Arquivos:
- `Editor/index.html` — estrutura HTML
- `Editor/style.css` — estilo dark moderno
- `Editor/app.js` — lógica completa (Canvas API)

---

## 🤖 Script de Branqueamento (`Editor/branquear.ps1`)

Script PowerShell que recolore tons quentes (pele, tecido) para **branco**, preservando luminosidade.

**Como funciona:**
- Processa imagens `1.jpeg` a `5.jpeg` na pasta `Editor/`
- Detecta "calor" da cor: `warmth = R - B`
- Aplica peso baseado em saturação e warmth
- Preserva fundos cinza/neutros intactos
- Salva como `{n}_branco.jpeg`

**Para executar:**
```powershell
cd C:\Users\Edinaldo\Downloads\Sua Lingerie\Editor
.\branquear.ps1
```

---

## ⚠️ Limitações Conhecidas (IMPORTANTE!)

1. **Persistência apenas em localStorage** — dados não sincronizam entre dispositivos
2. **Código inline** — CSS + HTML + JS tudo no mesmo arquivo `.html`. Editar com cuidado
3. **Fotos em base64** — ocupam muito espaço no localStorage (limite ~5-10MB)
4. **Senha hardcoded** — `PIN_ADMIN='1387'` visível no código fonte
5. **Sem controle de versão** — múltiplas cópias dos arquivos sem versionamento
6. **Botões admin reaparecem** após recarregar a página (comportamento normal de segurança)
7. **Produto com estoque 0** aparece como "Esgotado" e botão fica desabilitado

---

## 🔗 Comandos Úteis

| Ação | Como fazer |
|------|-----------|
| **Abrir site (loja)** | Dois cliques em `Sua Lingerie - Site (novo).html` |
| **Abrir app (gestão)** | Dois cliques em `Sua Lingerie - Novo Layout.html` |
| **Abrir editor de imagens** | Dois cliques em `Editor/index.html` |
| **Branquear fotos** | Executar `.\Editor\branquear.ps1` no PowerShell |
| **Acessar admin no site** | Clicar 5x no logo → digitar `1387` |
| **Limpar dados do site** | DevTools → Application → Local Storage → limpar `sualingerie.site.v2` |
| **Limpar dados do app** | DevTools → Application → Local Storage → limpar `sualingerie.v1` |

---

## 📄 Arquivos de Documentação

| Arquivo | Assunto |
|---------|---------|
| `COMO COLOCAR PRODUTOS NO SITE.txt` | Guia passo a passo de cadastro de produtos |
| `COMO USAR - Pedidos do Site.txt` | Fluxo completo: pedido WhatsApp → App |
| `COMO-ESCONDER-CONFIGURACOES.txt` | Sistema de senha e botões ocultos |
| `SUGESTOES - Melhorias no Site.txt` | Lista de 17 melhorias priorizadas |

---

## 🧠 Regras para Agentes de IA

1. **SEMPRE** leia este documento inteiro antes de modificar qualquer arquivo
2. **NUNCA** use `&&` no PowerShell 5.1 — use `;` para encadear comandos
3. **SEMPRE** faça backup do código antes de edições grandes
4. **Prefira** manter o padrão de código existente (2 espaços, camelCase, aspas simples)
5. **NUNCA** remova a proteção de senha (`PIN_ADMIN`) sem autorização explícita
6. **Documente** qualquer alteração significativa neste arquivo
7. **Teste** sempre abrindo o HTML no navegador após alterações
8. **Mantenha** compatibilidade com o App de gestão (mesma estrutura de dados)