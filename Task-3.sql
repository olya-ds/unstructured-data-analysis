/*Создам и заполню таблицу со сгенерированными ненормированными значениями параметров квартир*/
CREATE TABLE apart
(
id_apart NUMBER,        /*id в списке*/
time_to_metro INT,      /*время до метро пешком*/
number_of_stations INT, /*число станций метро до работы*/
number_of_shops INT,    /*число магазинов в пределе 500 м от дома*/
price DECIMAL (6,2)     /*цена квартиры*/
);

INSERT INTO apart(id_apart, time_to_metro, number_of_stations, number_of_shops, price)
SELECT LEVEL as id_apart, 
round(dbms_random.value(2,30)) as time_to_metro,
round(dbms_random.value(3,12)) as number_of_station,
round(dbms_random.value(0,6)) as number_of_shop,
dbms_random.value(100,300) as price
FROM DUAL
CONNECT BY LEVEL <= 200;

SELECT * FROM apart;

/*Для того чтобы выбрать нормировку вычислим минимумы по всем атрибутам*/
SELECT MIN(TIME_TO_METRO), MIN(NUMBER_OF_STATIONS), MIN(NUMBER_OF_SHOPS), MIN(PRICE)
FROM apart;

/* Теперь вычислим размах по атрибутам*/
SELECT MAX(TIME_TO_METRO) - MIN(TIME_TO_METRO), MAX(NUMBER_OF_STATIONS) - MIN(NUMBER_OF_STATIONS), MAX(NUMBER_OF_SHOPS) - MIN(NUMBER_OF_SHOPS), MAX(PRICE) - MIN(PRICE)
FROM apart;

/*Буду использовать линейную нормировку, так как среди минимальных значений атрибутов есть ноль*/
SELECT id_apart,
round((TIME_TO_METRO - MIN(TIME_TO_METRO) OVER()) / (MAX(TIME_TO_METRO) OVER() - MIN(TIME_TO_METRO) OVER()),2) NORM_TIME_TO_METRO,
round((NUMBER_OF_STATIONS - MIN(NUMBER_OF_STATIONS) OVER()) / (MAX(NUMBER_OF_STATIONS) OVER() - MIN(NUMBER_OF_STATIONS) OVER()),2) NORM_NUMBER_OF_STATIONS,
round((NUMBER_OF_SHOPS - MIN(NUMBER_OF_SHOPS) OVER()) / (MAX(NUMBER_OF_SHOPS) OVER() - MIN(NUMBER_OF_SHOPS) OVER()),2) NORM_NUMBER_OF_SHOPS,
round((PRICE - MIN(PRICE) OVER()) / (MAX(PRICE) OVER() - MIN(PRICE) OVER()),2) NORM_PRICE
FROM apart;

/*Добавлю коэфициенты нормировки в целевую функцию и отсортирую данные по убыванию чтобы найти лучших представителей*/
SELECT id_apart,
round(4 * (TIME_TO_METRO - MIN(TIME_TO_METRO) OVER()) / (MAX(TIME_TO_METRO) OVER() - MIN(TIME_TO_METRO) OVER()) +
2 * (NUMBER_OF_STATIONS - MIN(NUMBER_OF_STATIONS) OVER()) / (MAX(NUMBER_OF_STATIONS) OVER() - MIN(NUMBER_OF_STATIONS) OVER()) +
(NUMBER_OF_SHOPS - MIN(NUMBER_OF_SHOPS) OVER()) / (MAX(NUMBER_OF_SHOPS) OVER() - MIN(NUMBER_OF_SHOPS) OVER()) +
3 * (PRICE - MIN(PRICE) OVER()) / (MAX(PRICE) OVER() - MIN(PRICE) OVER()),2) AS BEST
FROM apart
ORDER BY 2 DESC;