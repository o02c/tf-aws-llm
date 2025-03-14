# Terraform AWS Infrastructure

このリポジトリでは、Terraformを使用してAWS上に基本的なインフラストラクチャを構築します。VPC内にパブリックサブネットとプライベートサブネットを作成し、EC2インスタンスはパブリックサブネットに、RDSデータベースはプライベートサブネットに配置します。

## プロジェクト構成

```text
.
├── main.tf           # メインのTerraformコード
├── variables.tf      # 変数定義
├── outputs.tf        # 出力定義
├── terraform.tfvars  # 変数のデフォルト値
└── modules/          # モジュールディレクトリ
    ├── vpc/          # VPCモジュール
    ├── ec2/          # EC2モジュール
    └── rds/          # RDSモジュール
```

## 機能

- **VPC**: パブリックサブネット、プライベートサブネット、インターネットゲートウェイ、NATゲートウェイ、ルートテーブルを含むVPC
- **EC2**: パブリックサブネットに配置されたEC2インスタンス（AWS Bedrock APIへのアクセス権限付き）
- **RDS**: プライベートサブネットに配置されたMySQLデータベース（フラグで有効/無効化可能）
- **AWS Bedrock**: EC2インスタンスからAWS Bedrockモデル（Claude、Amazon Titan等）へのアクセス

## 使用方法

1. 必要に応じて`terraform.tfvars`ファイルを編集してください
2. 以下のコマンドを実行してインフラストラクチャをデプロイします

```bash
# Terraformの初期化（S3バックエンドを使用）
terraform init

# 実行計画の確認
terraform plan

# インフラストラクチャのデプロイ
terraform apply
```

## 状態管理

このプロジェクトでは、Terraformの状態ファイル（tfstate）をS3バケットに保存しています：

- **バケット名**: `mgt-tfstate-654654512164`
- **キープレフィックス**: `tf-aws-llm/terraform.tfstate`
- **リージョン**: `ap-northeast-1`
- **AWSプロファイル**: `o2c`

この設定により、チーム間での状態の共有やバージョン管理が可能になります。

**注意**: RDSを有効にする場合、`db_password`変数は必ず設定してください。セキュリティ上の理由から、`terraform.tfvars`ファイルに直接記載するのではなく、コマンドラインで指定することをお勧めします:

```bash
terraform apply -var="enable_rds=true" -var="db_password=YOUR_SECURE_PASSWORD"
```

RDSを無効化して実行する場合（デフォルト）:

```bash
terraform apply
```

## AWS Bedrockの利用

このインフラストラクチャでは、EC2インスタンスからAWS Bedrockサービスにアクセスするための設定が含まれています。

### セットアップ内容

1. EC2インスタンスには、AWS Bedrockサービスにアクセスするために必要なIAMポリシーが付与されています
2. インスタンス起動時に自動的に以下の設定が行われます:
   - Python、AWS CLI、boto3のインストール
   - Bedrockテスト用のPythonスクリプトの配置

### Bedrockの動作確認

EC2インスタンスにSSM Session ManagerまたはSSH経由で接続した後、以下のコマンドを実行してBedrockへのアクセスをテストできます:

```bash
python3 /home/ec2-user/test_bedrock.py
```

正常に動作する場合、利用可能なBedrockモデルのリストと、サンプルプロンプトに対するモデルの応答が表示されます。

### 注意事項

- AWS Bedrockサービスは一部のリージョンでのみ利用可能です（デフォルトでは`us-east-1`を使用）

### Bedrockモデルアクセスの有効化

Bedrockモデルを使用するには、AWSコンソールでモデルアクセスを有効にする必要があります。以下の手順に従ってください：

1. [AWS Bedrockコンソール](https://console.aws.amazon.com/bedrock/home)にアクセスします
2. 左側のナビゲーションメニューから「**Model access**」を選択します
3. 使用したいモデル（例：Amazon Titan、Claude、Llama 3など）の横にあるチェックボックスをオンにします
4. 「**Request model access**」ボタンをクリックします
5. 確認ダイアログが表示されたら「**Request**」をクリックします
6. モデルへのアクセスが承認されるまで待ちます（多くの場合、すぐに承認されます）

承認後、EC2インスタンスからテストスクリプトを実行して、モデルにアクセスできることを確認できます。

```bash
python3 /home/ec2-user/test_bedrock.py
```

### その他の注意事項

- 実際の本番環境では、より制限されたIAMポリシーを使用することをお勧めします
- Amazon Linux 2023を使用しているため、パッケージ管理は`dnf`コマンドで行われます

## 出力

デプロイ後、以下の情報が出力されます:

- VPC ID
- パブリックサブネットID
- EC2インスタンスID
- EC2パブリックIP
- RDSエンドポイント

## カスタマイズ

必要に応じて以下の変数をカスタマイズできます:

- `region`: AWSリージョン (デフォルト: ap-northeast-1)
- `vpc_cidr_block`: VPCのCIDRブロック (デフォルト: 10.0.0.0/16)
- `public_subnet_cidr`: パブリックサブネットのCIDRブロック (デフォルト: 10.0.1.0/24)
- `private_subnet_cidr`: プライベートサブネットのCIDRブロック (デフォルト: 10.0.2.0/24)
- `availability_zone`: アベイラビリティゾーン (デフォルト: ap-northeast-1a)
- `instance_type`: EC2インスタンスタイプ (デフォルト: t2.micro)
- `ami_id`: EC2のAMI ID (デフォルト: Amazon Linux 2023 in ap-northeast-1)
- `enable_rds`: RDSインスタンスの有効/無効化フラグ (デフォルト: false)
- `db_instance_class`: RDSインスタンスクラス (デフォルト: db.t3.micro)
- `db_name`: データベース名 (デフォルト: mydb)
- `db_username`: データベースユーザー名 (デフォルト: admin)
