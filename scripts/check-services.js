const http = require('http');
const chalk = require('chalk');

// Service configuration (ports from .env files)
const services = [
    { name: 'Auth Service', port: 4001 },
    { name: 'Cashback Service', port: 4002 },
    { name: 'Merchant Service', port: 4003 },
    { name: 'Notification Service', port: 4004 },
    { name: 'Points Service', port: 4005 },
    { name: 'Referral Service', port: 4006 },
    { name: 'Social Service', port: 4007 }
];

console.log(chalk.blue.bold('\n🔍 Checking Service Health\n'));
console.log(chalk.gray('─'.repeat(50)));

// Check each service
const checkService = (service) => {
    return new Promise((resolve) => {
        const options = {
            hostname: 'localhost',
            port: service.port,
            path: '/health',
            method: 'GET',
            timeout: 3000
        };

        const req = http.request(options, (res) => {
            if (res.statusCode === 200) {
                console.log(chalk.green('✅'), chalk.white(service.name.padEnd(25)), chalk.gray(`http://localhost:${service.port}`));
                resolve(true);
            } else {
                console.log(chalk.red('❌'), chalk.white(service.name.padEnd(25)), chalk.gray(`http://localhost:${service.port}`), chalk.yellow(`(Status: ${res.statusCode})`));
                resolve(false);
            }
        });

        req.on('error', () => {
            console.log(chalk.red('❌'), chalk.white(service.name.padEnd(25)), chalk.gray(`http://localhost:${service.port}`), chalk.yellow('(Not running)'));
            resolve(false);
        });

        req.on('timeout', () => {
            req.destroy();
            console.log(chalk.red('❌'), chalk.white(service.name.padEnd(25)), chalk.gray(`http://localhost:${service.port}`), chalk.yellow('(Timeout)'));
            resolve(false);
        });

        req.end();
    });
};

// Check all services
(async () => {
    const results = await Promise.all(services.map(checkService));

    const runningCount = results.filter(r => r).length;
    const totalCount = services.length;

    console.log(chalk.gray('\n─'.repeat(50)));

    if (runningCount === totalCount) {
        console.log(chalk.green.bold(`\n✅ All ${totalCount} services are running!\n`));
    } else if (runningCount > 0) {
        console.log(chalk.yellow.bold(`\n⚠️  ${runningCount}/${totalCount} services are running\n`));
    } else {
        console.log(chalk.red.bold(`\n❌ No services are running\n`));
        console.log(chalk.gray('💡 Run "npm start" to start all services\n'));
    }
})();
