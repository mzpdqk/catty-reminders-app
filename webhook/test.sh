#!/bin/bash
set -e

BRANCH=$1
APP_DIR="/home/mzpdqk/devops/catty-reminders-app"

echo "=== Запуск тестов проекта ветки $BRANCH ==="
cd "$APP_DIR"

# 1. Подтянуть свежий код (как deploy.sh)
git fetch origin
git checkout -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"

DEPLOY_REF="$(git rev-parse HEAD)"
echo "DEPLOY_REF=$DEPLOY_REF" > "$APP_DIR/.env"
echo "Текущий SHA: $DEPLOY_REF"

# 2. Активировать окружение
source venv/bin/activate

# 3. Playwright chromium
echo "=== Устанавливаем Playwright браузер ==="
playwright install chromium

# 4. Убедиться, что app.service отвечает (не убиваем его pkill'ом!)
if ! curl -s http://127.0.0.1:8181/login > /dev/null 2>&1; then
    echo "app.service не отвечает, рестартуем"
    sudo systemctl restart app.service
    sleep 5
fi

# 5. Прогнать тесты
echo "Выполняем тесты..."
export PYTHONPATH="$APP_DIR:$PYTHONPATH"
pytest tests --maxfail=1 --disable-warnings -q
