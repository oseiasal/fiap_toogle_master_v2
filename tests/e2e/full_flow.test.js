const axios = require('axios');

/**
 * Toogle Master E2E Jest Suite
 */

const config = {
    auth_host: process.env.AUTH_HOST || 'http://localhost:8001',
    flag_host: process.env.FLAG_HOST || 'http://localhost:8002',
    targeting_host: process.env.TARGETING_HOST || 'http://localhost:8003',
    evaluation_host: process.env.EVALUATION_HOST || 'http://localhost:8004',
    analytics_host: process.env.ANALYTICS_HOST || 'http://localhost:8005',
    master_key: process.env.MASTER_KEY || 'sua_chave_mestra_aqui'
};

describe('Toogle Master Full Flow E2E', () => {
    let apiKey = '';
    const testFlagName = `jest_e2e_flag_${Date.now()}`;

    // 1. Validar Saúde de todos os serviços antes de começar
    test('All services should be healthy', async () => {
        const services = ['auth', 'flag', 'targeting', 'evaluation', 'analytics'];
        for (const s of services) {
            const resp = await axios.get(`${config[`${s}_host`]}/health`);
            expect(resp.status).toBe(200);
            expect(resp.data.status).toBe('ok');
        }
    });

    // 2. Criar API Key
    test('Should create a new API Key', async () => {
        const resp = await axios.post(`${config.auth_host}/admin/keys`, 
            { name: "Jest E2E Test Key" },
            { headers: { 'Authorization': `Bearer ${config.master_key}` } }
        );
        expect(resp.status).toBe(201);
        expect(resp.data.key).toBeDefined();
        apiKey = resp.data.key;
    });

    // 3. Criar Feature Flag
    test('Should create a new Feature Flag', async () => {
        const resp = await axios.post(`${config.flag_host}/flags`, 
            { 
                name: testFlagName, 
                description: "Flag para teste Jest E2E",
                is_enabled: true 
            },
            { headers: { 'Authorization': `Bearer ${apiKey}` } }
        );
        expect(resp.status).toBe(201);
        expect(resp.data.name).toBe(testFlagName);
    });

    // 4. Configurar Regra de Targeting (100%)
    test('Should configure a 100% targeting rule', async () => {
        const resp = await axios.post(`${config.targeting_host}/rules`, 
            { 
                flag_name: testFlagName, 
                is_enabled: true,
                rules: { type: "PERCENTAGE", value: 100 } 
            },
            { headers: { 'Authorization': `Bearer ${apiKey}` } }
        );
        expect(resp.status).toBe(201);
        expect(resp.data.flag_name).toBe(testFlagName);
    });

    // 5. Avaliar a Flag e receber TRUE
    test('Should evaluate flag to TRUE for any user (100% rule)', async () => {
        // Delay opcional para propagação/cache (1s)
        await new Promise(resolve => setTimeout(resolve, 1000));

        const resp = await axios.get(`${config.evaluation_host}/evaluate`, {
            params: { flag_name: testFlagName, user_id: 'jest_user_123' },
            headers: { 'Authorization': `Bearer ${apiKey}` }
        });

        expect(resp.status).toBe(200);
        expect(resp.data.result).toBe(true);
        expect(resp.data.flag_name).toBe(testFlagName);
    });

    // Cleanup: Deletar a flag criada para manter o banco limpo
    afterAll(async () => {
        if (apiKey && testFlagName) {
            try {
                // Deleta a regra primeiro (se necessário dependendo da sua FK)
                await axios.delete(`${config.targeting_host}/rules/${testFlagName}`, {
                    headers: { 'Authorization': `Bearer ${apiKey}` }
                });
                // Deleta a flag
                await axios.delete(`${config.flag_host}/flags/${testFlagName}`, {
                    headers: { 'Authorization': `Bearer ${apiKey}` }
                });
            } catch (e) {
                console.warn('Cleanup failed (expected if DELETE not implemented):', e.message);
            }
        }
    });
});
