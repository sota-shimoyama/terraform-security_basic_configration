## 概要

以下のセキュリティサービスを有効化し、アカウントレベルの基本的な設定を行います。
* Config
* SecurityHub
* GuardDuty
* Inspector


設定は下記のSecurityHubコントロールに対応したものです。

| ID | 説明 |
| ---- | ---- |
| IAM.7 | IAM ユーザーのパスワードポリシーには、強力な設定が必要です |
| IAM.15 | IAM パスワードポリシーで、最小文字数の 14 文字かそれ以上が要求されていることを確認する |
| IAM.16 | IAM パスワードポリシーを確認して、パスワードの再利用を防ぐ |
| IAM.18 | AWS サポートでインシデントを管理するためのサポートロールが作成されていることを確認する |
| S3.1 | S3 ブロックパブリックアクセス設定を有効にする必要があります |
| EC2.7 | EBS のデフォルト暗号化を有効にする必要があります |

## リリース手順

### 準備

*./env/env.tfvars*　に環境に合わせた情報を記載(下記は例)
```
project = "hoge"
env     = "dev"
profile = "hoge-profile"
region  = "ap-northeast-1"

```

バックエンドをローカルではなくS3にする場合は、 *./env/env.backend.tf* に必要な情報を記載してから、
*./main.tf* 内の backend の指定を **local** から **s3** に変更してください。
### terraform

```bash
rm -fr .terraform #terraformの環境に依存するキャッシュをクリア
terraform init
terraform apply -var-file=./env/env.tfvars
```

### 有効化しないサービスがある場合

GuardDuty,Inspectorなど要件次第で有効化しないサービスがある場合、 *./main.tf* 内の該当サービスのモジュール部分をコメントアウトしてからapplyしてください。