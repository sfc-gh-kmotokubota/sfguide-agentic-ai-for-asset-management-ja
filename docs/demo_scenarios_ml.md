# MLノートブック デモシナリオ

**エージェント**: なし（Snowflakeノートブック直接実行）
**デモ画面**: Snowflakeノートブック（Projects > Notebooks）
**ノートブック**: `notebooks/market_regime_detection.ipynb`, `notebooks/factor_discovery.ipynb`, `notebooks/credit_risk_model.ipynb`

---

## 概要

このデモはエージェントを使用せず、Snowflakeノートブックで直接実行するMLワークフローを示します。
これらのノートブックはSnowflake ML機能（Feature Store、ML Functions、Cortex AI）を使用した
本番グレードの機械学習パイプラインのデモです。

---

## マーケットレジーム検出

**ノートブック**: `notebooks/market_regime_detection.ipynb`
**シナリオ**: `market_regime_ml`

### 概要

ガウス混合モデル（GMM）とSnowflakeフィーチャーストアを使用して、
市場環境（強気相場、弱気相場、ボラティリティ高等）を自動的に検出・分類します。

### デモフロー

#### ステップ 1: データの準備

```python
# Snowflakeフィーチャーストアから特徴量を取得
from snowflake.ml.feature_store import FeatureStore, FeatureView

fs = FeatureStore(session, "SAM_DEMO", "ML")
feature_view = fs.get_feature_view("MARKET_FEATURES", "1")

# フィーチャービューから学習データを取得
training_data = fs.retrieve_feature_values(
    spine_df=market_dates,
    feature_views=[feature_view]
)
```

**ポイント**:
- 「Snowflakeフィーチャーストアが特徴量の計算と再利用を管理」
- 「Training-serving skewを防ぎ、モデルの本番移行を容易にする」

#### ステップ 2: GMMモデルのトレーニング

```python
from sklearn.mixture import GaussianMixture
from snowflake.ml.registry import Registry

# GMMモデルをトレーニング
gmm = GaussianMixture(n_components=4, covariance_type='full', random_state=42)
gmm.fit(features_scaled)

# レジームラベルの予測
regime_labels = gmm.predict(features_scaled)
regime_probs = gmm.predict_proba(features_scaled)
```

#### ステップ 3: レジームの特徴分析

期待される出力:
```
## 検出されたマーケットレジーム

レジーム 0 - 強気相場（期間: 45%）
  - 平均リターン: +1.8%/月
  - ボラティリティ: 12%（年率）
  - 特徴: 低VIX、幅広い上昇

レジーム 1 - 弱気相場（期間: 15%）
  - 平均リターン: ▲3.2%/月
  - ボラティリティ: 28%（年率）
  - 特徴: 高VIX、リスクオフ

レジーム 2 - ラリー（期間: 25%）
  - 平均リターン: +0.9%/月
  - ボラティリティ: 16%（年率）
  - 特徴: 回復基調、セクターローテーション

レジーム 3 - 高ボラティリティ（期間: 15%）
  - 平均リターン: ▲0.5%/月
  - ボラティリティ: 35%（年率）
  - 特徴: 方向感なし、イベントリスク
```

#### ステップ 4: Snowflakeモデルレジストリへの登録

```python
# モデルをSnowflake MLレジストリに登録
registry = Registry(session, database_name="SAM_DEMO", schema_name="ML")

mv = registry.log_model(
    model=gmm_pipeline,
    model_name="MARKET_REGIME_DETECTOR",
    model_version="v1",
    comment="GMMベースのマーケットレジーム検出モデル",
    sample_input_data=X_test
)
```

**ポイント**:
- 「Snowflakeモデルレジストリで全モデルのバージョン管理と監査証跡を自動管理」
- 「モデルをSnowflakeに直接デプロイし、SQLから呼び出し可能」

#### ステップ 5: リアルタイム推論（SQLから）

