# アセットマネジメント向けエージェント型AI

Snowflake CoWork、Cortex Agents、Cortex Analyst、Cortex Searchを使用して、投資管理向けの完全なマルチエージェントAIシステムを構築します。

## 構成コンポーネント

| コンポーネント | 数量 | 説明 |
|--------------|------|------|
| **Cortex Agents** | 8 | ポートフォリオ、リサーチ、セールス、エグゼクティブ、リスク＆コンプライアンス、オペレーション、プライベートクレジット、プライベートエクイティ |
| **セマンティックビュー** | 10 | 構造化データクエリ用Cortex Analystモデル |
| **検索サービス** | 16 | ブローカーリサーチ、決算書類、SEC提出書類にまたがるドキュメント検索 |
| **エージェントスキル** | 36 | 特化型ワークフロー（バックテスト、モンテカルロ、メモ生成など） |
| **データテーブル** | 60以上 | 14,000以上のSEC提出書類からの実際の証券＋生成ポートフォリオ |
| **MLノートブック** | 3 | ファクター探索、マーケットレジーム検出、クレジットリスクモデリング |

---

## クイックスタート（約15〜20分）

### ステップ1: Gitワークスペースの作成

1. **Projects > Workspaces** に移動
2. **「+」** → **「Gitリポジトリから」** をクリック
3. Repository URL: `https://github.com/sfc-gh-kmotokubota/sfguide-agentic-ai-for-asset-management-ja.git`
4. 認証: パブリックリポジトリ（認証不要）
5. ワークスペースに名前を付ける（例：「SAM Demo JA」）

### ステップ2: インフラセットアップ（約2分）

ワークスペース内で [`scripts/setup.sql`](scripts/setup.sql) を開いて実行します。これにより以下が作成されます：
- 2つのウェアハウス（`SAM_DEMO_EXECUTION_WH` と `SAM_DEMO_CORTEX_WH`）
- すべてのスキーマを持つ `SAM_DEMO` データベース
- 必要な権限を持つ `SAM_DEMO_ROLE`（タスク実行を含む）
- マーケットプレイスデータ共有（Snowflake Public Data - 無料）の自動インストール
- Cortex AI有効化とSnowflake Intelligence

### ステップ3: セットアップの実行（約15〜20分）

1. ワークスペースで `python/workspace_main.py` を開く
2. プロンプトが表示されたら **ノートブックサービス** を接続：
   - Pythonバージョン: 3.11以上
   - コンピュートプール: 利用可能な任意のプール
   - Artifact repositories（任意）: SNOWFLAKE.SNOWPARK.PYPI_SHARED_REPOSITORY
3. ターミナルを開いて実行: `pip install -r "$PWD/requirements.txt"`
4. カーネルを再起動
5. **「Run」** をクリック

スクリプトが以下を順次構築します：
- 実際の証券データからのディメンション・ファクトテーブル
- Snowflake Marketplace からのマーケットデータ（SEC提出書類、価格、セグメント）
- 70以上のテンプレートからのドキュメントコーパス
- セマンティックビュー、検索サービス、ツール
- 36のスキルを持つ8つのCortex Agent

### ステップ4: エージェントの使用

1. **AI & ML > Snowflake CoWork** に移動
2. 任意のエージェントを選択
3. 質問を開始！

---

## エージェント一覧

| エージェント | ロール | 主な機能 |
|------------|--------|---------|
| **Portfolio Copilot** | ポートフォリオマネージャー | 保有銘柄、アトリビューション、リスク、バックテスト、モンテカルロ、パフォーマンスナラティブ |
| **Research Copilot** | リサーチアナリスト | 株式リサーチレポート、決算インテリジェンス、競合分析、投資メモ |
| **Sales Advisor** | クライアントリレーションズ | ミーティングブリーフ、クライアントレター、RFP対応、フロー分析 |
| **Executive Command Center** | 経営幹部 | 会社KPI、戦略ランキング、競合インテリジェンス、M&Aシミュレーション |
| **Risk & Compliance** | リスクオフィサー | ポジション制限、マンデート違反、ESG監視、規制調査 |
| **Operations Copilot** | ミドルオフィス | 決済追跡、照合、NAV、コーポレートアクション |
| **Private Credit Copilot** | クレジットPM | コベナンツ監視、ディールパイプライン、借り手財務状況 |
| **Private Equity Copilot** | PE PM | ディールソーシング、デューデリジェンス、バリュークリエーション追跡 |

---

## デモシナリオ

