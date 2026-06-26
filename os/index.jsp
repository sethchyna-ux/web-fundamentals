<link-local></link-local>

<welcome-file-list>
    <welcome-file>home.jsp</welcome-file>
    <welcome-file>index.html</welcome-file>
</welcome-file-list>

// --- CORE SYSTEM CLOCK ---
function updateClock() {
    const now = new Date();
    document.getElementById('right-status').innerText = now.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}
setInterval(updateClock, 1000);
updateClock();

// --- OS MODE SWITCHER LOGIC ---
function setMode(mode) {
    document.body.className = `${mode}-mode`;
    
    const leftStatus = document.getElementById('left-status');
    if (mode === 'darwin') leftStatus.innerText = ' Hybrid OS';
    if (mode === 'linux') leftStatus.innerText = '[root@hybridos ~]#';
    if (mode === 'android') leftStatus.innerText = '100% 🔋';
}

/* ==========================================================================
   PHASE 2: WINDOW MANAGER PHYSICS ENGINE
   ========================================================================== */
let highestZIndex = 100;

// 1. FOCUS MANAGEMENT (Bring clicked window to front)
function focusWindow(win) {
    // In Linux tiling mode or Android mode, z-index sorting is disabled
    if (document.body.classList.contains('linux-mode') || document.body.classList.contains('android-mode')) return;
    
    highestZIndex++;
    win.style.zIndex = highestZIndex;
}

// Attach focus listeners to all open windows
document.querySelectorAll('.window').forEach(win => {
    win.addEventListener('mousedown', () => focusWindow(win));
});

// 2. DRAG & DROP PHYSICS
function makeDraggable(win) {
    const header = win.querySelector('.window-header');
    let isDragging = false;
    let startX, startY, initialLeft, initialTop;

    header.addEventListener('mousedown', (e) => {
        // Disable dragging in Linux Grid or Android Fullscreen modes
        if (document.body.classList.contains('linux-mode') || document.body.classList.contains('android-mode')) return;
        
        isDragging = true;
        focusWindow(win);

        startX = e.clientX;
        startY = e.clientY;
        initialLeft = win.offsetLeft;
        initialTop = win.offsetTop;

        document.body.style.cursor = 'grabbing';
    });

    window.addEventListener('mousemove', (e) => {
        if (!isDragging) return;

        const dx = e.clientX - startX;
        const dy = e.clientY - startY;

        win.style.left = `${initialLeft + dx}px`;
        win.style.top = `${initialTop + dy}px`;
    });

    window.addEventListener('mouseup', () => {
        isDragging = false;
        document.body.style.cursor = 'default';
    });
}

// Initialize dragging for existing apps
document.querySelectorAll('.window').forEach(win => makeDraggable(win));

// 3. TRAFFIC LIGHT WINDOW CONTROLS (Close / Minimize / Maximize)
document.querySelectorAll('.window').forEach(win => {
    const closeBtn = win.querySelector('.close');
    const minBtn = win.querySelector('.min');
    const maxBtn = win.querySelector('.max');

    // CLOSE: Completely remove window from DOM
    if (closeBtn) {
        closeBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            win.style.display = 'none';
        });
    }

    // MINIMIZE: Collapse window to just its header bar
    if (minBtn) {
        minBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            const content = win.querySelector('.window-content');
            if (content.style.display === 'none') {
                content.style.display = 'block';
                win.style.height = '250px';
            } else {
                content.style.display = 'none';
                win.style.height = '32px';
            }
        });
    }

    // MAXIMIZE: Toggle 100% desktop width/height
    if (maxBtn) {
        maxBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (win.classList.contains('maximized')) {
                win.classList.remove('maximized');
                win.style.width = '400px';
                win.style.height = '250px';
                win.style.top = '100px';
                win.style.left = '100px';
            } else {
                win.classList.add('maximized');
                win.style.width = 'calc(100vw - 40px)';
                win.style.height = 'calc(100vh - 120px)';
                win.style.top = '10px';
                win.style.left = '20px';
            }
        });
    }
});