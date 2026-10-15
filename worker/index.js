const encoder = new TextEncoder();
const sessionLifetimeSeconds = 60 * 60 * 24 * 7;
const passwordIterations = 100000;
const loginWindowSeconds = 60;
const maxLoginAttempts = 8;

const seedData = {
  circles: [
    { id: 1, name: 'حلقة الصديق', teacherName: 'الأستاذ عبدالله', timing: 'بعد صلاة المغرب', category: '', location: 'المصلى', maxCapacity: 15, description: '' },
    { id: 2, name: 'حلقة الفاروق', teacherName: 'الأستاذ محمد', timing: 'بعد صلاة المغرب', category: '', location: 'المصلى', maxCapacity: 18, description: '' },
    { id: 3, name: 'حلقة أبي الحسنين', teacherName: 'الأستاذ عبدالله', timing: 'بعد صلاة المغرب', category: '', location: 'المصلى', maxCapacity: 20, description: '' },
  ],
  curricula: [
    { id: 1, title: 'سفينة النجاة', category: 'فقه', author: '', totalLessons: 18, targetLevel: '', summary: '', keyTopics: '' },
    { id: 2, title: 'الأربعون النووية', category: 'حديث شريف', author: 'الإمام يحيى بن شرف النووي', totalLessons: 24, targetLevel: '', summary: '', keyTopics: '' },
  ],
  plans: [
    { id: 1, title: 'خطة إتمام حفظ جزء عم وتبارك', circleCategory: '', durationWeeks: 16, weeklyMemorization: '', weeklyRevision: '', educationalFocus: '', status: 'نشطة' },
  ],
  students: [
    { id: 1, name: 'عبد الله بن محمد', studentCode: 'STD-201', circleId: 1, circleName: 'حلقة الصديق', age: 15, educationalLevel: 'المرحلة المتوسطة', guardianPhone: '0501234567', studentPhone: '0559876543', enrollmentDate: '2025-09-01', memorizedParts: 12, notes: '' },
    { id: 2, name: 'عمر بن علي', studentCode: 'STD-202', circleId: 2, circleName: 'حلقة الفاروق', age: 16, educationalLevel: '', guardianPhone: '0531122334', studentPhone: '', enrollmentDate: '2025-09-05', memorizedParts: 9, notes: '' },
    { id: 3, name: 'طالب تجريبي', studentCode: 'STD-301', circleId: 3, circleName: 'حلقة أبي الحسنين', age: 11, educationalLevel: 'المرحلة الابتدائية', guardianPhone: '0544556677', studentPhone: '', enrollmentDate: '2025-09-10', memorizedParts: 4, notes: '' },
  ],
  attendance: [],
  grades: [
    { id: 1, studentId: 1, testTitle: 'اختبار جزء الذاريات', category: 'حفظ جديد', score: 98, maxScore: 100, date: '2026-03-10', notes: 'ممتاز جداً مع ترتيل متقن' },
  ],
};

const allowedDataKeys = new Set(Object.keys(seedData));

function jsonResponse(data, status = 200, additionalHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      ...additionalHeaders,
    },
  });
}

function failure(message, status) {
  return jsonResponse({ error: message }, status);
}

function encodeBase64(bytes) {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function decodeBase64(value) {
  return Uint8Array.from(atob(value), (character) => character.charCodeAt(0));
}

async function sha256(value) {
  const digest = await crypto.subtle.digest('SHA-256', encoder.encode(value));
  return encodeBase64(new Uint8Array(digest));
}

async function hashPassword(password, salt) {
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    'PBKDF2',
    false,
    ['deriveBits'],
  );
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', hash: 'SHA-256', salt, iterations: passwordIterations },
    key,
    256,
  );
  return encodeBase64(new Uint8Array(bits));
}

function randomBytes(length) {
  return crypto.getRandomValues(new Uint8Array(length));
}

function publicUser(row) {
  return {
    id: row.id,
    username: row.username,
    password: '',
    displayName: row.display_name,
    role: row.role,
    phone: row.phone,
    createdAt: row.created_at,
    isActive: row.is_active === 1,
  };
}

async function seedAppData(db) {
  const initialized = await db.prepare(
    "SELECT meta_value FROM app_meta WHERE meta_key = 'seeded-v1'",
  ).first();
  if (initialized) return;

  const statements = Object.entries(seedData).map(([key, value]) =>
    db.prepare('INSERT OR IGNORE INTO app_data (data_key, value) VALUES (?, ?)')
      .bind(key, JSON.stringify(value)),
  );
  statements.push(db.prepare(
    "INSERT OR IGNORE INTO app_meta (meta_key, meta_value) VALUES ('seeded-v1', '1')",
  ));
  await db.batch(statements);
}

