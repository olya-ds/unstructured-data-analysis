/*Создадим и заполним таблицу с именами студентов и их id*/
CREATE TABLE student
(
student_id INT UNIQUE,
student_name VARCHAR2(50)
);

INSERT ALL
    INTO student (student_id, student_name) VALUES (1, 'Иван Иванов')
    INTO student (student_id, student_name) VALUES (2, 'Семен Петров')
    INTO student (student_id, student_name) VALUES (3, 'Василий Осипов')
    INTO student (student_id, student_name) VALUES (4, 'Милена Смирнова')
    INTO student (student_id, student_name) VALUES (5, 'Дарья Сидорова')
    INTO student (student_id, student_name) VALUES (6, 'Михаил Медведев')
    INTO student (student_id, student_name) VALUES (7, 'Константин Рыбков')
    INTO student (student_id, student_name) VALUES (8, 'Алексей Михайлов')
    INTO student (student_id, student_name) VALUES (9, 'Екатерина Харитонова')
    INTO student (student_id, student_name) VALUES (10, 'Анастатсия Пронина')
    INTO student (student_id, student_name) VALUES (11, 'Даниил Соколов')
    INTO student (student_id, student_name) VALUES (12, 'Ирина Воронина')
    INTO student (student_id, student_name) VALUES (13, 'Алина Логинова')
    INTO student (student_id, student_name) VALUES (14, 'Лев Волков')
    INTO student (student_id, student_name) VALUES (15, 'Ольга Харитонова')
    INTO student (student_id, student_name) VALUES (16, 'Игорь Денисов')
    INTO student (student_id, student_name) VALUES (17, 'Александра Мясникова')
    INTO student (student_id, student_name) VALUES (18, 'Любовь Петрова')
    INTO student (student_id, student_name) VALUES (19, 'Елизавета Семенова')
    INTO student (student_id, student_name) VALUES (20, 'Анна Тарасова')
SELECT * FROM dual;

/*Создадим и заполним таблицу с названиями кинотеатров и их id*/
CREATE TABLE cinema
(
cinema_id INT UNIQUE,
cinema_name VARCHAR2(50)
);

INSERT ALL
	INTO cinema (cinema_id, cinema_name) VALUES (1, 'Формула Кино')
	INTO cinema (cinema_id, cinema_name) VALUES (2, 'Каро Охта')
	INTO cinema (cinema_id, cinema_name) VALUES (3, 'Нева')
	INTO cinema (cinema_id, cinema_name) VALUES (4, 'Художественный')
	INTO cinema (cinema_id, cinema_name) VALUES (5, 'Синема Парк')
	INTO cinema (cinema_id, cinema_name) VALUES (6, 'Каро Невский')
	INTO cinema (cinema_id, cinema_name) VALUES (7, 'Победа')
	INTO cinema (cinema_id, cinema_name) VALUES (8, 'Мир кино')
	INTO cinema (cinema_id, cinema_name) VALUES (9, 'Заневский')
	INTO cinema (cinema_id, cinema_name) VALUES (10, 'Центральный')
	INTO cinema (cinema_id, cinema_name) VALUES (11, 'Море Синема')
SELECT * FROM dual;

/*Создадим и заполним таблицу, в которой сгенерируем случайные значения из диапозона для номера студента, номера кинотеатра и даты киносеанса в 200 строк*/
CREATE TABLE go_cinema
(
id_row NUMBER,
student_number INT,
cinema_number INT,
date_cinema DATE
);

INSERT INTO go_cinema(id_row, student_number, cinema_number, date_cinema)
SELECT level as id_row, round(dbms_random.value(1,20)) as student_number,
round(dbms_random.value(1,11)) as cinema_number,
trunc(sysdate + dbms_random.value(0, 20)) as date_cinema
FROM DUAL
CONNECT BY LEVEL <= 200;

SELECT * FROM go_cinema;

/*Таблицу со сгенерированными данными объединим с таблицей студентов и кинотеатров*/
SELECT id_row, student_number, student_name, cinema_number, cinema_name, date_cinema 
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id
ORDER BY date_cinema;

/*Создадим запрос для создания кросс-табицы о посещениях студентами кинотеатры*/
SELECT * FROM (SELECT student_name, cinema_name 
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id)
PIVOT (count(*) FOR cinema_name IN ('Формула Кино','Каро Охта','Нева','Художественный','Синема Парк','Каро Невский','Победа','Мир кино','Заневский','Центральный','Море Синема'));

/*Создадим запрос, выдающий данные о количестве посещений кинотеатра по датам*/
/*1 шаг. Выборка данных о посещении кинотеатра "Нева". Видно что кинотеатр посещали не во все дни*/
SELECT cinema_name, date_cinema, COUNT(*) AS amount
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id
WHERE cinema_name = 'Нева'
GROUP BY cinema_name, date_cinema
ORDER BY date_cinema;

/*2 шаг. Определим период посещения кинотеатра "Нева"*/
SELECT min(date_cinema)-1 pred_day,
max(date_cinema) - min(date_cinema) day_number
FROM (SELECT * 
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id
WHERE cinema_name = 'Нева');

/*3 шаг. Сгененрируем все даты, соотвествующие периоду посещения кинотеатра*/
SELECT to_date('21.02.2022','dd.mm.yy')+level as date_cinema
FROM dual CONNECT BY level <=20;

/*4 шаг. Объединим запросы про посещение кинотатра "Нева" и сгененрированные даты. В результате запроса встречаются неопредленные значения*/
SELECT t2.date_cinema, t1.amount
FROM (SELECT cinema_name, date_cinema, COUNT(*) AS amount
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id
WHERE cinema_name = 'Нева'
GROUP BY cinema_name, date_cinema
ORDER BY date_cinema) t1
RIGHT OUTER JOIN
(SELECT to_date('21.02.2022','dd.mm.yy')+level as date_cinema
FROM dual CONNECT BY level <=20) t2
ON t1.date_cinema = t2.date_cinema
GROUP BY t2.date_cinema, t1.amount
ORDER BY 1;

/*5 шаг. Добавим в запрос функцию NVL, избавляющую нас от неопределенных значений*/
SELECT t2.date_cinema, NVL(t1.amount,0) AS amount
FROM (SELECT cinema_name, date_cinema, COUNT(*) AS amount
FROM student RIGHT OUTER JOIN go_cinema ON go_cinema.student_number = student.student_id 
JOIN cinema ON go_cinema.cinema_number = cinema.cinema_id
WHERE cinema_name = 'Нева'
GROUP BY cinema_name, date_cinema
ORDER BY date_cinema) t1
RIGHT OUTER JOIN
(SELECT to_date('21.02.2022','dd.mm.yy')+level as date_cinema
FROM dual CONNECT BY level <=20) t2
ON t1.date_cinema = t2.date_cinema
GROUP BY t2.date_cinema, t1.amount
ORDER BY 1;

/*В результате у нас получился запрос, выдающий данные о количестве посещений кинотеатра за каждую дату без пропусков*/
/*Готово, Вы великолепны!*/