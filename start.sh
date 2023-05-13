#!/bin/bash

#* yt_channels ver_2.9.5

# Команда переходит в каталог, в котором находится текущий скрипт, и выводит его полный путь.
cd "$(dirname "$(readlink -f "$0")")"
folder="$(dirname "$(readlink -f "$0")")"

# Папка для сохранения видео
load_folder="/mnt/e/yt_channels_loads"

# Список URL-адресов
url="url/*.txt"
#url="test_url/*.txt"

# Максимальное количество загрузок с канала за 1 запуск скрипта
counts_loads="--max-downloads 1"

# Максимальная глубина даты выложеного видео от сегодняшней даты
data_loads="--break-match-filters upload_date>=20130101"

# Файл настроек
config="--config-location conf.txt"

# Старт времени в секундах
time_start_script=$(date +%s)
time_start="$(date '+%A %H:%M')"

echo "Старт: $time_start" >> $load_folder/_log.txt

# Установка даты
datetime=$(date +'%Y-%m-%d-%H-%M-%S')

# Удаление временной папки перед запуском
rm -rf $folder/_temp*

# Задание переменных качества скачивания и формат файлов
opus="-S acodec:opus -x"
m4a="-S acodec:m4a -x"

low="-f bv+ba/b -S res:240,codec,br:40"
sd="-f bv+ba/b -S res:480,codec,br:70"
hdl="-f bv+ba/b -S res:720,codec,br:70"
hd="-f bv+ba/b -S res:720,codec,br:160"
fhd="-f bv+ba/b -S res:1080,codec,br:260"
v2k="-f bv+ba/b -S res:1440,codec,br:260"
v4k="-f bv+ba/b -S res:2160,codec,br:260"

# Имя файла при сохранении
channel_file="-o %(uploader_id)s_S%(upload_date>%y)sE%(upload_date>%m%d)s%(n_entries+1-playlist_index)d_[%(id)s].%(ext)s" 
playlist_file="-o %(playlist)s_pls/%(uploader_id)s_S01E%(upload_date>%y%m%d)s_[%(id)s].%(ext)s" 

for i in $url; do
  # Получение URL
  for u in $(cat $i); do

    time_start_video=$(date +%s)

    # Определение папки по имени канала из пути ссылки
    folder_name=$(echo $u | cut -d "@" -f 2 | cut -d "/" -f 1)
    
    echo $i | grep -qi "playlist_" && folder_name=""
    categoria=$(basename ${i%_*})

    # Определение названия итогового файла
    name_file=$channel_file
    echo $i | grep -qi "playlist_" && name_file=$playlist_file

    # Выбор качества видео
    codec=$sd
    echo $i | grep -qi "_opus" && codec=$opus
    echo $i | grep -qi "_m4a" && codec=$m4a
    echo $i | grep -qi "_sd" && codec=$sd
    echo $i | grep -qi "_hd" && codec=$hd
    echo $i | grep -qi "_fhd" && codec=$fhd
    echo $i | grep -qi "_v2k" && codec=$v2k
    echo $i | grep -qi "_v4k" && codec=$v4k
    echo $i | grep -qi "_low" && codec=$low
    echo $i | grep -qi "_hdl" && codec=$hdl

    # Создание папки для сохранения видео      
    folder_save="$load_folder/$categoria/$folder_name"
    if [ ! -d "$folder_save" ]; then
      mkdir -p $folder_save
    fi

    # Архив номеров скачанных видео и лог 
    archive="--download-archive $folder_save/_archive.txt"
    log_file="$folder_save/_log.txt"

    echo
    echo START -------------------------------------------------

    # Получить информацию о видео
    info=$(yt-dlp $codec $counts_loads $archive -o "%(uploader_id)s/%(playlist)s" --get-filename --get-title --get-duration --get-format $u <<< info)

    # Создать массив информации о видео
    array=()
    while read -r line; do
      array+=("$line") 
    done <<< "$info"

    ouput_info="${array[1]}"

    # Выделяем название канала
    channel=${ouput_info%%/*}
    # Выделяем название плейлиста
    playlist=${ouput_info#*/}
    
    # Вывод информации о видео на экран
    echo "Канал           - $channel"
    echo "Плейлист        - $playlist"
    echo "Название видео  - ${array[0]}"
    echo "Формат видео    - ${array[3]}"
    echo "Длительность    - ${array[2]}"
    echo
    echo "Ссылка на канал - $u"
    echo "Категория       - $categoria"
    echo "Каталог         - $load_folder/$categoria"

    echo     
    # Основная команда для скачивания видео
    yt-dlp $config $counts_loads $data_loads $codec $u -P "temp:$folder/_temp-$datetime" -P $folder_save $name_file $archive >$log_file
    
    # Вычисление времени на скачивание видео
    time_end_video=$(date +%s)
    time_diff_video=$((time_end_video-time_start_video))
    
    echo "END ------ Время скачивания видео: $(($time_diff_video / 60)) мин $(($time_diff_video % 60)) сек" ------
    echo  
  done
done

echo Скачивание завершено

# Создание обложки для канала

# Маска файла, который нужно найти
mask="*ENA*.jpg"

# Новое имя файла
new_file="poster.jpg"

find $load_folder -name "$mask" -print0 | while read -d $'\0' file
do
  dir_path=$(dirname "$file")
  mv "$file" "$dir_path/$new_file"
done

# rm -rf $folder/_temp*
echo Создание обложек завершено

# Конец времени в секундах
time_end_script=$(date +%s)
time_stop="$(date '+%A %H:%M')"

# Вычислени времени исполнения скрипта
time_diff_script=$((time_end_script-time_start_script))
time_cacl="$(($time_diff_script / 60)) мин. $(($time_diff_script % 60)) сек."    

echo "Общее время работы: $time_cacl"
echo "Старт/Стоп: $time_start/$time_stop - Время работы: $time_cacl" >> $load_folder/_log.txt