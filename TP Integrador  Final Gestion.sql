
CREATE DATABASE VentasDB;
USE VentasDB;


CREATE TABLE Empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL
);


CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    fecha DATE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
);


INSERT INTO Empleados (nombre, apellido) VALUES
('Carlos', 'Pérez'),
('Ana', 'Gómez'),
('Luis', 'Martínez');


INSERT INTO Ventas (id_empleado, fecha, total) VALUES
(1, '2024-12-01', 150.00),
(2, '2024-12-01', 200.00),
(1, '2024-12-02', 300.00),
(3, '2024-11-30', 120.00);

-- Crear función para calcular el total de ventas por mes y año
DELIMITER //
CREATE FUNCTION calcular_total_ventas(mes INT, anio INT) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_ventas DECIMAL(10, 2);
    SELECT SUM(total) INTO total_ventas
    FROM Ventas
    WHERE MONTH(fecha) = mes AND YEAR(fecha) = anio;
    RETURN IFNULL(total_ventas, 0);
END //
DELIMITER ;

-- Verificar función calcular_total_ventas
SELECT calcular_total_ventas(12, 2024) AS Total_Diciembre_2024;

-- Crear función para obtener el nombre completo del empleado
DELIMITER //
CREATE FUNCTION obtener_nombre_empleado(id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(100);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
    FROM Empleados
    WHERE id_empleado = id;
    RETURN nombre_completo;
END //
DELIMITER ;

-- Verificar función obtener_nombre_empleado
SELECT obtener_nombre_empleado(1) AS Nombre_Empleado;


-- 3 - Crear un procedimiento almacenado llamado "obtener_promedio" que tome como parámetro de entrada el nombre de un curso y
--  calcule el promedio de las calificaciones de todos los alumnos inscriptos en ese curso. 
-- Verificar mediante ejecución del procedimiento.

-- Crear esquema para la nueva base de datos
CREATE DATABASE CursosDB;
USE CursosDB;

-- Tabla de Cursos
CREATE TABLE Cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL
);

-- Tabla de Alumnos
CREATE TABLE Alumnos (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL
);

-- Tabla de Inscripciones con calificaciones
CREATE TABLE Inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_curso INT,
    id_alumno INT,
    calificacion DECIMAL(5, 2),
    FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso),
    FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno)
);

-- Insertar datos de ejemplo en la tabla Cursos
INSERT INTO Cursos (nombre_curso) VALUES
('Matemáticas'),
('Historia'),
('Programación');

-- Insertar datos de ejemplo en la tabla Alumnos
INSERT INTO Alumnos (nombre, apellido) VALUES
('Juan', 'López'),
('María', 'García'),
('Pedro', 'Martínez');

-- Insertar datos de ejemplo en la tabla Inscripciones
INSERT INTO Inscripciones (id_curso, id_alumno, calificacion) VALUES
(1, 1, 85.5),
(1, 2, 90.0),
(2, 1, 88.0),
(3, 3, 75.0),
(1, 3, 92.5);

-- Crear el procedimiento almacenado obtener_promedio
DELIMITER //
CREATE PROCEDURE obtener_promedio (IN curso_nombre VARCHAR(100), OUT promedio DECIMAL(5, 2))
BEGIN
    SELECT AVG(calificacion) INTO promedio
    FROM Inscripciones i
    JOIN Cursos c ON i.id_curso = c.id_curso
    WHERE c.nombre_curso = curso_nombre;
END //
DELIMITER ;

-- Verificar ejecución del procedimiento
CALL obtener_promedio('Matemáticas', @resultado);
SELECT @resultado AS Promedio_Matematicas;

-- 4 - Crear un procedimiento almacenado "actualizar_stock" que tome como parámetros de entrada el código del producto y
--  la cantidad a agregar al stock actual. El procedimiento debe actualizar el stock sumando
-- la cantidad especificada al stock actual del producto correspondiente. 
-- Verificar mediante ejecución del procedimiento.

-- Agregar tabla de Productos a VentasDB
USE VentasDB;

CREATE TABLE Productos (
    codigo_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    stock_actual INT NOT NULL
);

