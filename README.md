NAME : PRANSHU KANDOI
ROLL NO : 200101086
PROGRAMMING LANGUAGE USER : BASH
CS242 ASSIGNMENT 3 : PROBLEM 2

to run the program:
        bash 200101086.sh [flags] [files]

various format encountered are:

cf:
        bash 200101086.sh -cf [sample_file].tar [file1] [file2] [file3] ...

    where [files] can be any text file that needed to be archived and [sample_file] is the file name of the tar file generated

cvf:
        bash 200101086.sh -cvf sample_file.tar [file1] [file2] [file3] ...

    where [files] can be any text file that needed to be archived and [sample_file] is the file name of the tar file generated

xf:
        bash 200101086.sh -xf [sample_file].tar

    where [sample_file] is the tar file that need to be extracted

xvf:
        bash 200101086.sh -xvf [sample_file].tar

    where [sample_file] is the tar file that need to be extracted

tf:
        bash 200101086.sh -tf [sample_file].tar

    where [sample_file] is the tar file whose content need to be displayed

tvf:
        bash 200101086.sh -tvf [sample_file].tar

    where [sample_file] is the tar file whose content need to be displayed

rf:
        bash 200101086.sh -rf [sample_file].tar [file1] [file2] [file3] ...

    where [files] can be any text file that needed to be appended to the archive and [sample_file] is the file name of the tar file where to append the given files

rvf:
        bash 200101086.sh -rvf [sample_file].tar [file1] [file2] [file3] ...

    where [files] can be any text file that needed to be appended to the archive and [sample_file] is the file name of the tar file where to append the given files

eg code:
    bash 200101086.sh -cvf test.tar *.cpp
    rm *.cpp
    bash 200101086.sh -xvf test.tar
    bash 200101086.sh -rvf test.tar *.c
    rm *.cpp *.c
    bash 200101086.sh -xvf test.tar
    bash 200101086.sh -tvf test.tar

similarly this can also be done
    bash 200101086.sh -cf test.tar *.cpp
    rm *.cpp
    bash 200101086.sh -xf test.tar
    bash 200101086.sh -rf test.tar *.c
    rm *.cpp *.c
    bash 200101086.sh -xf test.tar
    bash 200101086.sh -tf test.tar


IMPLEMENTATION:
I hane tried to replicate exactly the behaviour of tar command.
i have implemented the given above option.

basically i have implemented the program in block format of 512 byte.
the metadata is 512 byte and consists all the basic information like
-name 100 byte
-mode 8
-uid 8
-gid 8
-size 12
-mtime 12
-chksum 8
-typeflag 1
-magic 6
-version 2
-uname 32
-gname 32
etc. total of 512 byte of metadata 
then content of file is there in blocks of 512 byte is there.

then the same process is repeated over all file.
this is exactly similar to actual tar command format 