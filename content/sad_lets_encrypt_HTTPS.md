Title: Let's Encrypt HTTPS
Date: 2020/11/24
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: HTTPS, Let's Encrypt

#### Vamos a configurar el protocolo HTTPS para el acceso a nuestras aplicaciones, para ello tienes que tener en cuenta los siguiente.

**1. Vamos a utilizar el servicio `https://letsencrypt.org` para solicitar los certificados de nuestras páginas.**



**2. Explica detenidamente cómo se solicita un certificado en *Let's Encrypt*. En tu explicación deberás responder a estas preguntas:**

**¿Qué función tiene el cliente ACME?**



**¿Qué configuración se realiza en el servidor web?**



**¿Qué pruebas realiza *Let's Encrypt* para asegurar que somos los administrados del sitio web?**



**¿Se puede usar el DNS para verificar que somos administradores del sitio?**




**3. Utiliza dos ficheros de configuración de *Nginx*: uno para la configuración del *virtualhost* HTTP y otro para la configuración del virtualhost HTTPS.**



**4. Realiza una redirección o una reescritura para que cuando accedas a HTTP te redirija al sitio HTTPS.**



**5. Comprueba que se ha creado una tarea *cron* que renueva el certificado cada 3 meses.**



**6. Comprueba que las páginas son accesible por HTTPS y visualiza los detalles del certificado que has creado.**



**7. Modifica la configuración del cliente de *Nextcloud* para comprobar que sigue en funcionamiento con HTTPS.**




#### Recursos interesantes

- [¿Qué es Let’s Encrypt y como configurarlo?](https://medium.com/@alonsus91/que-es-lets-encrypt-y-como-configurarlo-dae155f62a57)

- [¿Cómo funciona Let's Encrypt?](https://letsencrypt.org/es/how-it-works/)
