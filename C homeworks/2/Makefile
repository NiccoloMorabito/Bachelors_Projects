all: 2.server 2.client

2.server : 2.server.c
	gcc -Wall -Werror -g 2.server.c -o 2.server
	
2.client : 2.client.c
	gcc -Wall -Werror -g 2.client.c -o 2.client

.PHONY: clean
clean: 
	rm -f 2.client
	rm -f 2.server
