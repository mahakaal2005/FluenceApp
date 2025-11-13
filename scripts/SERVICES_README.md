# 🚀 Fluence Backend Services - Quick Start

## Installation

First, install the dependencies:
```bash
cd FluenceApp
npm install
```

## Commands

### Start All Services
```bash
npm start
```
This will start all 7 microservices **in separate terminal windows** with custom titles.

Each window will show:
- 🔐 Auth Service - Port 4001
- 💰 Cashback Service - Port 4002
- 🏪 Merchant Service - Port 4003
- 🔔 Notification Service - Port 4004
- ⭐ Points Service - Port 4005
- 🎁 Referral Service - Port 4006
- 👥 Social Service - Port 4007

### Stop All Services
```bash
npm run stop
```
This will stop all running Node.js services and close all terminal windows.

### Check Service Status
```bash
npm run status
```
This will check if all services are running and healthy.

### Restart All Services
```bash
npm run restart
```
This will stop and then start all services.

---

## Service Ports

| Service | Port | URL |
|---------|------|-----|
| Auth Service | 4001 | http://localhost:4001 |
| Cashback Service | 4002 | http://localhost:4002 |
| Merchant Service | 4003 | http://localhost:4003 |
| Notification Service | 4004 | http://localhost:4004 |
| Points Service | 4005 | http://localhost:4005 |
| Referral Service | 4006 | http://localhost:4006 |
| Social Service | 4007 | http://localhost:4007 |

---

## Health Check Endpoints

All services have a `/health` endpoint:
- http://localhost:4001/health
- http://localhost:4002/health
- http://localhost:4003/health
- http://localhost:4004/health
- http://localhost:4005/health
- http://localhost:4006/health
- http://localhost:4007/health

---

## Running the Flutter App

### Android/Mobile
Open the project in Android Studio and run normally.

### Web
```bash
flutter run -d chrome
```

---

## Troubleshooting

### Port Already in Use
If you get port conflicts, check what's using the ports:
```bash
# Windows
netstat -ano | findstr :4001

# Kill the process
taskkill /F /PID <process_id>
```

### Services Not Starting
1. Make sure you're in the FluenceApp directory
2. Check that Fluence-Backend-Private is in the parent directory
3. Verify each service has node_modules installed:
   ```bash
   cd ../Fluence-Backend-Private/auth-service
   npm install
   ```

### Check Logs
Each service logs to its own console window. Check individual windows for errors.

---

## Development Tips

- Each service auto-restarts on file changes (nodemon)
- Press Ctrl+C in the main terminal to stop all services
- Use `npm run status` to quickly check if services are running
- Services start in parallel for faster startup

---

**Happy Coding! 🚀**
