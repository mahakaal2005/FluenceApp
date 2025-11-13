const { exec } = require('child_process');
const path = require('path');
const chalk = require('chalk');
const fs = require('fs');

// Service configuration (ports from .env files)
const services = [
    { name: 'Auth Service', port: 4001, dir: 'auth-service', displayName: '🔐 Auth Service' },
    { name: 'Cashback Service', port: 4002, dir: 'cashback-budget-service', displayName: '💰 Cashback Service' },
    { name: 'Merchant Service', port: 4003, dir: 'merchant-onboarding-service', displayName: '🏪 Merchant Service' },
    { name: 'Notification Service', port: 4004, dir: 'notification-service', displayName: '🔔 Notification Service' },
    { name: 'Points Service', port: 4005, dir: 'points-wallet-service', displayName: '⭐ Points Service' },
    { name: 'Referral Service', port: 4006, dir: 'referral-service', displayName: '🎁 Referral Service' },
    { name: 'Social Service', port: 4007, dir: 'social-features-service', displayName: '👥 Social Service' }
];

// Get backend directory path
const backendDir = path.resolve(__dirname, '../../Fluence-Backend-Private');

console.log(chalk.blue.bold('\n🚀 Starting Fluence Backend Services\n'));
console.log(chalk.gray('Backend directory:', backendDir));
console.log(chalk.gray('─'.repeat(70)));

// Check if backend directory exists
if (!fs.existsSync(backendDir)) {
    console.error(chalk.red('\n❌ Backend directory not found!'));
    console.error(chalk.yellow(`Expected location: ${backendDir}`));
    console.error(chalk.gray('\nPlease ensure Fluence-Backend-Private is in the parent directory.\n'));
    process.exit(1);
}

// Platform detection
const isWindows = process.platform === 'win32';

if (!isWindows) {
    console.error(chalk.red('\n❌ This script currently only supports Windows.'));
    console.error(chalk.yellow('For Linux/Mac, please use Docker or run services manually.\n'));
    process.exit(1);
}

// Start each service in a new terminal window
services.forEach((service, index) => {
    const servicePath = path.join(backendDir, service.dir);

    // Check if service directory exists
    if (!fs.existsSync(servicePath)) {
        console.log(chalk.red(`\n❌ [${index + 1}/${services.length}]`), chalk.white(`${service.name} directory not found`));
        console.log(chalk.gray(`    Expected: ${servicePath}`));
        return;
    }

    console.log(chalk.cyan(`\n✓ [${index + 1}/${services.length}]`), chalk.white(`Starting ${service.displayName}...`));
    console.log(chalk.gray(`    Directory: ${service.dir}`));
    console.log(chalk.gray(`    Port: ${service.port}`));

    // Windows command to start in new terminal with custom title
    // Using cmd /k to keep window open, and title command for window name
    const command = `start "${service.displayName} - Port ${service.port}" cmd /k "cd /d ${servicePath} && echo. && echo ========================================== && echo ${service.displayName} && echo Port: ${service.port} && echo ========================================== && echo. && npm start"`;

    exec(command, (error) => {
        if (error) {
            console.error(chalk.red(`\n❌ Error starting ${service.name}:`), error.message);
        }
    });
});

console.log(chalk.green.bold('\n\n✅ All services are starting in separate terminal windows!\n'));
console.log(chalk.gray('─'.repeat(70)));

console.log(chalk.blue('\n📋 Service Information:\n'));
services.forEach(service => {
    console.log(chalk.white(`   ${service.displayName.padEnd(30)}`), chalk.cyan(`http://localhost:${service.port}`));
});

console.log(chalk.yellow('\n\n💡 Important Notes:\n'));
console.log(chalk.gray('   • Each service runs in its own terminal window'));
console.log(chalk.gray('   • Window titles show service name and port'));
console.log(chalk.gray('   • Close individual windows to stop specific services'));
console.log(chalk.gray('   • Or run "npm run stop" to stop all services at once'));
console.log(chalk.gray('   • Run "npm run status" to check service health'));

console.log(chalk.cyan('\n\n⏳ Waiting 15 seconds for services to initialize...\n'));

// Wait for services to start, then check health
setTimeout(() => {
    console.log(chalk.blue('🔍 Checking service health...\n'));

    // Run the check-services script
    const checkProcess = require('child_process').spawn('node', ['scripts/check-services.js'], {
        cwd: path.resolve(__dirname, '..'),
        stdio: 'inherit',
        shell: true
    });

    checkProcess.on('exit', () => {
        console.log(chalk.gray('\n─'.repeat(70)));
        console.log(chalk.green.bold('\n🎉 Setup Complete!\n'));
        console.log(chalk.gray('You can now run your Flutter app from Android Studio.\n'));
    });
}, 15000);
