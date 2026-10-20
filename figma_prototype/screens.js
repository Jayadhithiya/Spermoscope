/* ==========================================================================
   SPERMOSCOPE PROTOTYPE - SCREEN DEFINITIONS & SVG GENERATORS
   ========================================================================== */

const APP_SCREENS = [
  {
    id: 'splash',
    name: '01 • Splash Screen',
    shortName: 'Splash',
    category: 'Onboarding',
    renderHtml: () => `
      <div class="screen-splash" onclick="goToScreen('login')">
        <div class="splash-glow-ring">
          <div class="splash-logo-circle">
            <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="50" cy="50" r="46" fill="#1E293B"/>
              <path d="M60 40C60 48.2843 53.2843 55 45 55C41.8 55 38.8 54 36.4 52.3L26 62.7C24.8 63.9 22.8 63.9 21.6 62.7C20.4 61.5 20.4 59.5 21.6 58.3L32 47.9C30.3 45.6 29.3 42.6 29.3 39.4C29.3 31.1 36 24.4 44.3 24.4C52.6 24.4 60 31.1 60 40Z" fill="white"/>
              <path d="M35 55C32 60 25 65 18 70" stroke="white" stroke-width="3.5" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
        <div class="splash-title">SPERMOSCOPE</div>
        <div class="splash-badge">AUTOMATED MOTILITY ANALYSIS SYSTEM</div>
        <div class="splash-dots">
          <div class="splash-dot"></div>
          <div class="splash-dot"></div>
          <div class="splash-dot"></div>
        </div>
        <div class="splash-status-text">Initializing AI Diagnostic Core...</div>
        <div class="splash-footer">
          WHO 2021 Reference Standards • SIMATS v1.0.0<br/>
          <span style="opacity: 0.6; font-size: 9px; margin-top: 4px; display: inline-block;">Tap anywhere to advance &#8594;</span>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="splashBg" x1="195" y1="0" x2="195" y2="844" gradientUnits="userSpaceOnUse">
            <stop offset="0%" stop-color="#07152B"/>
            <stop offset="55%" stop-color="#0F274A"/>
            <stop offset="100%" stop-color="#132F5A"/>
          </linearGradient>
          <filter id="glowEffect" x="80" y="240" width="230" height="230" filterUnits="userSpaceOnUse">
            <feGaussianBlur stdDeviation="15" result="blur"/>
          </filter>
        </defs>
        <rect width="390" height="844" rx="44" fill="url(#splashBg)"/>
        <!-- Glow Ring -->
        <circle cx="195" cy="350" r="70" fill="#38BDF8" fill-opacity="0.25" filter="url(#glowEffect)"/>
        <circle cx="195" cy="350" r="62" stroke="#60A5FA" stroke-width="2" stroke-opacity="0.4"/>
        <!-- Logo Circle -->
        <circle cx="195" cy="350" r="50" fill="white"/>
        <circle cx="195" cy="350" r="38" fill="#1E293B"/>
        <path d="M205 340C205 348 198 355 190 355C186.8 355 183.8 354 181.4 352.3L171 362.7C169.8 363.9 167.8 363.9 166.6 362.7C165.4 361.5 165.4 359.5 166.6 358.3L177 347.9C175.3 345.6 174.3 342.6 174.3 339.4C174.3 331.1 181 324.4 189.3 324.4C197.6 324.4 205 331.1 205 340Z" fill="white"/>
        <path d="M180 355C177 360 170 365 163 370" stroke="white" stroke-width="3" stroke-linecap="round"/>
        <!-- Title & Subtitle -->
        <text x="195" y="460" font-family="Plus Jakarta Sans, Roboto, sans-serif" font-size="24" font-weight="800" letter-spacing="4" fill="white" text-anchor="middle">SPERMOSCOPE</text>
        <rect x="80" y="480" width="230" height="26" rx="13" fill="white" fill-opacity="0.1" stroke="white" stroke-opacity="0.2"/>
        <text x="195" y="497" font-family="Plus Jakarta Sans, Roboto, sans-serif" font-size="10" font-weight="600" letter-spacing="1" fill="#93C5FD" text-anchor="middle">AUTOMATED MOTILITY ANALYSIS</text>
        <!-- Footer -->
        <text x="195" y="800" font-family="Plus Jakarta Sans, Roboto, sans-serif" font-size="10" fill="white" fill-opacity="0.4" text-anchor="middle">WHO 2021 Reference Standards • SIMATS v1.0.0</text>
      </svg>
    `
  },
  {
    id: 'login',
    name: '02 • Clinical Login',
    shortName: 'Login',
    category: 'Auth',
    renderHtml: () => `
      <div class="screen-login">
        <div class="login-header-banner">
          <div class="login-brand-row">
            <div class="login-brand-icon">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#0F274A" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14.5 2v17.5c0 1.4-1.1 2.5-2.5 2.5h0c-1.4 0-2.5-1.1-2.5-2.5V2"/>
                <path d="M8.5 2h7"/>
                <path d="M14.5 16h-5"/>
              </svg>
            </div>
            <div>
              <div class="login-title">SPERMOSCOPE</div>
              <div class="login-subtitle">Clinical Precision Diagnostics</div>
            </div>
          </div>
          <div style="font-size: 13px; font-weight: 500; opacity: 0.9;">Sign in to your practitioner portal</div>
        </div>

        <div class="login-card">
          <div class="role-tabs">
            <div class="role-tab-btn active" onclick="setRole('doctor')">Doctor</div>
            <div class="role-tab-btn" onclick="setRole('admin')">Admin</div>
          </div>

          <div class="form-group">
            <label class="form-label">Clinical Email</label>
            <input type="email" id="loginEmail" class="input-box" value="" placeholder="doctor@hospital.com" />
          </div>

          <div class="form-group">
            <label class="form-label">Password</label>
            <input type="password" id="loginPwd" class="input-box" value="" placeholder="e.g. Doctor@2024" />
            <div style="font-size: 11px; color: #64748b; margin-top: 4px;">Requires: 1 capital letter & 1 special character</div>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px; margin-bottom: 14px;">
            <label style="display: flex; align-items: center; gap: 4px; color: #64748b; cursor: pointer;">
              <input type="checkbox" checked /> Remember me
            </label>
            <span style="color: #1e3a8a; font-weight: 600; cursor: pointer;" onclick="goToScreen('signup')">Forgot?</span>
          </div>

          <button class="btn-submit-app" onclick="handlePrototypeLogin()">Sign In to Dashboard &#8594;</button>

          <div style="text-align: center; margin-top: 14px; font-size: 11px; color: #64748b;">
            New practitioner? <span style="color: #1e3a8a; font-weight: 700; cursor: pointer;" onclick="goToScreen('signup')">Register here</span>
          </div>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F1F5F9"/>
        <!-- Header Banner -->
        <path d="M0 0H390V190C390 205.464 377.464 218 362 218H28C12.536 218 0 205.464 0 190V0Z" fill="#0F274A"/>
        <!-- Brand Icon -->
        <rect x="24" y="60" width="44" height="44" rx="12" fill="white"/>
        <text x="80" y="85" font-family="Plus Jakarta Sans, sans-serif" font-size="18" font-weight="800" fill="white" letter-spacing="1.5">SPERMOSCOPE</text>
        <text x="80" y="100" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="500" fill="#93C5FD">Clinical Precision Diagnostics</text>
        <!-- Card -->
        <rect x="20" y="180" width="350" height="420" rx="18" fill="white" stroke="#E2E8F0"/>
        <!-- Role Tabs -->
        <rect x="40" y="200" width="310" height="38" rx="8" fill="#F1F5F9"/>
        <rect x="42" y="202" width="153" height="34" rx="6" fill="white"/>
        <text x="118" y="223" font-family="Plus Jakarta Sans, sans-serif" font-size="12" font-weight="700" fill="#0F274A" text-anchor="middle">Doctor</text>
        <text x="272" y="223" font-family="Plus Jakarta Sans, sans-serif" font-size="12" font-weight="600" fill="#64748B" text-anchor="middle">Admin</text>
        <!-- Email Input -->
        <text x="40" y="268" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="600" fill="#475569">Clinical Email</text>
        <rect x="40" y="278" width="310" height="42" rx="8" fill="#F8FAFC" stroke="#CBD5E1"/>
        <text x="52" y="304" font-family="Plus Jakarta Sans, sans-serif" font-size="13" fill="#0F172A">doctor@demo.com</text>
        <!-- Password Input -->
        <text x="40" y="348" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="600" fill="#475569">Password</text>
        <rect x="40" y="358" width="310" height="42" rx="8" fill="#F8FAFC" stroke="#CBD5E1"/>
        <text x="52" y="385" font-family="Plus Jakarta Sans, sans-serif" font-size="16" fill="#0F172A">••••••••••••</text>
        <!-- Submit Button -->
        <rect x="40" y="440" width="310" height="46" rx="10" fill="#0F274A"/>
        <text x="195" y="468" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="white" text-anchor="middle">Sign In to Dashboard &#8594;</text>
      </svg>
    `
  },
  {
    id: 'signup',
    name: '03 • Practitioner Registration',
    shortName: 'Sign Up',
    category: 'Auth',
    renderHtml: () => `
      <div class="screen-login">
        <div class="login-header-banner" style="padding-top: 48px;">
          <div style="font-size: 11px; color: #93c5fd; cursor: pointer; margin-bottom: 8px;" onclick="goToScreen('login')">&#8592; Back to Login</div>
          <div class="login-title">Practitioner Portal</div>
          <div style="font-size: 12px; color: #93c5fd;">Register new clinical specialist or supervisor</div>
        </div>

        <div class="login-card" style="margin-top: -10px;">
          <div class="form-group">
            <label class="form-label">Full Name & Title</label>
            <input type="text" class="input-box" value="Dr. Ayesha Malik" />
          </div>

          <div class="form-group">
            <label class="form-label">Medical Specialization</label>
            <select class="input-box" style="height: 40px;">
              <option selected>Andrology & Reproductive Biology</option>
              <option>Clinical Urology</option>
              <option>IVF Laboratory Specialist</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Clinical License ID / Council No</label>
            <input type="text" class="input-box" value="MED-ANDRO-8841" />
          </div>

          <div class="form-group">
            <label class="form-label">Institutional Email</label>
            <input type="email" class="input-box" value="ayesha@hospital.org" />
          </div>

          <button class="btn-submit-app" onclick="goToScreen('home')">Create Account &#8594;</button>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F1F5F9"/>
        <path d="M0 0H390V160C390 175.464 377.464 188 362 188H28C12.536 188 0 175.464 0 160V0Z" fill="#0F274A"/>
        <text x="24" y="80" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">&#8592; Back to Login</text>
        <text x="24" y="115" font-family="Plus Jakarta Sans, sans-serif" font-size="20" font-weight="800" fill="white">Practitioner Registration</text>
        <rect x="20" y="160" width="350" height="480" rx="18" fill="white" stroke="#E2E8F0"/>
        <!-- Name -->
        <text x="40" y="200" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="600" fill="#475569">Full Name &amp; Title</text>
        <rect x="40" y="210" width="310" height="40" rx="8" fill="#F8FAFC" stroke="#CBD5E1"/>
        <text x="52" y="235" font-family="Plus Jakarta Sans, sans-serif" font-size="13" fill="#0F172A">Dr. Ayesha Malik</text>
        <!-- Specialty -->
        <text x="40" y="280" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="600" fill="#475569">Specialization</text>
        <rect x="40" y="290" width="310" height="40" rx="8" fill="#F8FAFC" stroke="#CBD5E1"/>
        <text x="52" y="315" font-family="Plus Jakarta Sans, sans-serif" font-size="13" fill="#0F172A">Andrology &amp; Reproductive Biology</text>
        <rect x="40" y="550" width="310" height="46" rx="10" fill="#0F274A"/>
        <text x="195" y="578" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="white" text-anchor="middle">Create Account &#8594;</text>
      </svg>
    `
  },
  {
    id: 'home',
    name: '04 • Clinical Dashboard',
    shortName: 'Dashboard',
    category: 'Core',
    renderHtml: () => `
      <div class="screen-home">
        <div class="home-top-bar">
          <div class="doctor-profile-badge">
            <div class="avatar-circle">DD</div>
            <div>
              <div class="doctor-name">Dr. Demo</div>
              <div class="doctor-unit">Andrology Unit • SIMATS</div>
            </div>
          </div>
          <div style="background: rgba(255,255,255,0.15); padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 600; cursor: pointer;" onclick="goToScreen('admin')">
            Admin View
          </div>
        </div>

        <div class="stats-grid-row">
          <div class="stat-card">
            <div class="stat-label">Total Patients</div>
            <div class="stat-num">142</div>
            <div style="font-size: 10px; color: #10b981; font-weight: 600;">+12 this week</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Samples Tested</div>
            <div class="stat-num">389</div>
            <div style="font-size: 10px; color: #0d99ff; font-weight: 600;">99.4% precision</div>
          </div>
        </div>

        <div class="action-buttons-section">
          <div class="primary-cta-card" onclick="goToScreen('patient_form')">
            <div>
              <div style="font-weight: 700; font-size: 15px;">+ New Semen Analysis</div>
              <div style="font-size: 11px; opacity: 0.9; margin-top: 2px;">Record patient & upload chamber sample</div>
            </div>
            <div style="font-size: 20px; font-weight: bold;">&#8594;</div>
          </div>

          <div style="display: flex; gap: 8px;">
            <div style="flex: 1; background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; font-size: 12px; font-weight: 600; color: #0f274a; cursor: pointer; text-align: center;" onclick="goToScreen('graph')">
              📊 Kinetics Analytics
            </div>
            <div style="flex: 1; background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; font-size: 12px; font-weight: 600; color: #0f274a; cursor: pointer; text-align: center;" onclick="goToScreen('results')">
              📑 Last Diagnosis
            </div>
          </div>
        </div>

        <div class="recent-patients-list">
          <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin: 12px 0 8px;">Recent Patient Analyses</div>

          <div class="patient-row-card" onclick="goToScreen('results')">
            <div>
              <div style="font-weight: 700; font-size: 13px; color: #0f172a;">Ali Raza (p001)</div>
              <div style="font-size: 11px; color: #64748b;">Age 32 • Conc: 42.0 M/mL • Motility: 65%</div>
            </div>
            <span class="status-pill status-normal">Normozoospermic</span>
          </div>

          <div class="patient-row-card" onclick="goToScreen('results')">
            <div>
              <div style="font-weight: 700; font-size: 13px; color: #0f172a;">Bilal Ahmed (p002)</div>
              <div style="font-size: 11px; color: #64748b;">Age 28 • Conc: 15.0 M/mL • Motility: 40%</div>
            </div>
            <span class="status-pill status-oligo">Oligospermia</span>
          </div>

          <div class="patient-row-card" onclick="goToScreen('results')">
            <div>
              <div style="font-weight: 700; font-size: 13px; color: #0f172a;">Sara Khan (p003)</div>
              <div style="font-size: 11px; color: #64748b;">Age 35 • Conc: 80.0 M/mL • Motility: 72%</div>
            </div>
            <span class="status-pill status-normal">Normozoospermic</span>
          </div>
        </div>

        <div class="bottom-nav-mobile">
          <div class="nav-tab-item active" onclick="goToScreen('home')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            <span>Home</span>
          </div>
          <div class="nav-tab-item" onclick="goToScreen('patient_form')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            <span>Patient</span>
          </div>
          <div class="nav-tab-item" onclick="goToScreen('upload_sample')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            <span>Sample</span>
          </div>
          <div class="nav-tab-item" onclick="goToScreen('graph')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            <span>Analytics</span>
          </div>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F8FAFC"/>
        <!-- Header -->
        <rect width="390" height="120" fill="#0F274A"/>
        <circle cx="45" cy="70" r="20" fill="#1E3A8A" stroke="#38BDF8" stroke-width="2"/>
        <text x="45" y="75" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="white" text-anchor="middle">DD</text>
        <text x="75" y="68" font-family="Plus Jakarta Sans, sans-serif" font-size="14" font-weight="700" fill="white">Dr. Demo</text>
        <text x="75" y="82" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">Andrology Unit • SIMATS</text>
        <!-- Stats -->
        <rect x="20" y="136" width="165" height="84" rx="14" fill="white" stroke="#E2E8F0"/>
        <text x="36" y="160" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#64748B">Total Patients</text>
        <text x="36" y="190" font-family="Plus Jakarta Sans, sans-serif" font-size="22" font-weight="800" fill="#0F274A">142</text>
        <rect x="205" y="136" width="165" height="84" rx="14" fill="white" stroke="#E2E8F0"/>
        <text x="221" y="160" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#64748B">Samples Tested</text>
        <text x="221" y="190" font-family="Plus Jakarta Sans, sans-serif" font-size="22" font-weight="800" fill="#0F274A">389</text>
        <!-- CTA -->
        <rect x="20" y="234" width="350" height="72" rx="14" fill="#1E3A8A"/>
        <text x="40" y="265" font-family="Plus Jakarta Sans, sans-serif" font-size="15" font-weight="700" fill="white">+ New Semen Analysis</text>
        <text x="40" y="282" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">Record patient &amp; upload chamber sample</text>
      </svg>
    `
  },
  {
    id: 'patient_form',
    name: '05 • Patient Intake Form',
    shortName: 'Patient Form',
    category: 'Core',
    renderHtml: () => `
      <div class="screen-login" style="padding-bottom: 30px;">
        <div class="login-header-banner" style="padding-top: 48px;">
          <div style="font-size: 11px; color: #93c5fd; cursor: pointer; margin-bottom: 8px;" onclick="goToScreen('home')">&#8592; Back to Dashboard</div>
          <div class="login-title">Patient Intake Record</div>
          <div style="font-size: 12px; color: #93c5fd;">Clinical demographics & lifestyle assessment</div>
        </div>

        <div class="login-card" style="margin-top: -10px;">
          <div class="form-group">
            <label class="form-label">Patient Name</label>
            <input type="text" class="input-box" value="Ali Raza" />
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
            <div class="form-group">
              <label class="form-label">Age (Years)</label>
              <input type="number" class="input-box" value="32" />
            </div>
            <div class="form-group">
              <label class="form-label">Abstinence (Days)</label>
              <input type="number" class="input-box" value="3" />
            </div>
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
            <div class="form-group">
              <label class="form-label">Height (m)</label>
              <input type="text" class="input-box" value="1.75" />
            </div>
            <div class="form-group">
              <label class="form-label">Weight (kg)</label>
              <input type="text" class="input-box" value="70.0" />
            </div>
          </div>

          <div style="background: #f1f5f9; padding: 8px 12px; border-radius: 8px; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
            <span style="font-size: 11px; color: #475569; font-weight: 600;">Calculated BMI:</span>
            <span style="font-size: 12px; font-weight: 800; color: #059669; background: #dcfce7; padding: 2px 8px; border-radius: 12px;">22.8 (Normal)</span>
          </div>

          <div class="form-group">
            <label class="form-label">Lifestyle Risk Factors</label>
            <div style="display: flex; gap: 12px; font-size: 11px; color: #475569;">
              <label><input type="checkbox" /> Smoker</label>
              <label><input type="checkbox" /> Alcohol</label>
              <label><input type="checkbox" /> Medication</label>
            </div>
          </div>

          <button class="btn-submit-app" onclick="goToScreen('upload_sample')">Proceed to Sample Capture &#8594;</button>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F1F5F9"/>
        <rect width="390" height="150" fill="#0F274A"/>
        <text x="24" y="70" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">&#8592; Back to Dashboard</text>
        <text x="24" y="105" font-family="Plus Jakarta Sans, sans-serif" font-size="20" font-weight="800" fill="white">Patient Intake Record</text>
        <rect x="20" y="140" width="350" height="520" rx="18" fill="white" stroke="#E2E8F0"/>
        <!-- Patient Form Elements -->
        <text x="40" y="180" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="600" fill="#475569">Patient Name</text>
        <rect x="40" y="190" width="310" height="40" rx="8" fill="#F8FAFC" stroke="#CBD5E1"/>
        <text x="52" y="215" font-family="Plus Jakarta Sans, sans-serif" font-size="13" fill="#0F172A">Ali Raza</text>
        <rect x="40" y="600" width="310" height="46" rx="10" fill="#0F274A"/>
        <text x="195" y="628" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="white" text-anchor="middle">Proceed to Sample Capture &#8594;</text>
      </svg>
    `
  },
  {
    id: 'upload_sample',
    name: '06 • Microscopic Sample Capture',
    shortName: 'Sample Capture',
    category: 'Core',
    renderHtml: () => `
      <div class="screen-login" style="padding-bottom: 30px;">
        <div class="login-header-banner" style="padding-top: 48px;">
          <div style="font-size: 11px; color: #93c5fd; cursor: pointer; margin-bottom: 8px;" onclick="goToScreen('patient_form')">&#8592; Back to Patient</div>
          <div class="login-title">Chamber Sample Capture</div>
          <div style="font-size: 12px; color: #93c5fd;">Patient: Ali Raza (p001) • Field 1/6</div>
        </div>

        <div class="login-card" style="margin-top: -10px;">
          <!-- Camera Viewfinder Mockup -->
          <div style="width: 100%; height: 210px; background: #07152b; border-radius: 12px; position: relative; overflow: hidden; display: flex; align-items: center; justify-content: center; border: 2px dashed #38bdf8;">
            <!-- Grid crosshair overlay -->
            <div style="position: absolute; width: 100%; height: 1px; background: rgba(56, 189, 248, 0.3);"></div>
            <div style="position: absolute; height: 100%; width: 1px; background: rgba(56, 189, 248, 0.3);"></div>
            <div style="width: 120px; height: 120px; border: 1px solid rgba(56, 189, 248, 0.4); border-radius: 50%;"></div>
            
            <!-- Live Cells Simulation dots -->
            <div style="position: absolute; top: 40px; left: 80px; width: 6px; height: 6px; background: #10b981; border-radius: 50%; box-shadow: 0 0 8px #10b981;"></div>
            <div style="position: absolute; top: 120px; left: 190px; width: 6px; height: 6px; background: #10b981; border-radius: 50%; box-shadow: 0 0 8px #10b981;"></div>
            <div style="position: absolute; top: 80px; left: 240px; width: 6px; height: 6px; background: #f59e0b; border-radius: 50%; box-shadow: 0 0 8px #f59e0b;"></div>
            <div style="position: absolute; top: 160px; left: 110px; width: 6px; height: 6px; background: #ef4444; border-radius: 50%;"></div>

            <div style="position: absolute; top: 10px; left: 12px; background: rgba(0,0,0,0.6); padding: 3px 8px; border-radius: 4px; font-size: 10px; color: #38bdf8; font-weight: 700;">
              REC • 1080p @ 60 FPS
            </div>
            <div style="position: absolute; bottom: 10px; right: 12px; background: rgba(0,0,0,0.6); padding: 3px 8px; border-radius: 4px; font-size: 10px; color: #a0aec0;">
              Mag: 20x • Makler 10µm
            </div>
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-top: 14px;">
            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 8px; font-size: 11px;">
              <span style="color: #64748b;">Chamber Type:</span><br/>
              <b>Makler Chamber</b>
            </div>
            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 8px; font-size: 11px;">
              <span style="color: #64748b;">Duration:</span><br/>
              <b>10.0 Seconds Video</b>
            </div>
          </div>

          <button class="btn-submit-app" style="background: #1e3a8a;" onclick="goToScreen('ai_processing')">
            🚀 Run AI Motility Classification &#8594;
          </button>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F1F5F9"/>
        <rect width="390" height="150" fill="#0F274A"/>
        <text x="24" y="70" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">&#8592; Back to Patient</text>
        <text x="24" y="105" font-family="Plus Jakarta Sans, sans-serif" font-size="20" font-weight="800" fill="white">Sample Microscopic Capture</text>
        <rect x="20" y="140" width="350" height="420" rx="18" fill="white" stroke="#E2E8F0"/>
        <!-- Viewfinder -->
        <rect x="36" y="156" width="318" height="200" rx="12" fill="#07152B" stroke="#38BDF8" stroke-dasharray="4 4"/>
        <circle cx="195" cy="256" r="60" stroke="#38BDF8" stroke-opacity="0.3"/>
        <rect x="36" y="470" width="318" height="46" rx="10" fill="#1E3A8A"/>
        <text x="195" y="498" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="white" text-anchor="middle">Run AI Classification &#8594;</text>
      </svg>
    `
  },
  {
    id: 'ai_processing',
    name: '07 • AI Computer Vision Tracking',
    shortName: 'AI Engine',
    category: 'Core',
    renderHtml: () => `
      <div class="screen-splash" onclick="goToScreen('results')">
        <div style="font-size: 13px; font-weight: 700; color: #38bdf8; letter-spacing: 2px; margin-bottom: 14px;">NEURAL MOTILITY ENGINE</div>

        <!-- Animated Radar Screen -->
        <div style="width: 200px; height: 200px; border-radius: 50%; border: 2px solid rgba(56, 189, 248, 0.4); position: relative; margin-bottom: 24px; display: flex; align-items: center; justify-content: center; background: radial-gradient(circle, rgba(15, 39, 74, 0.8) 0%, rgba(7, 21, 43, 0.95) 100%);">
          <div style="position: absolute; width: 140px; height: 140px; border: 1px dashed rgba(56, 189, 248, 0.3); border-radius: 50%;"></div>
          <div style="position: absolute; width: 80px; height: 80px; border: 1px solid rgba(56, 189, 248, 0.5); border-radius: 50%;"></div>
          
          <!-- Tracking Trajectories -->
          <svg width="180" height="180" viewBox="0 0 100 100" style="position: absolute;">
            <path d="M20 70 Q 35 40, 60 45 T 85 25" fill="none" stroke="#10b981" stroke-width="2" stroke-linecap="round"/>
            <circle cx="85" cy="25" r="3" fill="#10b981"/>
            
            <path d="M30 30 Q 50 60, 40 80" fill="none" stroke="#f59e0b" stroke-width="2" stroke-linecap="round"/>
            <circle cx="40" cy="80" r="3" fill="#f59e0b"/>
            
            <circle cx="25" cy="45" r="2.5" fill="#ef4444"/>
          </svg>

          <div style="font-size: 11px; font-weight: 800; color: #38bdf8; background: rgba(0,0,0,0.6); padding: 4px 8px; border-radius: 6px;">
            98.7% Confidence
          </div>
        </div>

        <div style="font-size: 18px; font-weight: 800; color: white; margin-bottom: 6px;">Segmenting 142 Trajectories</div>
        <div style="font-size: 11px; color: #94a3b8; max-width: 280px; margin-bottom: 24px;">
          Calculating VCL (Curvilinear Velocity) &amp; VSL (Straight-line Velocity) per WHO criteria
        </div>

        <div class="splash-dots">
          <div class="splash-dot"></div>
          <div class="splash-dot"></div>
          <div class="splash-dot"></div>
        </div>

        <div style="font-size: 10px; color: #38bdf8; margin-top: 14px; cursor: pointer;">
          Tap anywhere to view Diagnosis &#8594;
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#07152B"/>
        <text x="195" y="160" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="#38BDF8" letter-spacing="2" text-anchor="middle">NEURAL MOTILITY ENGINE</text>
        <circle cx="195" cy="340" r="100" stroke="#38BDF8" stroke-opacity="0.4" stroke-width="2" fill="#0F274A" fill-opacity="0.5"/>
        <circle cx="195" cy="340" r="60" stroke="#38BDF8" stroke-opacity="0.3" stroke-dasharray="4 4"/>
        <!-- Vectors -->
        <path d="M140 380 Q 160 320, 210 330 T 260 280" fill="none" stroke="#10B981" stroke-width="3" stroke-linecap="round"/>
        <text x="195" y="500" font-family="Plus Jakarta Sans, sans-serif" font-size="18" font-weight="800" fill="white" text-anchor="middle">Segmenting Trajectories...</text>
      </svg>
    `
  },
  {
    id: 'results',
    name: '08 • Diagnostic Report (WHO 2021)',
    shortName: 'Result Report',
    category: 'Core',
    renderHtml: () => `
      <div class="screen-report">
        <div class="report-header-card">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div style="font-size: 11px; color: #93c5fd; cursor: pointer;" onclick="goToScreen('home')">&#8592; Dashboard</div>
            <div style="font-size: 10px; background: rgba(255,255,255,0.15); padding: 3px 8px; border-radius: 10px;">ID: p001</div>
          </div>
          <div style="font-size: 18px; font-weight: 800;">Ali Raza • 32 Yrs</div>
          <div style="font-size: 11px; color: #93c5fd;">Diagnostic Classification:</div>
          <div class="score-badge-huge">✓ NORMOZOOSPERMIC</div>
        </div>

        <div class="metrics-table-card">
          <div style="font-size: 12px; font-weight: 700; color: #0f172a; margin-bottom: 12px; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
            WHO 2021 Standards Comparison
          </div>

          <!-- Metric 1 -->
          <div class="metric-bar-row">
            <div class="metric-row-title">
              <span>Sperm Concentration</span>
              <span style="font-weight: 800; color: #0f274a;">42.0 M/mL <span style="font-size: 10px; color: #10b981;">(Normal ≥ 15)</span></span>
            </div>
            <div class="metric-progress-track">
              <div class="metric-progress-fill" style="width: 85%; background: #10b981;"></div>
            </div>
          </div>

          <!-- Metric 2 -->
          <div class="metric-bar-row">
            <div class="metric-row-title">
              <span>Total Motility (PR + NP)</span>
              <span style="font-weight: 800; color: #0f274a;">65% <span style="font-size: 10px; color: #10b981;">(Normal ≥ 42%)</span></span>
            </div>
            <div class="metric-progress-track">
              <div class="metric-progress-fill" style="width: 78%; background: #10b981;"></div>
            </div>
          </div>

          <!-- Metric 3 -->
          <div class="metric-bar-row">
            <div class="metric-row-title">
              <span>Progressive Motility (PR)</span>
              <span style="font-weight: 800; color: #0f274a;">52% <span style="font-size: 10px; color: #10b981;">(Normal ≥ 30%)</span></span>
            </div>
            <div class="metric-progress-track">
              <div class="metric-progress-fill" style="width: 72%; background: #0d99ff;"></div>
            </div>
          </div>

          <!-- Metric 4 -->
          <div class="metric-bar-row">
            <div class="metric-row-title">
              <span>Normal Morphology</span>
              <span style="font-weight: 800; color: #0f274a;">12% <span style="font-size: 10px; color: #10b981;">(Normal ≥ 4%)</span></span>
            </div>
            <div class="metric-progress-track">
              <div class="metric-progress-fill" style="width: 60%; background: #7b61ff;"></div>
            </div>
          </div>
        </div>

        <div style="padding: 0 20px; display: flex; gap: 8px;">
          <button class="btn-submit-app" style="margin-top: 0; background: #0f274a;" onclick="goToScreen('graph')">
            📊 View Kinetics Curve &#8594;
          </button>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F8FAFC"/>
        <rect width="390" height="190" fill="#0F274A"/>
        <text x="24" y="60" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">&#8592; Dashboard</text>
        <text x="24" y="90" font-family="Plus Jakarta Sans, sans-serif" font-size="18" font-weight="800" fill="white">Ali Raza • 32 Yrs</text>
        <rect x="24" y="110" width="160" height="28" rx="14" fill="#10B981" fill-opacity="0.2" stroke="#10B981"/>
        <text x="104" y="128" font-family="Plus Jakarta Sans, sans-serif" font-size="11" font-weight="800" fill="#10B981" text-anchor="middle">✓ NORMOZOOSPERMIC</text>
        <!-- Table Card -->
        <rect x="20" y="210" width="350" height="340" rx="14" fill="white" stroke="#E2E8F0"/>
        <text x="36" y="240" font-family="Plus Jakarta Sans, sans-serif" font-size="13" font-weight="700" fill="#0F172A">WHO 2021 Reference Standards</text>
        <rect x="36" y="280" width="318" height="8" rx="4" fill="#F1F5F9"/>
        <rect x="36" y="280" width="240" height="8" rx="4" fill="#10B981"/>
      </svg>
    `
  },
  {
    id: 'graph',
    name: '09 • Kinetics Multi-Field Analytics',
    shortName: 'Analytics Graph',
    category: 'Analytics',
    renderHtml: () => `
      <div class="screen-home" style="padding-bottom: 70px;">
        <div class="home-top-bar" style="padding-top: 48px;">
          <div>
            <div style="font-size: 11px; color: #93c5fd; cursor: pointer; margin-bottom: 4px;" onclick="goToScreen('results')">&#8592; Results</div>
            <div style="font-size: 16px; font-weight: 800;">Motility Kinetics Curves</div>
          </div>
          <div style="font-size: 11px; color: #38bdf8; font-weight: 700;">6 Fields Analyzed</div>
        </div>

        <div style="margin: 16px 20px; background: white; border-radius: 14px; padding: 16px; border: 1px solid #e2e8f0;">
          <div style="font-size: 12px; font-weight: 700; color: #0f274a; margin-bottom: 12px;">Active Sperm Concentration by Field (M/mL)</div>

          <!-- Bar Chart Visualization -->
          <div style="display: flex; align-items: flex-end; justify-content: space-between; height: 140px; padding-top: 20px; border-bottom: 1.5px solid #cbd5e1; position: relative;">
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">42M</div>
              <div style="height: 60px; background: #3b82f6; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S1</div>
            </div>
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">48M</div>
              <div style="height: 70px; background: #3b82f6; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S2</div>
            </div>
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">55M</div>
              <div style="height: 80px; background: #3b82f6; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S3</div>
            </div>
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">62M</div>
              <div style="height: 95px; background: #1d4ed8; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S4</div>
            </div>
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">59M</div>
              <div style="height: 88px; background: #3b82f6; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S5</div>
            </div>
            <div style="text-align: center; width: 14%;">
              <div style="font-size: 9px; font-weight: 700; color: #1e3a8a;">68M</div>
              <div style="height: 108px; background: #1d4ed8; border-radius: 4px; margin-top: 4px;"></div>
              <div style="font-size: 10px; color: #64748b; margin-top: 4px;">S6</div>
            </div>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 10px; color: #64748b; margin-top: 6px;">
            <span>Chamber Grid 10µm</span>
            <span>Avg: 55.8 M/mL</span>
          </div>
        </div>

        <div style="margin: 0 20px; background: white; border-radius: 14px; padding: 14px; border: 1px solid #e2e8f0;">
          <div style="font-size: 12px; font-weight: 700; color: #0f274a; margin-bottom: 8px;">Kinematic Parameters</div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; font-size: 11px;">
            <div style="background: #f8fafc; padding: 6px 10px; border-radius: 6px;">
              <span style="color: #64748b;">VCL (Curvilinear):</span> <b>58.4 µm/s</b>
            </div>
            <div style="background: #f8fafc; padding: 6px 10px; border-radius: 6px;">
              <span style="color: #64748b;">VSL (Straight Line):</span> <b>32.1 µm/s</b>
            </div>
            <div style="background: #f8fafc; padding: 6px 10px; border-radius: 6px;">
              <span style="color: #64748b;">LIN (Linearity):</span> <b>55.0%</b>
            </div>
            <div style="background: #f8fafc; padding: 6px 10px; border-radius: 6px;">
              <span style="color: #64748b;">ALH (Head Displ):</span> <b>3.8 µm</b>
            </div>
          </div>
        </div>

        <div class="bottom-nav-mobile">
          <div class="nav-tab-item" onclick="goToScreen('home')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            <span>Home</span>
          </div>
          <div class="nav-tab-item" onclick="goToScreen('patient_form')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            <span>Patient</span>
          </div>
          <div class="nav-tab-item active" onclick="goToScreen('graph')">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            <span>Analytics</span>
          </div>
        </div>
      </div>
    `,
    generateSvg: () => `
      <svg width="390" height="844" viewBox="0 0 390 844" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="390" height="844" rx="44" fill="#F8FAFC"/>
        <rect width="390" height="120" fill="#0F274A"/>
        <text x="24" y="65" font-family="Plus Jakarta Sans, sans-serif" font-size="11" fill="#93C5FD">&#8592; Results</text>
        <text x="24" y="90" font-family="Plus Jakarta Sans, sans-serif" font-size="16" font-weight="800" fill="white">Motility Kinetics Curves</text>
        <!-- Bar Chart Card -->
        <rect x="20" y="140" width="350" height="220" rx="14" fill="white" stroke="#E2E8F0"/>
        <text x="36" y="170" font-family="Plus Jakarta Sans, sans-serif" font-size="12" font-weight="700" fill="#0F274A">Concentration by Field (M/mL)</text>
        <!-- Bars -->
        <rect x="45" y="270" width="30" height="50" rx="4" fill="#3B82F6"/>
        <rect x="95" y="260" width="30" height="60" rx="4" fill="#3B82F6"/>
        <rect x="145" y="245" width="30" height="75" rx="4" fill="#3B82F6"/>
        <rect x="195" y="230" width="30" height="90" rx="4" fill="#1D4ED8"/>
        <rect x="245" y="235" width="30" height="85" rx="4" fill="#3B82F6"/>
        <rect x="295" y="220" width="30" height="100" rx="4" fill="#1D4ED8"/>
      </svg>
    `
  }
];
