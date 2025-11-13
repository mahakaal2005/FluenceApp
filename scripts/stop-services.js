const { exec } = require('child_process');
const chalk = require('chalk');

console.log(chalk.blue.bold('\n🛑 Stopping Fluence Backend Services\n'));
console.log(chalk.gray('─'.repeat(70)));

// Platform-specific commands to kill Node.js processes
const isWindows = process.platform === 'win32';

if (!isWindows) {
    console.log(chalk.yellow('\n⚠️  Non-Windows platform detected'));
    console.log(chalk.gray('Using pkill command...\n'));
}

const killCommand = isWindows
    ? 'taskkill /F /IM node.exe'
    : 'pkill -f node';

console.log(chalk.cyan('🔍 Finding and stopping Node.js processes...\n'));

exec(killCommand, (error) => {
    if (error) {
        if (error.code === 128 || error.message.includes('not found') || error.message.includes('not running')) {
            console.log(chalk.yellow('⚠️  No Node.js services were running'));
        } else {
            console.error(chalk.red('❌ Error stopping services:'), error.message);
        }
    } else {
        console.log(chalk.green('✅ All Node.js services stopped successfully'));

        if (isWindows) {
            console.log(chalk.gray('\n💡 All terminal windows have been closed'));
        }
    }

    console.log(chalk.gray('\n─'.repeat(70)));
    console.log(chalk.blue('\n📋 All backend microservices have been terminated\n'));
    console.log(chalk.yellow('💡 Tip: Run "npm start" to start services again\n'));
});
