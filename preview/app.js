/**
 * Calmpal — Dynamic Analogue Clock Lab
 * High-performance Canvas rendering of analogue-inspired flipped-number clock variations.
 */

const canvas = document.getElementById('clockCanvas');
const ctx = canvas.getContext('2d');

// State
let state = {
  concept: 'radialFlipped',
  flipMode: 'radialOutward',
  segmentsCount: 24,
  lineLength: 22,
  glowIntensity: 50,
  totalDuration: 1800,
  remainingSeconds: 1800,
  isPlaying: true,
  currentBg: 'images/crickets-night.jpg',
  displayMode: 'phone'
};

// Elements
const digitalTime = document.getElementById('digitalTime');
const timerLabel = document.getElementById('timerLabel');
const timeScrubber = document.getElementById('timeScrubber');
const togglePlayBtn = document.getElementById('togglePlayBtn');
const resetTimerBtn = document.getElementById('resetTimerBtn');
const lineLengthSlider = document.getElementById('lineLength');
const lineLengthVal = document.getElementById('lineLengthVal');
const glowSlider = document.getElementById('glowIntensity');
const glowVal = document.getElementById('glowVal');
const bgSelect = document.getElementById('bgSelect');
const bgLayer = document.getElementById('bgLayer');
const iphoneShell = document.getElementById('iphoneShell');
const dockPlayBtn = document.getElementById('dockPlayBtn');
const playPauseIcon = document.getElementById('playPauseIcon');

// Initialize background
bgLayer.style.backgroundImage = `url('${state.currentBg}')`;

