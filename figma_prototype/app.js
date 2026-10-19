/* ==========================================================================
   SPERMOSCOPE FIGMA PROTOTYPE - APP CONTROLLER
   ========================================================================== */

let currentScreenId = 'splash';
let currentMode = 'prototype'; // 'prototype' or 'canvas'
let currentZoom = 1.0;

document.addEventListener('DOMContentLoaded', () => {
  initScreenList();
  initCanvasGrid();
  renderCurrentScreen();
  updateClock();
  setInterval(updateClock, 30000);
});

// Update status bar clock
function updateClock() {
  const now = new Date();
  let hours = now.getHours();
  let minutes = now.getMinutes();
  minutes = minutes < 10 ? '0' + minutes : minutes;
  const timeStr = `${hours}:${minutes}`;
  const clockEl = document.getElementById('deviceClock');
  if (clockEl) clockEl.textContent = timeStr;
}

// Initialize left sidebar screens tree
function initScreenList() {
  const treeContainer = document.getElementById('screenTree');
  const dropdown = document.getElementById('screenSelectDropdown');
  
  if (!treeContainer) return;
  treeContainer.innerHTML = '';
  if (dropdown) dropdown.innerHTML = '';

  APP_SCREENS.forEach((screen, index) => {
    // Tree item
    const li = document.createElement('li');
    li.className = `screen-tree-item ${screen.id === currentScreenId ? 'active' : ''}`;
    li.dataset.screenId = screen.id;
    li.onclick = () => goToScreen(screen.id);
    li.innerHTML = `
      <span class="screen-badge-num">#0${index + 1}</span>
      <span>${screen.shortName}</span>
    `;
    treeContainer.appendChild(li);

    // Dropdown option
    if (dropdown) {
      const opt = document.createElement('option');
      opt.value = screen.id;
      opt.textContent = screen.name;
      opt.selected = (screen.id === currentScreenId);
      dropdown.appendChild(opt);
    }
  });
}

// Switch between screens
function goToScreen(screenId) {
  const targetScreen = APP_SCREENS.find(s => s.id === screenId);
  if (!targetScreen) return;

  currentScreenId = screenId;

  // Update left sidebar active state
  document.querySelectorAll('.screen-tree-item').forEach(item => {
    item.classList.toggle('active', item.dataset.screenId === screenId);
  });

  // Update dropdown
  const dropdown = document.getElementById('screenSelectDropdown');
  if (dropdown) dropdown.value = screenId;

  // Switch to prototype mode if currently on canvas mode
  if (currentMode === 'canvas') {
    setMode('prototype');
  }

  renderCurrentScreen();
}

// Render active screen in phone mockup
function renderCurrentScreen() {
  const viewport = document.getElementById('screenViewport');
  const screen = APP_SCREENS.find(s => s.id === currentScreenId);
  if (!viewport || !screen) return;

  viewport.innerHTML = screen.renderHtml();

  // Update status bar text color based on screen background
  const statusBar = document.getElementById('phoneStatusBar');
  const homeIndicator = document.getElementById('homeIndicator');
  
  if (statusBar && homeIndicator) {
    if (['splash', 'ai_processing'].includes(screen.id)) {
      statusBar.classList.remove('dark-text');
      homeIndicator.classList.remove('dark-bar');
    } else {
      statusBar.classList.remove('dark-text'); // keep crisp white on top banner
      homeIndicator.classList.add('dark-bar');
    }
  }
}

// Populate Canvas Grid with all artboards
function initCanvasGrid() {
  const gridContainer = document.getElementById('artboardsGridView');
  if (!gridContainer) return;

  gridContainer.innerHTML = '';

  APP_SCREENS.forEach((screen, index) => {
    const card = document.createElement('div');
    card.className = 'artboard-card';
    card.innerHTML = `
      <div class="artboard-header">
        <span>${screen.name}</span>
        <span class="artboard-dims">390 × 844</span>
      </div>
      <div class="artboard-frame" onclick="goToScreen('${screen.id}')">
        <div style="transform: scale(0.82); transform-origin: top left; width: 390px; height: 844px; pointer-events: none;">
          ${screen.renderHtml()}
        </div>
      </div>
      <div style="display: flex; gap: 6px; margin-top: 4px;">
        <button class="btn-secondary-figma" style="flex: 1; font-size: 11px; padding: 4px;" onclick="exportScreenSvg('${screen.id}')">
          Export SVG
        </button>
        <button class="btn-primary-figma" style="font-size: 11px; padding: 4px 10px;" onclick="goToScreen('${screen.id}')">
          Preview
        </button>
      </div>
    `;
    gridContainer.appendChild(card);
  });
}

