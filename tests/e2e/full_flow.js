const axios = require('axios');

/**
 * Toogle Master E2E Test Suite
 * 
 * Este teste valida o fluxo completo entre os microserviços.
 * Pode ser configurado via variáveis de ambiente para testar Docker, K8s, HML ou PROD.
 */

// Configurações de ambiente (podem ser sobrescritas por variáveis de ambiente)
const config = {
    auth_host: process.env.AUTH_HOST || 'http://localhost:8001',
    flag_host: process.env.FLAG_HOST || 'http://localhost:8002',
    targeting_host: process.env.TARGETING_HOST || 'http://localhost:8003',
    evaluation_host: process.env.EVALUATION_HOST || 'http://localhost:8004',
    analytics_host: process.env.ANALYTICS_HOST || 'http://localhost:8005',
    master_key: process.env.MASTER_KEY || 'sua_chave_mestra_aqui'
};

const testState = {
    apiKey: '',
    testFlagName: `e2e_test_flag_${Date.now()}`
};

async function runTests() {
    console.log('🚀 Iniciando Testes E2E - Toogle Master');
    console.log(`📍 Alvos: Auth(${config.auth_host}), Flag(${config.flag_host}), Evaluation(${config.evaluation_host})\n`);

    try {
        // 1. Health Checks
        console.log('--- Passo 1: Health Checks ---');
        const services = ['auth', 'flag', 'targeting', 'evaluation', 'analytics'];
        for (const s of services) {
            const resp = await axios.get(`${config[`${s}_host`]}/health`);
            if (resp.data.status === 'ok') {
                console.log(`✅ ${s}-service está saudável.`);
            } else {
                throw new Error(`${s}-service retornou status inválido.`);
            }
        }

        // 2. Criar Nova API Key
        console.log('\n--- Passo 2: Gestão de Acesso ---');
        const keyResp = await axios.post(`${config.auth_host}/admin/keys`, 
            { name: "E2E Test Key" },
            { headers: { 'Authorization': `Bearer ${config.master_key}` } }
        );
        testState.apiKey = keyResp.data.key;
        console.log(`✅ API Key criada com sucesso.`);

        // 3. Criar Feature Flag
        console.log('\n--- Passo 3: Criar Feature Flag ---');
        await axios.post(`${config.flag_host}/flags`, 
            { 
                name: testState.testFlagName, 
                description: "Flag para teste E2E",
                is_enabled: true 
            },
            { headers: { 'Authorization': `Bearer ${testState.apiKey}` } }
        );
        console.log(`✅ Flag '${testState.testFlagName}' criada.`);

        // 4. Configurar Regra de Targeting (100% para garantir resultado 'true')
        console.log('\n--- Passo 4: Configurar Regra de Targeting ---');
        await axios.post(`${config.targeting_host}/rules`, 
            { 
                flag_name: testState.testFlagName, 
                is_enabled: true,
                rules: { type: "PERCENTAGE", value: 100 } 
            },
            { headers: { 'Authorization': `Bearer ${testState.apiKey}` } }
        );
        console.log(`✅ Regra de 100% configurada.`);

        // 5. Avaliação da Flag (O grande final)
        console.log('\n--- Passo 5: Avaliação Final ---');
        // Adicionamos um pequeno delay para garantir que o Evaluation Service não pegue cache vazio se o Redis estiver lento
        await new Promise(resolve => setTimeout(resolve, 1000));

        const evalResp = await axios.get(`${config.evaluation_host}/evaluate`, {
            params: { flag_name: testState.testFlagName, user_id: 'e2e_user' },
            headers: { 'Authorization': `Bearer ${testState.apiKey}` }
        });

        if (evalResp.data.result === true) {
            console.log(`✅ Avaliação bem sucedida! Resultado: TRUE`);
        } else {
            throw new Error(`Avaliação falhou: Esperado TRUE, recebido ${evalResp.data.result}`);
        }

        console.log('\n====================================================');
        console.log('🎉 TESTES E2E CONCLUÍDOS COM SUCESSO!');
        console.log('====================================================');

    } catch (error) {
        console.error('\n❌ ERRO DURANTE OS TESTES E2E:');
        if (error.response) {
            console.error(`Status: ${error.response.status}`);
            console.error(`Data: ${JSON.stringify(error.response.data)}`);
        } else {
            console.error(error.message);
        }
        process.exit(1);
    }
}

runTests();
