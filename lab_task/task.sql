-- 1)

CREATE TYPE rus_month AS ENUM (
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
    ); -- Cоздаем такой кастомный тип для хранения даты, она только в месяцах
-- Enum тип позволяет делать сравнения 'Cентябрь' > 'Апрель'. Удобно в данном кейсе :)



CREATE TABLE Garage (
    garage_id INTEGER PRIMARY KEY ,
    number_garage VARCHAR(100) NOT NULL,
    place VARCHAR(100) NOT NULL,
    commission_percents SMALLINT
); -- Создаем таблицу гаражей, ну гараж_айди это ключ, поэтому исрльзуем Primary key и INTEGER
--  номер гаража это строка из цифр и букв и судя по всему не очень большая, поэтому
-- VARCHAR(100) хватит с запасом, place тоже небольшая строка, процент это число от 0 до 100,
-- в наших данных нет дробных процентов, поэтому можно использовать и SMALLINT



CREATE TABLE Car (
    car_id INTEGER PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    atp_owner VARCHAR(100) NOT NULL,
    discount_percent SMALLINT NOT NULL
); -- про PK не буду дублировать еще раз
-- брэнд это тоже небольшая строка
-- овнер тоже самое, процент аналогичен предыдущему

CREATE TABLE Details (
    detail_id SERIAL PRIMARY KEY,
    detail_name VARCHAR(100) NOT NULL,
    vendor VARCHAR(100) NOT NULL,
    cost INTEGER NOT NULL,
    max_number INTEGER NOT NULL
); -- Здесь все тоже самое, только у ключа еще SERIAL, ну автоинкремент, в прошлых забыл поставить,
-- но в данном кейсе лабы это не так важно

CREATE TABLE Repair (
    order_number SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL REFERENCES Car (car_id),
    day_month_date rus_month NOT NULL,
    garage_id INTEGER NOT NULL REFERENCES Garage (garage_id),
    detail_id INTEGER NOT NULL REFERENCES Details (detail_id),
    detail_number INTEGER NOT NULL,
    price INTEGER NOT NULL
);
-- Здесь поинтереснее. Несколько форижен ключей, которые
-- относятся к предыдущим ключам, ну в данном случае они не особо важны,
-- так как никакие каскадные операции я не делаю, но зато это улучшает
-- перфоманс и вообще гуд практис, а еще IDE подсказывает во время джоинов
-- Для хранения месяца я использую кастомный enum type. Очень удобно в
-- данном кейсе.


-- 2) Все, что я использовал можно посмотреть на github: https://github.com/didhat/car-db-lab
-- там неплохой такой оверхед получился. Я описываю все таблички в виде датаклассов,
-- потом серилизую все данные из файлика в эти датаклассы. А потом лист из датаклассов
-- преобразую в INSERT команду. Но зато получилось интересно :) Узнал о датаклассах
-- некоторые штуки, которые никогда не использовал.

-- 3)
-- На первые запросы я не стал вывод писать, так как там все просто и очевидно :)
SELECT *
FROM details;
SELECT *
FROM car;
SELECT *
FROM repair;
SELECT *
FROM garage;

-- 4)
-- a)
SELECT DISTINCT car.brand
FROM car
-- Ну выводим все марки в без повторений с помощью DISTINCT
;
-- b)
SELECT place, commission_percents
FROM garage
GROUP BY place, commission_percents
ORDER BY place
;
-- Выводим все атп (в данном случае атп представлено place) c комиссией
-- Тут также используется группировка, можно и без нее, но можно и с ней
-- Гениальные цитаты, да D:
-- c)
SELECT detail_name, cost
FROM details
GROUP BY detail_name, cost
ORDER BY cost DESC
;
-- Ну то же самое, еще я сортирую, но это просто для лучшего перфоманса.


-- 5)
-- a)
SELECT detail_name, max_number
FROM details
WHERE vendor IN ('АТП1', 'АТП2')
ORDER BY max_number DESC
;
-- Максимальное количество, как я понял для отдельной каждой детали,
-- а то было бы уже слишком сложно для первых заданий
-- Использую IN потому что могу
-- b)
SELECT order_number, day_month_date, detail_number
FROM repair
WHERE price > 30000
ORDER BY price, day_month_date
;
-- Ну тут ремонт мы считаем, как каждую строку в repair
-- Иначе опять таки слишком сложно
-- Тут просто обычная проверка на условие и вывод только нужных полей

