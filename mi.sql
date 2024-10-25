begin;
\o output_file.txt
create table temp_canciones(
    id int,
    titulo text,
    duracion text
);
\d temp_canciones
copy temp_canciones (id, titulo, duracion) 
from '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/canciones.csv' 
DELIMITER ';' 
CSV HEADER;
-- COPY ddbb.peliculas    FROM peliculas.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL 'NULL', ENCODING 'UTF-8');
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
copy temp_discos (id, nombre, fecha_lanzamiento, id_grupo, nombre_grupo, url_grupo, genero, url_portada)
from '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/canciones.csv' 
DELIMITER ';' 
CSV HEADER;
--COPY ddbb.peliculas    FROM peliculas.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL 'NULL', ENCODING 'UTF-8');
select * from temp_discos;
rollback;