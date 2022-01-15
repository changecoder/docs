.PHONY: sync
sync:
	rsync -av ~/workspace/docs root@47.242.177.227:~/dev/ 
