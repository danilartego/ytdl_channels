## Скачивание каналов с Youtube для Linux

В системе должны быть установлены и прописаны в переменной окружения 
yt-dlp 2023.03.04 и выше
```
sudo wget -qO /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
yt-dlp --version
sudo yt-dlp -U
```
ffmpeg

Для запуска скрипта каждые 5 минут с помощью cron в Windows Subsystem for Linux (WSL) вам нужно изменить строку в файле `crontab` на следующую:

```
# В этой строке знак `*/5` означает выполнение каждые 5 минут. 
*/5 * * * * /home/user/my_script.sh

# То есть задача будет выполняться каждый день в 8 часов утра.
0 8 * * * /home/user/my_script.sh

# Задача будет выполняться каждый час
0 * * * * /home/user/my_script.sh

# Задача будет выполняться каждые два дня в 12:00
0 12 */2 * * /home/user/my_script.sh
```
Эта строка содержит следующие поля:
Минуты Часы Дни_месяца Месяцы Дни_недели /home/user/my_script.sh

После сохранения файл `crontab` cron автоматически загрузит задачу и начнет ее выполнение каждые 5 минут.

Не забудьте запустить сервис cron, используя команды:

### Для Ubuntu
```
# Запустить
sudo service cron start

# Перезапустить
sudo service cron restart

# Остановить
sudo service cron stop
```

### Для Fedora
```
# Запустить
systemctl start crond.service

# Перезапустить
systemctl restart crond.service

# Остановить
systemctl stop crond.service
```

Посмотреть задачу в cron 
```
crontab -l
```

Изменить задачу 
```
crontab -e
```