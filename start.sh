#!/bin/bash

#* yt_channels ver_2.8

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

sd="-S res:480,vcodec:vp9:h264:av01,acodec:opus,br:32 --merge-output-format mp4"
hd="-S hdr:HLG,res:720,vcodec:av01:vp9.2:vp9,acodec:m4a:opus --merge-output-format mp4"
fhd="-S hdr:HLG,res:1080,vcodec:av01:vp9.2:vp9,acodec:m4a:opus--merge-output-format mp4"
v2k="-S hdr:HLG,res:1440,vcodec:av01:vp9.2:vp9,acodec:m4a:opus--merge-output-format mp4"
v4k="-S hdr:HLG,res:2160,vcodec:av01:vp9.2:vp9,acodec:m4a:opus --merge-output-format mp4"
low="-S res:144,vcodec:vp9:h264:av01,acodec:opus,br:32 --merge-output-format mp4"

pls="-S res:720,vcodec:vp9:av01:h264,acodec:opus,br:32 --merge-output-format mp4"
# mypls="-S res:480,vcodec:vp9:av01:h264,acodec:opus,br:32 --merge-output-format mp4"

# Папка для загрузки каналов
load_folder="/mnt/e/yt_channels_loads"

# Список URL-адресов листов
url="url/*.txt"

# Файл настроек
config="--config-location conf.txt"

# Файл список плейлистов Downloads
batch="--batch-file downloads.txt"

# Максимальное количество загрузок с канала за 1 запуск скрипта
counts_loads="--max-downloads 1"

# Максимальная глубина даты выложеного видео от сегодняшней даты
data_loads="--break-match-filters upload_date>=20130101"

# Имя файла при сохранении
name_file="-o %(uploader_id)s_S%(upload_date>%y)sE%(upload_date>%m%d)s%(n_entries+1-playlist_index)d_[%(id)s].%(ext)s" 
# name_down="-o %(uploader_id)s/S%(upload_date>%y)sE%(upload_date>%m%d)s%(n_entries+1-playlist_index)d_[%(id)s]_%(title)s.%(ext)s"
name_plist="-o %(playlist)s_pls/%(uploader_id)s_S%(upload_date>%y)sE%(upload_date>%m%d)s%(n_entries+1-playlist_index)d_[%(id)s].%(ext)s" 

for i in $url; do
  # Получение URL
  for u in $(cat $i); do
              
    # folder_name=$(echo $u | grep -oP '(?<=@)[^/]*')
    folder_name=$(echo $u | cut -d "@" -f 2 | cut -d "/" -f 1)
 
    categoria=$(basename "$i" .txt)

    echo $categoria | grep -qi "_pls" && folder_name=""
    # echo $categoria | grep -qi "_dwn" && folder_name=""

    echo
    echo START------------------------------
    
    echo Имя канала              - $folder_name
    echo Ссылка канала           - $u
    echo Категория               - $categoria 
    echo Каталог сохранения      - $load_folder
     
    folder_save="$load_folder/$categoria/$folder_name"
    if [ ! -d "$folder_save" ]; then
      mkdir -p $folder_save
    fi
    
    codec=$sd
    echo $categoria | grep -qi "_opus" && codec=$opus
    echo $categoria | grep -qi "_m4a" && codec=$m4a
    echo $categoria | grep -qi "_sd" && codec=$sd
    echo $categoria | grep -qi "_hd" && codec=$hd
    echo $categoria | grep -qi "_fhd" && codec=$fhd
    echo $categoria | grep -qi "_v2k" && codec=$v2k
    echo $categoria | grep -qi "_v4k" && codec=$v4k
    echo $categoria | grep -qi "_low" && codec=$low
    echo $categoria | grep -qi "_pls" && codec=$pls

    file=$name_file
    echo $categoria | grep -qi "_pls" && file=$name_plist
    # echo $categoria | grep -qi "_dwn" && file=$name_down
    
          
    yt-dlp $config $counts_loads $data_loads $codec $u -P "temp:$folder/_temp-$datetime" -P $folder_save $file --download-archive $folder_save/archive.txt >"$folder_save/_log.txt"
    
    echo END--------------------------------
    echo  
    
  done
done

echo Скачивание завершено

# Создание обложки для канала

# Маска файла, который нужно найти
mask="*SNAENA*.jpg"

# Новое имя файла
new_file="poster.jpg"

find $load_folder -name "$mask" -print0 | while read -d $'\0' file
do
  dir_path=$(dirname "$file")
  mv "$file" "$dir_path"/$new_file
done

# rm -rf $folder/_temp*
echo Создание обложек завершено