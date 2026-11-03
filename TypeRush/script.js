const $ = id => document.getElementById(id);

// ---------- settings ----------
const CFG = {
  bubbles: { Easy:   { speed: 1,   spawn: 1400, max: 5, limit: 8 },   // speed = px per tick (30 ms)
             Medium: { speed: 1.6, spawn: 1000, max: 6, limit: 6 },   // spawn = ms between new bubbles
             Hard:   { speed: 2.2, spawn: 700,  max: 8, limit: 5 } }, // limit = misses allowed
  magnet:  { Easy:   { time: 45, limit: 0 },      // time = seconds, limit = ms allowed per key (0 = none)
             Medium: { time: 30, limit: 3000 },
             Hard:   { time: 20, limit: 1500 } }
};
const SETS = { home: 'ASDFJKL', top: 'QWERTYUIOP', bottom: 'ZXCVBNM', all: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' };
const ROWS = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

let mode, diff, set;     // current choices
let S = null;            // game state (score, misses, ...)
let timer = null;        // the ONE running interval

// ---------- on-screen keyboard + physical keyboard ----------
$('kb').innerHTML = ROWS.map(r =>
  `<div class="row">${[...r].map(k => `<button class="key" data-k="${k}">${k}</button>`).join('')}</div>`).join('');
$('kb').onmousedown = e => e.preventDefault();               // keep focus off the buttons
$('kb').onclick = e => e.target.dataset.k && press(e.target.dataset.k);
addEventListener('keydown', e => {
  if (/^[a-z]$/i.test(e.key) && !e.ctrlKey && !e.metaKey && !e.altKey) press(e.key.toUpperCase());
});

// ---------- helpers ----------
function show(id) { ['menu', 'game', 'results'].forEach(s => $(s).hidden = s !== id); }
function flash(type) {                       // green / red feedback
  const el = $('stage');
  el.classList.remove('ok', 'bad'); void el.offsetWidth; el.classList.add(type);
}
function stop() { clearInterval(timer); timer = null; $('arena').innerHTML = ''; }   // kills the loop + clears bubbles
function markKeys() {                        // highlight key set + target on keyboard
  document.querySelectorAll('.key').forEach(b => {
    b.classList.toggle('inset', mode === 'magnet' && SETS[set].includes(b.dataset.k));
    b.classList.toggle('target', mode === 'magnet' && b.dataset.k === S.target);
  });
}

// ---------- start / restart / reset ----------
function start(m) {                          // start('bubbles') from menu, start() = restart
  if (m) { mode = m; diff = $(m === 'bubbles' ? 'diffA' : 'diffB').value; set = $('setB').value; }
  stop();                                    // never two loops at once
  document.activeElement.blur();
  const c = CFG[mode][diff];
  S = { running: true, c, score: 0, good: 0, bad: 0, miss: 0, level: 1, speed: c.speed,
        bubbles: [], ticks: 0, left: (c.time || 0) * 1000, age: 0, times: [], target: '' };
  show('game');
  $('arena').hidden = mode !== 'bubbles';
  $('magnet').hidden = mode !== 'magnet';
  if (mode === 'bubbles') {
    markKeys();
    const H = $('arena').clientHeight;
    for (let i = 0; i < 5; i++) spawn(H - 60 - i * H * 0.12);   // 5 bubbles at the start
    timer = setInterval(tickBubbles, 30);
  } else {
    nextTarget();
    timer = setInterval(tickMagnet, 100);
  }
  render();
}
function reset() {                           // back to home, everything cleared
  stop(); S = null; show('menu');
  ['diffA', 'diffB'].forEach(id => $(id).value = 'Medium'); $('setB').value = 'home';
}

// ---------- status bar ----------
function render() {
  $('status').innerHTML = `<span>Score <b>${S.score}</b></span>` + (mode === 'bubbles'
    ? `<span>Misses <b>${S.miss}/${S.c.limit}</b></span><span>Speed level <b>${S.level}</b></span>`
    : `<span>Time <b>${Math.ceil(S.left / 1000)}s</b></span><span>✔ <b>${S.good}</b></span><span>✘ <b>${S.bad}</b></span>`)
    + `<span>${diff}</span>`;
}

// ---------- MODE A: Bubbles ----------
function spawn(y) {
  const used = S.bubbles.map(b => b.k);
  const free = [...SETS.all].filter(k => !used.includes(k));       // no duplicate letters on screen
  const k = free[Math.random() * free.length | 0];
  const el = document.createElement('div');
  el.className = 'bubble'; el.textContent = k; el.style.top = y + 'px';
  el.style.left = Math.random() * ($('arena').clientWidth - 56) + 'px';
  $('arena').appendChild(el);
  S.bubbles.push({ k, el, y });
}
function removeBubble(b) { b.el.remove(); S.bubbles = S.bubbles.filter(x => x !== b); }

function tickBubbles() {
  S.ticks++;
  const every = Math.round(S.c.spawn / 30);
  const low = S.bubbles.length < 5 && S.ticks % 8 === 0;           // keep at least 5 on screen
  if (low || (S.ticks % every === 0 && S.bubbles.length < S.c.max)) spawn($('arena').clientHeight);
  S.bubbles.slice().forEach(b => {
    b.y -= S.speed;                                                // move upward
    b.el.style.top = b.y + 'px';
    if (b.y < -10) { removeBubble(b); S.miss++; flash('bad'); }    // reached the top = miss
  });
  render();
  if (S.miss >= S.c.limit) end();
}

// ---------- MODE B: KeyMagnet ----------
function nextTarget() {
  const pool = [...SETS[set]];
  let k;
  do { k = pool[Math.random() * pool.length | 0]; } while (k === S.target && pool.length > 1);
  S.target = k; S.age = 0;
  $('target').textContent = k;
  markKeys();
}
function tickMagnet() {
  S.left -= 100; S.age += 100;
  $('bar').style.width = S.c.limit ? Math.min(100, S.age / S.c.limit * 100) + '%' : '0';
  if (S.c.limit && S.age >= S.c.limit) { S.bad++; flash('bad'); nextTarget(); }   // too slow = incorrect
  render();
  if (S.left <= 0) end();
}

// ---------- key press (both modes) ----------
function press(k) {
  if (!S || !S.running) return;
  if (mode === 'bubbles') {
    const b = S.bubbles.find(b => b.k === k);
    if (b) {
      removeBubble(b); S.score += 10; S.good++; flash('ok');
      if (S.good % 10 === 0) { S.level++; S.speed += 0.25; }       // difficulty rises during play
    } else { S.score = Math.max(0, S.score - 5); S.bad++; flash('bad'); }
  } else {
    if (k === S.target) {
      S.good++; S.times.push(S.age); S.score += S.age < 1000 ? 15 : 10; flash('ok'); nextTarget();
    } else { S.score = Math.max(0, S.score - 2); S.bad++; flash('bad'); }
  }
  render();
}

// ---------- game over / results ----------
function end() {
  stop(); S.running = false;
  const total = S.good + S.bad, acc = (total ? Math.round(S.good / total * 100) : 0) + '%';
  const avg = S.times.length ? (S.times.reduce((a, b) => a + b, 0) / S.times.length / 1000).toFixed(2) + 's' : '-';
  const best = S.times.length ? (Math.min(...S.times) / 1000).toFixed(1) + 's' : '-';
  const rows = mode === 'bubbles'
    ? [['Score', S.score], ['Bubbles popped', S.good], ['Wrong keys', S.bad], ['Misses', S.miss], ['Speed level', S.level], ['Accuracy', acc]]
    : [['Score', S.score], ['Correct', S.good], ['Incorrect', S.bad], ['Accuracy', acc], ['Avg response', avg], ['Fastest', best]];
  $('resTitle').textContent = mode === 'bubbles' ? '💥 Game Over' : "⏱ Time's Up!";
  $('resStats').innerHTML = rows.map(([l, v]) => `<div><small>${l}</small><b>${v}</b></div>`).join('');
  show('results');
}
