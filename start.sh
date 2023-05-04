#!/bin/bash

#* yt_channels ver_2.9

time_start_script=$(date +%s)

# Эта команда переходит в каталог, в котором находится текущий скрипт, и выводит его полный путь.
cd "$(dirname "$(readlink -f "$0")")"
folder="$(dirname "$(readlink -f "$0")")"

# Установка даты
datetime=$(date +'%Y-%m-%d-%H-%M-%S')

# Удаление временной папки перед запуском
rm -rf $folder/_temp*

# Задание переменных качества скачивания и формат файлов
opus="-S acodec:opus -x"
m4a="-S acodec:m4a -x"

low="-S res:144,vcodec:vp9:h264:av01,acodec:opus,br:32"
sd="-S res:480,vcodec:vp9:h264:av01,acodec:opus,br:70"
hd="-S hdr:HLG,res:720,vcodec:av01:vp9.2:vp9,acodec:m4a:opus"
hdl="-S res:720,vcodec:av01:vp9.2:vp9,acodec:opus,br:70"
fhd="-S hdr:HLG,res:1080,vcodec:av01:vp9.2:vp9,acodec:m4a:opus"
v2k="-S hdr:HLG,res:1440,vcodec:av01:vp9.2:vp9,acodec:m4a:opus"
v4k="-S hdr:HLG,res:2160,vcodec:av01:vp9.2:vp9,acodec:m4a:opus"

# Папка для загрузки каналов
load_folder="/mnt/e/yt_channels_loads"

# Список URL-адресов листов
url="url/*.txt"
#url="test_url/*.txt"

# Файл настроек
config="--config-location conf.txt"

# Файл список плейлистов Downloads
batch="--batch-file downloads.txt"

# Максимальное количество загрузок с канала за 1 запуск скрипта
counts_loads="--max-downloads 1"

# Максимальная глубина даты выложеного видео от сегодняшней даты
data_loads="--break-match-filters upload_date>=20130101"

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

time_end_script=$(date +%s)
time_diff_script=$((time_end_script-time_start_script))
    
echo "Общее время скачивания: $(($time_diff_script / 60)) мин $(($time_diff_script % 60)) сек"