#!/bin/bash

#* yt_channels ver_2.9

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
sd="-S res:480,vcodec:vp9:h264:av01,acodec:opus,br:32"
hd="-S hdr:HLG,res:720,vcodec:av01:vp9.2:vp9,acodec:m4a:opus"
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

    folder_name=$(echo $u | cut -d "@" -f 2 | cut -d "/" -f 1)
    
    echo $i | grep -qi "playlist_" && folder_name=""
    categoria=$(basename ${i%_*})

    name_file=$channel_file
    echo $i | grep -qi "playlist_" && name_file=$playlist_file

    codec=$sd
    echo $i | grep -qi "_opus" && codec=$opus
    echo $i | grep -qi "_m4a" && codec=$m4a
    echo $i | grep -qi "_sd" && codec=$sd
    echo $i | grep -qi "_hd" && codec=$hd
    echo $i | grep -qi "_fhd" && codec=$fhd
    echo $i | grep -qi "_v2k" && codec=$v2k
    echo $i | grep -qi "_v4k" && codec=$v4k
    echo $i | grep -qi "_low" && codec=$low 

    echo
    echo START------------------------------

    channel_name=$(yt-dlp $counts_loads -o "%(uploader_id)s" --get-filenam $u)
    paylist_name=$(yt-dlp $counts_loads -o "%(playlist)s" --get-filenam $u)
    channel_title=$(yt-dlp $counts_loads --get-title $u)
    channel_duration=$(yt-dlp $counts_loads --get-duration $u)
    # channel_link=$(yt-dlp $counts_loads --get-url $u)
    link_format=$(yt-dlp $counts_loads $codec --get-format $u)

    echo "Канал         - $channel_name"
    echo "Плейлист      - $paylist_name"
    echo "Название      - $channel_title"
    #echo "Линк          - $channel_link"
    echo "Формат        - $link_format"
    echo "Длительность  - $channel_duration"
    echo
    echo "Ссылка        - $u"
    echo "Категория     - $categoria"
    echo "Каталог       - $load_folder/$categoria"
          
    folder_save="$load_folder/$categoria/$folder_name"
    if [ ! -d "$folder_save" ]; then
      mkdir -p $folder_save
    fi
      
    archive="--download-archive $folder_save/_archive.txt"
    log_file="$folder_save/_log.txt"
    
    echo     
    yt-dlp $config $counts_loads $data_loads $codec $u -P "temp:$folder/_temp-$datetime" -P $folder_save $name_file $archive >$log_file
    
    echo END--------------------------------
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