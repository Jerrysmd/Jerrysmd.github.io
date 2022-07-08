# The Advanced method of reading files


Read the binary file (any file will do; this article uses binary as an example) and read the entire contents of the binary file into a char* string. With fseek() and fread() functions to achieve file reading advanced methods. 
<!--more-->

# 需求
* 使用fwrite(dbdata, dblength, 1,fp)把字节流写入二进制文件。在新程序读取二进制文件遇到问题：二进制内容不能向文本一样行读取，也不知道二进制文件长度，在fread()函数中无从下手。
---
## 1.creat FILE pointer and set mode as 'rb'
```c
FILE *f = fopen(inputFN, "rb");
```
## 2.check the FILE pointer is not null
```c
if (!f) {
        fprintf(stderr, "ERROR: unable to open file \"%s\": %s\n", inputFN,strerror(errno));
        return NULL;
}
```
## 3.use fseek/ftell to get data length
* fseek(f,0,SEEK_END) put the pointer to the end of the file.
* ftell(f) can get the current offset.
* then use fseek(f,0,SEEK_SET) put the pointer to the start of file.
```c
if (fseek(f, 0, SEEK_END) != 0) {
        fprintf(stderr, "ERROR: unable to seek file \"%s\": %s\n", inputFN,
                strerror(errno));
        fclose(f);
        return NULL;
}
long datalen = ftell(f);
if (dataLen < 0) {
        fprintf(stderr, "ERROR: ftell() failed: %s\n", strerror(errno));
        fclose(f);
        return NULL;
}
    if (fseek(f, 0, SEEK_SET) != 0) {
        fprintf(stderr, "ERROR: unable to seek file \"%s\": %s\n", inputFN,
                strerror(errno));
        fclose(f);
        return NULL;
    }
```
## 4.check the datalen
```c
if ((unsigned long)dataLen > UINT_MAX) {
        dataLen = UINT_MAX;
        printf("WARNING: clipping data to %ld bytes\n", dataLen);
    } else if (dataLen == 0) {
        fprintf(stderr, "ERROR: input file \"%s\" is empty\n", inputFN);
        fclose(f);
        return NULL;
    }
```
## 5.malloc memory to char *inputData
```c
char *inputData = static_cast<char *>(malloc(dataLen));
    if (!inputData) {
        fprintf(stderr, "ERROR: unable to malloc %ld bytes\n", dataLen);
        fclose(f);
        return NULL;
    }
```
## 6.read the bin data
```c
// create a pointer p to point the begin of the inputData
char *p = inputData;
// create a bytesLeft to record the moving of offset
size_t bytesLeft = dataLen;
while (bytesLeft) {
	//fread will return the bytes of read
        size_t bytesRead = fread(p, 1, bytesLeft, f);
        bytesLeft -= bytesRead;
        p += bytesRead;
        if (ferror(f) != 0) {
            fprintf(stderr, "ERROR: fread() failed\n");
            free(inputData);
            fclose(f);
            return NULL;
	}
}
```
## 7.close the File stream
```c
fclose(f);
```
## 8.return length & inputData
```c
//change the parameter of &length
*length = (unsigned int)dataLen;
return inputData;
```
## 9.完整代码
```c
    FILE *f = fopen(inputFN, "rb");
    if (!f) {
        fprintf(stderr, "ERROR: unable to open file \"%s\": %s\n", inputFN,strerror(errno));
        return NULL;
    }

    if (fseek(f, 0, SEEK_END) != 0) {
        fprintf(stderr, "ERROR: unable to seek file \"%s\": %s\n", inputFN,
                strerror(errno));
        fclose(f);
        return NULL;
    }
    long dataLen = ftell(f);
    if (dataLen < 0) {
        fprintf(stderr, "ERROR: ftell() failed: %s\n", strerror(errno));
        fclose(f);
        return NULL;
    }
    if (fseek(f, 0, SEEK_SET) != 0) {
        fprintf(stderr, "ERROR: unable to seek file \"%s\": %s\n", inputFN,
                strerror(errno));
        fclose(f);
        return NULL;
    }

    if ((unsigned long)dataLen > UINT_MAX) {
        dataLen = UINT_MAX;
        printf("WARNING: clipping data to %ld bytes\n", dataLen);
    } else if (dataLen == 0) {
        fprintf(stderr, "ERROR: input file \"%s\" is empty\n", inputFN);
        fclose(f);
        return NULL;
    }

    char *inputData = static_cast<char *>(malloc(dataLen));
    if (!inputData) {
        fprintf(stderr, "ERROR: unable to malloc %ld bytes\n", dataLen);
        fclose(f);
        return NULL;
    }

    char *p = inputData;
    size_t bytesLeft = dataLen;
    while (bytesLeft) {
        size_t bytesRead = fread(p, 1, bytesLeft, f);
        bytesLeft -= bytesRead;
        p += bytesRead;
        if (ferror(f) != 0) {
            fprintf(stderr, "ERROR: fread() failed\n");
            free(inputData);
            fclose(f);
            return NULL;
        }
    }

    fclose(f);

    *length = (unsigned int)dataLen;
```

