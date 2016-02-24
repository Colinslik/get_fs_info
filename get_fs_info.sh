#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/bin/X11:/usr/local/sbin:/usr/local/bin:$PATH

if [ -z "$1" ]; then
  Target=`pwd`/
else
  Target="$1"
fi

if [ -z "$2" ]; then
   createto=/share/Public/
else
   createto="$2"
fi

tmp_file=`pwd`/list.tmp

root=`echo $Target | sed -n 's/\/$//p' | sed 's/^.*\///'`

WorkDir=$createto/$root/

Current=./

LS_log=LS.log

DU_log=DU.log
 
DU_tmp=DU.tmp

function dump_info()
{
  current_dir=$1
  dump_dir=$2
  ls -Alh "$current_dir" >> "$dump_dir$LS_log"
  dump_DU "$dump_dir"
}

function dump_DU()
{
  dump_dir=$1
  cd "$Target"
  if [ -e "$dump_dir$DU_tmp" ]; then
    sed -n '1,$'p "$dump_dir$DU_tmp" | tr '\n' '\0' | xargs -0 du -s | sort -n >> "$dump_dir$DU_log"
    rm "$dump_dir$DU_tmp"
  else
    :
  fi
}


function push_dir()
{
  target_dir=$1
  current_dir=$2
  cd "$target_dir$current_dir"
  for D in *; do
      if [ -d "${D}" ]; then
        echo "$current_dir${D}/" >> "$tmp_file"
        echo "$current_dir${D}/" >> "$WorkDir$current_dir$DU_tmp"
#	echo "PUSH:    $current_dir${D}/"
      fi
  done
}

function pop_dir()
{
#  sed -n '1p' $tmp_file | sed 's/\ /\\\ /g' && sed -i '1d' $tmp_file
  if [ -e "$tmp_file" ]; then
    sed -n '1p' "$tmp_file" && sed -i '1d' "$tmp_file"
    echo $current
  else
    :
  fi
}


while [ ! -z "$Current" ]
do
  cd "$Target$Current"
  mkdir -p "$WorkDir$Current"
  if [ ! -e "$WorkDir$Current$LS_log" ]; then
      push_dir "$Target" "$Current"
      dump_info "$Target$Current" "$WorkDir$Current"
  else
      echo "OK"
  fi
  Current=$(pop_dir)
#  echo "POP:   $Current"
done
rm $tmp_file
cd "$createto"
tar -cvpf "$root".tar "$root"
rm -rf "$root"