-- c)
SELECT brand
FROM car
WHERE brand LIKE '%Газ%'
;
-- Нам нужны все машины Газ, поэтому просто используем LIKE

-- 6)
-- a)
SELECT order_number, c.brand, day_month_date, price
FROM repair
         LEFT JOIN car c on c.car_id = repair.car_id
ORDER BY price

-- Тут просто вывод с сортировкой, но нужно вывести поля, которые не хранятся в
-- repair. Но зато у нас есть индексы для других таблиц, в которых эта информация есть
-- Поэтому берем JOIN и получаем данные. В данном случае еще используется LEFT JOIN,
-- так как нам важно вывести все ремонты, даже если нет соответствующей машины в бд,
-- может она удалилась как нибудь :(

;
-- b) Не совсем понял, что есть название гаража, поэтому просто вывел его номер
SELECT day_month_date, g.number_garage, d.detail_name, detail_number
FROM repair
         LEFT JOIN details d on d.detail_id = repair.detail_id
         LEFT JOIN garage g on g.garage_id = repair.garage_id
;
-- Ну тут тоже самое, только у нас уже два JOIN

-- 7)
-- a)
SELECT r.order_number, c.brand, r.day_month_date, g.number_garage
FROM (SELECT * FROM garage WHERE place = 'АТП1') as g
         JOIN repair as r ON r.garage_id = g.garage_id
         JOIN car c on c.car_id = r.car_id
;
-- То же самое только с условием, ну делаю JOIN сразу к
-- к отфильтрованной таблице, поэтому на уровне основного JOIN у меня
-- нет WHERE
-- Results:
-- 5017,Газ-1222,Август,N1
-- 5016,Зил-133,Август,N1
-- 5012,Газ-52,Июнь,N1
-- 5014,Зил-130,Август,N2


-- b)
SELECT c.atp_owner, g.number_garage, day_month_date
FROM repair
         JOIN garage g on g.garage_id = repair.garage_id
         JOIN details d on d.detail_id = repair.detail_id
         JOIN car c on c.car_id = repair.car_id
WHERE c.discount_percent > 3
  AND day_month_date > 'Январь'
ORDER BY c.atp_owner, g.number_garage, day_month_date
-- Тут я уже решил сначала все соединить, а потом уже отфильтровать
;
-- RESULT:
-- АТП1,N1,Май
-- АТП1,N4,Май
-- АТП4,N1,Август
-- АТП4,N4,Август
-- АТП4,N5,Апрель
-- АТП5,N1,Август
-- АТП5,N5,Июнь
-- c)
SELECT c.car_id, c.brand
FROM repair
         JOIN garage g on g.garage_id = repair.garage_id
         JOIN car c on c.car_id = repair.car_id
         JOIN details d on d.detail_id = repair.detail_id
WHERE g.number_garage != 'N1'
  AND d.detail_name = 'Толкатель'
;
-- То же самое, но с другими условиями
-- RESULT:
-- 2,Газ-52
-- 1,Газ-24
-- d)
SELECT d.detail_name, repair.detail_number
FROM repair
         JOIN details d on d.detail_id = repair.detail_id
         JOIN car c on c.car_id = repair.car_id
         JOIN garage g on g.garage_id = repair.garage_id
WHERE g.place in ('АТП2', 'АТП4')
  AND c.brand = 'Зил-130'
;
-- То же самое
-- RESULT:
-- Скоба,4
-- Штуцер,1
-- Прокладка,21

-- 8)
SELECT order_number, price - (price::decimal * c.discount_percent::decimal / 100)
FROM repair
         JOIN car c on c.car_id = repair.car_id
;
-- Сначала просто выведем новые прайсы без изменния
-- Result:
-- 5002,73150
-- 5003,19400
-- 5004,6790
-- 5005,29100
-- 5006,99000
-- 5007,38000
-- 5008,31680
-- 5009,76800
-- 5010,155200
-- 5011,101850
-- 5012,50000
-- 5013,14400
-- 5014,29100
-- 5015,38000
-- 5016,73150
-- 5017,4800
-- 5018,5000
-- Теперь, убедившись, что все ок (ну на глаз...), напишем запрос для полноценного
-- апдейта, там также нужно поменять тип столбца, да в нашем кейсе все заканчивается
-- на два нуля, но деньги все равно лучше в decimal хранить
-- Запрос на апдейт:

