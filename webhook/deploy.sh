#!/bin/bash
set -e

BRANCH=$1
APP_DIR="/home/mzpdqk/devops/catty-reminders-app"

echo "=== DEPLOY ветки $BRANCH ==="
cd "$APP_DIR"

# код уже обновлён test.sh, но на всякий случай
git fetch origin
git reset --hard "origin/$BRANCH"

DEPLOY_REF="$(git rev-parse HEAD)"
echo "DEPLOY_REF=$DEPLOY_REF" > "$APP_DIR/.env"
echo "Текущий SHA: $DEPLOY_REF"

if [ -f requirements.txt ]; then
    source venv/bin/activate
    echo "=== установка зависимостей ==="
    pip install -q -r requirements.txt
fi

echo "=== Перезапуск сервиса ==="
sudo systemctl daemon-reload
sudo systemctl restart app.service

echo "=== Деплой завершен ==="