// Mode Switcher (Prototype Phone vs Canvas Grid)
function setMode(mode) {
  currentMode = mode;

  document.querySelectorAll('.mode-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.mode === mode);
  });

  const phoneWrapper = document.getElementById('deviceFrameWrapper');
  const canvasGrid = document.getElementById('artboardsGridView');

  if (mode === 'prototype') {
    if (phoneWrapper) phoneWrapper.style.display = 'flex';
    if (canvasGrid) canvasGrid.classList.remove('active');
  } else {
    if (phoneWrapper) phoneWrapper.style.display = 'none';
    if (canvasGrid) canvasGrid.classList.add('active');
  }
}

// Zoom controls
function setZoom(factor) {
  currentZoom = factor;
  const phoneWrapper = document.getElementById('deviceFrameWrapper');
  if (phoneWrapper) {
    phoneWrapper.style.transform = `scale(${currentZoom})`;
  }
  document.querySelectorAll('.zoom-btn').forEach(btn => {
    btn.classList.toggle('active', parseFloat(btn.dataset.zoom) === factor);
  });
}

// Download an SVG file for Figma
function downloadFile(content, fileName, mimeType = 'image/svg+xml') {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  setTimeout(() => {
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  }, 100);
}

// Export single screen as Figma SVG
function exportScreenSvg(screenId) {
  const screen = APP_SCREENS.find(s => s.id === screenId);
  if (!screen) return;
  const svg = screen.generateSvg();
  downloadFile(svg, `Spermoscope_${screen.id}_artboard.svg`);
}

// Export Current Screen
function exportCurrentScreenSvg() {
  exportScreenSvg(currentScreenId);
}

// Export All Screens as a combined Figma Canvas SVG
function exportAllScreensSvg() {
  const spacing = 40;
  const cardWidth = 390;
  const cardHeight = 844;
  const totalWidth = (cardWidth + spacing) * APP_SCREENS.length + spacing;
  const totalHeight = cardHeight + 120;

  let combinedContent = `
    <svg width="${totalWidth}" height="${totalHeight}" viewBox="0 0 ${totalWidth} ${totalHeight}" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="${totalWidth}" height="${totalHeight}" fill="#141414"/>
  `;

  APP_SCREENS.forEach((screen, index) => {
    const x = spacing + index * (cardWidth + spacing);
    const y = 60;

    combinedContent += `
      <!-- Artboard: ${screen.name} -->
      <g transform="translate(${x}, ${y})">
        <text x="0" y="-18" font-family="Plus Jakarta Sans, sans-serif" font-size="14" font-weight="700" fill="#A0A0A0">${screen.name}</text>
        <g id="artboard_${screen.id}">
          ${screen.generateSvg()}
        </g>
      </g>
    `;
  });

  combinedContent += `</svg>`;
  downloadFile(combinedContent, `Spermoscope_Complete_Figma_UI_Kit.svg`);
}

// Helper: Demo login credential autocompletion
function fillCreds(email, pwd) {
  const emailInput = document.getElementById('loginEmail');
  const pwdInput = document.getElementById('loginPwd');
  if (emailInput) emailInput.value = email;
  if (pwdInput) pwdInput.value = pwd;
}

// Helper: Role tab switch in login
function setRole(role) {
  document.querySelectorAll('.role-tab-btn').forEach(btn => {
    btn.classList.toggle('active', btn.textContent.toLowerCase().includes(role));
  });
  if (role === 'admin') {
    fillCreds('admin@demo.com', 'admin123');
  } else {
    fillCreds('doctor@demo.com', 'password123');
  }
}

// Copy Design Tokens
function copyTokens() {
  const tokens = `/* SPERMOSCOPE DESIGN TOKENS */
Primary Navy: #0F274A
Secondary Blue: #1E3A8A
Accent Cyan: #38BDF8
Surface White: #FFFFFF
Background Slate: #F1F5F9
Text Main: #0F172A
Text Muted: #64748B
Success Green: #059669
Warning Amber: #D97706
Danger Red: #DC2626
Border: #E2E8F0
Font Family: 'Plus Jakarta Sans', Roboto, sans-serif
Border Radius: 14px`;

  navigator.clipboard.writeText(tokens).then(() => {
    alert('✅ Design Tokens copied to clipboard! Paste into Figma inspect panel or your design notes.');
  });
}