-- Insertar datos de ejemplo en la tabla Productos
INSERT INTO Productos (nombre_producto, stock_actual) VALUES
('Producto A', 50),
('Producto B', 30),
('Producto C', 20);

-- Crear el procedimiento almacenado actualizar_stock
DELIMITER //
CREATE PROCEDURE actualizar_stock (
    IN codigo INT,
    IN cantidad INT
)
BEGIN
    UPDATE Productos
    SET stock_actual = stock_actual + cantidad
    WHERE codigo_producto = codigo;
END //
//DELIMITER ;


CALL actualizar_stock(1, 10); -- Agregar 10 al stock del Producto A
SELECT * FROM Productos WHERE codigo_producto = 1; -- Verificar cambios

-- 5 - Crear una vista que muestre el título, el autor, el precio y 
-- la editorial de todos los libros de cocina de la base pubs.

CREATE VIEW CocinaBooks AS
SELECT 
    t.title AS Título,
    CONCAT(a.au_fname, ' ', a.au_lname) AS Autor,
    t.price AS Precio,
    p.pub_name AS Editorial
FROM 
    titles t
JOIN 
    titleauthor ta ON t.title_id = ta.title_id
JOIN 
    authors a ON ta.au_id = a.au_id
JOIN 
    publishers p ON t.pub_id = p.pub_id
WHERE 
    t.type = 'cooking';


-- 6)
 -- a) Crear un índice compuesto en las columnas id_fabricante y nombre_producto de la tabla productos.
 CREATE INDEX idx_productos_id_fabricante_nombre 
ON productos (id_fabricante, nombre_producto);

 
-- b) Crear un índice único en la columna id_producto de la tabla productos.
CREATE UNIQUE INDEX idx_productos_id_producto 
ON productos (id_producto);

-- c) Modificar el índice idx_productos_id_fabricante_nombre para que sea  único en la columna id_fabricante.
DROP INDEX idx_productos_id_fabricante_nombre 
ON productos;

CREATE UNIQUE INDEX idx_productos_id_fabricante_nombre 
ON productos (id_fabricante);

 -- d) Crear un nuevo índice único en la columna id_fabricante
 CREATE UNIQUE INDEX idx_productos_id_fabricante 
ON productos (id_fabricante);

 -- e) Eliminar el índice idx_productos_id_fabricante de la tabla productos
 DROP INDEX idx_productos_id_fabricante 
ON productos;

-- 7)
DELIMITER //

CREATE TRIGGER trigger_transferir_a_jubilados
AFTER INSERT ON empleados
FOR EACH ROW
BEGIN
  -- Verificar si el empleado cumple con los criterios de jubilación
  IF NEW.edad >= 65 AND NEW.antiguedad >= 30 THEN
    -- Insertar automáticamente en la tabla jubilados
    INSERT INTO jubilados (nombre, edad, antiguedad)
    VALUES (NEW.nombre, NEW.edad, NEW.antiguedad);
  END IF;
END;
//

DELIMITER ;

-- Insertar empleados que cumplen con los criterios de jubilación
INSERT INTO empleados (nombre, edad, antiguedad)
VALUES ('Juan Pérez', 65, 30), ('María López', 66, 35);

-- Insertar empleados que no cumplen con los criterios
INSERT INTO empleados (nombre, edad, antiguedad)
VALUES ('Carlos Gómez', 40, 15), ('Ana Martínez', 64, 29);

-- Verificar los datos en la tabla jubilados
SELECT * FROM jubilados;

-- 8)
 CREATE TABLE empleados (
    codigo_empleado VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL
);

-- Insertar datos iniciales
INSERT INTO empleados (codigo_empleado, nombre, salario)
VALUES ('EMP001', 'Juan Pérez', 3000.00),
       ('EMP002', 'Ana López', 4500.00),
       ('EMP003', 'Carlos Gómez', 2500.00);


DELIMITER //

