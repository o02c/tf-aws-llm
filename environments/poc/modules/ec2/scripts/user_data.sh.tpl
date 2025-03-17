#!/bin/bash
# JupyterHubセットアップスクリプト

# ログファイルの設定
LOG_FILE="/var/log/user_data.log"
echo "Starting setup script at $(date)" > $LOG_FILE

# 必要なパッケージのインストール
echo "Installing required packages..." >> $LOG_FILE
dnf update -y >> $LOG_FILE 2>&1
dnf install -y python3.12 python3.12-pip git >> $LOG_FILE 2>&1

# AWS CLIとBoto3をインストール
echo "Installing AWS CLI and Boto3..." >> $LOG_FILE
pip3.12 install --upgrade awscli boto3 >> $LOG_FILE 2>&1

# S3バケット名 - Terraformによって埋め込まれる
echo "S3 bucket name: ${s3_bucket_name}" >> $LOG_FILE

# JypyterHub/Labのインストール
echo "Installing JupyterHub and JupyterLab..." >> $LOG_FILE
pip3.12 install jupyterhub jupyterlab notebook sudospawner >> $LOG_FILE 2>&1
pip3.12 install jupyterlab-language-pack-ja-JP

# Node.jsとConfigurable HTTP Proxyのインストール
echo "Installing Node.js and Configurable HTTP Proxy..." >> $LOG_FILE
dnf install -y nodejs >> $LOG_FILE 2>&1
npm install -g configurable-http-proxy >> $LOG_FILE 2>&1

# 共有ディレクトリの作成
echo "Creating shared directories..." >> $LOG_FILE
groupadd jupyter
mkdir -p /opt/notebooks
mkdir -p /opt/notebooks/shared

# jupyter_adminユーザーの作成
echo "Creating jupyter_admin user..." >> $LOG_FILE
useradd jupyter_admin -G jupyter 
usermod -aG wheel jupyter_admin
# パスワードの設定
usermod -p $(perl -e 'print crypt("jupyter_admin", "salt")') jupyter_admin
mkdir -p /opt/notebooks/jupyter_admin
chown jupyter_admin. /opt/notebooks/jupyter_admin/
chmod 750 /opt/notebooks/jupyter_admin
usermod -d /opt/notebooks/jupyter_admin jupyter_admin
chown -R jupyter_admin:jupyter /opt/notebooks/

# JupyterHubディレクトリの作成
echo "Setting up JupyterHub..." >> $LOG_FILE
mkdir -p /opt/jupyterhub
cd /opt/jupyterhub

# S3からjupyterhub_config.pyを取得
echo "Downloading jupyterhub_config.py from S3..." >> $LOG_FILE
aws s3 cp "s3://${s3_bucket_name}/scripts/jupyterhub_config.py" "/opt/jupyterhub/jupyterhub_config.py" >> $LOG_FILE 2>&1

# ユーザー追加スクリプトの作成
echo "Creating user add script..." >> $LOG_FILE
cat > /opt/jupyterhub/add_user.sh <<EOF
#!/bin/bash
username="$${1}"

# jupyterグループに所属するユーザーを作成
sudo useradd -p $$(perl -e 'print crypt("cryptseed", "salt")') -d "/home/$${username}" -G jupyter "$${username}"
# ユーザー用のノートブックディレクトリを作成
sudo mkdir -p "/opt/notebooks/$${username}"
sudo chown "$${username}:jupyter" "/opt/notebooks/$${username}/"
sudo chmod 750 "/opt/notebooks/$${username}"
EOF
chmod 777 /opt/jupyterhub/add_user.sh

# JupyterHubのサービス設定
echo "Creating JupyterHub service..." >> $LOG_FILE
cat > /lib/systemd/system/jupyterhub.service <<EOF
[Unit]
Description=Jupyterhub

[Service]
User=root
Environment="PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/bin/sudo:/usr/bin"
ExecStart=/usr/local/bin/jupyterhub --url 0.0.0.0 -f /opt/jupyterhub/jupyterhub_config.py
WorkingDirectory=/opt/jupyterhub

[Install]
WantedBy=multi-user.target
EOF

# サービスの有効化と起動
echo "Enabling and starting JupyterHub service..." >> $LOG_FILE
systemctl daemon-reload
systemctl enable jupyterhub
systemctl start jupyterhub

# 完了メッセージ
echo "Setup completed successfully at $(date)" >> $LOG_FILE
echo "SUCCESS" > /var/log/jupyterhub_setup_complete.log