async function createInitialAdmin(db, env) {
  const current = await db.prepare("SELECT id FROM users WHERE role = 'admin' LIMIT 1").first();
  if (current) return;

  const username = env.INITIAL_ADMIN_USERNAME?.trim().toLowerCase();
  const password = env.INITIAL_ADMIN_PASSWORD;
  if (
    !username ||
    !/^[a-z0-9._-]{3,32}$/.test(username) ||
    !password ||
    password.length < 12
  ) {
    throw new Error('INITIAL_ADMIN_SECRET_MISSING');
  }

  const salt = randomBytes(16);
  const passwordHash = await hashPassword(password, salt);
  const today = new Date().toISOString().slice(0, 10);
  await db.prepare(
    `INSERT OR IGNORE INTO users
      (id, username, password_salt, password_hash, display_name, role, phone, created_at, is_active)
     VALUES (?, ?, ?, ?, ?, 'admin', '', ?, 1)`,
  ).bind(
    crypto.randomUUID(),
    username,
    encodeBase64(salt),
    passwordHash,
    'مدير النظام',
    today,
  ).run();
}

async function createSession(db, userId) {
  await db.prepare('DELETE FROM sessions WHERE expires_at <= ?')
    .bind(Math.floor(Date.now() / 1000))
    .run();
  const token = `${crypto.randomUUID()}${crypto.randomUUID()}`;
  const tokenHash = await sha256(token);
  const expiresAt = Math.floor(Date.now() / 1000) + sessionLifetimeSeconds;
  await db.prepare('INSERT INTO sessions (token_hash, user_id, expires_at) VALUES (?, ?, ?)')
    .bind(tokenHash, userId, expiresAt)
    .run();
  return token;
}

async function loginAllowed(db, ipAddress) {
  const now = Math.floor(Date.now() / 1000);
  const row = await db.prepare(
    'SELECT window_started_at, attempts FROM login_attempts WHERE ip_address = ?',
  ).bind(ipAddress).first();
  return !row ||
    now - row.window_started_at >= loginWindowSeconds ||
    row.attempts < maxLoginAttempts;
}

async function recordLoginFailure(db, ipAddress) {
  const now = Math.floor(Date.now() / 1000);
  await db.prepare(
    `INSERT INTO login_attempts (ip_address, window_started_at, attempts)
     VALUES (?, ?, 1)
     ON CONFLICT(ip_address) DO UPDATE SET
       attempts = CASE
         WHEN login_attempts.window_started_at + ? <= excluded.window_started_at THEN 1
         ELSE login_attempts.attempts + 1
       END,
       window_started_at = CASE
         WHEN login_attempts.window_started_at + ? <= excluded.window_started_at THEN excluded.window_started_at
         ELSE login_attempts.window_started_at
       END`,
  ).bind(ipAddress, now, loginWindowSeconds, loginWindowSeconds).run();
}

async function requireUser(request, db) {
  const cookie = request.headers.get('Cookie') ?? '';
  const match = /(?:^|;\s*)halqat_session=([^;]+)/.exec(cookie);
  if (!match) return null;

  const tokenHash = await sha256(decodeURIComponent(match[1]));
  const row = await db.prepare(
    `SELECT users.*
       FROM sessions
       JOIN users ON users.id = sessions.user_id
      WHERE sessions.token_hash = ? AND sessions.expires_at > ?`,
  ).bind(tokenHash, Math.floor(Date.now() / 1000)).first();
  if (!row || row.is_active !== 1) return null;
  return row;
}

function userListItem(row) {
  return publicUser(row);
}