BEGIN;
ALTER TABLE repair
    ALTER column price TYPE decimal;
SELECT price
FROM repair;

UPDATE repair r
SET price =
        (SELECT r.price - r.price::decimal * c.discount_percent::decimal / 100
         FROM car c
         WHERE c.car_id = r.car_id)
;

COMMIT;
-- В одной транзакции меняем тип столбца и изменяем данные
-- Новые значения:
-- 73150
-- 19400
-- 6790
-- 29100
-- 99000
-- 38000
-- 31680
-- 76800
-- 155200
-- 101850
-- 50000
-- 14400
-- 29100
-- 38000
-- 73150
-- 4800
-- 5000

-- 9) Сначала мы добавим новый столбец для repair, кстати эта команда имеет блокировку
-- ALL EXCLUSIVE, поэтому во время добавления таблица будет не доступна, но в Postgres 11+
-- таблица полностью не перзаписывается, а идет только обновление каталога, хотя добавление
-- столбца с дефолтным значением null, как в этом кейсе будет быстро работать и <11 версиях
-- в итоге при обновлении мы получаем блокировку, но она не будет слишком долгой.
-- После этого мы обновляем новый столбец правильными значениями, для этого мы исользем
-- NO KEY UPDATE, это делается, чтобы не блокировать свеянные таблицы, так как мы не обновляем
-- ключи и обновляем только один столбец, а не все. В итоге мы делаем апдейт с минимальной
-- возможной блокировкой и это не так сильно влияет на работоспособность системы.

BEGIN;
ALTER TABLE repair
    ADD COLUMN commission_percents NUMERIC;

BEGIN;
SELECT commission_percents
FROM repair FOR NO KEY UPDATE;

UPDATE repair
SET commission_percents = g.commission_percents
FROM garage g
WHERE g.garage_id = repair.garage_id;

COMMIT;

-- LEVEL 2
-- 10)
-- a)
SELECT *
FROM garage
         JOIN repair r on garage.garage_id = r.garage_id
         JOIN details d on d.detail_id = r.detail_id
         JOIN car c on c.car_id = r.car_id
WHERE d.detail_name IN ('Толкатель')
  AND c.atp_owner IN ('АТП3')
;
-- Здесь тоже обычный JOIN с условиями
-- Result: Таких гаражей нет :(

--
-- b) Здесь мы сначала делаем несколько подзапросов перед основным запросом.
-- Сначала создаем pop, который будем использовать в двух других запросах
-- Потот находим все детали, которые использовались в тот же месяц, что
-- и картер, потом уже делаем итоговый запрос, где достаем все детали,
-- которые не использовались в один месяц с картером, ну еще добавили DISTINCT,
-- так как нам нужные только названия деталей, а не их количество
WITH pop AS (SELECT *
             FROM details
                      JOIN repair r on details.detail_id = r.detail_id),
     non_right_details AS (SELECT detail_name
                           FROM details
                                    JOIN repair r2 on details.detail_id = r2.detail_id
                           WHERE day_month_date IN
                                 (SELECT pop.day_month_date FROM pop WHERE pop.detail_name in ('Картер')))
SELECT DISTINCT detail_name
FROM pop
WHERE detail_name NOT IN (SELECT detail_name FROM non_right_details)
;
-- Result:
-- Пробка
-- Штуцер
-- Скоба


-- 11)
-- a)
-- Не совсем понял условие, но примерно это значит, что общая стоимость это сумма всех
-- ремонтов для каждой машины
-- Сначала находим машину с максимальной стоимостью ремонта, потом находим самую дорогую деталь

WITH max_price as (SELECT DISTINCT ON (fp) car_id, SUM(price) as fp
                   FROM repair
                   GROUP BY car_id
                   ORDER BY fp DESC
                   LIMIT 1),
     most_expensive_detail as (SELECT d.detail_name, d.detail_id, max(d.cost) mx
                               FROM repair
                                        JOIN details d on d.detail_id = repair.detail_id
                               WHERE car_id = ANY (SELECT car_id FROM max_price)
                               GROUP BY d.detail_name, d.detail_id
                               ORDER BY mx DESC
                               LIMIT 1)
