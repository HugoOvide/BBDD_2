begin;
-- Fichero donde se vuelca la información en vez de terminal.
\o output_file.txt
-- Tablas temporales nombradas temp_(nombre del fichero a insertar en la tabla.)
\echo 'Creación de tablas temporales canciones, discos, ediciones, usuario_desea_disco, usuario_tiene_edición y usuarios:'
create table temp_canciones(
    id int,
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
\echo 'Creación de las tablas del modelor relacional:'

create table grupo(
    nombre text primary key,
    url text
);
insert into grupo (nombre, url) select distinct nombre_grupo, url_grupo from temp_discos;
\d grupo

create table disco(
    titulo text,
    año_publicacion integer,
    url_portada text,
    nombre_grupo text,
    primary key (titulo, año_publicacion, nombre_grupo)
);
\d disco
insert into disco (titulo, año_publicacion, url_portada, nombre_grupo) select distinct nombre, fecha_lanzamiento::integer, url_portada, nombre_grupo from temp_discos;


create table genero(
    nombre text,
    titulo_disco text,
    año_pub_disco int,
    primary key (titulo_disco,año_pub_disco,nombre)
);
-- He tenido que meter como PK el genero porque sino no me los diferencia y me saltan muchos repetidos.
insert into genero (nombre, titulo_disco, año_pub_disco, nombre_grupo) select distinct regexp_split_to_table(genero, ',\s+'), nombre, fecha_lanzamiento::integer, nombre_grupo from temp_discos;
select * from genero;


rollback;