// Format time
function formatTime(seconds) {
  const total = Math.max(0, Math.ceil(seconds));
  const hrs = Math.floor(total / 3600);
  const mins = Math.floor((total % 3600) / 60);
  const secs = total % 60;
  if (hrs > 0) {
    return `${hrs}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// UI Event Listeners
document.getElementById('conceptGroup').addEventListener('click', (e) => {
  const btn = e.target.closest('.btn-option');
  if (!btn) return;
  document.querySelectorAll('#conceptGroup .btn-option').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  state.concept = btn.dataset.concept;
});

document.getElementById('flipGroup').addEventListener('click', (e) => {
  const btn = e.target.closest('.chip');
  if (!btn) return;
  document.querySelectorAll('#flipGroup .chip').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  state.flipMode = btn.dataset.flip;
});

document.getElementById('linesGroup').addEventListener('click', (e) => {
  const btn = e.target.closest('.chip');
  if (!btn) return;
  document.querySelectorAll('#linesGroup .chip').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  state.segmentsCount = parseInt(btn.dataset.lines, 10);
});

lineLengthSlider.addEventListener('input', (e) => {
  state.lineLength = parseInt(e.target.value, 10);
  lineLengthVal.textContent = `${state.lineLength}px`;
});

glowSlider.addEventListener('input', (e) => {
  state.glowIntensity = parseInt(e.target.value, 10);
  glowVal.textContent = `${state.glowIntensity}%`;
});

timeScrubber.addEventListener('input', (e) => {
  state.remainingSeconds = parseFloat(e.target.value);
  state.totalDuration = Math.max(state.totalDuration, state.remainingSeconds);
  updateTimerUI();
});

function togglePlay() {
  state.isPlaying = !state.isPlaying;
  togglePlayBtn.textContent = state.isPlaying ? '⏸ Pause Simulation' : '▶ Play Simulation';
  playPauseIcon.innerHTML = state.isPlaying 
    ? '<path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>' 
    : '<path d="M8 5v14l11-7z"/>';
}

togglePlayBtn.addEventListener('click', togglePlay);
dockPlayBtn.addEventListener('click', togglePlay);
document.getElementById('clockStage').addEventListener('click', togglePlay);

resetTimerBtn.addEventListener('click', () => {
  state.totalDuration = 1800;
  state.remainingSeconds = 1800;
  timeScrubber.value = 1800;
  updateTimerUI();
});

bgSelect.addEventListener('change', (e) => {
  state.currentBg = e.target.value;
  bgLayer.style.backgroundImage = `url('${state.currentBg}')`;
});

document.getElementById('frameGroup').addEventListener('click', (e) => {
  const btn = e.target.closest('.chip');
  if (!btn) return;
  document.querySelectorAll('#frameGroup .chip').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  state.displayMode = btn.dataset.frame;
  if (state.displayMode === 'fullscreen') {
    iphoneShell.classList.add('fullscreen-mode');
  } else {
    iphoneShell.classList.remove('fullscreen-mode');
  }
});

function updateTimerUI() {
  const str = formatTime(state.remainingSeconds);
  digitalTime.textContent = str;
  timerLabel.textContent = str;
}

// Render Animation Loop
let lastTime = performance.now();

function render(now) {
  const dt = (now - lastTime) / 1000;
  lastTime = now;

  if (state.isPlaying && state.remainingSeconds > 0) {
    state.remainingSeconds = Math.max(0, state.remainingSeconds - dt);
    timeScrubber.value = state.remainingSeconds;
    updateTimerUI();
  }

  // Clear Canvas
  const w = canvas.width;
  const h = canvas.height;
  const cx = w / 2;
  const cy = h / 2;
  const radius = w * 0.44;

  ctx.clearRect(0, 0, w, h);

  const progress = state.totalDuration > 0 ? (state.remainingSeconds / state.totalDuration) : 0;
  const elapsed = (state.totalDuration - state.remainingSeconds);
  const sweepAngle = (1.0 - progress) * Math.PI * 2; // from 0 to 2PI

  // Breathing wave pulse
  const breath = Math.sin(now * 0.002) * 0.05 + 1.0;

  ctx.save();
  ctx.translate(cx, cy);

  // ── Render Clock Variations ──
  switch (state.concept) {
    case 'radialFlipped':
      drawRadialFlippedClock(ctx, radius, progress, now);
      break;
    case 'kinetic3D':
      drawKinetic3DClock(ctx, radius, progress, now);
      break;
    case 'bauhausChrono':
      drawBauhausChronoClock(ctx, radius, progress, now);
      break;
    case 'orbitalGravity':
      drawOrbitalGravityClock(ctx, radius, progress, now);
      break;
  }

  ctx.restore();

  requestAnimationFrame(render);
}

// ── 1. Radial Flipped Clock ─────────────────────────────────────────────────
function drawRadialFlippedClock(ctx, r, progress, now) {
  const N = state.segmentsCount;
  const lineLen = state.lineLength * 2.0;
  const glow = state.glowIntensity / 100;

  // 1. Base Outer Ring Track
  ctx.beginPath();
  ctx.arc(0, 0, r, 0, Math.PI * 2);
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
  ctx.lineWidth = 3;
  ctx.stroke();

  // 2. Inner Enclosure Ring
  ctx.beginPath();
  ctx.arc(0, 0, r - lineLen - 40, 0, Math.PI * 2);
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
  ctx.lineWidth = 2;
  ctx.stroke();

  // 3. Radial Separator Lines & Flipped Numbers
  const numLabels = 12;
  for (let i = 0; i < N; i++) {
    const angle = (i / N) * Math.PI * 2 - Math.PI / 2;
    const isMajor = (i % (N / numLabels)) === 0;
    const currentLineLen = isMajor ? lineLen : lineLen * 0.55;

    // Line Start / End
    const x1 = Math.cos(angle) * r;
    const y1 = Math.sin(angle) * r;
    const x2 = Math.cos(angle) * (r - currentLineLen);
    const y2 = Math.sin(angle) * (r - currentLineLen);

    // Segment active highlight
    const segProgress = (i / N);
    const isActive = (1.0 - progress) >= segProgress;

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.lineWidth = isMajor ? 3 : 1.5;
    ctx.strokeStyle = isActive ? '#ffffff' : 'rgba(255, 255, 255, 0.22)';
    if (isActive && glow > 0) {
      ctx.shadowColor = 'rgba(255, 255, 255, 0.8)';
      ctx.shadowBlur = 12 * glow;
    } else {
      ctx.shadowBlur = 0;
    }
    ctx.stroke();
    ctx.shadowBlur = 0;
  }

  // Draw Flipped Numerals between separators
  for (let i = 0; i < numLabels; i++) {
    // Center of each numeral cell (offset by half a slot)
    const angle = ((i + 0.5) / numLabels) * Math.PI * 2 - Math.PI / 2;
    const numRadius = r - lineLen * 0.5 - 18;
    const nx = Math.cos(angle) * numRadius;
    const ny = Math.sin(angle) * numRadius;
    const label = ((i + 1) * (60 / numLabels)).toString(); // e.g. 5, 10, 15, 20... 60

    ctx.save();
    ctx.translate(nx, ny);

    // Apply Orientation / Flip Transform
    applyNumberFlip(ctx, angle, i, numLabels, now);

    ctx.font = '600 18px "Plus Jakarta Sans", sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const numProgress = (i + 1) / numLabels;
    const isActive = (1.0 - progress) >= numProgress;
    ctx.fillStyle = isActive ? '#ffffff' : 'rgba(255, 255, 255, 0.45)';
    if (isActive && glow > 0) {
      ctx.shadowColor = 'rgba(255, 255, 255, 0.9)';
      ctx.shadowBlur = 10 * glow;
    }
    ctx.fillText(label, 0, 0);
    ctx.restore();
  }

  // 4. Smooth Floating Remaining Progress Arc
  const activeSweep = (1.0 - progress) * Math.PI * 2;
  ctx.beginPath();
  ctx.arc(0, 0, r, -Math.PI / 2, -Math.PI / 2 + activeSweep);
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 5;
  ctx.lineCap = 'round';
  if (glow > 0) {
    ctx.shadowColor = '#ffffff';
    ctx.shadowBlur = 14 * glow;
  }
  ctx.stroke();
  ctx.shadowBlur = 0;

  // 5. Leading Dynamic Floating Pearl Dot
  const dotAngle = -Math.PI / 2 + activeSweep;
  const dotX = Math.cos(dotAngle) * r;
  const dotY = Math.sin(dotAngle) * r;

  ctx.beginPath();
  ctx.arc(dotX, dotY, 7, 0, Math.PI * 2);
  ctx.fillStyle = '#ffffff';
  ctx.shadowColor = '#ffffff';
  ctx.shadowBlur = 16;
  ctx.fill();
  ctx.shadowBlur = 0;
}

// ── 2. 3D Kinetic Flip Clock ────────────────────────────────────────────────
function drawKinetic3DClock(ctx, r, progress, now) {
  const N = 12;
  const lineLen = state.lineLength * 2.2;
  const glow = state.glowIntensity / 100;

  // Outer segmented bevel rings
  ctx.beginPath();
  ctx.arc(0, 0, r + 8, 0, Math.PI * 2);
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
  ctx.lineWidth = 1.5;
  ctx.setLineDash([4, 6]);
  ctx.stroke();
  ctx.setLineDash([]);

  // Radial Laser Splitters
  for (let i = 0; i < N; i++) {
    const angle = (i / N) * Math.PI * 2 - Math.PI / 2;
    const x1 = Math.cos(angle) * (r + 4);
    const y1 = Math.sin(angle) * (r + 4);
    const x2 = Math.cos(angle) * (r - lineLen);
    const y2 = Math.sin(angle) * (r - lineLen);

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.lineWidth = 2.5;
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.35)';
    ctx.stroke();
  }

  // 3D Flipping Numeral Slots
  for (let i = 0; i < N; i++) {
    const angle = ((i + 0.5) / N) * Math.PI * 2 - Math.PI / 2;
    const numRadius = r - lineLen * 0.5;
    const nx = Math.cos(angle) * numRadius;
    const ny = Math.sin(angle) * numRadius;
    const label = ((i + 1) * 5).toString();

    ctx.save();
    ctx.translate(nx, ny);

    // Continuous 3D kinetic spin/flip synced with time
    const slotProgress = (i + 0.5) / N;
    const distToHand = Math.abs((1.0 - progress) - slotProgress);
    const wave = Math.sin(now * 0.003 + i * 0.5);

    // Base orientation
    ctx.rotate(angle + Math.PI / 2);

    // 3D Scale/Flip projection
    const flipFactor = Math.cos(now * 0.002 + i * 0.6);
    ctx.scale(1, flipFactor); // Vertical 3D perspective flip

    ctx.font = '700 20px "Plus Jakarta Sans", sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = (1.0 - progress) >= slotProgress ? '#ffffff' : 'rgba(255, 255, 255, 0.5)';
    
    if (distToHand < 0.08 && glow > 0) {
      ctx.shadowColor = '#ffffff';
      ctx.shadowBlur = 18 * glow;
    }
    ctx.fillText(label, 0, 0);
    ctx.restore();
  }

  // Active Chrono Progress Arc
  const activeSweep = (1.0 - progress) * Math.PI * 2;
  ctx.beginPath();
  ctx.arc(0, 0, r - lineLen - 12, -Math.PI / 2, -Math.PI / 2 + activeSweep);
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.85)';
  ctx.lineWidth = 4;
  ctx.stroke();
}

// ── 3. Bauhaus Chrono Clock ─────────────────────────────────────────────────
function drawBauhausChronoClock(ctx, r, progress, now) {
  const N = state.segmentsCount;
  const lineLen = state.lineLength * 1.8;

  // Crisp architectural radial lines
  for (let i = 0; i < N; i++) {
    const angle = (i / N) * Math.PI * 2 - Math.PI / 2;
    const isPrimary = (i % 6 === 0);
    const len = isPrimary ? lineLen : lineLen * 0.4;

    const x1 = Math.cos(angle) * r;
    const y1 = Math.sin(angle) * r;
    const x2 = Math.cos(angle) * (r - len);
    const y2 = Math.sin(angle) * (r - len);

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.lineWidth = isPrimary ? 3 : 1;
    ctx.strokeStyle = isPrimary ? 'rgba(255, 255, 255, 0.7)' : 'rgba(255, 255, 255, 0.2)';
    ctx.stroke();
  }

  // Minimal flipped numbers along outer boundary
  const labels = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  for (let i = 0; i < 12; i++) {
    const angle = (i / 12) * Math.PI * 2 - Math.PI / 2;
    const nx = Math.cos(angle) * (r - lineLen - 24);
    const ny = Math.sin(angle) * (r - lineLen - 24);

    ctx.save();
    ctx.translate(nx, ny);
    applyNumberFlip(ctx, angle, i, 12, now);

    ctx.font = '300 16px "Plus Jakarta Sans", sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = '#ffffff';
    ctx.fillText(labels[i].toString(), 0, 0);
    ctx.restore();
  }

  // Smooth Minimal Sweep Hand
  const handAngle = -Math.PI / 2 + (1.0 - progress) * Math.PI * 2;
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(Math.cos(handAngle) * (r - 10), Math.sin(handAngle) * (r - 10));
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 2.5;
  ctx.stroke();
}

// ── 4. Orbital Gravity Clock ────────────────────────────────────────────────
function drawOrbitalGravityClock(ctx, r, progress, now) {
  const lineLen = state.lineLength * 2.0;

  // Particle Aura Ring
  const numParticles = 36;
  for (let i = 0; i < numParticles; i++) {
    const pAngle = (i / numParticles) * Math.PI * 2 + now * 0.0005;
    const pRadius = r + Math.sin(now * 0.003 + i) * 8;
    const px = Math.cos(pAngle) * pRadius;
    const py = Math.sin(pAngle) * pRadius;

    ctx.beginPath();
    ctx.arc(px, py, 1.5, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.fill();
  }

  // Segmented Divider Wedges
  const N = 12;
  for (let i = 0; i < N; i++) {
    const angle = (i / N) * Math.PI * 2 - Math.PI / 2;
    const x1 = Math.cos(angle) * r;
    const y1 = Math.sin(angle) * r;
    const x2 = Math.cos(angle) * (r - lineLen);
    const y2 = Math.sin(angle) * (r - lineLen);

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.lineWidth = 2;
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    ctx.stroke();

    // Orbital Inverted Numerals
    const numAngle = ((i + 0.5) / N) * Math.PI * 2 - Math.PI / 2;
    const nx = Math.cos(numAngle) * (r - lineLen * 0.5);
    const ny = Math.sin(numAngle) * (r - lineLen * 0.5);

    ctx.save();
    ctx.translate(nx, ny);
    applyNumberFlip(ctx, numAngle, i, N, now);

    ctx.font = '500 17px "Plus Jakarta Sans", sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = '#ffffff';
    ctx.fillText(((i + 1) * 5).toString(), 0, 0);
    ctx.restore();
  }

  // Active Gravity Flow Sweep Arc
  const activeSweep = (1.0 - progress) * Math.PI * 2;
  ctx.beginPath();
  ctx.arc(0, 0, r, -Math.PI / 2, -Math.PI / 2 + activeSweep);
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 4.5;
  ctx.shadowColor = '#ffffff';
  ctx.shadowBlur = 14;
  ctx.stroke();
  ctx.shadowBlur = 0;
}

// ── Number Flip Helper ──────────────────────────────────────────────────────
function applyNumberFlip(ctx, angle, index, total, now) {
  switch (state.flipMode) {
    case 'radialOutward':
      // Numbers follow the radius facing outward (upside down on lower half)
      ctx.rotate(angle + Math.PI / 2);
      break;

    case 'flippedUpsideDown':
      // Explicit 180° inversion for all numerals
      ctx.rotate(Math.PI);
      break;

    case 'tangentFlipped':
      // Tangential alignment flipped inwards
      ctx.rotate(angle - Math.PI / 2);
      break;

    case 'mirrored':
      // Mirrored on horizontal/vertical axis
      ctx.rotate(angle + Math.PI / 2);
      ctx.scale(-1, 1);
      break;
  }
}

// Start Render Loop
requestAnimationFrame(render);