async function saveUsers(db, users, currentUser) {
  if (!Array.isArray(users) || users.length > 500) {
    return failure('قائمة المستخدمين غير صالحة', 400);
  }

  const normalized = [];
  const usernames = new Set();
  for (const item of users) {
    if (!item || typeof item !== 'object') return failure('بيانات مستخدم غير صالحة', 400);
    const id = String(item.id ?? '').trim();
    const username = String(item.username ?? '').trim().toLowerCase();
    const displayName = String(item.displayName ?? '').trim();
    const role = item.role === 'admin' ? 'admin' : item.role === 'user' ? 'user' : '';
    const password = String(item.password ?? '');
    if (
      !id ||
      !/^[a-z0-9._-]{3,32}$/.test(username) ||
      !displayName ||
      !role
    ) {
      return failure('بيانات مستخدم غير مكتملة', 400);
    }
    if (usernames.has(username)) return failure('اسم المستخدم مكرر', 409);
    usernames.add(username);
    normalized.push({ ...item, id, username, displayName, role, password });
  }

  const existingResult = await db.prepare('SELECT id, password_hash FROM users').all();
  const existing = new Map(existingResult.results.map((row) => [row.id, row]));
  const activeAdminCount = normalized.filter((user) => user.role === 'admin' && user.isActive !== false).length;
  if (activeAdminCount === 0) return failure('يجب الإبقاء على مدير نشط واحد على الأقل', 400);

  const currentAccount = normalized.find((user) => user.id === currentUser.id);
  if (!currentAccount || currentAccount.isActive === false) {
    return failure('لا يمكن حذف حسابك الحالي أو تعطيله', 400);
  }

  const statements = [];
  for (const user of normalized) {
    let salt = '';
    let passwordHash = '';
    if (user.password) {
      if (user.password.length < 12) {
        return failure('كلمة مرور المستخدم يجب أن تكون 12 خانة على الأقل', 400);
      }
      const saltBytes = randomBytes(16);
      salt = encodeBase64(saltBytes);
      passwordHash = await hashPassword(user.password, saltBytes);
    } else if (!existing.has(user.id)) {
      return failure(`كلمة المرور مطلوبة للمستخدم الجديد: ${user.username}`, 400);
    }

    statements.push(db.prepare(
      `INSERT INTO users
        (id, username, password_salt, password_hash, display_name, role, phone, created_at, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
       ON CONFLICT(id) DO UPDATE SET
         username = excluded.username,
         password_salt = CASE WHEN excluded.password_hash = '' THEN users.password_salt ELSE excluded.password_salt END,
         password_hash = CASE WHEN excluded.password_hash = '' THEN users.password_hash ELSE excluded.password_hash END,
         display_name = excluded.display_name,
         role = excluded.role,
         phone = excluded.phone,
         is_active = excluded.is_active`,
    ).bind(
      user.id,
      user.username,
      salt,
      passwordHash,
      user.displayName,
      user.role,
      String(user.phone ?? ''),
      String(user.createdAt ?? new Date().toISOString().slice(0, 10)),
      user.isActive === false ? 0 : 1,
    ));
    if (passwordHash) {
      statements.push(db.prepare('DELETE FROM sessions WHERE user_id = ?').bind(user.id));
    }
  }

  for (const existingId of existing.keys()) {
    if (!normalized.some((user) => user.id === existingId)) {
      statements.push(db.prepare('DELETE FROM users WHERE id = ?').bind(existingId));
      statements.push(db.prepare('DELETE FROM sessions WHERE user_id = ?').bind(existingId));
    }
  }
  for (const user of normalized) {
    if (user.isActive === false) {
      statements.push(db.prepare('DELETE FROM sessions WHERE user_id = ?').bind(user.id));
    }
  }

  try {
    if (statements.length) await db.batch(statements);
  } catch (error) {
    console.error('Failed to save user records', error);
    return failure('تعذر حفظ المستخدمين؛ تحقق من عدم تكرار اسم المستخدم', 409);
  }

  return jsonResponse({ ok: true });
}