SELECT detail_id, detail_name
FROM most_expensive_detail
-- Result:
-- 1, Трубка

;
-- b) Подзапросом находим минимальную скидку среди машин атп1 и потом прсто находим машину с такой скидкой
-- в теории может быть несколько таких машин, но в задании про такой кейс ничего не сказано
SELECT *
FROM car
WHERE atp_owner = 'АТП1'
  AND discount_percent = ANY (SELECT min(discount_percent) FROM car WHERE atp_owner = 'АТП1')
;
-- Result:
-- 2,Газ-52,АТП1,0


-- с) Сначала находим максимальное число, которое требовалось для ремонта, потом находим детали
-- с таким количеством использования, потом делаем JOIN в таблицу деталей, чтобы вывести более подробную
-- информацию

WITH max_detail_need_number AS (SELECT max(rc.cnt)
                                FROM (SELECT sum(detail_number) as cnt
                                      FROM repair
                                      GROUP BY detail_id) as rc)
SELECT d.detail_id, detail_name
FROM (SELECT detail_id, sum(detail_number) as ko
      FROM repair
      GROUP BY detail_id) as pop
         JOIN details as d ON pop.detail_id = d.detail_id
WHERE pop.ko = ANY (SELECT * FROM max_detail_need_number)
;

-- RESULT :
-- 5,Прокладка

-- d) Здесь мы используем any, то есть берем только те заказы, которые есть в
-- в множестве, полученном из подзапроса и джойним парочку таблиц, чтобы отобразить ответ

SELECT r.order_number, c.brand, r.day_month_date
FROM repair as r
         JOIN car c on c.car_id = r.car_id
         JOIN details d on d.detail_id = r.detail_id
WHERE r.garage_id = ANY (SELECT g.garage_id FROM garage g WHERE g.place = 'АТП1')
;
-- Result:
-- 5017,Газ-1222,Август
-- 5016,Зил-133,Август
-- 5012,Газ-52,Июнь
-- 5014,Зил-130,Август


-- 12) просто делаем два запроса и объединяем, ну в условии не было чего дополнительного
SELECT atp_owner
FROM car
UNION
SELECT place
FROM garage
;
-- Result:
-- АТП3
-- АТП4
-- АТП5
-- АТП2
-- АТП1

-- p.s ну тот запрос дает как-то 0 полезных знаний, поэтому еще вот такой оставлю:
SELECT brand, atp_owner
FROM car
UNION
SELECT number_garage, place
FROM garage
;
-- Results:
-- N1,АТП1
-- Газ-1222,АТП5
-- N2,АТП1
-- Газ-24,АТП1
-- N4,АТП4
-- N3,АТП2
-- N5,АТП5
-- Газ-52,АТП1
-- Зил-133,АТП4
-- N1,АТП2
-- Зил-130,АТП3


-- 13)
-- a) Тут не совсем все однозначно, так как есть две машины, которые лежат в атп, которые вообще не продают
-- детали, то есть, чиня такие машины гараж сразу выполняет это условие и с таким допущением запрос
-- будет выглядеть как показано ниже
-- Мы проходим по всем гаражам и смотри можно ли составить с ним определенную таблицу
-- Вообще то запрос не очень эффективный, но свое дело делает как надо

SELECT *
FROM garage g
WHERE EXISTS(
              SELECT *
              FROM repair r
                       JOIN car c on r.car_id = c.car_id
                       JOIN details d on d.detail_id = r.detail_id
              WHERE r.garage_id = g.garage_id
                AND c.discount_percent >= 3
                AND c.discount_percent <= 7
                AND r.day_month_date < 'Декабрь'
                AND NOT EXISTS(
                      SELECT *
                      FROM repair r2
                               JOIN (SELECT * FROM car tc WHERE tc.car_id = c.car_id) c2 on c2.car_id = r2.car_id
                               RIGHT JOIN (SELECT * FROM details WHERE vendor = c.atp_owner) d2
                                          ON d2.detail_id = r2.detail_id
                      WHERE c2.car_id is null
                  )
          )
;
-- RESULT:
-- 6,N5,АТП5,3
-- 1,N1,АТП1,3
-- 3,N1,АТП2,4
-- 5,N4,АТП4,4


