# gen-signed-cert

## THIS IS FOR DEVELOPMENT, DO NOT USE IN PRODUCTION (:

This image generates a certificate signed by a certificate 
authority **for development purposes**

Chrome (at least on Android) requires certificates that are signed.

The only useful volume is `/certs`. This is where certs are generated.
You can also provide an existent certificate authority, but must be named 
`/certs/ca.pem` and `/certs/ca.key` and it must not contain a password.

