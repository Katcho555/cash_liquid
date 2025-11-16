function initWheel() {
  if (window._wheel_loaded) return;
  window._wheel_loaded = true;
  console.log("🚀 Initialisation de la roue...");

  const wheel       = document.getElementById("wheel");
  const btn         = document.getElementById("spinButton");
  const ptsEl       = document.getElementById("userPoints");
  const bonusEl     = document.getElementById("userBonusSpins");
  const spinsEl     = document.getElementById("spinsLeft");
  const progressBar = document.getElementById("progressBar");
  const goalPoints  = parseInt(document.getElementById("goalPoints").textContent, 10);
  const spinSound   = document.getElementById("spinSound");
  const options     = JSON.parse(document.getElementById("spinOptionsJson").textContent);

  /* ----------  FIX : sécurité  ---------- */
  const n = options.length;
  if (!n) { console.warn("Aucune option de spin"); return; }

  const segmentAngle = 360 / n;
  let currentRotation = 0;

  /* ----------  Construction roue  ---------- */
  function buildWheel() {
    wheel.innerHTML = "";
    options.forEach((opt, i) => {
      const seg = document.createElement("div");
      seg.className = "segment";
      seg.style.transform = `rotate(${i * segmentAngle}deg)`;

      const label = document.createElement("div");
      label.className = "label";
      label.textContent = opt.label;
      const mid = i * segmentAngle + segmentAngle / 2;
      label.style.transform = `rotate(${mid}deg) translate(0%) rotate(-${mid}deg)`;

      seg.appendChild(label);
      wheel.appendChild(seg);
    });

    const colors = ["#FF6B6B","#4ECDC4","#45B7D1","#96CEB4","#FFEAA7","#DDA0DD","#98D8C8","#F7DC6F","#BB8FCE","#85C1E9","#F8C471","#82E0AA"];
    const stops  = options.map((_, i) =>
      `${colors[i % colors.length]} ${i * segmentAngle}deg ${(i+1) * segmentAngle}deg`);
    wheel.style.background = `conic-gradient(${stops.join(",")})`;
  }

  /* ----------  Mise à jour visuelle bouton  ---------- */
  function refreshButton(spinsLeft, bonusLeft) {
    const total = spinsLeft + bonusLeft;
    btn.disabled = total <= 0;
    btn.textContent = total > 0 ? "🎡 Tourner la roue" : "⏳ Plus de spins aujourd’hui";
  }

  /* ----------  Spin  ---------- */
  btn.addEventListener("click", async () => {
    if (btn.disabled) return;
    btn.disabled = true;                       // verrou temporaire
    console.log("🎡 Début du spin...");

    try {
      const token = document.querySelector("meta[name='csrf-token']")?.content;
      const resp  = await fetch("/users/spin", {
        method : "POST",
        headers: { "X-CSRF-Token": token, "Accept": "application/json" }
      });
      const data  = await resp.json();

      if (!resp.ok) {
        showModal("Erreur", data.error);
        return;                                // finally réactivera
      }

      /* ----------  Son  ---------- */
      try { spinSound.currentTime = 0; await spinSound.play(); } catch {}

      /* ----------  Animation  ---------- */
      const idx = options.findIndex(o => o.label === data.label);
      if (idx === -1) { console.error("Segment non trouvé"); return; }

      const center     = idx * segmentAngle + segmentAngle / 2;
      const spins      = 6;
      const offset     = (Math.random() * 4 - 2);      // imprécision
      const finalRot   = spins * 360 + (360 - center) + offset;
      wheel.style.transform = `rotate(${currentRotation + finalRot}deg)`;
      currentRotation += finalRot;

      /* ----------  Attendre fin anim  ---------- */
      await new Promise(r => setTimeout(r, 4200));

      /* ----------  MAJ UI  ---------- */
      ptsEl.textContent   = data.new_points;
      bonusEl.textContent = data.bonus_spins;
      spinsEl.textContent = data.spins_left;           // ← on écrase avec la vérité back
      updateProgress(data.new_points);
      if (data.reached_goal) showRedeemButton();

      /* ----------  Message modal  ---------- */
      let msg = data.message || "";
      if (data.value === "bonus") {
        msg = "🎉 Vous avez gagné 1 spin bonus !";
      } else if (data.value === "retry_tomorrow") {
        msg = "⏳ Pas de chance… rien cette fois ! Réessaie !";
      } else if (/^\d+$/.test(data.value)) {
        // objectif **nouvellement** atteint ?
        msg = data.reached_goal && !data.was_already_reached
          ? "🎉 Félicitations, objectif atteint ! Récupère ta récompense."
          : `+${data.value} points`;
      }
      showModal(data.label, msg);

      refreshButton(data.spins_left, data.bonus_spins);

    } catch (err) {
      console.error("💥 Erreur spin:", err);
      showModal("Erreur", "Une erreur est survenue lors du spin");
    } finally {
      /* ----------  On réactive uniquement si il en reste ---------- */
      const free = parseInt(spinsEl.textContent, 10);
      const bonus = parseInt(bonusEl.textContent, 10);
      refreshButton(free, bonus);
      console.log("✅ Spin terminé");
    }
  });

  /* ----------  Récompense  ---------- */
  function redeemAction() {
    const token = document.querySelector("meta[name='csrf-token']")?.content;
    fetch("/users/redeem_reward", {
      method : "POST",
      headers: { "X-CSRF-Token": token, "Accept": "application/json" }
    })
      .then(r => r.json())
      .then(data => {
        if (data.error) return showModal("Erreur", data.error);
        showModal("🎁 Récompense reçue", `Vous avez reçu ${data.francs} FCFA !`);
        ptsEl.textContent = data.points || 0;
        updateProgress(data.points || 0);
        document.getElementById("redeemButton")?.remove();
      })
      .catch(() => showModal("Erreur", "Erreur lors de la rédemption"));
  }

  function showRedeemButton() {
    if (document.getElementById("redeemButton")) return;
    const wrap = document.querySelector(".spin-container .mt-2");
    const b    = document.createElement("button");
    b.id       = "redeemButton";
    b.className= "btn btn-success ms-2";
    b.textContent = "Obtenir ma récompense";
    b.addEventListener("click", redeemAction);
    wrap.appendChild(b);
  }

  function updateProgress(points) {
    const percent = Math.min(100, (points / goalPoints) * 100);
    progressBar.style.width = percent + "%";
  }

  /* ----------  Modal  ---------- */
  function showModal(title, msg) {
    const root = document.getElementById("spinModalRoot");
    root.innerHTML = `
      <div style="position:fixed;inset:0;background:rgba(0,0,0,.7);
      display:flex;align-items:center;justify-content:center;z-index:2000;
      backdrop-filter: blur(5px);">
        <div style="background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding:30px;border-radius:15px;text-align:center;color:white;
        box-shadow:0 20px 40px rgba(0,0,0,0.3);max-width:400px;width:90%;">
          <h4 style="margin-bottom:15px;font-weight:700;">${title}</h4>
          <p style="font-size:16px;margin-bottom:20px;">${msg}</p>
          <button id="closeModal" class="btn btn-light" style="border-radius:25px;padding:8px 25px;">
            Fermer
          </button>
        </div>
      </div>`;
    document.getElementById("closeModal").onclick = () => root.innerHTML = "";
  }

  /* ----------  Init ---------- */
  buildWheel();
  document.getElementById("redeemButton")?.addEventListener("click", redeemAction);

  /* ----------  FIX : un seul écouteur Turbo ---------- */
}
/*  Uniquement Turbo (évite double-init) */
document.addEventListener("turbo:load", initWheel);
