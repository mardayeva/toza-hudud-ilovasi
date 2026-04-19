import React, { useEffect, useMemo, useState } from "react";
import "./index.css";

const API_BASE = (() => {
  const envBase = import.meta.env.VITE_API_BASE;
  if (envBase) return envBase;
  if (typeof window !== "undefined" && window.location.hostname) {
    return `http://${window.location.hostname}:8000/v1`;
  }
  return "http://127.0.0.1:8000/v1";
})();

const NAV_SUPER = [
  { key: "dashboard", label: "Dashboard", icon: "📊" },
  { key: "admins", label: "Adminlar", icon: "🛡️" },
  { key: "jadval", label: "Jadval", icon: "🗓️" },
  { key: "drivers", label: "Haydovchilar", icon: "🚚" },
  { key: "shikoyat", label: "Shikoyatlar", icon: "⚠️" },
  { key: "messages", label: "Xabarlar", icon: "✉️" }
];

const NAV_TUMAN = [
  { key: "dashboard", label: "Dashboard", icon: "📊" },
  { key: "jadval", label: "Jadval", icon: "🗓️" },
  { key: "drivers", label: "Haydovchilar", icon: "🚚" },
  { key: "shikoyat", label: "Shikoyatlar", icon: "⚠️" },
  { key: "messages", label: "Xabarlar", icon: "✉️" }
];

const DEMO_REGIONS = [
  {
    id: 1,
    nomi: "Termiz shahri",
    mahallalar: ["Bog'ishamol", "Jayhun", "Shodlik", "Manguzar"]
  },
  {
    id: 6,
    nomi: "Termiz tumani",
    mahallalar: ["Orol", "Xalqobod", "Yangiobod", "Nurafshon"]
  },
  {
    id: 14,
    nomi: "Denov tumani",
    mahallalar: ["Denov markazi", "Bog'ishamol", "Do'stlik", "Tinchlik"]
  }
];

