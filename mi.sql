begin;
-- Fichero donde se vuelca la información en vez de terminal.
\o output_file.txt
-- Tablas temporales nombradas temp_(nombre del fichero a insertar en la tabla.)
\echo 'Creación de tablas temporales canciones, discos, ediciones, usuario_desea_disco, usuario_tiene_edición y usuarios:'
create table temp_canciones(
    id text,
    titulo text,
    duracion text
);
\d temp_canciones
COPY temp_canciones FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/canciones.csv' WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

create table temp_discos(
    id text,
    nombre text,
    fecha_lanzamiento text,
    id_grupo text,
    nombre_grupo text,
    url_grupo text,
    genero text, 
    url_portada text
);
\d temp_discos
COPY temp_discos FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/discos.csv' WITH  (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

create table temp_ediciones(
    id text,
    año text,
    pais text,
    formato text
);
\d temp_ediciones
COPY temp_ediciones FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/ediciones.csv' WITH  (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

create table temp_usuario_desea_disco(
    nombre text,
    titulo text,
    año_lanzamiento text
);
\d temp_usuario_desea_disco
COPY temp_usuario_desea_disco FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/usuario_desea_disco.csv' WITH  (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

create table temp_usuario_tiene_edicion(
    nombre text,
    titulo text,
    año_lanzamiento text,
    año_edicion text,
    pais_edicion text,
    formato text,
    estado text
);
\d temp_usuario_tiene_edicion
COPY temp_usuario_tiene_edicion FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/usuario_tiene_edicion.csv' WITH  (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

create table temp_usuarios(
    nombre_completo text,
    nombre_usuario text,
    email text,
    password text
);
\d temp_usuarios
COPY temp_usuarios FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/usuarios.csv' WITH  (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

-- Tablas del diagrama relacional, nombradas como en el diagrama relacional en singular.
\echo 'Creación de las tablas del modelo relacional:'

create table grupos(
    nombre text primary key,
    url text
);
insert into grupos (nombre, url) select distinct nombre_grupo, url_grupo from temp_discos;
\d grupos

create table discos(
    titulo text,
    año_publicacion integer,
    url_portada text,
    nombre_grupo text,
    primary key (titulo, año_publicacion, nombre_grupo)
);
\d discos
insert into discos (titulo, año_publicacion, url_portada, nombre_grupo) select distinct on (nombre, fecha_lanzamiento, nombre_grupo) nombre, fecha_lanzamiento::integer, url_portada, nombre_grupo from temp_discos;

