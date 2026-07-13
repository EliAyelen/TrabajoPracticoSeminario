USE sakila;
GO

/* ============================================================================
1. Ranking de Clientes: Listar los 10 clientes que más dinero han gastado en alquileres. La salida debe
mostrar: ID del cliente, Nombre Completo (concatenado), cantidad de películas alquiladas y el total
pagado
============================================================================ */

WITH gasto_por_cliente AS (
    SELECT
        id_cliente,
        SUM(monto) AS total_pagado
    FROM pago
    GROUP BY id_cliente
),
alquileres_por_cliente AS (
    SELECT
        id_cliente,
        COUNT(*) AS cantidad_peliculas_alquiladas
    FROM alquiler
    GROUP BY id_cliente
)
SELECT TOP 10
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS nombre_completo,
    ac.cantidad_peliculas_alquiladas,
    gc.total_pagado
FROM cliente c
    INNER JOIN gasto_por_cliente gc ON gc.id_cliente = c.id_cliente
    INNER JOIN alquileres_por_cliente ac ON ac.id_cliente = c.id_cliente
ORDER BY gc.total_pagado DESC;
GO

/* ============================================================================
2. Rendimiento de Categorías por Tienda: Mostrar el total de ingresos generados por cada categoría de
película, desglosado por cada una de las tiendas del negocio.
============================================================================ */

SELECT
    t.id_tienda,
    cat.nombre AS categoria,
    SUM(p.monto) AS ingresos_totales
FROM pago p
    INNER JOIN alquiler a ON a.id_alquiler = p.id_alquiler
    INNER JOIN inventario i ON i.id_inventario = a.id_inventario
    INNER JOIN tienda t ON t.id_tienda = i.id_tienda
    INNER JOIN pelicula_categoria pc ON pc.id_pelicula = i.id_pelicula
    INNER JOIN categoria cat ON cat.id_categoria = pc.id_categoria
GROUP BY t.id_tienda, cat.nombre
ORDER BY t.id_tienda, ingresos_totales DESC;
GO

/* ============================================================================
3. Análisis de Inventario No Retornado: Listar todas las películas (título y nombre de la tienda) que fueron
alquiladas hace más de 15 días y que aún no han sido devueltas (la columna return_date está vacía).
Incluir los datos del cliente que la tiene en su poder.
============================================================================ */

SELECT
    pe.titulo AS pelicula,
    t.id_tienda,
    d_tienda.direccion AS direccion_tienda,
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    c.email,
    a.fecha_alquiler,
    DATEDIFF(DAY, a.fecha_alquiler, GETDATE()) AS dias_sin_devolver
FROM alquiler a
    INNER JOIN inventario i ON i.id_inventario = a.id_inventario
    INNER JOIN pelicula pe ON pe.id_pelicula = i.id_pelicula
    INNER JOIN tienda t ON t.id_tienda = i.id_tienda
    INNER JOIN direccion d_tienda ON d_tienda.id_direccion = t.id_direccion
    INNER JOIN cliente c ON c.id_cliente = a.id_cliente
WHERE a.fecha_devolucion IS NULL
    AND DATEDIFF(DAY, a.fecha_alquiler, GETDATE()) > 15
ORDER BY dias_sin_devolver DESC;
GO

/* ============================================================================
4. Actores Versátiles: Encontrar aquellos actores que han participado en películas de al menos 5 categorías
diferentes. Mostrar el nombre del actor y la cantidad de categorías distintas en las que ha actuado
============================================================================ */

SELECT
    act.id_actor,
    act.nombre + ' ' + act.apellido AS actor,
    COUNT(DISTINCT pc.id_categoria) AS cantidad_categorias
FROM actor act
    INNER JOIN pelicula_actor pa ON pa.id_actor = act.id_actor
    INNER JOIN pelicula_categoria pc ON pc.id_pelicula = pa.id_pelicula
GROUP BY act.id_actor, act.nombre, act.apellido
HAVING COUNT(DISTINCT pc.id_categoria) >= 5
ORDER BY cantidad_categorias DESC;
GO

/* ============================================================================
5. Películas Populares vs. No Alquiladas: Generar un reporte que clasifique las películas en tres categorías
según su cantidad de alquileres: "Alta Demanda" (más de 30 alquileres), "Demanda Media" (entre 10 y 30
alquileres) y "Baja Demanda / Sin Alquileres" (menos de 10 alquileres). Ordenar el resultado de mayor a
menor popularidad.
============================================================================ */

WITH alquileres_por_pelicula AS (
    SELECT
        pe.id_pelicula,
        pe.titulo,
        COUNT(a.id_alquiler) AS cantidad_alquileres
    FROM pelicula pe
        LEFT JOIN inventario i ON i.id_pelicula = pe.id_pelicula
        LEFT JOIN alquiler a ON a.id_inventario = i.id_inventario
    GROUP BY pe.id_pelicula, pe.titulo
)
SELECT
    titulo,
    cantidad_alquileres,
    CASE
        WHEN cantidad_alquileres > 30 THEN 'Alta Demanda'
        WHEN cantidad_alquileres BETWEEN 10 AND 30 THEN 'Demanda Media'
        ELSE 'Baja Demanda / Sin Alquileres'
    END AS clasificacion_demanda
FROM alquileres_por_pelicula
ORDER BY cantidad_alquileres DESC;
GO