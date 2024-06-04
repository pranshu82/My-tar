#!/bin/bash

#defining macros
REGTYPE=0
TMAGIC="ustar"

#redirection error message to /dev/null
exec 2> /dev/null

#function for finding ascii value
ord() {
  LC_CTYPE=C 
  val=`printf '%d' "'$1"`
}

#function to calculate checksum of a file
calculate_check_sum() {
    total=""

    #file name
    file_name=`stat -c %n $1`

    #adding to total
    total+=$file_name

    #file mode
    mode=`stat -c %a $1`
    mode_byte=`expr length $mode`
    remaining_mode_byte=$((7 - $mode_byte))
    for i in `seq $remaining_mode_byte`
    do
        total+='0'
    done
    #adding to total
    total+=$mode

    #file uid and gid
    uid=`stat -c %u $1`
    uid=`printf "%o" $uid`   
    uid_byte=`expr length $uid`
    remaining_uid_byte=$((7 - $uid_byte))   
    for i in `seq $remaining_uid_byte`
    do
        total+='0'
    done 
    #adding to total
    total+=$uid
    gid=`stat -c %g $1`
    gid=`printf "%o" $gid`
    gid_byte=`expr length $gid`
    remaining_gid_byte=$((7 - $gid_byte))
    for i in `seq $remaining_gid_byte`
    do
        total+='0'
    done 
    #adding to total
    total+=$gid  

    #file size
    size=`stat -c %s $1`
    size=`printf "%o" $size`
    size_byte=`expr length $size`
    remaining_size_byte=$((11 - $size_byte))
    for i in `seq $remaining_size_byte`
    do
        total+='0'
    done
    #adding to total
    total+=$size  

    #file modified time
    mtime=`stat -c %Y $1`
    mtime=`printf "%o" $mtime`
    mtime_byte=`expr length $mtime`
    remaining_mtime_byte=$((11 - $mtime_byte))
    for i in `seq $remaining_mtime_byte`
    do
        total+='0'
    done
    #adding to total
    total+=$mtime
    #adding to total
    total+=$REGTYPE
    #adding to total
    total+=$TMAGIC

    #user name and group name of the file
    uname=`stat -c %U $1`
    #adding to total
    total+=$uname
    gname=`stat -c %G $1`
    #adding to total
    total+=$gname
    n=${#total}

    #finding the checksum
    for i in `seq $n`
    do
        character=${total:(($i-1)):1}
        ord $character
        cksum=$(($cksum+$val))
    done 

    cksum=$(($cksum+320))
    #converting to octal
    cksum=`printf "%o" $cksum`
}

#function to echo file name in metadata in 100 byte rest null
calculate_file_name() {
    file_name=`stat -c %n $1`
    #echo $file_name
    file_name_bytes=`expr length $1`
    #echo $file_name_bytes
    remaining_file_name_size=$((100 - $file_name_bytes))
    #echo $remaining_file_name_size
    echo -n $file_name >>$2
    for i in `seq $remaining_file_name_size`
    do
        echo -ne '\0'
    done >>$2
}

#function to echo mode in meta data in 8 byte rest null
calculate_mode() {
    mode=`stat -c %a $1`
    #echo $mode
    mode_byte=`expr length $mode`
    #echo $mode_byte
    remaining_mode_byte=$((7 - $mode_byte))
    #echo $remaining_mode_byte
    for i in `seq $remaining_mode_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $mode >>$2
    echo -ne '\0' >>$2
}

#function to echo uid in meta data in 8 byte rest null
calculate_uid() {
    uid=`stat -c %u $1`
    uid=`printf "%o" $uid`
    #echo $uid
    uid_byte=`expr length $uid`
    #echo $uid_byte
    remaining_uid_byte=$((7 - $uid_byte))
    #echo $remaining_uid_byte
    for i in `seq $remaining_uid_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $uid >>$2
    echo -ne '\0' >>$2
}

#function to echo gid in meta data in 8 byte rest null
calculate_gid() {
    gid=`stat -c %g $1`
    gid=`printf "%o" $gid`
    #echo $gid
    gid_byte=`expr length $gid`
    #echo $gid_byte
    remaining_gid_byte=$((7 - $gid_byte))
    #echo $remaining_gid_byte
    for i in `seq $remaining_gid_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $gid >>$2
    echo -ne '\0' >>$2
}

#function to echo size in meta data in 12 byte rest null
calculate_size() {
    size=`stat -c %s $1`
    size=`printf "%o" $size`
    #echo $size
    size_byte=`expr length $size`
    #echo $size_byte
    remaining_size_byte=$((11 - $size_byte))
    #echo $remaining_size_byte
    for i in `seq $remaining_size_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $size >>$2
    echo -ne '\0' >>$2
}

#function to echo modified time  in meta data in 12 byte rest null
calculate_mtime() {
    mtime=`stat -c %Y $1`
    mtime=`printf "%o" $mtime`
    #echo $mtime
    mtime_byte=`expr length $mtime`
    #echo $mtime_byte
    remaining_mtime_byte=$((11 - $mtime_byte))
    #echo $remaining_mtime_byte
    for i in `seq $remaining_mtime_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $mtime >>$2
    echo -ne '\0' >>$2
}

#function to echo checksum calculated earlier in meta data in 8 byte rest null
calculate_chksum() {
    cksum_byte=`expr length $cksum`
    remaining_cksum_byte=$((6 - $cksum_byte))
    for i in `seq $remaining_cksum_byte`
    do
        echo -n '0'
    done >>$2
    echo -n $cksum >>$2
    echo -ne '\0' >>$2
    echo -n ' ' >>$2
}

#type flag fixed to 0 as regular file are handled only
calculate_typeflag() {
    typeflag=$REGTYPE
    echo -n $typeflag >>$2
}

#linkname set to null as regular file are handled 
calculate_linkname() {
    linkname=''
    #echo $linkname
    linkname_byte=0
    #echo $linkname_byte
    remaining_linkname_byte=$((100 - $linkname_byte))
    #echo $remaining_linkname_byte
    #echo -n $linkname >>$2
    for i in `seq $remaining_linkname_byte`
    do
        echo -ne '\0'
    done >>$2
}

#ustar format of tar file
calculate_magic() {
    magic=$TMAGIC
    echo -n $magic >>$2
    echo -n ' ' >>$2
}

#version is 00
calculate_version() {
    version=' '
    echo -n ' ' >>$2
    echo -ne '\0' >>$2
}

#function to echo user name calculated earlier in meta data in 32 byte rest null
calculate_uname() {
    uname=`stat -c %U $1`
    # echo $uname
    uname_byte=`expr length $uname`
    # echo $uname_byte
    remaining_uname_byte=$((32 - $uname_byte))
    # echo $remaining_uname_byte
    echo -n $uname >>$2
    truncate -s +$remaining_uname_byte $2
}

#function to echo group name calculated earlier in meta data in 32 byte rest null
calculate_gname(){
    gname=`stat -c %G $1`
    # echo $gname
    gname_byte=`expr length $gname`
    # echo $gname_byte
    remaining_gname_byte=$((32 - $gname_byte))
    # echo $remaining_gname_byte
    echo -n $gname >>$2
    truncate -s +$remaining_gname_byte $2
}

#device major set to null 8 byte
calculate_devmajor(){
    devmajor=''
    #echo $devmajor
    devmajor_byte=0
    #echo $devmajor_byte
    remaining_devmajor_byte=$((8 - $devmajor_byte))
    #echo $remaining_devmajor_byte
    #echo -n $devmajor >>$2
    truncate -s +$remaining_devmajor_byte $2
}

#device minor set to null 8 byte
calculate_devminor() {
    devminor=''
    #echo $devminor
    devminor_byte=0
    #echo $devminor_byte
    remaining_devminor_byte=$((8 - $devminor_byte))
    #echo $remaining_devminor_byte
    #echo -n $devminor >>$2
    truncate -s +$remaining_devminor_byte $2
}

#prefix set to null 155 byte
calculate_prefix() {
    prefix=''
    #echo $prefix
    prefix_byte=0
    #echo $prefix_byte
    remaining_prefix_byte=$((155 - $prefix_byte))
    #echo $remaining_prefix_byte
    #echo -n $prefix >>$2
    truncate -s +$remaining_prefix_byte $2
}

#padding of null 12 byte
calculate_padding(){
    padding=12
    truncate -s +$padding $2
}

#output file content in blocks of 512 byte
calculate_file_content() {
    #file content
    file_content=`cat $1`
    file_byte=`cat $1 | wc -c`
    #echo $file_byte
    if [ $file_byte -ne 0 ]
    then
        character_in_last_block=`expr $file_byte % 512`
        #echo $character_in_last_block
        remaining_file_size_byte=$((512 - $character_in_last_block))
        `cat $1 >>$2`
        if [ $character_in_last_block -ne 0 ]
        then
            #truncate file remaining byte with null
            truncate -s +$remaining_file_size_byte $2
        fi
    fi
}

#add closig null character to make the block multiple of 20
add_closing_block() {
    block_no=$2
    ending_null=$((512*$block_no))
    truncate -s +$ending_null $1
}

#preprocess output tar file such that if present delete it and then make it again
preprocess_output_file() {
    if test -e "$1";
    then
        `rm $1`
    fi
    `touch $1`
}


#function to perform cummulative task of all the metadata in the archived tar file
#-------------------------------METADATA---------------------------
make_tar_file() {
    cksum=0
    calculate_check_sum $1
    calculate_file_name $1 $2
    calculate_mode $1 $2
    calculate_uid $1 $2
    calculate_gid $1 $2
    calculate_size $1 $2
    calculate_mtime $1 $2
    calculate_chksum $1 $2
    calculate_typeflag $1 $2
    calculate_linkname $1 $2
    calculate_magic $1 $2
    calculate_version $1 $2
    calculate_uname $1 $2
    calculate_gname $1 $2
    calculate_devmajor $1 $2
    calculate_devminor $1 $2
    calculate_prefix $1 $2
    calculate_padding $1 $2
    calculate_file_content $1 $2
}
#---------------------------METADATA-------------------------------------

#extracting name of the file from archived tar file
extract_name() {
    extracted_file_name=`head -c $(($(($2*512))+100)) $1 | tail -c 100`
    # echo $extracted_file_name
}

#extracting mode of the file from archived tar file
extract_mode() {
    extracted_file_mode=`head -c $(($(($2*512))+107)) $1 | tail -c 7 | sed 's/^0*//'`
    # echo $extracted_file_mode
}

#extracting user id of the file from archived tar file
extract_uid() {
    extracted_file_uid=`head -c $(($(($2*512))+115)) $1 | tail -c 7 | sed 's/^0*//'`
    # echo $extracted_file_uid
}

#extracting user gid of the file from archived tar file
extract_gid() {
    extracted_file_gid=`head -c $(($(($2*512))+123)) $1 | tail -c 7 | sed 's/^0*//'`
    # echo $extracted_file_gid
}

#extracting size of the file from archived tar file
extract_size() {
    extracted_file_size=`head -c $(($(($2*512))+135)) $1 | tail -c 11 | sed 's/^0*//'`
    extracted_file_size=$((8#$extracted_file_size))
    #echo $extracted_file_size
}

#extracting modified time of the file from archived tar file
extract_mtime() {
    extracted_file_mtime=`head -c $(($(($2*512))+147)) $1| tail -c 11 | sed 's/^0*//'`
    extracted_file_mtime=$((8#$extracted_file_mtime))
    # echo $extracted_file_mtime
}

#extracting checksum of the file from archived tar file
extract_cksum() {
    extracted_file_cksum=`head -c $(($(($2*512))+154)) $1| tail -c 6 | sed 's/^0*//'`
    # echo $extracted_file_cksum
}

#extracting type of the file from archived tar file
extract_typeflag() {
   extracted_file_typeflag=`head -c $(($(($2*512))+157)) $1| tail -c 1 | awk '{printf "%d\n",$0;}'`
    # echo $extracted_file_typeflag
}

#extracting user name of the file from archived tar file
extract_uname() {
    extracted_file_uname=`head -c $(($(($2*512))+297)) $1| tail -c 32`
    # echo $extracted_file_uname
}

#extracting group name of the file from archived tar file
extract_gname() {
    extracted_file_gname=`head -c $(($(($2*512))+329)) $1| tail -c 32`
    # echo $extracted_file_gname
}

#extracting content of the file from archived tar file
extract_content() {
    extracted_file_content=$"`head -c $((512+$(($2*512))+$extracted_file_size)) $1| tail -c $extracted_file_size`"
    # echo $extracted_file_content
}

#make the required file and set the previous properties
extract_file_with_properties() {

    preprocess_output_file $extracted_file_name
    echo -n "$extracted_file_content" >$extracted_file_name
    # chown $extracted_file_uname $extracted_file_name
    # chgrp $extracted_file_gname $extracted_file_name
    chmod $extracted_file_mode $extracted_file_name
    touch -m --date=@$extracted_file_mtime $extracted_file_name

}

#function to archive file
archive_process() {
   
    #preprocess ouput file
    preprocess_output_file $1

    #block count
    output_block=0

    #loop through all the file to be archived
    for file in "${files[@]}"
    do
        #call the make tar function
        make_tar_file $file $1

        #verbose option
        if [ $verbose -eq 1 ]
        then
            echo $file
        fi

        #increment the block count
        output_block=$(($output_block+1))
        output_file_size=`stat -c %s $file`
        content_block=`expr $output_file_size / 512`
        output_block=$(($output_block+$content_block))
        if [ `expr $output_file_size % 512` -ne 0 ]
        then
            output_block=$(($output_block+1))
        fi
        #done
    done

    #closing null block count 
    output_block=`expr $output_block % 20`
    output_block=$((20 - $output_block))
    if [ $output_block -eq 20 ]
    then
        output_block=0
    fi
    
    #adding that null block
    add_closing_block $1 $output_block
}

#extract function for extracting all files from tar archived file
extract_process() {

    #given tar file to extracted
    input_file=$1

    #block count
    extract_block=0
    while true
    do

        #calling various function to extract different part of the meta data
        extract_name $input_file $extract_block
        extract_mode $input_file $extract_block
        extract_uid $input_file $extract_block
        extract_gid $input_file $extract_block
        extract_size $input_file $extract_block
        extract_mtime $input_file $extract_block
        extract_cksum $input_file $extract_block
        extract_typeflag $input_file $extract_block
        extract_uname $input_file $extract_block
        extract_gname $input_file $extract_block
        extract_content $input_file $extract_block

        #making and setting file properties calculated above
        extract_file_with_properties

        #checking for verbose
        if [ $verbose -eq 1 ]
        then
            echo $extracted_file_name
        fi

        #increment extract block
        extract_block=$(($extract_block+1))
        content_block=`expr $extracted_file_size / 512`
        extract_block=$(($extract_block+$content_block))
        if [ `expr $extracted_file_size % 512` -ne 0 ]
        then
            extract_block=$(($extract_block+1))
        fi

        #checking for program termination
        check="`head -c $(($(($extract_block*512))+1)) $input_file | tail -c 1`"
        if [[ "$check" == '' ]]
        then
            break
        fi
    done

}

#function to append file at the end of given tar file
append_process() {
    #calculate original file size
    append_size() {
        appended_file_size=`head -c $(($(($2*512))+135)) $1 | tail -c 11 | sed 's/^0*//'`
        appended_file_size=$((8#$appended_file_size))
        #echo $appended_file_size
    }
    #append file
    append_file=$1
    #block count
    append_block=0

    #loop to count no of blocks 
    while true
    do
        #calculate file size
        append_size $append_file $append_block
        append_block=$(($append_block+1))
        content_block=`expr $appended_file_size / 512`
        append_block=$(($append_block+$content_block))

        #increment block count
        if [ `expr $appended_file_size % 512` -ne 0 ]
        then
            append_block=$(($append_block+1))
        fi

        #checking for termination
        check="`head -c $(($(($append_block*512))+1)) $append_file | tail -c 1`"
        if [[ "$check" == '' ]]
        then
            break
        fi

    done

    #truncate file upto block count and thus removing trailing null character
    truncate -s $(($append_block*512)) $append_file

    #appending file now
    for file in "${files[@]}"
    do
        #calling the same make file function
        make_tar_file $file $append_file

        #verbose
        if [ $verbose -eq 1 ]
        then
            echo $file
        fi

        #incrementing block count
        append_block=$(($append_block+1))
        appended_file_size=`stat -c %s $file`
        content_block=`expr $appended_file_size / 512`
        append_block=$(($append_block+$content_block))
        if [ `expr $appended_file_size % 512` -ne 0 ]
        then
            append_block=$(($append_block+1))
        fi
        #done
    done
    
    #calculating trailling null character
    append_block=`expr $append_block % 20`
    append_block=$((20 - $append_block))
    if [ $append_block -eq 20 ]
    then
        append_block=0
    fi

    #adding the closing block
    add_closing_block $append_file $append_block
}

#for t option calculating the file size already present at particular bock
list_size() {
    list_file_size=`head -c $(($(($2*512))+135)) $1 | tail -c 11 | sed 's/^0*//'`
    list_file_size=$((8#$list_file_size))
    #echo $list_file_size
}

#for t option calculating the file name already present at particular bock
list_name() {
    list_file_name=`head -c $(($(($2*512))+100)) $1 | tail -c 100`
    #echo $list_file_name
}

#for t option calculating the file mode already present at particular bock
list_mode() {
    list_file_mode=`head -c $(($(($2*512))+107)) $1 | tail -c 7 | sed 's/^0*//'`
    # echo $list_file_mode
}

#for t option calculating the file user name already present at particular bock
list_uname() {
    list_file_uname=`head -c $(($(($2*512))+297)) $1| tail -c 32`
    # echo $list_file_uname
}

#for t option calculating the file group name already present at particular bock
list_gname() {
    list_file_gname=`head -c $(($(($2*512))+329)) $1| tail -c 32`
    # echo $list_file_gname
}

#for t option calculating the file modified time already present at particular bock
list_mtime() {
    list_file_mtime=`head -c $(($(($2*512))+147)) $1| tail -c 11 | sed 's/^0*//'`
    list_file_mtime=$((8#$list_file_mtime))
    # echo $list_file_mtime
}

#convert function to change mode format like 664 to -rw-rw-r--
convert_mode() {
    a=$1
    r=`expr $a / 4`
    a=`expr $a % 4`
    w=`expr $a / 2`
    a=`expr $a % 2`
    x=$a
    ans=''
    if [ $r -eq 1 ]
    then
        ans+='r'
    else
        ans+='-'
    fi
    if [ $w -eq 1 ]
    then
        ans+='w'
    else
        ans+='-'
    fi
    if [ $x -eq 1 ]
    then
        ans+='x'
    else
        ans+='-'
    fi
    echo -n $ans
}

#handling t option
list_process() {

    #given tar file
    list_file=$1

    #calculate block 
    list_block=0

    #looping through all file
    while true
    do

        #calling various function to get various file properties
        list_size $list_file $list_block
        list_mode $list_file $list_block
        list_uname $list_file $list_block
        list_gname $list_file $list_block
        list_mtime $list_file $list_block
        list_name $list_file $list_block

        #handling verbose
        if [ $verbose -eq 1 ]
        then
            #managing date format
            list_file_mtime=`date --date=@$list_file_mtime "+%Y-%m-%d %H:%M"`
            #handling permission
            read_permission=${list_file_mode:0:1}
            write_permission=${list_file_mode:1:1}
            execute_permission=${list_file_mode:2:1}

            echo -n '-'
            #convert permission
            convert_mode $read_permission
            convert_mode $write_permission
            convert_mode $execute_permission
            #echo like ls
            echo " $list_file_uname/$list_file_gname $list_file_size  $list_file_mtime $list_file_name"
        else
            #echo file name if v absent
            echo $list_file_name
        fi
        
        #incrementing block count
        list_block=$(($list_block+1))
        content_block=`expr $list_file_size / 512`
        list_block=$(($list_block+$content_block))
        if [ `expr $list_file_size % 512` -ne 0 ]
        then
            list_block=$(($list_block+1))
        fi

        #checking for termination of loop
        check="`head -c $(($(($list_block*512))+1)) $list_file | tail -c 1`"
        if [[ "$check" == '' ]]
        then
            break
        fi
    done
}

#setting various flags to 0
c_flag=0
x_flag=0
verbose=0
r_flag=0
t_flag=0
f_flag=0

#checking which flags are present
while getopts "cxrvtf" flag;
do
    case $flag in
    f) f_flag=1;;
    c) c_flag=1 ;;
    x) x_flag=1 ;;
    v) verbose=1 ;;
    r) r_flag=1;;
    t) t_flag=1 ;;
    esac
done

#f flag should be present
if [ $f_flag -eq 1 ]
then
    #only xf vr rf cf or xvf rvf tvf cvf can be present otherwise error
    if ([ $c_flag -eq 0 ] && [ $r_flag -eq 0 ] && [ $t_flag -eq 0 ] && [ $x_flag -eq 0 ]) || ([ $c_flag -eq 1 ] && ([ $x_flag -eq 1 ] || [ $t_flag -eq 1 ] || [ $r_flag -eq 1 ])) || ([ $x_flag -eq 1 ] && ([ $r_flag -eq 1 ] || [ $t_flag -eq 1 ])) || ([ $t_flag -eq 1 ] && [ $r_flag -eq 1 ])
    then
        echo "Error: You must specify one and only one among 'r' , 'x' or 'c' "
    else
        #if c is present then archive
        if [ $c_flag -eq 1 ]
        then
            #calculate no of files
            no_of_files=$(($#-1))
            tar_file=$2
            files=()
            #store files
            for i in `seq $(($no_of_files-1))`
            do
                i=$(($i+2))
                files+=("${!i}")
            done
            #error check on tar file
            if [ $# -eq 1 ]
            then
                echo "option requires an argument -- 'f'"
                exit
            fi
            #error check on no of files
            if [ $(($no_of_files-1)) -eq 0 ]
            then
                echo "Cowardly refusing to create an empty archive"
                exit
            fi
            #checking that file is valid
            for file in "${files[@]}"
            do
                if ! test -e $file
                then
                    echo "Error: $file: Cannot stat: No such file or directory "
                    exit
                fi
            done
            #run the process
            archive_process $tar_file $files
        fi

        #if x is present 
        if [ $x_flag -eq 1 ]
        then
            #calculate no of files
            no_of_files=$(($#-1))
            tar_file=$2
            files=()
            #store files but work on only the tar file 
            for i in `seq $(($no_of_files-1))`
            do
                i=$(($i+2))
                files+=("${!i}")
            done       
            #check if a file is present
            if [ $# -eq 1 ]
            then
                echo "option requires an argument -- 'f'"
                exit
            fi   
            #check if tar file is present
            if ! test -e $tar_file
            then
                echo "Error: $tar_file: Cannot open: No such file or directory"
                exit
            fi           

            #run process
            extract_process $tar_file
        fi

        #if r flag is there
        if [ $r_flag -eq 1 ]
        then
            #calculate no of files
            no_of_files=$(($#-1))
            tar_file=$2
            files=()
            #store files
            for i in `seq $(($no_of_files-1))`
            do
                i=$(($i+2))
                files+=("${!i}")
            done  

            #check if argument is given
            if [ $# -eq 1 ]
            then
                echo "option requires an argument -- 'f'"
                exit
            fi  

            #all files are correct
            for file in "${files[@]}"
            do
                if ! test -e $file
                then
                    echo "Error: $file: Cannot stat: No such file or directory "
                    exit
                fi
            done

            #tar file is not present then run the cvf code
            if ! test -e $tar_file
            then
                archive_process $tar_file $files
                exit
            fi 

            #else run the append code
            append_process $tar_file $files
        fi

        #t flag is present
        if [ $t_flag -eq 1 ]
        then
            #calculate no of files
            no_of_files=$(($#-1))
            tar_file=$2
            files=()    

            #store files but work on only the tar file 
            for i in `seq $(($no_of_files-1))`
            do
                i=$(($i+2))
                files+=("${!i}")
            done    

            #check if a file is present
            if [ $# -eq 1 ]
            then
                echo "option requires an argument -- 'f'"
                exit
            fi    

            #check if tar file is present
            if ! test -e $tar_file
            then
                echo "Error: $tar_file: Cannot open: No such file or directory"
                exit
            fi      
            #run process
            list_process $tar_file

        fi
    fi
else 
    #else error
    echo "Error: Invalid argument"
fi