create table generos(
    nombre text,
    titulo_disco text,
    año_pub_disco int,
    primary key (titulo_disco,año_pub_disco,nombre)
);
\d generos
insert into generos (nombre, titulo_disco, año_pub_disco) select distinct regexp_split_to_table(replace(replace(replace(genero,'[',''),'''',''),']',''),',\s'), nombre, fecha_lanzamiento::integer from temp_discos;

create table canciones(
    titulo text,
    titulo_disco text,
    año_publicacion_disco int,
    duracion time,
    primary key (titulo,titulo_disco,año_publicacion_disco)
);
\d canciones
insert into canciones (titulo, titulo_disco, año_publicacion_disco, duracion)
    select distinct on (temp_canciones.titulo, temp_discos.nombre, temp_discos.fecha_lanzamiento)temp_canciones.titulo, temp_discos.nombre, temp_discos.fecha_lanzamiento::integer, 
        to_char(
            make_interval(hours => 0, mins => split_part(temp_canciones.duracion, ':', 1)::int, secs => split_part(temp_canciones.duracion, ':', 2)::int),'HH24:MM:SS')::time 
            from temp_canciones join temp_discos on temp_canciones.id = temp_discos.id;  

create table ediciones(
    formato text,
    año_edicion integer,
    pais text,
    titulo_disco text,
    año_disco integer,
    primary key (formato,año_edicion,pais,titulo_disco,año_disco)
);
\d ediciones
insert into ediciones (formato,año_edicion,pais,titulo_disco,año_disco)
    select distinct on (temp_ediciones.formato, temp_ediciones.año, temp_ediciones.pais, temp_discos.nombre, temp_discos.fecha_lanzamiento) 
        temp_ediciones.formato, temp_ediciones.año::integer, temp_ediciones.pais, temp_discos.nombre, temp_discos.fecha_lanzamiento::integer 
            from temp_ediciones join temp_discos on temp_ediciones.id = temp_discos.id;
select * from ediciones;
create table usuarios(
    nombre_usuario text primary key,
    nombre text,
    email text, 
    password text
);
\d usuarios
insert into usuarios (nombre_usuario, nombre, email, password)
    select temp_usuarios.nombre_usuario, temp_usuarios.nombre_completo, temp_usuarios.email, temp_usuarios.password from temp_usuarios;

create table usuarios_desean_discos(
    nombre_usuario text,
    titulo text,
    año_publicacion int,
    primary key (nombre_usuario, titulo, año_publicacion)
);
\d usuarios_desean_discos
insert into usuarios_desean_discos (nombre_usuario, titulo, año_publicacion)
    select distinct on (temp_usuario_desea_disco.nombre, temp_usuario_desea_disco.titulo, temp_usuario_desea_disco.año_lanzamiento) 
        temp_usuario_desea_disco.nombre, temp_usuario_desea_disco.titulo, temp_usuario_desea_disco.año_lanzamiento::integer
            from temp_usuario_desea_disco;

create type estado as enum ('M', 'NM', 'EX', 'VG+', 'VG', 'G', 'F');

create table usuario_tienen_ediciones(
    nombre_usuario text,
    titulo_disco text,
    año_lanzamiento_disco integer,
    año_edicion integer,
    pais_edicion text,
    formato text,
    estado estado,
    primary key(nombre_usuario,titulo_disco,año_lanzamiento_disco,año_edicion,pais_edicion,formato,estado)
);
\d usuario_tienen_ediciones
insert into usuario_tienen_ediciones (nombre_usuario,titulo_disco,año_lanzamiento_disco,año_edicion,pais_edicion,formato,estado)
    select temp_usuario_tiene_edicion.nombre,temp_usuario_tiene_edicion.titulo,temp_usuario_tiene_edicion.año_lanzamiento::integer,
            temp_usuario_tiene_edicion.año_edicion::integer,temp_usuario_tiene_edicion.pais_edicion,temp_usuario_tiene_edicion.formato,
                temp_usuario_tiene_edicion.estado::estado from temp_usuario_tiene_edicion;

select * from usuario_tienen_ediciones;

\echo "Consultas en SQL sobre la base de datos"
\echo "Mostrar los discos que tengan más de 5 canciones. Construir la expresión equivalente en álgebra relacional."
select discos.titulo
from discos
join canciones on discos.titulo = canciones.titulo_disco
group by discos.titulo
having count(canciones.titulo) > 5;
\echo "Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo"
select usuario_tienen_ediciones.titulo_disco, usuario_tienen_ediciones.pais_edicion, usuario_tienen_ediciones.año_edicion
from usuario_tienen_ediciones
join usuarios on usuario_tienen_ediciones.nombre_usuario = usuarios.nombre_usuario
where usuario_tienen_ediciones.formato = 'Vinyl' and usuarios.nombre = 'Juan García Gómez';
\echo "Disco con mayor duración de la colección. Construir la expresión equivalente en álgebra relacional."
select discos.titulo, sum(canciones.duracion) as duracion_total
from discos 
join canciones 
on discos.titulo = canciones.titulo_disco
group by discos.titulo
order by duracion_total DESC
limit 1;
\echo "De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan."
select usuarios_desean_discos.titulo, grupos.nombre
from usuarios_desean_discos
join usuarios on usuarios_desean_discos.nombre_usuario = usuarios.nombre_usuario
join discos on usuarios_desean_discos.titulo = discos.titulo
join grupos on discos.nombre_grupo = grupos.nombre
where usuarios.nombre = 'Juan García Gómez';
\echo "Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación."
select discos.titulo, discos.año_publicacion, ediciones.año_edicion, ediciones.pais, ediciones.formato, ediciones.año_disco
from discos
join ediciones on discos.titulo = ediciones.titulo_disco
where discos.año_publicacion <= 1972 and discos.año_publicacion >= 1970
order by ediciones.año_disco desc;

/*\echo "Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’. Construir la expresión equivalente en álgebra relacional."

\echo "Lista de discos con la duración total del mismo, editados antes del año 2000."

\echo "Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez"

\echo "Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M. Construir la expresión equivalente en álgebra relacional."

\echo " Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su
disco más nuevo, y el año medio de todos sus discos de su colección"

\echo "Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos"

\echo "Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos"*/

rollback;