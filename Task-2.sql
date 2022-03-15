/*Запрос для нахождения минимального и максимального значения торговых оборотов*/
SELECT
MIN((C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) as min_value,
MAX((C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) as max_value
FROM STOCK;

/*Формула торгового оборота*/
SELECT (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_ as average
FROM STOCK;

/* Запрос подготовки данных для распределения торговых оборотов за минутные интервалы (гистограмма из 100 интервалов)*/
SELECT  NVL(T1.AMOUNT,0) AMOUNT ,T2.INTERVAL_NUM
FROM 
    (SELECT COUNT(*) AMOUNT, interval_num
    FROM 
        (SELECT (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_,
        WIDTH_BUCKET((C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_, 0, 257635515.80001, 100) interval_num
        FROM STOCK)
    GROUP BY interval_num) T1
RIGHT OUTER JOIN
(SELECT LEVEL AS interval_num FROM DUAL CONNECT BY LEVEL <= 100) T2  
ON T1.interval_num = T2.interval_num
ORDER BY T2.interval_num;

SELECT * FROM STOCK;

/*Запрос подготовки данных для построения боксплотов по торговым оборотам за минутные интервалы.
  Цены сгруппированы по часам, когда проводились торги и упорядочены по возрастанию стнадартного отклонения*/
SELECT  
      SUBSTR(C_TIME_,1,2) AS HOUR,
      PERCENTILE_CONT(0) WITHIN GROUP (ORDER BY (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) AS MIN,
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) AS PERCENTILE_CONT_0_25,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) AS PERCENTILE_CONT_0_5,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) AS PERCENTILE_CONT_0_75,
      PERCENTILE_CONT(1) WITHIN GROUP (ORDER BY (C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_) AS MAX
FROM STOCK
GROUP BY SUBSTR(C_TIME_,1,2)
ORDER BY (ROUND(STDDEV((C_OPEN_+C_HIGH_+C_LOW_+C_CLOSE_)/4*C_VOL_),3));