CREATE PROCEDURE ActualizarEmpleados(
    IN codigo_empleado VARCHAR(10),
    IN salario_actualizado DECIMAL(10, 2)
)
BEGIN
    DECLARE salario_actual DECIMAL(10, 2);
    DECLARE mensaje_error VARCHAR(255);

    -- Iniciar una transacción
    START TRANSACTION;

    -- Obtener el salario actual del empleado
    SELECT salario INTO salario_actual
    FROM empleados
    WHERE codigo_empleado = codigo_empleado;

    -- Validar si el salario actualizado es menor que el salario actual
    IF salario_actualizado < salario_actual THEN
        SET mensaje_error = CONCAT('El nuevo salario (', salario_actualizado, ') es menor que el salario actual (', salario_actual, '). Operación cancelada.');
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje_error;
    ELSE
        -- Actualizar el salario del empleado
        UPDATE empleados
        SET salario = salario_actualizado
        WHERE codigo_empleado = codigo_empleado;

        -- Confirmar la transacción
        COMMIT;
    END IF;
END;
//

DELIMITER ;

-- Caso exitoso: El nuevo salario es mayor que el actual
CALL ActualizarEmpleados('EMP001', 3500.00);

-- Caso fallido: El nuevo salario es menor que el actual
CALL ActualizarEmpleados('EMP002', 4000.00);

-- Verificar los datos actualizados
SELECT * FROM empleados;


-- 9)
-- a) Crear un usuario sin privilegios específicos
CREATE USER 'usuario_sin_privilegios'@'localhost' IDENTIFIED BY 'contraseña123';

-- b) Crear un usuario con privilegios de lectura sobre la base pubs
CREATE USER 'usuario_lectura_pubs'@'localhost' IDENTIFIED BY 'lectura123';
GRANT SELECT ON pubs.* TO 'usuario_lectura_pubs'@'localhost';

-- c) Crear un usuario con privilegios de escritura sobre la base pubs
CREATE USER 'usuario_escritura_pubs'@'localhost' IDENTIFIED BY 'escritura123';
GRANT INSERT, UPDATE, DELETE ON pubs.* TO 'usuario_escritura_pubs'@'localhost';

-- d) Crear un usuario con todos los privilegios sobre la base pubs
CREATE USER 'usuario_todos_pubs'@'localhost' IDENTIFIED BY 'todos123';
GRANT ALL PRIVILEGES ON pubs.* TO 'usuario_todos_pubs'@'localhost';

-- e) Crear un usuario con privilegios de lectura sobre la tabla titles
CREATE USER 'usuario_lectura_titles'@'localhost' IDENTIFIED BY 'titles123';
GRANT SELECT ON pubs.titles TO 'usuario_lectura_titles'@'localhost';

-- f) Eliminar al usuario que tiene todos los privilegios sobre la base pubs
DROP USER 'usuario_todos_pubs'@'localhost';

-- g) Eliminar a dos usuarios a la vez
DROP USER 'usuario_sin_privilegios'@'localhost', 'usuario_lectura_pubs'@'localhost';

-- h) Eliminar un usuario y sus privilegios asociados
DROP USER 'usuario_escritura_pubs'@'localhost';

-- i) Revisar los privilegios de un usuario
SHOW GRANTS FOR 'usuario_lectura_titles'@'localhost';


-- 10)
-- a) Activar la base de datos "local" y luego imprimir las colecciones existentes.
use local
show collections

-- b) Activar la base de datos "test" y luego imprimir las colecciones existentes.
use test
show collections

-- c) Activar la base de datos "baseEjemplo2".
use baseEjemplo2

-- d) Mostrar las colecciones existentes en la base de datos "baseEjemplo2".
show collections

-- e) Crear otra colección llamada usuarios donde almacenar dos documentos con los 
-- campos nombre y clave.
db.usuarios.insertMany([
    { nombre: "usuario1", clave: "clave1" },
    { nombre: "usuario2", clave: "clave2" }
])

-- f) Mostrar nuevamente las colecciones existentes en la base de datos "baseEjemplo2".
show collections


-- En la base pubs:
-- g) Insertar 2 documentos en la colección clientes con '_id' no repetidos
db.clientes.insertMany([
    { _id: 1, nombre: "Cliente A", direccion: "Calle 123" },
    { _id: 2, nombre: "Cliente B", direccion: "Avenida 456" }
])

-- h) Intentar insertar otro documento con clave repetida.
db.clientes.insertOne({ _id: 1, nombre: "Cliente C", direccion: "Calle 789" })


-- i) Mostrar todos los documentos de la colección libros.
db.libros.find().pretty()