async function handleApi(request, env) {
  const db = env.DB;
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method.toUpperCase();
  const origin = request.headers.get('Origin');
  if (origin && origin !== url.origin) {
    return failure('مصدر الطلب غير مسموح', 403);
  }
  await seedAppData(db);

  if (path === '/api/auth/login' && method === 'POST') {
    const ipAddress = request.headers.get('CF-Connecting-IP') ?? 'unknown';
    if (!(await loginAllowed(db, ipAddress))) {
      return failure('محاولات كثيرة؛ انتظر دقيقة ثم حاول مجددًا', 429);
    }
    await createInitialAdmin(db, env);
    let body;
    try {
      body = await request.json();
    } catch {
      return failure('بيانات تسجيل الدخول غير صالحة', 400);
    }
    const username = String(body.username ?? '').trim().toLowerCase();
    const password = String(body.password ?? '');
    const row = await db.prepare('SELECT * FROM users WHERE username = ? COLLATE NOCASE').bind(username).first();
    if (!row || row.is_active !== 1) {
      await hashPassword(password, new Uint8Array(16));
      await recordLoginFailure(db, ipAddress);
      return failure('اسم المستخدم أو كلمة المرور غير صحيحة', 401);
    }

    const passwordHash = await hashPassword(password, decodeBase64(row.password_salt));
    if (passwordHash !== row.password_hash) {
      await recordLoginFailure(db, ipAddress);
      return failure('اسم المستخدم أو كلمة المرور غير صحيحة', 401);
    }

    await db.prepare('DELETE FROM login_attempts WHERE ip_address = ?')
      .bind(ipAddress)
      .run();
    const token = await createSession(db, row.id);
    return jsonResponse(
      { user: publicUser(row) },
      200,
      {
        'Set-Cookie': `halqat_session=${encodeURIComponent(token)}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=${sessionLifetimeSeconds}`,
      },
    );
  }

  if (path === '/api/auth/logout' && method === 'POST') {
    const cookie = request.headers.get('Cookie') ?? '';
    const match = /(?:^|;\s*)halqat_session=([^;]+)/.exec(cookie);
    if (match) {
      await db.prepare('DELETE FROM sessions WHERE token_hash = ?')
        .bind(await sha256(decodeURIComponent(match[1])))
        .run();
    }
    return jsonResponse(
      { ok: true },
      200,
      { 'Set-Cookie': 'halqat_session=; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=0' },
    );
  }

  const user = await requireUser(request, db);
  if (!user) return failure('انتهت الجلسة؛ سجّل الدخول مجددًا', 401);

  if (path === '/api/auth/me' && method === 'GET') {
    return jsonResponse({ user: publicUser(user) });
  }

  if (path === '/api/users' && method === 'GET') {
    if (user.role !== 'admin') return failure('هذه العملية تتطلب صلاحية المدير', 403);
    const result = await db.prepare('SELECT * FROM users ORDER BY username COLLATE NOCASE').all();
    return jsonResponse(result.results.map(userListItem));
  }

  if (path === '/api/users' && method === 'PUT') {
    if (user.role !== 'admin') return failure('هذه العملية تتطلب صلاحية المدير', 403);
    let users;
    try {
      users = await request.json();
    } catch {
      return failure('قائمة المستخدمين غير صالحة', 400);
    }
    return saveUsers(db, users, user);
  }

  const dataMatch = /^\/api\/data\/([a-z]+)$/.exec(path);
  if (dataMatch && allowedDataKeys.has(dataMatch[1])) {
    const key = dataMatch[1];
    if (method === 'GET') {
      const row = await db.prepare(
        'SELECT value, revision FROM app_data WHERE data_key = ?',
      ).bind(key).first();
      return jsonResponse({
        data: row ? JSON.parse(row.value) : [],
        revision: row?.revision ?? 0,
      });
    }
    if (method === 'PUT') {
      if (user.role !== 'admin') return failure('هذه العملية تتطلب صلاحية المدير', 403);
      let payload;
      try {
        payload = await request.json();
      } catch {
        return failure('البيانات المرسلة غير صالحة', 400);
      }
      if (!Array.isArray(payload.data) || !Number.isInteger(payload.revision)) {
        return failure('البيانات أو رقم المراجعة غير صالح', 400);
      }
      const serializedData = JSON.stringify(payload.data);
      if (encoder.encode(serializedData).byteLength > 1000000) {
        return failure('حجم البيانات يتجاوز الحد المسموح', 413);
      }
      const result = await db.prepare(
        `UPDATE app_data
            SET value = ?, revision = revision + 1
          WHERE data_key = ? AND revision = ?`,
      ).bind(serializedData, key, payload.revision).run();
      if (result.meta.changes !== 1) {
        return failure('تغيرت البيانات على جهاز آخر. أعد تحميل التطبيق وحاول مرة أخرى.', 409);
      }
      const updated = await db.prepare(
        'SELECT revision FROM app_data WHERE data_key = ?',
      ).bind(key).first();
      return jsonResponse({ ok: true, revision: updated.revision });
    }
  }

  return failure('المسار غير موجود', 404);
}

function addSecurityHeaders(response) {
  const headers = new Headers(response.headers);
  headers.set('X-Content-Type-Options', 'nosniff');
  headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  if (headers.get('Content-Type')?.includes('text/html')) {
    headers.set('Cache-Control', 'no-cache');
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

export default {
  async fetch(request, env) {
    try {
      const url = new URL(request.url);
      const response = url.pathname.startsWith('/api/')
        ? await handleApi(request, env)
        : await env.ASSETS.fetch(request);
      return addSecurityHeaders(response);
    } catch (error) {
      console.error('Worker request failed', error);
      const needsAdminSetup =
        error instanceof Error && error.message === 'INITIAL_ADMIN_SECRET_MISSING';
      const message = needsAdminSetup
        ? 'هيّئ سرّي المدير الأول في إعدادات Worker ثم أعد المحاولة.'
        : 'حدث خطأ داخلي؛ يرجى المحاولة لاحقًا';
      return addSecurityHeaders(failure(message, needsAdminSetup ? 503 : 500));
    }
  },
};
