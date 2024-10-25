begin;
\o output_file.txt
create table temp_canciones(
    id int,
    titulo text,
    duracion text
);
\d temp_canciones
COPY \temp_canciones FROM '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/canciones.csv' WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
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
select * from temp_discos;
rollback;