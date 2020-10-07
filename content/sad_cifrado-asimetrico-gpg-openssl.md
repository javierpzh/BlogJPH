Title: Cifrado asimétrico con gpg y openssl
Date: 2020/10/08
Category: Seguridad y Alta Disponibilidad

## Cifrado asimétrico con gpg

En esta práctica vamos a cifrar ficheros utilizando cifrado asimétrico utilizando el programa gpg. Puedes encontrar el resumen de comando en esta [chuleta](https://elbauldelprogramador.com/chuleta-de-comandos-para-gpg/) o buscar información en internet.

### Tarea 1: Generación de claves.

Los algoritmos de cifrado asimétrico utilizan dos claves para el cifrado y descifrado de mensajes. Cada persona involucrada (receptor y emisor) debe disponer, por tanto, de una pareja de claves pública y privada. Para generar nuestra pareja de claves con gpg utilizamos la opción --gen-key:

Para esta práctica no es necesario que indiquemos frase de paso en la generación de las claves (al menos para la clave pública).

**1. Genera un par de claves (pública y privada). ¿En que directorio se guarda las claves de un usuario?**

Para generar un nuevo par de claves, utlizamos el siguiente comando:
<pre>
gpg --gen-key
</pre>
Aquí muestro como lo he relizado yo:
<pre>
javier@debian:~$ gpg --gen-key
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Nota: Usa "gpg --full-generate-key" para el diálogo completo de generación de clave.

GnuPG debe construir un ID de usuario para identificar su clave.

Nombre y apellidos: Javier Pérez Hidalgo
Dirección de correo electrónico: reyole111@gmail.com
Está usando el juego de caracteres 'utf-8'.
Ha seleccionado este ID de usuario:
    "Javier Pérez Hidalgo <reyole111@gmail.com>"

¿Cambia (N)ombre, (D)irección o (V)ale/(S)alir? v
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
gpg: clave E446ACC5CFC7D182 marcada como de confianza absoluta
gpg: creado el directorio '/home/javier/.gnupg/openpgp-revocs.d'
gpg: certificado de revocación guardado como '/home/javier/.gnupg/openpgp-revocs.d/17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182.rev'
claves pública y secreta creadas y firmadas.

pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
      17A7AC2D8A4E98A191B8A5A7E446ACC5CFC7D182
uid                      Javier Pérez Hidalgo <reyole111@gmail.com>
sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

javier@debian:~$
</pre>
Antes de completar el proceso nos va a saltar una ventana donde vamos a tener que especificar nuestra contraseña.
Las claves y los datos que se crean se guardan en el directorio '.gnupg'.

**2. Lista las claves públicas que tienes en tu almacén de claves. Explica los distintos datos que nos muestra. ¿Cómo deberías haber generado las claves para indicar, por ejemplo, que tenga un 1 mes de validez?**



**3. Lista las claves privadas de tu almacén de claves.**




### Tarea 2: Importar / exportar clave pública.

Para enviar archivos cifrados a otras personas, necesitamos disponer de sus claves públicas. De la misma manera, si queremos que cierta persona pueda enviarnos datos cifrados, ésta necesita conocer nuestra clave pública. Para ello, podemos hacérsela llegar por email por ejemplo. Cuando recibamos una clave pública de otra persona, ésta deberemos incluirla en nuestro keyring o anillo de claves, que es el lugar donde se almacenan todas las claves públicas de las que disponemos.

**1. Exporta tu clave pública en formato ASCII y guárdalo en un archivo nombre_apellido.asc y envíalo al compañero con el que vas a hacer esta práctica.**



**2. Importa las claves públicas recibidas de vuestro compañero.**



**3. Comprueba que las claves se han incluido correctamente en vuestro keyring.**




### Tarea 3: Cifrado asimétrico con claves públicas.

Tras realizar el ejercicio anterior, podemos enviar ya documentos cifrados utilizando la clave pública de los destinatarios del mensaje.

**1. Cifraremos un archivo cualquiera y lo remitiremos por email a uno de nuestros compañeros que nos proporcionó su clave pública.**



**2. Nuestro compañero, a su vez, nos remitirá un archivo cifrado para que nosotros lo descifremos.**



**3. Tanto nosotros como nuestro compañero comprobaremos que hemos podido descifrar los mensajes recibidos respectivamente.**



**4. Por último, enviaremos el documento cifrado a alguien que no estaba en la lista de destinatarios y comprobaremos que este usuario no podrá descifrar este archivo.**



**5. Para terminar, indica los comandos necesarios para borrar las claves públicas y privadas que posees.**




### Tarea 4: Exportar clave a un servidor público de claves PGP.

Para distribuir las claves públicas es mucho más habitual utilizar un servidor específico para distribuirlas, que permite a los clientes añadir las claves públicas a sus anillos de forma mucho más sencilla.

**1. Genera la clave de revocación de tu clave pública para utilizarla en caso de que haya problemas.**



**2. Exporta tu clave pública al servidor `pgp.rediris.es` .**



**3. Borra la clave pública de alguno de tus compañeros de clase e impórtala ahora del servidor público de rediris.**




### Tarea 5: Cifrado asimétrico con openssl.

En esta ocasión vamos a cifrar nuestros ficheros de forma asimétrica utilizando la herramienta openssl.

**1. Genera un par de claves (pública y privada).**



**2. Envía tu clave pública a un compañero.**



**3. Utilizando la clave pública cifra un fichero de texto y envíalo a tu compañero.**



**4. Tu compañero te ha mandado un fichero cifrado, muestra el proceso para el descifrado.**
