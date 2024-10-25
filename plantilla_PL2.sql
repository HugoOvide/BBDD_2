\pset pager off

SET client_encoding = 'UTF8';

BEGIN;


\echo 'creando el esquema para la BBDD temporal'
create database temporal;
create table temp_canciones(
    id int,
    titulo text,
    duracion char(5)
);
\d temp_canciones
copy nombre_tabla (id del disco, Título de la canción, duración) from '/Users/hol/Documents/Biblioteca_Asignaturas/3º AÑO/BASES DE DATOS/BBDD_2/canciones.csv' DELIMITER ';' CSV HEADER;

select * from canciones;
pause
\echo 'creando un esquema temporal'


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'


\echo insertando datos en el esquema final

\echo Consulta 1: texto de la consulta

\echo Consulta n:


ROLLBACK;                       -- importante! permite correr el script multiples veces...p