```sql
-- 登録済みモデルをSQLから呼び出し
SELECT 
    DATE,
    RETURN,
    VOLATILITY,
    SAM_DEMO.ML.MARKET_REGIME_DETECTOR!PREDICT(
        OBJECT_CONSTRUCT('return', RETURN, 'volatility', VOLATILITY, 'vix', VIX)
    ):REGIME::NUMBER AS PREDICTED_REGIME
FROM SAM_DEMO.MARKET_DATA.DAILY_MARKET_DATA
ORDER BY DATE DESC
LIMIT 30;
```

### トーキングポイント

1. **ビジネス価値**: レジームに応じたダイナミックなリスク管理とアセットアロケーション
2. **技術的優位性**: フィーチャーストアによる特徴量の再利用とガバナンス
3. **統合**: SQLから直接MLモデルを呼び出せる - データエンジニアとデータサイエンスの壁を除去

---

## ファクターモデルワークフロー

**ノートブック**: `notebooks/factor_discovery.ipynb`
**シナリオ**: `factor_workflow_ml`

### 概要

XGBoostを使用して株式リターンを予測するファクターモデルを構築し、
どのファクターが最もリターン予測に貢献するかを分析します。

### デモフロー

#### ステップ 1: フィーチャーエンジニアリング

```python
# Snowflakeフィーチャーストアでファクター特徴量を定義
from snowflake.ml.feature_store import Entity, FeatureView
from snowflake.ml.feature_store import CreationMode

# エンティティ定義（証券）
security_entity = Entity(name="SECURITY", join_keys=["TICKER"])

# ファクタービューの作成
factor_fv = FeatureView(
    name="EQUITY_FACTORS",
    entities=[security_entity],
    feature_df=factor_df,  # バリュー、グロース、モメンタム、クオリティ等
    timestamp_col="DATE",
    refresh_freq="1d",
    desc="株式ファクターエクスポージャー"
)

fs.register_feature_view(
    feature_view=factor_fv,
    version="v1",
    block=True,
    overwrite=False
)
```

**利用可能なファクター（7ファクターモデル）**:
- バリューファクター: P/E、P/B、EV/EBITDA
- グロースファクター: 売上成長率、EPS成長率
- モメンタムファクター: 12ヶ月モメンタム、RSI
- クオリティファクター: ROE、ROA、負債比率
- サイズファクター: 時価総額
- ボラティリティファクター: 過去60日間のボラティリティ
- マクロファクター: ベータ、セクターエクスポージャー

#### ステップ 2: XGBoostモデルのトレーニング

```python
from xgboost import XGBRegressor
from sklearn.model_selection import TimeSeriesSplit

# 時系列クロスバリデーション（過学習防止）
tscv = TimeSeriesSplit(n_splits=5)

xgb_model = XGBRegressor(
    n_estimators=500,
    learning_rate=0.05,
    max_depth=4,
    subsample=0.8,
    colsample_bytree=0.8,
    random_state=42
)

# トレーニング（各フォールドのアウトオブサンプルスコア）
for fold, (train_idx, val_idx) in enumerate(tscv.split(X)):
    xgb_model.fit(X[train_idx], y[train_idx])
    # ... 評価
```

#### ステップ 3: SHAP特徴量重要度

期待される出力:
```
## ファクター重要度分析（SHAP値）

リターン予測への寄与度:
1. モメンタムファクター（12ヶ月）: 28.3%
2. バリューファクター（P/E）: 22.1%
3. クオリティファクター（ROE）: 18.7%
4. グロースファクター（EPS成長）: 15.4%
5. サイズファクター: 8.2%
6. ボラティリティ: 4.9%
7. マクロベータ: 2.4%

モデル精度（テストセット）:
- Information Coefficient (IC): 0.12
- ICIR（情報係数情報比率）: 1.8
- Hit Rate: 56%
```

#### ステップ 4: ポートフォリオ構築への適用

