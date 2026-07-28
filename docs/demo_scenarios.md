# SAMデモ - シナリオスクリプト

エージェント別に整理された完全なデモシナリオ（`config.SCENARIOS` に対応）。
ステップバイステップの会話、期待される応答、データフローを含みます。

---

## シナリオ概要

| シナリオ | エージェント | デモ画面 | ドキュメント |
|---------|------------|---------|------------|
| `portfolio_management` | `AM_portfolio_management_copilot` | CoWork + Cockpit | [ポートフォリオマネジメント](demo_scenarios_portfolio_management.md) |
| `research` | `AM_research_copilot` | CoWork | [リサーチ](demo_scenarios_research.md) |
| `risk_compliance` | `AM_risk_compliance_copilot` | CoWork | [リスク＆コンプライアンス](demo_scenarios_risk_compliance.md) |
| `client_advisory` | `AM_client_advisory_copilot` | CoWork | [クライアントアドバイザリー](demo_scenarios_client_advisory.md) |
| `operations` | `AM_operations_copilot` | CoWork | [オペレーション](demo_scenarios_operations.md) |
| `executive_leadership` | `AM_executive_leadership_copilot` | CoWork | [エグゼクティブリーダーシップ](demo_scenarios_executive_leadership.md) |
| `private_equity` | `AM_private_equity_copilot` | CoWork + Cockpit | [プライベートエクイティ](demo_scenarios_private_equity.md) |
| `private_credit` | `AM_private_credit_copilot` | CoWork + Cockpit | [プライベートクレジット](demo_scenarios_private_credit.md) |
| `market_regime_ml` | *（MLノートブック）* | ノートブック | [MLシナリオ](demo_scenarios_ml.md#マーケットレジーム検出) |
| `factor_workflow_ml` | *（MLノートブック）* | ノートブック | [MLシナリオ](demo_scenarios_ml.md#ファクターモデルワークフロー) |
| `credit_risk_ml` | *（MLノートブック）* | ノートブック | [MLシナリオ](demo_scenarios_ml.md#クレジットリスクスコアリング) |

**CoWork** = Snowflake CoWork（旧: Snowflake Intelligence）、**Cockpit** = PMコックピット（SPCSアプリ）

---

## エージェントシナリオ（8エージェント）

### [ポートフォリオマネジメント](demo_scenarios_portfolio_management.md)
**エージェント**: `AM_portfolio_management_copilot`

主要なデモエージェント — ポートフォリオ管理、アトリビューション分析、ファクター/クオンツ戦略、テーマ投資、ポートフォリオモデリングをカバー。PMコックピットSPCSアプリまたはSnowflake CoWorkで直接デモ可能。

| パート | カバレッジ |
|--------|----------|
| ポートフォリオ管理 | 保有銘柄レビュー、企業分析、イベント駆動型リスク、マンデートコンプライアンス |
| アトリビューション＆リスク分解 | Brinson詳細分析、マクロレジーム、セクターアトリビューション、隠れたファクター、ストレステスト |
| クオンツ/ファクター分析 | マルチファクタースクリーニング、ファクター戦略、アドホック回帰 |
| テーマ戦略 | AIインフラ、イールドカーブ、テーマ型キャッチオール |
| ポートフォリオモデリング | IPS駆動型構築、退職計画、モンテカルロ、最適化 |

---

### [リサーチ](demo_scenarios_research.md)
**エージェント**: `AM_research_copilot`

ドキュメントリサーチと分析 — ブローカーリサーチ統合、決算インテリジェンス、投資メモ、インサイダー/機関投資家の所有状況。

---

### [リスク＆コンプライアンス](demo_scenarios_risk_compliance.md)
**エージェント**: `AM_risk_compliance_copilot`

マンデートコンプライアンス監視、ESGリスク評価、違反是正、スチュワードシップ、規制レポーティング。

| パート | カバレッジ |
|--------|----------|
| コンプライアンス監視 | 集中制限、ポリシー検索、違反追跡、インサイダー監視 |
| ESGリスク＆スチュワードシップ | ESGレビュー、コントロバーシースキャン、格付け監視、エンゲージメント、SFDR/タクソノミー |

---

### [クライアントアドバイザリー](demo_scenarios_client_advisory.md)
**エージェント**: `AM_client_advisory_copilot`

クライアント関係管理 — 戦略Q&A、パフォーマンスストーリー、RFP対応、オンボーディング、リスク分析、セグメンテーション。

---

### [オペレーション](demo_scenarios_operations.md)
**エージェント**: `AM_operations_copilot`

ミドルオフィスオペレーション監視 — NAV計算、決済失敗、照合差異、コーポレートアクション。

---

### [エグゼクティブリーダーシップ](demo_scenarios_executive_leadership.md)
**エージェント**: `AM_executive_leadership_copilot`

会社全体のKPI、戦略的M&A分析、競合インテリジェンス、取締役会向けブリーフィング。

---

### [プライベートエクイティ](demo_scenarios_private_equity.md)
**エージェント**: `AM_private_equity_copilot`

プライベートエクイティのディールソーシング、デューデリジェンス、ポートフォリオ会社監視、バリュークリエーション追跡、ファンドレベルレポーティング。

---

### [プライベートクレジット](demo_scenarios_private_credit.md)
**エージェント**: `AM_private_credit_copilot`

クレジットポートフォリオ監視、コベナンツ追跡、金利感応度、ディールパイプラインスクリーニング、MLクレジットリスクスコアリング。

---

## MLシナリオ（ノートブック3種）

### [ML開発](demo_scenarios_ml.md)

ノートブックベースのMLワークフロー — エージェントを使用せず、Snowflakeノートブックでデモ。

| シナリオ | ノートブック | 説明 |
|---------|------------|------|
| `market_regime_ml` | マーケットレジーム検出 | フィーチャーストア経由のGMMレジーム分類 |
| `factor_workflow_ml` | ファクターモデルワークフロー | XGBoostファクターリターン予測 |
| `credit_risk_ml` | クレジットリスクスコアリング | SHAP説明可能性を持つXGBoost PDモデル |

---

## このドキュメントの使用方法

### デモンストレーション用

各シナリオドキュメントには以下が含まれます：
1. **エージェントの設定** — 利用可能なツールと機能
2. **ステップバイステップの会話フロー** — 正確なプロンプトと期待される応答
3. **トーキングポイント** — ビジネス価値の説明
4. **データフロー** — バックグラウンドで何が起きているか

### 効果的なデモの流れ

1. **単一エージェントから始める**: 最も関連性の高いエージェントに集中
2. **複雑なプロンプトを使用**: マルチツールオーケストレーションを示す
3. **ビジネス価値を強調**: 技術的な詳細ではなく、投資プロフェッショナルへの影響を伝える
4. **クロスエージェント機能を示す**: 必要に応じて複数のエージェントでワークフローをデモ

### 推奨デモシナリオの順序

**クイックデモ（15分）**: Portfolio Copilot → イベント駆動型リスク評価 → Executive Command Center

**包括的デモ（45分）**: Portfolio Copilot → Research Copilot → Risk & Compliance → Client Advisory → Executive Leadership
