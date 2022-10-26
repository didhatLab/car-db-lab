
-- 3)

SELECT * FROM details;
SELECT * FROM car;
SELECT * FROM repair;
SELECT * FROM garage;

-- 4)
-- a)
    SELECT DISTINCT car.brand
    FROM car
    ;
-- b)
    SELECT place, commission_percents
    FROM garage
    GROUP BY place, commission_percents
    ORDER BY place
    ;
-- c)
    SELECT detail_name, cost
    FROM details
    GROUP BY detail_name, cost
    ORDER BY cost DESC
;
-- 5)
-- a)
    SELECT detail_name, max_number
    FROM details
    WHERE vendor IN ('АТП1', 'АТП2')
    ORDER BY max_number DESC
;
-- b)
    SELECT order_number, day_month_date, detail_number
    FROM repair
    WHERE price > 30000
    ORDER BY price, day_month_date
    ;
-- c)
    SELECT brand
    FROM car
    WHERE brand LIKE '%Газ%'
    ;
-- 6)
-- a)
    SELECT order_number, c.brand, day_month_date, price
    FROM repair
             LEFT JOIN car c on c.car_id = repair.car_id
    ORDER BY price
    ;
-- b) Не совсем понял, что есть название гаража, поэтому просто вывел его номер
    SELECT day_month_date, g.number_garage, d.detail_name, detail_number
    FROM repair
             LEFT JOIN details d on d.detail_id = repair.detail_id
             LEFT JOIN garage g on g.garage_id = repair.garage_id
    ;
-- 7)
-- a)
    SELECT r.order_number, c.brand, r.day_month_date, g.number_garage FROM
        (SELECT * FROM garage WHERE place='АТП1') as g
        JOIN repair as r ON r.garage_id = g.garage_id
        JOIN car c on c.car_id = r.car_id
-- b)
    SELECT c.atp_owner, g.number_garage, day_month_date
    FROM repair
    JOIN garage g on g.garage_id = repair.garage_id
    JOIN details d on d.detail_id = repair.detail_id
    JOIN car c on c.car_id = repair.car_id
    WHERE c.discount_percent > 3 AND day_month_date > 'Январь'
    ORDER BY c.atp_owner, g.number_garage, day_month_date
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

-- 9)