-- j) Crear una base de datos llamada "blog".
use blog

-- k) Agregar una colección llamada "posts" e insertar 1 documento con una estructura a 
-- su elección.
db.posts.insertOne({
    titulo: "Primer Post",
    contenido: "Este es el contenido del primer post.",
    fecha: new Date(),
    autor: "Autor A"
})

-- l) Mostrar todas las bases de datos actuales.
show dbs

-- m) Eliminar la colección "posts"
db.posts.drop()

-- n) Eliminar la base de datos "blog" y mostrar las bases de datos existentes.
use blog
db.dropDatabase()
show dbs

-- 11)
-- a)
-- Empleado: Los empleados que fabrican componentes.
-- Componente: Los componentes que forman parte de los Smart TV.
-- Orden de Compra: Registro de las compras de componentes a importadores.
-- Hoja de Trabajo: Registro de los componentes fabricados por los empleados.
-- Modelo de TV: Representa los diferentes modelos de Smart TV fabricados.
-- Mapa de Armado: Relación entre los modelos de TV y los componentes, indicando su ubicación y orden.

-- b)

1. Empleado:
ID_Empleado (PK)
Nombre
Apellido
Puesto
2. Componente:
ID_Componente (PK)
Nombre
Tipo (Importado/Fabricado)
Descripción
3. Orden de Compra:
ID_Orden (PK)
ID_Componente (FK)
Fecha_Orden
Cantidad
4. Hoja de Trabajo:
ID_Hoja (PK)
ID_Empleado (FK)
ID_Componente (FK)
Fecha_Fabricación
Cantidad_Fabricada
5. Modelo de TV:
ID_Modelo (PK)
Nombre_Modelo
Descripción
Cantidad_Componentes
6. Mapa de Armado:
ID_Mapa (PK)
ID_Modelo (FK)
ID_Componente (FK)
Ubicación
Orden

-- d)

CREATE DATABASE SmartTV_Manufacturing;
USE SmartTV_Manufacturing;


CREATE TABLE Empleados (
    ID_Empleado INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Puesto VARCHAR(50)
);


CREATE TABLE Componentes (
    ID_Componente INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100),
    Tipo ENUM('Importado', 'Fabricado'),
    Descripcion TEXT
);


CREATE TABLE Ordenes (
    ID_Orden INT PRIMARY KEY AUTO_INCREMENT,
    ID_Componente INT,
    Fecha_Orden DATE,
    Cantidad INT,
    FOREIGN KEY (ID_Componente) REFERENCES Componentes(ID_Componente)
);


CREATE TABLE HojasTrabajo (
    ID_Hoja INT PRIMARY KEY AUTO_INCREMENT,
    ID_Empleado INT,
    ID_Componente INT,
    Fecha_Fabricacion DATE,
    Cantidad_Fabricada INT,
    FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID_Empleado),
    FOREIGN KEY (ID_Componente) REFERENCES Componentes(ID_Componente)
);


CREATE TABLE ModelosTV (
    ID_Modelo INT PRIMARY KEY AUTO_INCREMENT,
    Nombre_Modelo VARCHAR(100),
    Descripcion TEXT,
    Cantidad_Componentes INT
);


CREATE TABLE MapasArmado (
    ID_Mapa INT PRIMARY KEY AUTO_INCREMENT,
    ID_Modelo INT,
    ID_Componente INT,
    Ubicacion VARCHAR(100),
    Orden INT,
    FOREIGN KEY (ID_Modelo) REFERENCES ModelosTV(ID_Modelo),
    FOREIGN KEY (ID_Componente) REFERENCES Componentes(ID_Componente)
);

-- e)
-- 1) Obtener los modelos de TV con sus componentes y ubicación
SELECT 
    m.Nombre_Modelo,
    c.Nombre AS Nombre_Componente,
    ma.Ubicacion,
    ma.Orden
FROM ModelosTV m
JOIN MapasArmado ma ON m.ID_Modelo = ma.ID_Modelo
JOIN Componentes c ON ma.ID_Componente = c.ID_Componente
ORDER BY m.Nombre_Modelo, ma.Orden;

-- 2) Listar los empleados con la cantidad total de componentes fabricados