```python
# 予測スコアに基づいてポートフォリオを構築
predictions = xgb_model.predict(X_current)

# ロング/ショートポートフォリオ（上位20% vs 下位20%）
long_portfolio = pd.Series(predictions).nlargest(int(len(predictions)*0.2))
short_portfolio = pd.Series(predictions).nsmallest(int(len(predictions)*0.2))

# バックテスト（12ヶ月）
backtest_results = run_backtest(long_portfolio, short_portfolio, historical_returns)
```

### トーキングポイント

1. **フィーチャーストア**: 特徴量を1回計算して複数のモデルで再利用 - DRY原則
2. **時系列クロスバリデーション**: 金融データ特有のルックアヘッドバイアスを防止
3. **SHAP説明可能性**: 規制当局や投資委員会への説明責任を果たせる

---

## クレジットリスクスコアリング

**ノートブック**: `notebooks/credit_risk_model.ipynb`
**シナリオ**: `credit_risk_ml`

### 概要

XGBoostを使用して借り手のデフォルト確率（PD）を予測するクレジットリスクモデルを構築します。
SHAP値による特徴量の説明可能性分析も含みます。

### デモフロー

#### ステップ 1: クレジットデータの準備

```python
# SAM_DEMO.CURATEDからクレジットデータを取得
credit_df = session.sql("""
    SELECT 
        b.BORROWER_ID,
        b.INDUSTRY_SECTOR,
        b.LEVERAGE_RATIO,
        b.INTEREST_COVERAGE_RATIO,
        b.EBITDA_MARGIN,
        b.REVENUE_GROWTH_YOY,
        b.FREE_CASH_FLOW_CONVERSION,
        b.NET_DEBT_TO_EBITDA,
        b.CURRENT_RATIO,
        l.DEFAULT_FLAG  -- 目的変数
    FROM SAM_DEMO.CURATED.DIM_BORROWERS b
    JOIN SAM_DEMO.CURATED.FACT_LOAN_PERFORMANCE l 
        ON b.BORROWER_ID = l.BORROWER_ID
    WHERE l.OBSERVATION_DATE >= DATEADD(year, -5, CURRENT_DATE)
""").to_pandas()
```

#### ステップ 2: XGBoostモデルのトレーニング

```python
from xgboost import XGBClassifier
from sklearn.metrics import roc_auc_score, average_precision_score

# クレジットリスクモデル（不均衡データ対応）
xgb_credit = XGBClassifier(
    n_estimators=300,
    learning_rate=0.1,
    max_depth=5,
    scale_pos_weight=9,  # デフォルト率約10%に対応
    eval_metric='aucpr',
    random_state=42
)

xgb_credit.fit(X_train, y_train, 
               eval_set=[(X_val, y_val)],
               early_stopping_rounds=20)

# モデル評価
print(f"AUC-ROC: {roc_auc_score(y_test, y_pred_proba):.3f}")
print(f"AP Score: {average_precision_score(y_test, y_pred_proba):.3f}")
```

#### ステップ 3: SHAP説明可能性

```python
import shap

# SHAP値の計算
explainer = shap.TreeExplainer(xgb_credit)
shap_values = explainer.shap_values(X_test)

# ウォーターフォールプロット（個別借り手の説明）
shap.waterfall_plot(shap.Explanation(
    values=shap_values[0],
    base_values=explainer.expected_value,
    data=X_test.iloc[0],
    feature_names=feature_names
))
```

期待されるSHAP分析出力:
```
## 個別借り手のデフォルトリスク説明（Gamma Corp）

基準デフォルト確率（全体平均）: 3.2%

各特徴量のデフォルト確率への貢献:
↑ レバレッジ比率 (5.4x): +4.8% （業界平均3.2xを大幅超過）
↑ ICR低下トレンド: +2.1%（過去3四半期で2.8x→2.1x）
↑ EBITDAマージン低下: +1.9%（▲5%ポイント）
↓ 豊富な現金残高: ▲1.2%
↓ 良好な顧客分散: ▲0.8%

予測デフォルト確率: 10.0% ⚠️ 高リスク（業界平均3.2%の3倍）
```

