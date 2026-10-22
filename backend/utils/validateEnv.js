/**
 * Environment Variable Validator
 * Ensures all required environment variables are present on startup
 */

const requiredEnvVars = [
    'MONGO_URI',
    'PORT',
    'NODE_ENV',
    'AI_SERVICE_URL',
    'JWT_SECRET',
    'JWT_EXPIRE'
];

const validateEnv = () => {
    const missing = [];

    requiredEnvVars.forEach(varName => {
        if (!process.env[varName]) {
            missing.push(varName);
        }
    });

    if (missing.length > 0) {
        console.error('❌ Missing required environment variables:');
        missing.forEach(varName => {
            console.error(`   - ${varName}`);
        });
        console.error('\nPlease check your .env file and ensure all required variables are set.');
        console.error('See .env.example for reference.\n');
        process.exit(1);
    }

    // Validate JWT_SECRET is not the default placeholder
    if (process.env.JWT_SECRET === 'your_super_secret_jwt_key_change_in_production_123456789' ||
        process.env.JWT_SECRET.length < 32) {
        console.warn('⚠️  WARNING: JWT_SECRET appears to be weak or default!');
        console.warn('   For production, use a strong random secret (64+ characters).');
        console.warn('   Generate one with: node -e "console.log(require(\'crypto\').randomBytes(64).toString(\'hex\'))"\n');
    }

    console.log('✅ All required environment variables are set');
};

module.exports = validateEnv;
