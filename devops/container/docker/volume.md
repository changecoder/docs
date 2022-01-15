# Volume

## 创建一个数据卷
```
docker volume create data-volume
```
查看目录卷所在目录
```
docker volume inspect data-volume
```
默认是在/var/lib/docker目录下， 对应/var/lib/docker/data-volume目录