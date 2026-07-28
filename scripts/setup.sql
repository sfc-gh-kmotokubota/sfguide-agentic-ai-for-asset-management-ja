-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
-- Licensed under the Apache License, Version 2.0

-- ============================================================================
-- SAM Demo — インフラストラクチャセットアップ（Gitワークスペース前提条件）
-- ============================================================================
-- このスクリプトは一度だけ実行してください。
-- データベース、スキーマ、ロール、権限を作成し、Cortex機能を有効化します。
--
-- このスクリプト実行後の次のステップ:
--   1. Projects > Workspaces で新しいワークスペースを作成
--   2. 「Gitリポジトリから」を選択
--      Repository URL: https://github.com/sfc-gh-kmotokubota/sfguide-agentic-ai-for-asset-management-ja.git
--   3. python/workspace_main.py を開く
--   4. ノートブックサービスを接続（Python 3.11+、任意のコンピュートプール）
--      Artifact repositories: SNOWFLAKE.SNOWPARK.PYPI_SHARED_REPOSITORY（任意）
--   5. ターミナルで実行: pip install -r "$PWD/requirements.txt"、その後カーネル再起動
--   6. 「Run」をクリック — 完全なセットアップには約15〜20分かかります
-- 必要ロール: ACCOUNTADMIN
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- クエリタグを設定（追跡用）
ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"agentic_ai_for_asset_management","version":{"major":2,"minor":0},"attributes":{"is_quickstart":1,"source":"sql"}}';

-- ============================================================================
-- SECTION 1: ウェアハウス
-- ============================================================================

-- データ生成・エージェント実行用ウェアハウス
CREATE WAREHOUSE IF NOT EXISTS SAM_DEMO_EXECUTION_WH
    WAREHOUSE_SIZE = 'LARGE'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'SAMデモ データ生成・エージェント実行用ウェアハウス';

-- Cortex Searchサービス用ウェアハウス
CREATE WAREHOUSE IF NOT EXISTS SAM_DEMO_CORTEX_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'SAMデモ Cortex Searchサービス用ウェアハウス';

USE WAREHOUSE SAM_DEMO_EXECUTION_WH;

-- ============================================================================
-- SECTION 2: マーケットプレイスデータ（Snowflake Public Data - 無料）
-- ============================================================================

-- 財務データ共有を自動インストール（14,000以上の証券、SEC提出書類など）
CALL SYSTEM$REQUEST_LISTING_AND_WAIT('GZTSZ290BV255');
CALL SYSTEM$ACCEPT_LEGAL_TERMS('DATA_EXCHANGE_LISTING', 'GZTSZ290BV255');
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_PUBLIC_DATA_FREE FROM LISTING 'GZTSZ290BV255';

-- ============================================================================
-- SECTION 3: データベースとスキーマ
-- ============================================================================

CREATE DATABASE IF NOT EXISTS SAM_DEMO
    COMMENT = 'Simulated Asset Management (SAM) - エージェント型AIデモデータベース';

CREATE SCHEMA IF NOT EXISTS SAM_DEMO.RAW
    COMMENT = '生データレイヤー - 外部データと未処理ドキュメント';

CREATE SCHEMA IF NOT EXISTS SAM_DEMO.CURATED
    COMMENT = 'キュレートデータレイヤー - クリーンで検証済みのビジネスデータ';

CREATE SCHEMA IF NOT EXISTS SAM_DEMO.AI
    COMMENT = 'AIコンポーネント - セマンティックビュー、検索サービス、エージェント、ツール';

CREATE SCHEMA IF NOT EXISTS SAM_DEMO.MARKET_DATA
    COMMENT = 'マーケットデータレイヤー - 外部ソースからの実際の市場データ';

CREATE SCHEMA IF NOT EXISTS SAM_DEMO.ML
    COMMENT = '機械学習モデル、予測、フィーチャーストア';

-- ============================================================================
-- SECTION 4: ロールと権限
-- ============================================================================

CREATE ROLE IF NOT EXISTS SAM_DEMO_ROLE
    COMMENT = 'SAMデモ操作専用ロール';

-- データベースレベル権限
GRANT USAGE ON DATABASE SAM_DEMO TO ROLE SAM_DEMO_ROLE;
GRANT CREATE SCHEMA ON DATABASE SAM_DEMO TO ROLE SAM_DEMO_ROLE;

-- スキーマレベル権限（テーブル、ビュー、プロシージャ、関数、ステージなどすべてのオブジェクトタイプを含む）
GRANT ALL PRIVILEGES ON SCHEMA SAM_DEMO.RAW TO ROLE SAM_DEMO_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA SAM_DEMO.CURATED TO ROLE SAM_DEMO_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA SAM_DEMO.AI TO ROLE SAM_DEMO_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA SAM_DEMO.MARKET_DATA TO ROLE SAM_DEMO_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA SAM_DEMO.ML TO ROLE SAM_DEMO_ROLE;