export default function App() {
  const [active, setActive] = useState("dashboard");
  const [adminToken, setAdminToken] = useState(() => localStorage.getItem("admin_token") || "");
  const [loginUser, setLoginUser] = useState("admin");
  const [loginPass, setLoginPass] = useState("");
  const [loginError, setLoginError] = useState("");
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [adminRole, setAdminRole] = useState(() => localStorage.getItem("admin_role") || "");
  const [adminTumanId, setAdminTumanId] = useState(() => Number(localStorage.getItem("admin_tuman_id") || 0));

  useEffect(() => {
    if (adminToken) {
      localStorage.setItem("admin_token", adminToken);
      localStorage.setItem("admin_role", adminRole || "");
      localStorage.setItem("admin_tuman_id", String(adminTumanId || 0));
      return;
    }
    localStorage.removeItem("admin_token");
    localStorage.removeItem("admin_role");
    localStorage.removeItem("admin_tuman_id");
  }, [adminToken, adminRole, adminTumanId]);

  const doLogin = async (event) => {
    event?.preventDefault?.();
    if (isLoggingIn) return;
    setLoginError("");
    setIsLoggingIn(true);
    try {
      const res = await fetch(`${API_BASE}/admin/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: loginUser, password: loginPass })
      });
      if (!res.ok) {
        setLoginError("Login yoki parol noto'g'ri");
        setAdminToken("");
        setAdminRole("");
        setAdminTumanId(0);
        return;
      }
      const data = await res.json();
      setAdminToken(data.token || "");
      setAdminRole(data.role || "super");
      setAdminTumanId(Number(data.tuman_id) || 0);
    } catch (e) {
      setLoginError("Serverga ulanib bo'lmadi. Backendni tekshiring.");
      setAdminToken("");
      setAdminRole("");
      setAdminTumanId(0);
    } finally {
      setIsLoggingIn(false);
    }
  };

  const effectiveRole = adminRole || "super";
  const nav = effectiveRole === "super" ? NAV_SUPER : NAV_TUMAN;
  const pageMeta = {
    dashboard: { title: "Dashboard", subtitle: "Tizim holati va qisqa statistika" },
    admins: { title: "Adminlar", subtitle: "Admin hisoblari va ruxsatlar" },
    jadval: { title: "Jadval", subtitle: "Mahalla va haydovchi rejalari" },
    drivers: { title: "Haydovchilar", subtitle: "Transport va kontaktlar" },
    shikoyat: { title: "Shikoyatlar", subtitle: "Foydalanuvchi murojaatlari" },
    messages: { title: "Xabarlar", subtitle: "Bildirishnomalar va uzatishlar" }
  }[active] || { title: "Dashboard", subtitle: "Tizim holati" };

  if (!adminToken) {
    return (
      <div className="app auth-mode">
        <main className="auth-shell">
          <section className="auth-hero">
            <div className="auth-brand">
              <img src="/logo.jpg" alt="Toza Hudud" className="brand-logo" />
              <div>
                <h1>Toza Hudud Admin</h1>
                <p>Jadval, haydovchi va shikoyat boshqaruvi</p>
              </div>
            </div>

            <h2>Chiqindi tizimini bitta paneldan boshqaring.</h2>
            <p>
              Surxondaryo bo‘yicha jadval qo‘shish, haydovchilarni biriktirish
              va xabarlar yuborish uchun yaratilgan nazorat paneli.
            </p>

            <div className="hero-pills">
              <span>Jadval boshqaruvi</span>
              <span>Haydovchi nazorati</span>
              <span>Bildirishnoma</span>
              <span>Demo rejim</span>
            </div>
          </section>

          <section className="auth-card card">
            <div className="auth-topline">
              <span className="auth-badge">Admin kirish</span>
            </div>
            <h2>Panelga kirish</h2>
            <p className="auth-text">
              To‘g‘ri login va parol bilan kiring. Backend ishlamasa, xatolik
              ko‘rsatiladi va panel ochilmaydi.
            </p>
            <form style={{ display: "grid", gap: 12 }} onSubmit={doLogin}>
              <div>
                <label>Login</label>
                <input
                  value={loginUser}
                  onChange={(e) => setLoginUser(e.target.value)}
                />
              </div>
              <div>
                <label>Parol</label>
                <input
                  type="password"
                  value={loginPass}
                  onChange={(e) => setLoginPass(e.target.value)}
                />
              </div>
              {loginError && (
                <div className="notice notice-warn">{loginError}</div>
              )}
              <button className="primary auth-submit" type="submit" disabled={isLoggingIn}>
                {isLoggingIn ? "Kutilmoqda..." : "Kirish"}
              </button>
            </form>
          </section>
        </main>
      </div>
    );
  }

  return (
    <div className="app">
      <aside className="sidebar">
        <div className="brand">
          <img src="/logo.jpg" alt="Toza Hudud" className="brand-logo" />
          <div>
            <h1>Toza Hudud Admin</h1>
            <div className="role-chip">
              {effectiveRole === "super" ? "Super admin" : "Tuman admin"}
            </div>
          </div>
        </div>
        {nav.map((item) => (
          <button
            key={item.key}
            className={"nav-btn " + (active === item.key ? "active" : "")}
            onClick={() => setActive(item.key)}
          >
            <span className="nav-icon">{item.icon}</span>
            {item.label}
          </button>
        ))}
      </aside>
      <main className="main">
        <div className="topbar">
          <div className="topbar-title">
            <h2>{pageMeta.title}</h2>
            <p>{pageMeta.subtitle}</p>
          </div>
          <div className="topbar-search">
            <input placeholder="Search data points, drivers or districts..." />
          </div>
          <div className="topbar-actions">
            <button className="icon-btn" type="button">🔔</button>
            <button className="icon-btn" type="button">⚙️</button>
            <div className="profile-chip">
              <div>
                <strong>Admin Panel</strong>
                <span>{effectiveRole === "super" ? "Super Administrator" : "Tuman Administrator"}</span>
              </div>
              <img src="/logo.jpg" alt="Admin" className="profile-avatar" />
            </div>
          </div>
        </div>
        <div className="content">
          {active === "dashboard" && (
            <Dashboard
              adminToken={adminToken}
              setAdminToken={setAdminToken}
              effectiveRole={effectiveRole}
              adminTumanId={adminTumanId}
              onNavigate={setActive}
            />
          )}
          {active === "admins" && (
            <AdminsPage adminToken={adminToken} />
          )}
          {active === "jadval" && (
            <JadvalPage
              adminToken={adminToken}
              adminRole={effectiveRole}
              adminTumanId={adminTumanId}
            />
          )}
          {active === "drivers" && (
            <DriversPage
              adminToken={adminToken}
              adminRole={effectiveRole}
              adminTumanId={adminTumanId}
            />
          )}
          {active === "shikoyat" && <ShikoyatPage adminToken={adminToken} />}
          {active === "messages" && (
            <MessagesPage
              adminToken={adminToken}
              adminRole={effectiveRole}
              adminTumanId={adminTumanId}
            />
          )}
        </div>
      </main>
    </div>
  );
}

function Dashboard({ adminToken, setAdminToken, effectiveRole, adminTumanId, onNavigate }) {
  const { regions } = useRegions();
  const [adminForm, setAdminForm] = useState({
    username: "",
    password: "",
    tuman_id: 1
  });
  const [adminMsg, setAdminMsg] = useState("");
  const [stats, setStats] = useState({
    jadval: 0,
    drivers: 0,
    shikoyat: 0
  });

  const tumanName = useMemo(() => {
    const t = regions.find((x) => x.id === adminTumanId);
    return t ? t.nomi : "";
  }, [regions, adminTumanId]);

  const loadStats = async () => {
    try {
      const [j, d, s] = await Promise.all([
        fetch(`${API_BASE}/admin/jadval`, { headers: { "X-Admin-Token": adminToken } }),
        fetch(`${API_BASE}/admin/drivers`, { headers: { "X-Admin-Token": adminToken } }),
        fetch(`${API_BASE}/admin/shikoyat`, { headers: { "X-Admin-Token": adminToken } })
      ]);
      const jd = await j.json();
      const dd = await d.json();
      const sd = await s.json();
      setStats({
        jadval: Array.isArray(jd) ? jd.length : (jd.data || []).length,
        drivers: Array.isArray(dd) ? dd.length : (dd.data || []).length,
        shikoyat: Array.isArray(sd) ? sd.length : (sd.data || []).length
      });
    } catch (_) {
      setStats({ jadval: 18, drivers: 4, shikoyat: 3 });
    }
  };

  useEffect(() => { loadStats(); }, []);

  const createAdmin = async () => {
    setAdminMsg("");
    const res = await fetch(`${API_BASE}/admin/admins`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Admin-Token": adminToken
      },
      body: JSON.stringify({
        username: adminForm.username,
        password: adminForm.password,
        role: "tuman",
        tuman_id: Number(adminForm.tuman_id)
      })
    });
    if (!res.ok) {
      setAdminMsg("Admin yaratib bo'lmadi (faqat super admin)");
      return;
    }
    setAdminMsg("Tuman admin yaratildi");
  };

  return (
    <div>
      <div className="header">
        <div>
          <h2>Dashboard</h2>
          <div style={{ color: "#6b7a6b", fontSize: 12 }}>
            {effectiveRole === "super" ? "Barcha tumanlar" : `Tuman: ${tumanName || "-"}`}
          </div>
        </div>
        <button
          onClick={() => {
            setAdminToken("");
            setAdminRole("");
            setAdminTumanId(0);
            localStorage.removeItem("admin_token");
            localStorage.removeItem("admin_role");
            localStorage.removeItem("admin_tuman_id");
          }}
        >
          Chiqish
        </button>
      </div>

      <div className="grid-2">
        <div className="stat">
          <div className="stat-icon">🗓️</div>
          <div style={{ fontSize: 12, color: "#6b7a6b" }}>Jadval yozuvlari</div>
          <div style={{ fontSize: 22, fontWeight: 800 }}>{stats.jadval}</div>
        </div>
        <div className="stat">
          <div className="stat-icon">🚚</div>
          <div style={{ fontSize: 12, color: "#6b7a6b" }}>Haydovchilar</div>
          <div style={{ fontSize: 22, fontWeight: 800 }}>{stats.drivers}</div>
        </div>
        <div className="stat">
          <div className="stat-icon">⚠️</div>
          <div style={{ fontSize: 12, color: "#6b7a6b" }}>Shikoyatlar</div>
          <div style={{ fontSize: 22, fontWeight: 800 }}>{stats.shikoyat}</div>
        </div>
        <div className="stat">
          <div className="stat-icon">✓</div>
          <div style={{ fontSize: 12, color: "#6b7a6b" }}>Tizim holati</div>
          <div style={{ fontSize: 18, fontWeight: 800 }}>Faol</div>
        </div>
      </div>

      <div className="card" style={{ marginTop: 14 }}>
        <div className="header">
          <h2>Tezkor amallar</h2>
          <div style={{ fontSize: 12, color: "#6b7a6b" }}>Bir klik bilan</div>
        </div>
        <div className="quick-actions">
          <button className="primary" onClick={() => onNavigate("jadval")}>
            Jadval qo'shish
          </button>
          <button onClick={() => onNavigate("drivers")}>
            Haydovchi qo'shish
          </button>
          <button onClick={() => onNavigate("shikoyat")}>
            Shikoyatlar
          </button>
        </div>
      </div>

      {effectiveRole === "super" && (
        <div className="card" style={{ marginTop: 14 }}>
          <h3>Tuman admin yaratish</h3>
          <div className="row">
            <div>
              <label>Login</label>
              <input
                value={adminForm.username}
                onChange={(e) => setAdminForm({ ...adminForm, username: e.target.value })}
              />
            </div>
            <div>
              <label>Parol</label>
              <input
                value={adminForm.password}
                onChange={(e) => setAdminForm({ ...adminForm, password: e.target.value })}
              />
            </div>
            <div>
              <label>Tuman</label>
              <select
                value={adminForm.tuman_id}
                onChange={(e) => setAdminForm({ ...adminForm, tuman_id: e.target.value })}
              >
                {(regions || []).map((t) => (
                  <option key={t.id} value={t.id}>{t.nomi}</option>
                ))}
              </select>
            </div>
          </div>
          <div style={{ marginTop: 10, display: "flex", gap: 8 }}>
            <button className="primary" onClick={createAdmin}>Yaratish</button>
            {adminMsg && <span style={{ fontSize: 12 }}>{adminMsg}</span>}
          </div>
        </div>
      )}
    </div>
  );
}

function AdminsPage({ adminToken }) {
  const { regions, error: regionsError } = useRegions();
  const [items, setItems] = useState([]);
  const [form, setForm] = useState({
    username: "",
    password: "",
    tuman_id: 1
  });
  const [msg, setMsg] = useState("");

  const tumanName = (id) => {
    const t = regions.find((x) => x.id === Number(id));
    return t ? t.nomi : "-";
  };

  const load = async () => {
    setMsg("");
    try {
      const res = await fetch(`${API_BASE}/admin/admins`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        setItems([
          { id: 1, username: "super", role: "super", tuman_id: null },
          { id: 2, username: "termiz_admin", role: "tuman", tuman_id: 6 }
        ]);
        setMsg("Demo adminlar ko'rsatildi.");
        return;
      }
      const data = await res.json();
      setItems(Array.isArray(data) ? data : []);
    } catch (e) {
      setItems([
        { id: 1, username: "super", role: "super", tuman_id: null },
        { id: 2, username: "termiz_admin", role: "tuman", tuman_id: 6 }
      ]);
      setMsg("Demo adminlar ko'rsatildi.");
    }
  };

  const create = async () => {
    setMsg("");
    const res = await fetch(`${API_BASE}/admin/admins`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Admin-Token": adminToken
      },
      body: JSON.stringify({
        username: form.username,
        password: form.password,
        role: "tuman",
        tuman_id: Number(form.tuman_id)
      })
    });
    if (!res.ok) {
      setMsg("Demo rejimda admin yaratildi.");
      setItems((prev) => [
        ...prev,
        {
          id: Date.now(),
          username: form.username,
          role: "tuman",
          tuman_id: Number(form.tuman_id)
        }
      ]);
      return;
    }
    setMsg("Tuman admin yaratildi");
    load();
  };

  useEffect(() => { load(); }, []);

  useEffect(() => {
    if (!regions.length) return;
    if (form.tuman_id) return;
    setForm((f) => ({ ...f, tuman_id: regions[0].id }));
  }, [regions]);

  return (
    <div className="card">
      <div className="header">
        <h2>Adminlar</h2>
        <button onClick={load}>Yangilash</button>
      </div>
      {regionsError && (
        <div style={{ color: "#c0392b", fontSize: 12, marginBottom: 8 }}>
          {regionsError}
        </div>
      )}
      <div className="row">
        <div>
          <label>Login</label>
          <input
            value={form.username}
            onChange={(e) => setForm({ ...form, username: e.target.value })}
          />
        </div>
        <div>
          <label>Parol</label>
          <input
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
          />
        </div>
        <div>
          <label>Tuman</label>
          <select
            value={form.tuman_id}
            onChange={(e) => setForm({ ...form, tuman_id: e.target.value })}
          >
            {(regions || []).map((t) => (
              <option key={t.id} value={t.id}>{t.nomi}</option>
            ))}
          </select>
        </div>
      </div>
      <div style={{ marginTop: 10, display: "flex", gap: 8 }}>
        <button className="primary" onClick={create}>Yaratish</button>
        {msg && <span style={{ fontSize: 12 }}>{msg}</span>}
      </div>

      <table className="table" style={{ marginTop: 14 }}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Login</th>
            <th>Role</th>
            <th>Tuman</th>
          </tr>
        </thead>
        <tbody>
          {items.map((a) => (
            <tr key={a.id}>
              <td>{a.id}</td>
              <td>{a.username}</td>
              <td>{a.role === "super" ? "Super admin" : "Tuman admin"}</td>
              <td>{a.tuman_id ? tumanName(a.tuman_id) : "-"}</td>
            </tr>
          ))}
          {items.length === 0 && (
            <tr>
              <td colSpan={4} style={{ color: "#6b7a6b", fontSize: 12 }}>
                Adminlar topilmadi.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

function useRegions() {
  const [regions, setRegions] = useState(DEMO_REGIONS);
  const [error, setError] = useState("");
  useEffect(() => {
    fetch(`${API_BASE}/regions`)
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error("bad response"))))
      .then((d) => setRegions(d.tumanlar || DEMO_REGIONS))
      .catch(() => {
        setError("Demo tumanlar ko'rsatildi.");
        setRegions(DEMO_REGIONS);
      });
  }, []);
  return { regions, error };
}

function JadvalPage({ adminToken, adminRole, adminTumanId }) {
  const { regions, error: regionsError } = useRegions();
  const [drivers, setDrivers] = useState([]);
  const todayISO = () => {
    const now = new Date();
    const tzOffset = now.getTimezoneOffset() * 60000;
    return new Date(now - tzOffset).toISOString().slice(0, 10);
  };
  const autoHolatForDate = (dateStr) => {
    if (!dateStr) return "keladi";
    const today = todayISO();
    if (dateStr === today) return "bugun";
    return dateStr < today ? "tugadi" : "keladi";
  };
  const [form, setForm] = useState({
    tuman_id: 0,
    tuman: "",
    mahalla: "",
    sana: "",
    boshlanish: "09:00",
    tugash: "10:30",
    holat: "keladi",
    driver_id: "",
    mashina_raqam: "60 A 123 BA",
    haydovchi_ism: "Alisher Karimov"
  });

  const [rows, setRows] = useState([]);
  const [editingId, setEditingId] = useState(null);
  const [msg, setMsg] = useState("");
  const [noticeMsg, setNoticeMsg] = useState("");
  const [search, setSearch] = useState("");

  const onChange = (e) => {
    const { name, value } = e.target;
    if (name === "sana") {
      const next = { ...form, sana: value };
      if (form.holat !== "bekor") {
        next.holat = autoHolatForDate(value);
      }
      setForm(next);
      return;
    }
    setForm({ ...form, [name]: value });
  };

  const visibleRows = rows.filter((r) => {
    const q = search.trim().toLowerCase();
    if (!q) return true;
    return [
      r.mahalla,
      r.tuman,
      r.boshlanish,
      r.tugash,
      r.mashina_raqam,
      r.haydovchi_ism,
      r.holat
    ]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(q));
  });

  const load = async () => {
    setMsg("");
    try {
      if (!form.tuman_id || !form.mahalla) {
        setMsg("Tuman va mahalla tanlang.");
        return;
      }
      const res = await fetch(`${API_BASE}/admin/jadval`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        const txt = await res.text();
        setMsg(`Yuklash xatolik (${res.status}). ${txt.slice(0, 120)}`);
        return;
      }
      const data = await res.json();
      const list = Array.isArray(data) ? data : (data.data || []);
      const filtered = list.filter((r) => {
        if (form.driver_id) {
          return Number(r.driver_id || 0) === Number(form.driver_id);
        }
        return r.tuman_id === Number(form.tuman_id) && r.mahalla === form.mahalla;
      });
      setRows(filtered);
    } catch (e) {
      setRows([
        {
          id: 1,
          sana: form.sana || todayISO(),
          mahalla: form.mahalla || "Bog'ishamol",
          boshlanish: "09:00",
          tugash: "10:30",
          mashina_raqam: "60 A 123 BA",
          haydovchi_ism: "Alisher Karimov",
          holat: autoHolatForDate(form.sana || todayISO()),
          tuman_id: Number(form.tuman_id || 6),
          tuman: form.tuman || "Termiz shahri",
          driver_id: form.driver_id || 1
        }
      ]);
      setMsg("Demo jadval ko'rsatildi.");
    }
  };

  const create = async () => {
    setMsg("");
    try {
      const payload = {
        ...form,
        tuman_id: Number(form.tuman_id),
        driver_id: form.driver_id ? Number(form.driver_id) : null,
      };
      const res = await fetch(`${API_BASE}/admin/jadval`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        setMsg("Demo rejimda jadval saqlandi.");
        setRows((prev) => [
          ...prev,
          {
            id: Date.now(),
            sana: form.sana,
            mahalla: form.mahalla,
            boshlanish: form.boshlanish,
            tugash: form.tugash,
            mashina_raqam: form.mashina_raqam,
            haydovchi_ism: form.haydovchi_ism,
            holat: form.holat,
            tuman_id: Number(form.tuman_id),
            tuman: form.tuman,
            driver_id: form.driver_id || null
          }
        ]);
        return;
      }
      load();
    } catch (e) {
      setMsg("Demo rejimda jadval saqlandi.");
      setRows((prev) => [
        ...prev,
        {
          id: Date.now(),
          sana: form.sana,
          mahalla: form.mahalla,
          boshlanish: form.boshlanish,
          tugash: form.tugash,
          mashina_raqam: form.mashina_raqam,
          haydovchi_ism: form.haydovchi_ism,
          holat: form.holat,
          tuman_id: Number(form.tuman_id),
          tuman: form.tuman,
          driver_id: form.driver_id || null
        }
      ]);
    }
  };

  const createWeek = async () => {
    setMsg("");
    try {
      if (!form.tuman_id || !form.mahalla || !form.sana) {
        setMsg("Tuman, mahalla va sana kiriting.");
        return;
      }
      const base = new Date(form.sana + "T00:00:00");
      const payloads = Array.from({ length: 7 }).map((_, i) => {
        const d = new Date(base);
        d.setDate(base.getDate() + i);
        const iso = new Date(d - d.getTimezoneOffset() * 60000)
          .toISOString()
          .slice(0, 10);
        return {
          ...form,
          sana: iso,
          tuman_id: Number(form.tuman_id),
          driver_id: form.driver_id ? Number(form.driver_id) : null,
          holat: form.holat === "bekor" ? "bekor" : autoHolatForDate(iso)
        };
      });
      const results = await Promise.all(
        payloads.map((p) =>
          fetch(`${API_BASE}/admin/jadval`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "X-Admin-Token": adminToken
            },
            body: JSON.stringify(p)
          })
        )
      );
      const failed = results.filter((r) => !r.ok).length;
      if (failed > 0) {
        setMsg(`1 haftalik saqlashda xatolik: ${failed} ta yozuv.`);
      } else {
        setMsg("1 haftalik jadval saqlandi.");
      }
      load();
    } catch (e) {
      setMsg("1 haftalik saqlashda xatolik. Backendni tekshiring.");
    }
  };

  const update = async () => {
    if (!editingId) return;
    try {
      const payload = {
        ...form,
        tuman_id: Number(form.tuman_id),
        driver_id: form.driver_id ? Number(form.driver_id) : null,
      };
      const res = await fetch(`${API_BASE}/admin/jadval/${editingId}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify(payload)
      });
      if (!res.ok) {
        setMsg("Yangilashda xatolik.");
        return;
      }
      setEditingId(null);
      load();
    } catch (e) {
      setMsg("Yangilashda xatolik. Backendni tekshiring.");
    }
  };

  const sendChangeNotice = async () => {
    setNoticeMsg("");
    try {
      const title = "Jadval o'zgardi";
      const body = `${form.mahalla} · ${form.sana} ${form.boshlanish}-${form.tugash}`;
      const res = await fetch(`${API_BASE}/admin/notifications`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify({
          tuman_id: Number(form.tuman_id),
          mahalla: form.mahalla,
          title,
          body,
          level: "warning"
        })
      });
      if (!res.ok) {
        setNoticeMsg("Xabar yuborilmadi.");
        return;
      }
      setNoticeMsg("Jadval xabari yuborildi.");
    } catch (e) {
      setNoticeMsg("Xabar yuborilmadi.");
    }
  };

  const remove = async (id) => {
    try {
      const res = await fetch(`${API_BASE}/admin/jadval/${id}`, {
        method: "DELETE",
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        setMsg("Ochirishda xatolik.");
        return;
      }
      load();
    } catch (e) {
      setMsg("Ochirishda xatolik. Backendni tekshiring.");
    }
  };

  const selectedTuman = regions.find((t) => t.id === Number(form.tuman_id)) || regions[0];
  const mahallalar = selectedTuman ? selectedTuman.mahallalar : [];

  const loadDrivers = async (tumanId) => {
    try {
      const res = await fetch(`${API_BASE}/admin/drivers`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) return;
      const list = await res.json();
      const filtered = adminRole === "super" && tumanId
        ? list.filter((d) => Number(d.tuman_id || 0) === Number(tumanId))
        : list;
      setDrivers(Array.isArray(filtered) ? filtered : []);
    } catch (_) {
      setDrivers([]);
    }
  };

  useEffect(() => {
    if (!regions.length) return;
    if (form.tuman_id) return;
    const t = adminRole === "tuman"
      ? regions.find((x) => x.id === adminTumanId) || regions[0]
      : regions[0];
    setForm((f) => ({
      ...f,
      tuman_id: t.id,
      tuman: t.nomi,
      mahalla: t.mahallalar?.[0] || "",
      sana: f.sana || todayISO(),
      holat: f.holat === "bekor" ? "bekor" : autoHolatForDate(f.sana || todayISO())
    }));
  }, [regions, adminRole, adminTumanId]);

  useEffect(() => {
    if (!adminToken) return;
    if (!form.tuman_id) return;
    loadDrivers(form.tuman_id);
  }, [adminToken, form.tuman_id]);

  return (
    <div className="card">
      <div className="header">
        <h2>Jadval boshqaruvi</h2>
      </div>
      {regionsError && (
        <div style={{ color: "#c0392b", fontSize: 12, marginBottom: 8 }}>
          {regionsError}
        </div>
      )}
      <div className="row">
        <div>
          <label>Tuman</label>
          <select
            name="tuman_id"
            value={form.tuman_id}
            disabled={adminRole === "tuman"}
            onChange={(e) => {
              const id = Number(e.target.value);
              const t = regions.find((x) => x.id === id);
              setForm({ ...form, tuman_id: id, tuman: t?.nomi || "", mahalla: t?.mahallalar?.[0] || "" });
            }}
          >
            {regions.map((t) => (
              <option key={t.id} value={t.id}>{t.nomi}</option>
            ))}
          </select>
        </div>
        <div>
          <label>Mahalla</label>
          <select
            name="mahalla"
            value={form.mahalla}
            onChange={(e) => setForm({ ...form, mahalla: e.target.value })}
          >
            {mahallalar.map((m) => (
              <option key={m} value={m}>{m}</option>
            ))}
          </select>
        </div>
        <div>
          <label>Haydovchi</label>
          <select
            name="driver_id"
            value={form.driver_id}
            onChange={(e) => {
              const id = e.target.value;
              const d = drivers.find((x) => String(x.id) === String(id));
              setForm({
                ...form,
                driver_id: id,
                tuman_id: d?.tuman_id || form.tuman_id,
                mahalla: d?.mahalla || form.mahalla,
                haydovchi_ism: d?.full_name || form.haydovchi_ism,
              });
            }}
          >
            <option value="">--</option>
            {drivers.map((d) => (
              <option key={d.id} value={d.id}>
                {d.full_name} ({d.login})
              </option>
            ))}
          </select>
        </div>
        <div>
          <label>Sana</label>
          <input name="sana" value={form.sana} onChange={onChange} />
        </div>
        <div>
          <label>Boshlanish</label>
          <input name="boshlanish" value={form.boshlanish} onChange={onChange} />
        </div>
        <div>
          <label>Tugash</label>
          <input name="tugash" value={form.tugash} onChange={onChange} />
        </div>
        <div>
          <label>Holat</label>
          <select name="holat" value={form.holat} onChange={onChange}>
            <option value="keladi">keladi</option>
            <option value="bugun">bugun</option>
            <option value="tugadi">tugadi</option>
            <option value="bekor">bekor</option>
          </select>
        </div>
        <div>
          <label>Mashina raqam</label>
          <input name="mashina_raqam" value={form.mashina_raqam} onChange={onChange} />
        </div>
        <div>
          <label>Haydovchi ism</label>
          <input name="haydovchi_ism" value={form.haydovchi_ism} onChange={onChange} />
        </div>
      </div>
      <div style={{ marginTop: 12, display: "flex", gap: 8, alignItems: "center" }}>
        <button className="primary" onClick={editingId ? update : create}>
          {editingId ? "Yangilash" : "Saqlash"}
        </button>
        <button onClick={createWeek}>1 haftalik yaratish</button>
        <button onClick={load}>Jadvalni yuklash</button>
        <button onClick={sendChangeNotice}>Jadval o'zgarishi xabari</button>
        {msg && <span style={{ fontSize: 12, color: "#c0392b" }}>{msg}</span>}
        {noticeMsg && <span style={{ fontSize: 12 }}>{noticeMsg}</span>}
      </div>

      <div className="toolbar">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Jadval bo'yicha qidirish..."
        />
      </div>

      <table className="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Sana</th>
            <th>Mahalla</th>
            <th>Vaqt</th>
            <th>Mashina</th>
            <th>Haydovchi</th>
            <th>Holat</th>
            <th>Amal</th>
          </tr>
        </thead>
        <tbody>
          {visibleRows.map((r) => (
            <tr key={r.id}>
              <td>{r.id}</td>
              <td>{r.sana}</td>
              <td>{r.mahalla}</td>
              <td>{r.boshlanish} - {r.tugash}</td>
              <td>{r.mashina_raqam}</td>
              <td>{r.haydovchi_ism}</td>
              <td><span className="badge">{r.holat}</span></td>
              <td>
                <button onClick={() => {
                  setEditingId(r.id);
                  setForm({
                    tuman_id: r.tuman_id,
                    tuman: r.tuman,
                    mahalla: r.mahalla,
                    sana: r.sana,
                    boshlanish: r.boshlanish,
                    tugash: r.tugash,
                    holat: r.holat,
                    driver_id: r.driver_id || "",
                    mashina_raqam: r.mashina_raqam || "",
                    haydovchi_ism: r.haydovchi_ism || ""
                  });
                }}>Tahrirlash</button>
                <button style={{ marginLeft: 6 }} onClick={() => remove(r.id)}>Ochirish</button>
              </td>
            </tr>
          ))}
          {visibleRows.length === 0 && (
            <tr>
              <td colSpan={8} style={{ color: "#6b7a6b", fontSize: 12 }}>
                Jadval topilmadi. Avval saqlang yoki filtrni tekshiring.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

function ShikoyatPage({ adminToken }) {
  const [items, setItems] = useState([]);
  const [search, setSearch] = useState("");

  const fmt = (v) => {
    try {
      return new Date(v).toLocaleString();
    } catch (_) {
      return v || "-";
    }
  };

  const visibleItems = items.filter((s) => {
    const q = search.trim().toLowerCase();
    if (!q) return true;
    return [s.tuman, s.mahalla, s.xil, s.izoh]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(q));
  });

  const load = async () => {
    try {
      const res = await fetch(`${API_BASE}/admin/shikoyat`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) throw new Error("bad response");
      const data = await res.json();
      setItems(data);
    } catch (_) {
      setItems([
        {
          id: 1,
          created_at: new Date().toISOString(),
          tuman: "Termiz shahri",
          mahalla: "Bog'ishamol",
          xil: "mashina_kelmadi",
          izoh: "Mashina kech keldi."
        },
        {
          id: 2,
          created_at: new Date().toISOString(),
          tuman: "Denov tumani",
          mahalla: "Denov markazi",
          xil: "jadval_noto'g'ri",
          izoh: "Jadval vaqtini tekshirish kerak."
        }
      ]);
    }
  };

  const reply = async (item) => {
    const javob = window.prompt(`"${item.mahalla}" shikoyatiga javob yozing:`);
    if (!javob || !javob.trim()) return;
    try {
      const res = await fetch(`${API_BASE}/admin/shikoyat/${item.id}/javob`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify({ javob: javob.trim() })
      });
      if (!res.ok) throw new Error("bad response");
      load();
    } catch (_) {
      alert("Javob yuborilmadi");
    }
  };

  useEffect(() => { load(); }, []);

  return (
    <div className="card">
      <div className="header">
        <h2>Shikoyatlar</h2>
        <button onClick={load}>Yangilash</button>
      </div>
      <div className="toolbar">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Shikoyat bo'yicha qidirish..."
        />
      </div>
      <table className="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Vaqt</th>
            <th>Tuman</th>
            <th>Mahalla</th>
            <th>Xil</th>
            <th>Izoh</th>
            <th>Amal</th>
          </tr>
        </thead>
        <tbody>
          {visibleItems.map((s) => (
            <tr key={s.id}>
              <td>{s.id}</td>
              <td>{fmt(s.created_at)}</td>
              <td>{s.tuman}</td>
              <td>{s.mahalla}</td>
              <td>{s.xil}</td>
              <td>{s.izoh}</td>
              <td>
                <button onClick={() => reply(s)}>Javob berish</button>
              </td>
            </tr>
          ))}
          {visibleItems.length === 0 && (
            <tr>
              <td colSpan={7} style={{ color: "#6b7a6b", fontSize: 12 }}>
                Shikoyatlar topilmadi.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

function MessagesPage({ adminToken, adminRole, adminTumanId }) {
  const { regions, error: regionsError } = useRegions();
  const [items, setItems] = useState([]);
  const [msg, setMsg] = useState("");
  const [search, setSearch] = useState("");
  const [form, setForm] = useState({
    tuman_id: 0,
    mahalla: "",
    title: "",
    body: "",
    level: "info"
  });

  const onChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const visibleItems = items.filter((n) => {
    const q = search.trim().toLowerCase();
    if (!q) return true;
    return [n.title, n.body, n.mahalla, n.level, n.tuman_id]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(q));
  });

  const load = async () => {
    setMsg("");
    try {
      const res = await fetch(`${API_BASE}/admin/notifications`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        setItems([
          {
            id: 1,
            created_at: new Date().toISOString(),
            tuman_id: 6,
            mahalla: "Bog'ishamol",
            title: "Jadval yangilandi",
            body: "Bugungi yig'ish 09:00 da boshlanadi.",
            level: "success"
          }
        ]);
        setMsg("Demo xabarlar ko'rsatildi.");
        return;
      }
      const data = await res.json();
      setItems(Array.isArray(data) ? data : []);
    } catch (e) {
      setItems([
        {
          id: 1,
          created_at: new Date().toISOString(),
          tuman_id: 6,
          mahalla: "Bog'ishamol",
          title: "Jadval yangilandi",
          body: "Bugungi yig'ish 09:00 da boshlanadi.",
          level: "success"
        },
        {
          id: 2,
          created_at: new Date().toISOString(),
          tuman_id: 14,
          mahalla: "Denov markazi",
          title: "Haydovchi yo'lda",
          body: "Mashina sizning mahallaga yaqinlashmoqda.",
          level: "info"
        }
      ]);
      setMsg("Demo xabarlar ko'rsatildi.");
    }
  };

  const create = async () => {
    setMsg("");
    try {
      const res = await fetch(`${API_BASE}/admin/notifications`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify({
          tuman_id: Number(form.tuman_id),
          mahalla: form.mahalla || null,
          title: form.title,
          body: form.body,
          level: form.level
        })
      });
      if (!res.ok) {
        setItems((prev) => [
          ...prev,
          {
            id: Date.now(),
            created_at: new Date().toISOString(),
            tuman_id: Number(form.tuman_id),
            mahalla: form.mahalla || null,
            title: form.title,
            body: form.body,
            level: form.level
          }
        ]);
        setMsg("Demo rejimda xabar yuborildi.");
        return;
      }
      setForm({ ...form, title: "", body: "" });
      load();
    } catch (e) {
      setItems((prev) => [
        ...prev,
        {
          id: Date.now(),
          created_at: new Date().toISOString(),
          tuman_id: Number(form.tuman_id),
          mahalla: form.mahalla || null,
          title: form.title,
          body: form.body,
          level: form.level
        }
      ]);
      setMsg("Demo rejimda xabar yuborildi.");
    }
  };

  const remove = async (id) => {
    setMsg("");
    try {
      const res = await fetch(`${API_BASE}/admin/notifications/${id}`, {
        method: "DELETE",
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        const txt = await res.text();
        setMsg(`O'chirishda xatolik (${res.status}). ${txt.slice(0, 120)}`);
        return;
      }
      load();
    } catch (e) {
      setMsg("O'chirishda xatolik.");
    }
  };

  useEffect(() => { load(); }, []);

  useEffect(() => {
    if (!regions.length) return;
    if (form.tuman_id) return;
    const t = adminRole === "tuman"
      ? regions.find((x) => x.id === adminTumanId) || regions[0]
      : regions[0];
    setForm((f) => ({
      ...f,
      tuman_id: t.id,
      mahalla: t.mahallalar?.[0] || ""
    }));
  }, [regions, adminRole, adminTumanId]);

  const selectedTuman = regions.find((t) => t.id === Number(form.tuman_id)) || regions[0];
  const mahallalar = selectedTuman ? selectedTuman.mahallalar : [];

  return (
    <div className="card">
      <div className="header">
        <h2>Xabarlar</h2>
        <button onClick={load}>Yangilash</button>
      </div>
      <div className="toolbar">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Xabar bo'yicha qidirish..."
        />
      </div>
      {regionsError && (
        <div style={{ color: "#c0392b", fontSize: 12, marginBottom: 8 }}>
          {regionsError}
        </div>
      )}
      <div className="row">
        <div>
          <label>Tuman</label>
          <select
            name="tuman_id"
            value={form.tuman_id}
            disabled={adminRole === "tuman"}
            onChange={(e) => {
              const id = Number(e.target.value);
              const t = regions.find((x) => x.id === id);
              setForm({ ...form, tuman_id: id, mahalla: t?.mahallalar?.[0] || "" });
            }}
          >
            {regions.map((t) => (
              <option key={t.id} value={t.id}>{t.nomi}</option>
            ))}
          </select>
        </div>
        <div>
          <label>Mahalla</label>
          <select
            name="mahalla"
            value={form.mahalla}
            onChange={onChange}
          >
            <option value="">Barcha mahallalar</option>
            {mahallalar.map((m) => (
              <option key={m} value={m}>{m}</option>
            ))}
          </select>
        </div>
        <div>
          <label>Sarlavha</label>
          <input name="title" value={form.title} onChange={onChange} />
        </div>
        <div>
          <label>Matn</label>
          <input name="body" value={form.body} onChange={onChange} />
        </div>
        <div>
          <label>Xil</label>
          <select name="level" value={form.level} onChange={onChange}>
            <option value="info">info</option>
            <option value="warning">warning</option>
            <option value="success">success</option>
            <option value="error">error</option>
          </select>
        </div>
      </div>
      <div style={{ marginTop: 12, display: "flex", gap: 8, alignItems: "center" }}>
        <button className="primary" onClick={create}>Yuborish</button>
        {msg && <span style={{ fontSize: 12, color: "#c0392b" }}>{msg}</span>}
      </div>

      <table className="table" style={{ marginTop: 12 }}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Vaqt</th>
            <th>Tuman</th>
            <th>Mahalla</th>
            <th>Sarlavha</th>
            <th>Matn</th>
            <th>Xil</th>
            <th>Amal</th>
          </tr>
        </thead>
        <tbody>
          {visibleItems.map((n) => (
            <tr key={n.id}>
              <td>{n.id}</td>
              <td>{new Date(n.created_at).toLocaleString()}</td>
              <td>{n.tuman_id}</td>
              <td>{n.mahalla || "-"}</td>
              <td>{n.title}</td>
              <td>{n.body}</td>
              <td>{n.level}</td>
              <td>
                <button onClick={() => remove(n.id)}>O'chirish</button>
              </td>
            </tr>
          ))}
          {visibleItems.length === 0 && (
            <tr>
              <td colSpan={8} style={{ color: "#6b7a6b", fontSize: 12 }}>
                Xabarlar yo'q.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

function DriversPage({ adminToken, adminRole, adminTumanId }) {
  const { regions, error: regionsError } = useRegions();
  const [form, setForm] = useState({
    full_name: "Alisher Karimov",
    login: "driver01",
    password: "driver123",
    vehicle_number: "60 A 123 BA",
    phone: "",
    tuman_id: 0,
    mahalla: ""
  });
  const [items, setItems] = useState([]);
  const [locations, setLocations] = useState([]);
  const [msg, setMsg] = useState("");
  const [search, setSearch] = useState("");

  const onChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const visibleItems = items.filter((d) => {
    const q = search.trim().toLowerCase();
    if (!q) return true;
    return [d.full_name, d.login, d.vehicle_number, d.mahalla, d.tuman_id]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(q));
  });

  const load = async () => {
    try {
      const res = await fetch(`${API_BASE}/admin/drivers`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) {
        setItems([
          {
            id: 1,
            full_name: "Alisher Karimov",
            login: "driver01",
            vehicle_number: "60 A 123 BA",
            tuman_id: 6,
            mahalla: "Bog'ishamol"
          },
          {
            id: 2,
            full_name: "Rustam Tursunov",
            login: "driver02",
            vehicle_number: "60 B 456 BB",
            tuman_id: 14,
            mahalla: "Denov markazi"
          }
        ]);
        setMsg("Demo haydovchilar ko'rsatildi.");
        return;
      }
      const data = await res.json();
      setItems(data);
    } catch (e) {
      setItems([
        {
          id: 1,
          full_name: "Alisher Karimov",
          login: "driver01",
          vehicle_number: "60 A 123 BA",
          tuman_id: 6,
          mahalla: "Bog'ishamol"
        }
      ]);
      setMsg("Demo haydovchilar ko'rsatildi.");
    }
  };

  const create = async () => {
    setMsg("");
    try {
      const res = await fetch(`${API_BASE}/admin/drivers`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Token": adminToken
        },
        body: JSON.stringify(form)
      });
      if (!res.ok) {
        setItems((prev) => [
          ...prev,
          {
            id: Date.now(),
            full_name: form.full_name,
            login: form.login,
            vehicle_number: form.vehicle_number,
            tuman_id: Number(form.tuman_id),
            mahalla: form.mahalla
          }
        ]);
        setMsg("Demo rejimda haydovchi saqlandi.");
        return;
      }
      load();
    } catch (e) {
      setItems((prev) => [
        ...prev,
        {
          id: Date.now(),
          full_name: form.full_name,
          login: form.login,
          vehicle_number: form.vehicle_number,
          tuman_id: Number(form.tuman_id),
          mahalla: form.mahalla
        }
      ]);
      setMsg("Demo rejimda haydovchi saqlandi.");
    }
  };

  const loadLocations = async () => {
    try {
      const res = await fetch(`${API_BASE}/admin/driver-locations`, {
        headers: { "X-Admin-Token": adminToken }
      });
      if (!res.ok) throw new Error("bad response");
      const data = await res.json();
      setLocations(data.data || []);
    } catch (e) {
      setLocations([
        { driver_id: 1, lat: 37.224, lon: 67.278, mahalla: "Bog'ishamol" },
        { driver_id: 2, lat: 37.806, lon: 67.272, mahalla: "Denov markazi" }
      ]);
      setMsg("Demo kuzatuv ko'rsatildi.");
    }
  };

  useEffect(() => { load(); }, []);

  useEffect(() => {
    if (!regions.length) return;
    if (form.tuman_id) return;
    const t = adminRole === "tuman"
      ? regions.find((x) => x.id === adminTumanId) || regions[0]
      : regions[0];
    setForm((f) => ({
      ...f,
      tuman_id: t.id,
      mahalla: t.mahallalar?.[0] || ""
    }));
  }, [regions, adminRole, adminTumanId]);

  const selectedTuman = regions.find((t) => t.id === Number(form.tuman_id)) || regions[0];
  const mahallalar = selectedTuman ? selectedTuman.mahallalar : [];

  return (
    <div className="card">
      <h2>Haydovchilar</h2>
      {regionsError && (
        <div style={{ color: "#c0392b", fontSize: 12, marginBottom: 8 }}>
          {regionsError}
        </div>
      )}
      <div className="row">
        <div>
          <label>F.I.Sh</label>
          <input name="full_name" value={form.full_name} onChange={onChange} />
        </div>
        <div>
          <label>Login</label>
          <input name="login" value={form.login} onChange={onChange} />
        </div>
        <div>
          <label>Parol</label>
          <input name="password" value={form.password} onChange={onChange} />
        </div>
        <div>
          <label>Telefon</label>
          <input name="phone" value={form.phone} onChange={onChange} />
        </div>
        <div>
          <label>Mashina raqam</label>
          <input name="vehicle_number" value={form.vehicle_number} onChange={onChange} />
        </div>
        <div>
          <label>Tuman</label>
          <select
            name="tuman_id"
            value={form.tuman_id}
            disabled={adminRole === "tuman"}
            onChange={(e) => {
              const id = Number(e.target.value);
              const t = regions.find((x) => x.id === id);
              setForm({ ...form, tuman_id: id, mahalla: t?.mahallalar?.[0] || "" });
            }}
          >
            {regions.map((t) => (
              <option key={t.id} value={t.id}>{t.nomi}</option>
            ))}
          </select>
        </div>
        <div>
          <label>Mahalla</label>
          <select
            name="mahalla"
            value={form.mahalla}
            onChange={(e) => setForm({ ...form, mahalla: e.target.value })}
          >
            {mahallalar.map((m) => (
              <option key={m} value={m}>{m}</option>
            ))}
          </select>
        </div>
      </div>
      <div style={{ marginTop: 12, display: "flex", gap: 8 }}>
        <button className="primary" onClick={create}>Saqlash</button>
        <button onClick={load}>Yangilash</button>
        <button onClick={loadLocations}>Kuzatish</button>
        {msg && <span style={{ fontSize: 12, color: "#c0392b" }}>{msg}</span>}
      </div>

      <div className="toolbar">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Haydovchi qidirish..."
        />
      </div>

      <table className="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>F.I.Sh</th>
            <th>Login</th>
            <th>Mashina</th>
            <th>Tuman</th>
            <th>Mahalla</th>
          </tr>
        </thead>
        <tbody>
          {visibleItems.map((d) => (
            <tr key={d.id}>
              <td>{d.id}</td>
              <td>{d.full_name}</td>
              <td>{d.login}</td>
              <td>{d.vehicle_number}</td>
              <td>{d.tuman_id || "-"}</td>
              <td>{d.mahalla || "-"}</td>
            </tr>
          ))}
          {visibleItems.length === 0 && (
            <tr>
              <td colSpan={6} style={{ color: "#6b7a6b", fontSize: 12 }}>
                Haydovchilar topilmadi.
              </td>
            </tr>
          )}
        </tbody>
      </table>

      <h3 style={{ marginTop: 16 }}>Real vaqt kuzatuv</h3>
      <table className="table">
        <thead>
          <tr>
            <th>Driver ID</th>
            <th>Lat</th>
            <th>Lon</th>
            <th>Mahalla</th>
          </tr>
        </thead>
        <tbody>
          {locations.map((l, i) => (
            <tr key={i}>
              <td>{l.driver_id}</td>
              <td>{l.lat}</td>
              <td>{l.lon}</td>
              <td>{l.mahalla}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
