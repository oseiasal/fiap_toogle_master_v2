#!/usr/bin/env python3
"""
Script de Automacao do AWS Secrets Manager - ToogleMaster
Descobre dinamicamente os endpoints do RDS, senhas geradas pela AWS,
Redis, SQS e atualiza os 5 segredos no Secrets Manager com URL-Encoding automatico.
"""

import subprocess
import json
import urllib.parse
import sys

REGION = "us-east-1"
ACCOUNT_ID = "665303623973"
ENV = "dev"
PREFIX = f"/tooglemaster/{ENV}"

def run_cmd(cmd):
    """Executa um comando e retorna a saida em texto"""
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        print(f"[ERRO] Erro ao executar comando: {' '.join(cmd)}")
        print(res.stderr)
        return None
    return res.stdout.strip()

def get_json(cmd):
    """Executa um comando e converte a saida para JSON"""
    out = run_cmd(cmd)
    if not out:
        return None
    try:
        return json.loads(out)
    except Exception as e:
        print(f"[ERRO] Erro ao decodificar JSON: {e}")
        return None

def main():
    print("=" * 60)
    print(" TOOGLEMASTER - ATUALIZADOR DO AWS SECRETS MANAGER")
    print("=" * 60)

    # 1. Obter detalhes das instancias RDS (Endpoints e ARNs de Secrets)
    print("\n[1/4] Buscando instancias RDS na AWS...")
    rds_data = get_json([
        "aws", "rds", "describe-db-instances",
        "--region", REGION,
        "--output", "json"
    ])

    if not rds_data or "DBInstances" not in rds_data:
        print("[ERRO] Nao foi possivel listar instancias RDS.")
        sys.exit(1)

    db_map = {}
    for db in rds_data["DBInstances"]:
        ident = db["DBInstanceIdentifier"]
        endpoint = db.get("Endpoint", {}).get("Address")
        secret_arn = db.get("MasterUserSecret", {}).get("SecretArn")
        db_map[ident] = {
            "endpoint": endpoint,
            "secret_arn": secret_arn
        }
        print(f"   * Encontrado RDS '{ident}' -> {endpoint}")

    # 2. Obter senhas do Secrets Manager nativo do RDS e aplicar URL-Encoding
    print("\n[2/4] Obtendo senhas mestras do RDS e aplicando URL-Encoding...")
    passwords = {}
    raw_passwords = {}
    for ident, info in db_map.items():
        if not info["secret_arn"]:
            print(f"[AVISO] RDS '{ident}' nao tem MasterUserSecret associado.")
            continue

        sec_data = get_json([
            "aws", "secretsmanager", "get-secret-value",
            "--secret-id", info["secret_arn"],
            "--query", "SecretString",
            "--output", "text",
            "--region", REGION
        ])

        if sec_data and "password" in sec_data:
            raw_pwd = sec_data["password"]
            raw_passwords[ident] = raw_pwd
            enc_pwd = urllib.parse.quote(raw_pwd, safe="")
            passwords[ident] = enc_pwd
            print(f"   * Senha obtida e codificada para '{ident}'")
        else:
            print(f"[ERRO] Falha ao obter senha para '{ident}'")

    # 3. Obter Endpoints de Redis e Fila SQS
    print("\n[3/4] Buscando Redis e Fila SQS...")
    redis_endpoint = run_cmd([
        "aws", "elasticache", "describe-cache-clusters",
        "--cache-cluster-id", "toogle-redis",
        "--show-cache-node-info",
        "--query", "CacheClusters[0].CacheNodes[0].Endpoint.Address",
        "--output", "text",
        "--region", REGION
    ])
    print(f"   * Redis Endpoint: {redis_endpoint}")

    sqs_url = run_cmd([
        "aws", "sqs", "get-queue-url",
        "--queue-name", "toogle-events",
        "--query", "QueueUrl",
        "--output", "text",
        "--region", REGION
    ])
    print(f"   * SQS Queue URL: {sqs_url}")

    # Montar Connection Strings
    auth_host = db_map.get("auth-db", {}).get("endpoint")
    auth_pwd = passwords.get("auth-db")
    auth_db_url = f"postgres://dbuser:{auth_pwd}@{auth_host}:5432/auth_db?sslmode=require"

    flag_host = db_map.get("main-db", {}).get("endpoint")
    flag_pwd = passwords.get("main-db")
    flag_db_url = f"postgres://dbuser:{flag_pwd}@{flag_host}:5432/flag_db?sslmode=require"

    target_host = db_map.get("targeting-db", {}).get("endpoint")
    target_pwd = passwords.get("targeting-db")
    target_db_url = f"postgres://dbuser:{target_pwd}@{target_host}:5432/targeting_db?sslmode=require"

    redis_url = f"redis://{redis_endpoint}:6379"

    # 4. Definir os 5 Segredos e Atualizar no Secrets Manager
    print("\n[4/4] Atualizando os 5 Segredos no AWS Secrets Manager...")

    secrets_to_update = {
        f"{PREFIX}/auth": {
            "DATABASE_URL": auth_db_url,
            "MASTER_KEY": "ToogleMasterSecret2026!"
        },
        f"{PREFIX}/flag": {
            "DATABASE_URL": flag_db_url
        },
        f"{PREFIX}/targeting": {
            "DATABASE_URL": target_db_url
        },
        f"{PREFIX}/evaluation": {
            "REDIS_URL": redis_url,
            "AWS_SQS_URL": sqs_url,
            "SERVICE_API_KEY": "tm_key_f54b81bc161a5b84c277ed954384ae950c87adb8c795892db4abfaef75aaacab"
        },
        f"{PREFIX}/analytics": {
            "AWS_SQS_URL": sqs_url
        }
    }

    for secret_id, secret_dict in secrets_to_update.items():
        secret_json_str = json.dumps(secret_dict)
        res = run_cmd([
            "aws", "secretsmanager", "put-secret-value",
            "--secret-id", secret_id,
            "--secret-string", secret_json_str,
            "--region", REGION
        ])
        if res:
            print(f"   [OK] Atualizado com sucesso: {secret_id}")
        else:
            print(f"   [FALHA] Falha ao atualizar: {secret_id}")

    print("\n" + "=" * 60)
    print(" TODOS OS SEGREDOS FORAM ATUALIZADOS COM SUCESSO!")
    print("=" * 60)

if __name__ == "__main__":
    main()