-- ロール階層
GRANT ROLE SAM_DEMO_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE SAM_DEMO_ROLE TO ROLE SYSADMIN;
SET current_username = CURRENT_USER();
GRANT ROLE SAM_DEMO_ROLE TO USER IDENTIFIER($current_username);

-- ウェアハウス権限
GRANT USAGE ON WAREHOUSE SAM_DEMO_EXECUTION_WH TO ROLE SAM_DEMO_ROLE;
GRANT OPERATE ON WAREHOUSE SAM_DEMO_EXECUTION_WH TO ROLE SAM_DEMO_ROLE;
GRANT MODIFY ON WAREHOUSE SAM_DEMO_EXECUTION_WH TO ROLE SAM_DEMO_ROLE;
GRANT USAGE ON WAREHOUSE SAM_DEMO_CORTEX_WH TO ROLE SAM_DEMO_ROLE;
GRANT OPERATE ON WAREHOUSE SAM_DEMO_CORTEX_WH TO ROLE SAM_DEMO_ROLE;
GRANT MODIFY ON WAREHOUSE SAM_DEMO_CORTEX_WH TO ROLE SAM_DEMO_ROLE;

-- マーケットプレイスデータアクセス
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_PUBLIC_DATA_FREE TO ROLE SAM_DEMO_ROLE;

-- ============================================================================
-- SECTION 5: Cortex AI権限
-- ============================================================================

-- AIコンポーネント作成権限
GRANT CREATE AGENT ON SCHEMA SAM_DEMO.AI TO ROLE SAM_DEMO_ROLE;
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA SAM_DEMO.AI TO ROLE SAM_DEMO_ROLE;
GRANT CREATE SEMANTIC VIEW ON SCHEMA SAM_DEMO.AI TO ROLE SAM_DEMO_ROLE;

-- アカウントレベルのCortex権限（LLM関数に必要）
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE SAM_DEMO_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SAM_DEMO_ROLE;

-- クロスリージョンCortexを有効化（Cortex非対応リージョンのアカウントに必要）
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

-- ============================================================================
-- SECTION 6: Task権限（スケジューリング）
-- ============================================================================
-- 以下のために必要:
--   - ノートブックをスケジュールタスクとしてデプロイ
--   - ストリームトリガーによるインクリメンタルデータパイプライン
--   - 定期的なエージェント操作（朝のブリーフィング、シグナル抽出）

GRANT EXECUTE TASK ON ACCOUNT TO ROLE SAM_DEMO_ROLE;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE SAM_DEMO_ROLE;
GRANT CREATE TASK ON SCHEMA SAM_DEMO.RAW TO ROLE SAM_DEMO_ROLE;
GRANT CREATE TASK ON SCHEMA SAM_DEMO.CURATED TO ROLE SAM_DEMO_ROLE;
GRANT CREATE TASK ON SCHEMA SAM_DEMO.AI TO ROLE SAM_DEMO_ROLE;
GRANT CREATE TASK ON SCHEMA SAM_DEMO.MARKET_DATA TO ROLE SAM_DEMO_ROLE;
GRANT CREATE TASK ON SCHEMA SAM_DEMO.ML TO ROLE SAM_DEMO_ROLE;

-- ============================================================================
-- SECTION 7: Snowflake Intelligence
-- ============================================================================

CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT;
GRANT CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT TO ROLE SAM_DEMO_ROLE;
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE SAM_DEMO_ROLE;
GRANT MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE SAM_DEMO_ROLE;
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE PUBLIC;

-- ============================================================================
-- 完了 — 次のステップ
-- ============================================================================
-- 1. Projects > Workspaces を開く
-- 2. 「+」→「Gitリポジトリから」をクリック
--    Repository URL: https://github.com/sfc-gh-kmotokubota/sfguide-agentic-ai-for-asset-management-ja.git
-- 3. python/workspace_main.py を開く
-- 4. ノートブックサービスを接続（Python 3.11+、任意のコンピュートプール）
-- 5. ターミナルで実行: pip install -r "$PWD/requirements.txt"、その後カーネル再起動
-- 6. 「Run」をクリック — セットアップは約15〜20分かかります
-- 完了後:
--   - AI & ML > Snowflake CoWork でエージェントを操作
--   - MLワークフローのデモにノートブックを活用
-- ============================================================================

SELECT 'インフラセットアップ完了。Gitワークスペースを開いてpython/workspace_main.pyを実行してください。' AS status;