-- b) Сначала достаем все машины, которые подходят под условие,
-- а потом проходим гаражы и проверяем можно ли сделать райт джоин с таржет карс без
-- нулл, то есть все машинки должны найти пару с ремонтов в определенном гараже,
-- но такого гаража не находится
-- Ну чтобы он нашелся нам нужно просто добавить новые ремонты в табличку
-- p.s. cорри фор май инглищ

WITH target_cars as (SELECT c.car_id
                     FROM repair
                              JOIN car c on c.car_id = repair.car_id
                              JOIN details d on d.detail_id = repair.detail_id

                     WHERE d.detail_name != 'Прокладка'
                     GROUP BY c.car_id)

SELECT *
FROM garage g
WHERE NOT EXISTS(
        SELECT *
        FROM (SELECT * FROM repair r2 WHERE r2.garage_id = g.garage_id) as r
                 RIGHT JOIN target_cars as tc ON tc.car_id = r.car_id
        WHERE r.car_id is NULL
    )
;
-- с) Здесь снова есть одна деталь, которая хранится в атп3, но нет ни одного гаража
-- в этой зоне... Но про такие тонкости ничего не сказано, поэтому решение рабочее

    WITH detail_garage AS
             (SELECT d.detail_id, detail_name, detail_name, vendor, place, g.garage_id
              FROM details d
                       JOIN garage g ON d.vendor = g.place
                       JOIN repair r2 on d.detail_id = r2.detail_id)
    SELECT *
    FROM details kek
    WHERE NOT exists(
            SELECT *
            FROM (SELECT * FROM detail_garage WHERE detail_id = kek.detail_id) dp
                     LEFT JOIN (SELECT d2.detail_id, garage_id
                                FROM repair
                                         JOIN details d2 on repair.detail_id = d2.detail_id
                                         JOIN car c on repair.car_id = c.car_id
                                WHERE d2.detail_id = kek.detail_id
                                  AND d2.vendor = kek.vendor
                                  AND c.atp_owner = kek.vendor) as pop ON pop.garage_id = dp.garage_id
            WHERE pop.detail_id is NULL
    )
    ;

-- Result:
-- 3,Картер,АТП3,40000,70


-- d) Ну тут все совсем просто =: проходим по всем деталям и смотрим существует ли
-- результат, он сушествует только если количество деталей во всех ремонтах больше 2

    SELECT *
    FROM details d
    WHERE exists(
                  SELECT 1
                  WHERE 2 <= ALL (SELECT r.detail_number FROM repair r WHERE r.detail_id = d.detail_id)
              )
;
-- Results:
-- 1,Трубка,АТП1,10000,100
-- 3,Картер,АТП3,40000,70
-- 5,Прокладка,АТП2,5000,1200
-- 7,Толкатель,АТП1,11000,120




-- 14)
-- a) Просто находим максимальное количество c max() в подзапросе, а потом детали с таким
-- максимальным количеством

    SELECT *
    FROM details
    WHERE max_number = (SELECT max(max_number) FROM details)
    ;
-- Results:
-- 5,Прокладка,АТП2,5000,1200


-- b) Сначала находим нужные ремонты full_repairs, а потом сумму комиссий, потом, их количество
-- после этого вычисляем среднюю комиссию, так же мы это делаем все в decimal

    WITH full_repairs as (SELECT g.commission_percents, price
                          FROM repair
                                   JOIN car c on c.car_id = repair.car_id
                                   JOIN garage g on g.garage_id = repair.garage_id
                          WHERE c.atp_owner != g.place),
         sum_of_commissions as (SELECT SUM(price::decimal * (commission_percents::decimal / 100)) as s
                                FROM full_repairs),
        count_of_repairs as (SELECT count(1) cnt FROM full_repairs)
    SELECT s / cnt as av_commision
        FROM sum_of_commissions, count_of_repairs
    ;
-- Result:
-- 1816.95

-- с) Сначала находим все подходяшщие под условие машины, потом находим максимальную скидку
-- а потом находим машины с такой скидкой


    WITH norm_cars as (SELECT discount_percent, c.car_id, brand
                       FROM repair
                                JOIN garage g on g.garage_id = repair.garage_id
                                JOIN car c on c.car_id = repair.car_id
                       WHERE g.place in ('АТП1', 'АТП2')),
        max_discount as (
            SELECT max(discount_percent) FROM norm_cars
        )
    SELECT norm_cars.car_id, norm_cars.brand, discount_percent FROM norm_cars
    WHERE discount_percent = (SELECT * FROM max_discount)
    ;
