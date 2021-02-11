Title: iSCSI
Date: 2021/02/10
Category: Cloud Computing
Header_Cover: theme/images/banner-hlc.jpg
Tags: iSCSI

- Crea un target con una LUN y conéctala a un cliente GNU/Linux. Explica cómo escaneas desde el cliente buscando los targets disponibles y utiliza la unidad lógica proporcionada, formateándola si es necesario y montándola.
- Utiliza systemd mount para que el target se monte automáticamente al arrancar el cliente
- Crea un target con 2 LUN y autenticación por CHAP y conéctala a un cliente windows. Explica cómo se escanea la red en windows y cómo se utilizan las unidades nuevas (formateándolas con NTFS)

--------------------------------------------------------------------------------

En este artículo vamos a configurar un escenario con *Vagrant* que incluirá varias máquinas, y permitirá realizar la configuración de un servidor **iSCSI** y dos clientes, (uno linux y otro windows).

## ¿Qué es iSCSI?

**iSCSI** es un extensión de *SCSI*, que es un protocolo para comunicación de dispositivos. *SCSI* suele usarse en dispositivos conectados físicamente a un *host* o servidor, tales como discos duros, lectoras de CDs, ... En *iSCSI*, los comandos *SCSI* que manejan el dispositivo, se envían a través de la red. De forma que en vez de tener un disco *SCSI* conectado físicamente a nuestro equipo, lo conectamos por medio de la red.

¿Eso quiere decir que es lo mismo que *Samba* o *NFS*? Pues no, ya que esos sistemas trabajan importando un sistema de archivos mediante la red, mientras que *iSCSI* importa todo el dispositivo hardware por la red, de manera que en el cliente es detectado como un dispositivo *SCSI* más. Todo esto se hace de forma transparente, como si el disco estuviera conectado directamente al hardware.

Es una gran alternativa económica a *FiberChannel*.

[.](images/hlc_iSCSI/iscsi.png)

Y respecto a la velocidad, ¿es rápido, es lento? Un requisito indispensable de un buen disco es que sea rápido. Los discos *SCSI* suelen entregar excelentes tasas de transferencia. Pero recordemos que *iSCSI* se lleva sobre la red, por eso mismo, *iSCSI* es recomendado solo para redes conmutadas de alta velocidad.

La velocidad de transferencia del *iSCSI* es de **1000 MB/seg**, aunque debido al protocolo, la velocidad baja hasta *800 MB/seg*. En caso de que utilicemos tarjetas DUAL CHANNEL, como las que tienen los QNAP, podremos llegar a 1600 MB/Seg, teniendo en cuenta las pérdidas por protocolo.











































.
