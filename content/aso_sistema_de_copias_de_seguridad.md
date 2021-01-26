Title: Sistema de copias de seguridad
Date: 2021/01/26
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: OpenStack, Bacula, Backup

--------------------------------------------------------------------------------

- Selecciona una aplicación para realizar el proceso: bacula, amanda, shell script con tar, rsync, dar, afio, etc.
- Utiliza una de las instancias como servidor de copias de seguridad, añadiéndole un volumen y almacenando localmente las copias de seguridad que consideres adecuadas en él.
- El proceso debe realizarse de forma completamente automática
- Selecciona qué información es necesaria guardar (listado de paquetes, ficheros de configuración, documentos, datos, etc.)
- Realiza semanalmente una copia completa
- Realiza diariamente una copia incremental, diferencial o delta diferencial (decidir cual es más adecuada)
- Implementa una planificación del almacenamiento de copias de seguridad para una ejecución prevista de varios años, detallando qué copias completas se almacenarán de forma permanente y cuales se irán borrando.
- Crea un registro de las copias, indicando fecha, tipo de copia, si se realizó correctamente o no y motivo.
- Selecciona un directorio de datos "críticos" que deberá almacenarse cifrado en la copia de seguridad, bien encargándote de hacer la copia manualmente o incluyendo la contraseña de cifrado en el sistema
- Incluye en la copia los datos de las nuevas aplicaciones que se vayan instalando durante el resto del curso
- Utiliza saturno u otra opción que se te facilite como equipo secundario para almacenar las copias de seguridad. Solicita acceso o la instalación de las aplicaciones que sean precisas.

El sistema de copias debe estar operativo para la fecha de entrega, aunque se podrán hacer correcciones menores que se detecten a medida que vayan ejecutándose las copias. La corrección se realizará la última semana de curso y consistirá tanto en la restauración puntual de un fichero en cualquier fecha como la restauración completa de una de las máquinas.

--------------------------------------------------------------------------------

**En este artículo vamos a implementar un sistema de copias de seguridad para las máquinas del escenario de *OpenStack* y la máquina de *OVH*.**

En primer lugar, me gustaría aclarar un poco cuál va a ser el entorno de trabajo, y es que el escenario sobre el que vamos a trabajar, ha sido construido en diferentes *posts* previamente elaborados. Los dejo ordenados a continuación por si te interesa:

- [Creación del escenario de trabajo en OpenStack](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html)
- [Modificación del escenario de trabajo en OpenStack](https://javierpzh.github.io/modificacion-del-escenario-de-trabajo-en-openstack.html)
- [Servidores OpenStack: DNS, Web y Base de Datos](https://javierpzh.github.io/servidores-openstack-dns-web-y-base-de-datos.html)

He hecho más tareas sobre este escenario, las puedes encontrar todas [aquí](https://javierpzh.github.io/tag/openstack.html).

Respecto al equipo de **OVH**, se trata de un *VPS* con un sistema *Debian*.

Explicado esto, vamos a pasar con el contenido del *post* en cuestión, no sin antes explicar un poco la aplicación que vamos a utilizar y sus componentes.

## Bacula

He decidido escoger **Bacula** como aplicación para llevar a cabo este sistema de *backups*.

*Bacula* es una colección de herramientas de respaldo capaz de cubrir las necesidades de respaldo de equipos bajo redes IP. Se basa en una arquitectura cliente-servidor que resulta eficaz y fácil de manejar, dada la amplia gama de funciones y características que brinda. Además, debido a su desarrollo y estructura modular, *Bacula* se adapta tanto al uso personal como profesional, desde un equipo hasta grandes parques de servidores. Todo el conjunto de elementos que forman *Bacula* trabajan en sincronía y son totalmente compatibles con bases de datos como **MySQL**, **SQLite** y **PostgreSQL**.

#### Componentes de *Bacula*

- **Director *(DIR, bacula-director)*:** es el programa servidor que supervisa todas las funciones necesarias para las operaciones de copia de seguridad y restauración. Es el eje central de *Bacula* y en él se declaran todos los parámetros necesarios. Se ejecuta como un *demonio* en el servidor.

- **Storage *(SD, bacula-sd)*:** es el programa que gestiona las unidades de almacenamiento donde se almacenarán los datos. Es el responsable de escribir y leer en los medios que utilizaremos para nuestras copias de seguridad. Se ejecuta como un *demonio* en la máquina propietaria de los medios utilizados. En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Catalog**: es la base de datos (*MySQL* en mi caso) que almacena la información necesaria para localizar donde se encuentran los datos salvaguardados de cada archivo, de cada cliente, ... En muchos casos será en el propio servidor, pero también puede ser otro equipo independiente.

- **Console *(bconsole)*:** es el programa que permite la interacción con el *Director* para todas las funciones del servidor. La versión original es una aplicación en modo texto *(bconsole)*. Existen igualmente aplicaciones GUI para Windows y Linux *(Webmin, Bacula Admin Tool, Bacuview, Webacula, Reportula, Bacula-Web, ...)*.

- **File *(FD)*:** este servicio, conocido como *cliente* o servidor de ficheros está instalado en cada máquina a salvaguardar y es específico al sistema operativo donde se ejecuta. Responsable para enviar al *Director* los datos cuando este lo requiera.





















## Sistema de copias de seguridad

En mi caso, he decidido escoger como servidor (también conocido como **director**) de copias de seguridad a *Dulcinea*. Le he añadido un nuevo volumen de 10 GB de espacio, donde se irán almacenando las copias de las distintas máquinas.



































.
