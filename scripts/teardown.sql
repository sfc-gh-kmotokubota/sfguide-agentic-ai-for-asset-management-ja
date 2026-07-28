-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0

-- ============================================================================
-- SAM Demo - クリーンアップスクリプト
-- ============================================================================
-- このスクリプトはSnowflakeアカウントからすべてのSAMデモコンポーネントを削除します。
-- 警告: すべてのデータとAIコンポーネントが完全に削除されます！
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- Step 1: Cortex Agentの削除
-- ============================================================================
-- 注意: エージェントをドロップするとSnowflake Intelligenceから自動的に登録解除されます

DROP AGENT IF EXISTS SAM_DEMO.AI.AM_PORTFOLIO_COPILOT;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_RESEARCH_COPILOT;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_THEMATIC_MACRO_ADVISOR;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_ESG_GUARDIAN;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_COMPLIANCE_ADVISOR;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_SALES_ADVISOR;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_QUANT_ANALYST;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_MIDDLE_OFFICE_COPILOT;
DROP AGENT IF EXISTS SAM_DEMO.AI.AM_EXECUTIVE_COPILOT;

-- ============================================================================
-- Step 2: Cortex Searchサービスの削除（16サービス）
-- ============================================================================

DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_BROKER_RESEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_COMPANY_EVENTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_PRESS_RELEASES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_NGO_REPORTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_ENGAGEMENT_NOTES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_POLICY_DOCS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_SALES_TEMPLATES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_PHILOSOPHY_DOCS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_REPORT_TEMPLATES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_MACRO_EVENTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_CUSTODIAN_REPORTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_RECONCILIATION_NOTES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_SSI_DOCUMENTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_OPS_PROCEDURES;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_STRATEGY_DOCUMENTS;
DROP CORTEX SEARCH SERVICE IF EXISTS SAM_DEMO.AI.SAM_REAL_SEC_FILINGS;

-- ============================================================================
-- Step 3: セマンティックビューの削除（10ビュー）
-- ============================================================================

DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_ANALYST_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_IMPLEMENTATION_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_SUPPLY_CHAIN_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_MIDDLE_OFFICE_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_COMPLIANCE_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_EXECUTIVE_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_FUNDAMENTALS_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_STOCK_PRICES_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_SEC_FINANCIALS_VIEW;
DROP SEMANTIC VIEW IF EXISTS SAM_DEMO.AI.SAM_SEC_SEGMENTS_VIEW;

-- ============================================================================
-- Step 4: データベースの削除（すべてのテーブル、ビュー、プロシージャ、ステージを含む）
-- ============================================================================

DROP DATABASE IF EXISTS SAM_DEMO CASCADE;

-- ============================================================================
-- Step 5: ウェアハウスの削除
-- ============================================================================

DROP WAREHOUSE IF EXISTS SAM_DEMO_EXECUTION_WH;
DROP WAREHOUSE IF EXISTS SAM_DEMO_CORTEX_WH;

-- 旧バージョンとの互換性（存在する場合のみ削除）
DROP WAREHOUSE IF EXISTS SAM_DEMO_WH;

-- ============================================================================
-- Step 6: ロールの削除
-- ============================================================================

REVOKE ROLE SAM_DEMO_ROLE FROM ROLE ACCOUNTADMIN;
REVOKE ROLE SAM_DEMO_ROLE FROM ROLE SYSADMIN;
DROP ROLE IF EXISTS SAM_DEMO_ROLE;

-- ============================================================================
-- 完了
-- ============================================================================

SELECT 'クリーンアップ完了 - すべてのSAMデモコンポーネントが削除されました' AS status;
