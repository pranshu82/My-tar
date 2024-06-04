# ShellScript_replicating_tar_command
The command that has to be typed from command prompt to execute your programme:
 	 ``
	 bash my_tar.sh [flags] [files]
   ``


________________________________________________________________________________


### various format encountered are:

* cf:
  ```
        bash my_tar.sh -cf [sample_file].tar [file1] [file2] [file3] ...
  ```
    where [files] can be any text file that needed to be archived and [sample_file] is the file name of the tar file generated

* cvf:
  ```
        bash my_tar.sh -cvf sample_file.tar [file1] [file2] [file3] ...
  ```

    where [files] can be any text file that needed to be archived and [sample_file] is the file name of the tar file generated

* xf:
  ```
        bash my_tar.sh -xf [sample_file].tar
  ```

    where [sample_file] is the tar file that need to be extracted

* xvf:
 	```
        bash my_tar.sh -xvf [sample_file].tar
	```
    where [sample_file] is the tar file that need to be extracted

* tf:
  ```
        bash my_tar.sh -tf [sample_file].tar
  ```
    where [sample_file] is the tar file whose content need to be displayed

* tvf:
	```
        bash my_tar.sh -tvf [sample_file].tar
	```
    where [sample_file] is the tar file whose content need to be displayed

* rf:
	```
        bash my_tar.sh -rf [sample_file].tar [file1] [file2] [file3] ...
	```
    where [files] can be any text file that needed to be appended to the archive and [sample_file] is the file name of the tar file where to append the given files

* rvf:
	```
        bash my_tar.sh -rvf [sample_file].tar [file1] [file2] [file3] ...
	```
    where [files] can be any text file that needed to be appended to the archive and [sample_file] is the file name of the tar file where to append the given files

### eg code:
    bash my_tar.sh -cvf test.tar *.cpp
    rm *.cpp
    bash my_tar.sh -xvf test.tar
    bash my_tar.sh -rvf test.tar *.c
    rm *.cpp *.c
    bash my_tar.sh -xvf test.tar
    bash my_tar.sh -tvf test.tar

### similarly this can also be done
    bash my_tar.sh -cf test.tar *.cpp
    rm *.cpp
    bash my_tar.sh -xf test.tar
    bash my_tar.sh -rf test.tar *.c
    rm *.cpp *.c
    bash my_tar.sh -xf test.tar
    bash my_tar.sh -tf test.tar


IMPLEMENTATION:
I hane tried to replicate exactly the behaviour of tar command.
i have implemented the given above option.

basically i have implemented the program in block format of 512 byte.
the metadata is 512 byte and consists all the basic information like:
```
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
```
etc. total of 512 byte of metadata 
then content of file is there in blocks of 512 byte is there.

then the same process is repeated over all file.
this is exactly similar to actual tar command format 
