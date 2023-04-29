#!/bin/bash

# Папка в котором находится текущий скрипт
folder="$(dirname "$(readlink -f "$0")")"

# Задать путь к скрипту, который будет выполняться по расписанию
script_path="$folder/start.sh"

# Ввести расписание для задания (минуты, часы, дни, месяцы, дни недели)
# Данная команда запускает каждый час
schedule="0 * * * *"

# Добавить задание в cron с указанным расписанием
(crontab -l ; echo "$schedule $script_path") | crontab -

sudo service cron restart
sudo systemctl restart crond.service

echo "Задание добавлено в cron"