**ポイント**:
- 「個別借り手について、なぜデフォルトリスクが高いのかを定量的に説明できる」
- 「規制当局（バーゼルIII等）の説明可能性要件に対応」

#### ステップ 4: バッチスコアリングと本番デプロイ

```python
# Snowflake MLレジストリに登録
registry = Registry(session, database_name="SAM_DEMO", schema_name="ML")

credit_mv = registry.log_model(
    model=xgb_credit,
    model_name="CREDIT_RISK_SCORER",
    model_version="v2",
    comment="XGBoostクレジットリスクモデル - デフォルト確率予測",
    sample_input_data=X_test.head(10)
)

# SQLでバッチスコアリング（全ポートフォリオ）
session.sql("""
    CREATE OR REPLACE TABLE SAM_DEMO.ML.CREDIT_RISK_SCORES AS
    SELECT 
        BORROWER_ID,
        SAM_DEMO.ML.CREDIT_RISK_SCORER!PREDICT(
            OBJECT_CONSTRUCT(
                'leverage_ratio', LEVERAGE_RATIO,
                'icr', INTEREST_COVERAGE_RATIO,
                'ebitda_margin', EBITDA_MARGIN,
                'revenue_growth', REVENUE_GROWTH_YOY
            )
        ):PD::FLOAT AS DEFAULT_PROBABILITY,
        CURRENT_TIMESTAMP AS SCORED_AT
    FROM SAM_DEMO.CURATED.DIM_BORROWERS
""").collect()
```

### トーキングポイント

1. **説明可能AI**: SHAPにより「なぜデフォルトリスクが高いか」を定量的に説明
2. **Snowflake統合**: モデルをSnowflakeに直接デプロイ、SQLからリアルタイム推論
3. **規制対応**: バーゼルIIIのモデルリスク管理要件（MRM）に対応した透明性
4. **スケーラビリティ**: ポートフォリオ全体のバッチスコアリングが数秒で完了

---

## 全MLシナリオ共通のデモポイント

### Snowflake MLの主要機能

| 機能 | 説明 | デモでの活用 |
|------|------|-----------|
| **Snowflake Feature Store** | 特徴量の定義・計算・再利用 | ファクターエクスポージャー、マクロ指標 |
| **MLレジストリ** | モデルのバージョン管理・デプロイ | GMMとXGBoostモデルの管理 |
| **SQLからの推論** | 登録済みモデルをSQLで呼び出し | リアルタイムリスクスコアリング |
| **Snowflakeノートブック** | Snowpark Pythonでのインタラクティブ開発 | 全MLワークフロー |
| **ウェアハウス計算** | モデルトレーニングがウェアハウスで実行 | 大規模データでの高速トレーニング |

### ビジネス価値のメッセージ

- **統合環境**: データ、ML、アナリティクスをすべてSnowflakeで管理 - データ移動不要
- **ガバナンス**: データリネージ、モデルバージョン管理、アクセス制御を自動管理
- **スケーラビリティ**: 数千証券のリスク評価を数秒でバッチ処理
- **説明可能性**: 規制当局への説明責任を果たすSHAPベースの解釈

### 推奨デモの流れ

**クイックデモ（15分）**:
1. マーケットレジーム検出: フィーチャーストアの概念説明 + GMMの結果可視化
2. クレジットリスクスコアリング: SHAP説明可能性の実演

**技術的詳細デモ（30分）**:
1. ファクターモデルワークフロー: フィーチャーエンジニアリング → トレーニング → SHAP
2. クレジットリスクスコアリング: モデル登録 → SQLからの推論
3. MLレジストリでのバージョン管理デモ
