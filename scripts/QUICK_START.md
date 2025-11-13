# ⚡ Quick Start Guide

## 🎯 One-Time Setup

### 1. Install Dependencies
```bash
cd FluenceApp
npm install
```

### 2. Create Admin User
```bash
cd ../Fluence-Backend-Private
node setup-admin.js
```

**Default Credentials:**
- Email: `admin@gmail.com`
- Password: `admin12345678`

---

## 🚀 Daily Usage

### Start Backend Services
```bash
cd FluenceApp
npm start
```

### Start Flutter Web
```bash
flutter run -d chrome
```

### Stop Backend Services
```bash
npm run stop
```

### Check Service Health
```bash
npm run status
```

---

## 🔧 Service Ports

| Service | Port |
|---------|------|
| 🔐 Auth | 4001 |
| 💰 Cashback | 4002 |
| 🏪 Merchant | 4003 |
| 🔔 Notification | 4004 |
| ⭐ Points | 4005 |
| 🎁 Referral | 4006 |
| 👥 Social | 4007 |

---

## 🆘 Troubleshooting

**Services not starting?**
```bash
netstat -ano | findstr :4001
taskkill /F /PID <process_id>
```

**Need to restart?**
```bash
npm run restart
```

---

That's it! 🎉