-- RESULT:
-- 4,Зил-133,5
-- 4,Зил-133,5

-- d) Здесь мы просто считаем количестов строк из подзарпроса, который берет только
-- подходящие машины и только оригинальнрые (Distinct)

    SELECT count(*)
    FROM (SELECT DISTINCT car_id
          FROM repair
                   JOIN garage g on repair.garage_id = g.garage_id
          WHERE g.place = 'АТП1'
            and day_month_date >= 'Июнь'
            and day_month_date <= 'Август') as r
    ;
-- Result: 4


-- 15)
-- a)
-- Делаем подзапрос, в котором группируем детали и машины попарно из ремонтов и
-- там же складываем количество, а потом просто делаем джоины, чтобы сделать отображение
-- более понятным

    SELECT d.detail_id, c.car_id, detail_name, c.brand, all_details
    FROM (SELECT car_id, detail_id, sum(detail_number) as all_details
          FROM repair
          GROUP BY car_id, detail_id) pop
             JOIN details d ON pop.detail_id = d.detail_id
             JOIN car c ON c.car_id = pop.car_id
    ORDER BY all_details DESC
    ;
-- RESULT:
-- 5,3,Прокладка,Зил-130,27
-- 1,3,Трубка,Зил-130,16
-- 7,4,Толкатель,Зил-133,14
-- 7,2,Толкатель,Газ-52,9
-- 6,4,Пробка,Зил-133,8
-- 6,3,Пробка,Зил-130,6
-- 1,2,Трубка,Газ-52,5
-- 1,4,Трубка,Зил-133,4
-- 2,3,Скоба,Зил-130,4
-- 7,1,Толкатель,Газ-24,3
-- 2,5,Скоба,Газ-1222,3
-- 3,1,Картер,Газ-24,2
-- 2,2,Скоба,Газ-52,1
-- 6,5,Пробка,Газ-1222,1
-- 4,3,Штуцер,Зил-130,1

--b) Тут просто группируем и считаем, я честно уже устал писать

    SELECT r.detail_id, d.detail_name, count(DISTINCT c.car_id) cnt
    FROM repair r
             JOIN car c on c.car_id = r.car_id
             JOIN details d on r.detail_id = d.detail_id
    WHERE c.discount_percent > 3
    GROUP BY r.detail_id, d.detail_name, r.detail_id
    ORDER BY cnt DESC
    ;
-- Result:
-- 6,Пробка,2
-- 7,Толкатель,2
-- 1,Трубка,1
-- 2,Скоба,1
-- 3,Картер,1


-- с) Так а тут не совсем понятно, суммарную стоимость уже из машин из других атп
-- или из всех? И нужно вывести сумму всех или для каждого гаража, но учитывая, что
-- нужно юзать группировку, то для всех наверное отдельно?
-- Тут просто делаем группировку по гараже айди и еще берем номер гаража, для большей наглядности
-- ну и получаем сумму для каждого гаража, так как во всех были какие-то ремонты чужих машинок
    SELECT g.garage_id, g.number_garage, sum(r.price)
    FROM repair r
             JOIN garage g on g.garage_id = r.garage_id
             JOIN car c on c.car_id = r.car_id
    WHERE g.place != c.atp_owner
    GROUP BY g.garage_id, g.number_garage
    ;
-- d) Получаем вот такой запрос, сначала с помощью группировки находим
-- максимальную плату за один ремонт у машины, а потом просто берем оттуда
-- те, которые меньше 70000

    SELECT *
    FROM (SELECT c.car_id, c.brand, max(r.price) as mxp
          FROM repair r
                   JOIN garage g on g.garage_id = r.garage_id
                   JOIN car c on c.car_id = r.car_id
          WHERE g.place = 'АТП2'
          GROUP BY c.car_id, c.brand) kek
    WHERE kek.mxp <= 70000
    ;

-- RESULT:

-- 1,Газ-24,76800
-- 2,Газ-52,5000
-- 3,Зил-130,19400
-- 4,Зил-133,73150


-- Ну вот и конец, я немного даже устал, пока все это делал.
-- Отличная лаба, мне очень понравилась.
-- Жаль, что ты убрал у нас пары по субботам, тем, кто работает, по субботам гораздо приятнее на
-- пары ходить :)