各エージェントには、ステップバイステップの会話フローを含む包括的なデモシナリオがあります：

- [ポートフォリオマネジメントシナリオ](docs/demo_scenarios_portfolio_management.md)
- [リサーチアナリストシナリオ](docs/demo_scenarios_research.md)
- [クライアントアドバイザリーシナリオ](docs/demo_scenarios_client_advisory.md)
- [リスク＆コンプライアンスシナリオ](docs/demo_scenarios_risk_compliance.md)
- [オペレーションシナリオ](docs/demo_scenarios_operations.md)
- [エグゼクティブリーダーシップシナリオ](docs/demo_scenarios_executive_leadership.md)
- [プライベートエクイティシナリオ](docs/demo_scenarios_private_equity.md)
- [プライベートクレジットシナリオ](docs/demo_scenarios_private_credit.md)
- [MLノートブックシナリオ](docs/demo_scenarios_ml.md)
- [全シナリオ概要](docs/demo_scenarios.md)

---

## プロジェクト構造

```
python/
├── workspace_main.py       <- ワークスペースエントリーポイント（「Run」をクリック）
├── main.py                 <- CLIエントリーポイント（ローカル開発用）
├── config.py               <- 中央設定
├── ai/
│   ├── agents/             <- 8つのエージェント定義
│   ├── tools/              <- UDF/SP（バックテスト、モンテカルロ、PDF生成など）
│   ├── builder.py          <- AIオーケストレーション
│   ├── cortex_search.py    <- 検索サービス作成
│   └── semantic_views.py   <- セマンティックビュー作成
├── data/
│   ├── structured.py       <- ディメンション/ファクト生成
│   ├── market_data.py      <- マーケットプレイスデータ統合
│   ├── unstructured.py     <- ドキュメントコーパス生成
│   └── pipelines.py        <- ストリーム/タスクパイプラインインフラ
├── core/                   <- ハイドレーションエンジン、PDFエクスポート
└── utils/                  <- DBヘルパー、SQLユーティリティ、ロギング

data/
├── skills/                 <- 36のエージェントスキル定義（YAML）
│   ├── historical-backtest/
│   ├── monte-carlo-simulation/
│   ├── equity-research-report/
│   ├── investment-memo-generation/
│   ├── earnings-intelligence/
│   ├── brinson-attribution/
│   ├── factor-model-explorer/
│   ├── portfolio-optimizer/
│   ├── concentration-risk-assessment/
│   ├── esg-mandate-compliance/
│   ├── covenant-monitoring/
│   ├── deal-pipeline-screening/
│   ├── quarterly-client-letter/
│   ├── rfp-response-preparation/
│   ├── executive-briefing/
│   └── ... （その他21スキル）
└── reference_data/         <- YAML設定ファイル

content_library/            <- 70以上のドキュメントテンプレート

notebooks/
├── factor_discovery.ipynb          <- ファクター探索ノートブック
├── market_regime_detection.ipynb   <- マーケットレジーム検出
└── credit_risk_model.ipynb         <- クレジットリスクモデリング

scripts/
├── setup.sql               <- インフラDDL（最初に実行）
└── teardown.sql            <- 完全クリーンアップスクリプト
```

---

## クリーンアップ

[`scripts/teardown.sql`](scripts/teardown.sql) を実行するか、以下のSQLを使用します：

```sql
DROP DATABASE IF EXISTS SAM_DEMO;
DROP WAREHOUSE IF EXISTS SAM_DEMO_EXECUTION_WH;
DROP WAREHOUSE IF EXISTS SAM_DEMO_CORTEX_WH;
DROP ROLE IF EXISTS SAM_DEMO_ROLE;
```

---

## 前提条件

- Cortex機能が有効なSnowflakeアカウント
- ACCOUNTADMIN ロール（初期セットアップ用）
- Snowflake Intelligence が利用可能
- ワークスペースノートブックサービス用のコンピュートプール

---

## 参考ドキュメント

- [Snowflake CoWorkドキュメント](https://docs.snowflake.com/en/user-guide/snowflake-intelligence)
- [Cortex Agentsガイド](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Cortex Searchドキュメント](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Cortex Analystドキュメント](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)

---

## ライセンス

Apache-2.0 — 詳細は [LICENSE](LICENSE) を参照してください。

---

## 謝辞

このリポジトリは [Snowflake-Labs/sfguide-agentic-ai-for-asset-management](https://github.com/Snowflake-Labs/sfguide-agentic-ai-for-asset-management) の日本語翻訳版です。
