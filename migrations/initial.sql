CREATE TABLE Garage (
    garage_id INTEGER PRIMARY KEY ,
    number_garage VARCHAR(100) NOT NULL,
    place VARCHAR(100) NOT NULL,
    commission_percents SMALLINT
);


CREATE TABLE Car (
    car_id INTEGER PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    atp_owner VARCHAR(100) NOT NULL,
    discount_percent SMALLINT NOT NULL
);

CREATE TABLE Details (
    detail_id SERIAL PRIMARY KEY,
    detail_name VARCHAR(100) NOT NULL,
    vendor VARCHAR(100) NOT NULL,
    cost INTEGER NOT NULL,
    max_number INTEGER
);

CREATE TABLE Repair (
    order_number SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL REFERENCES Car (car_id),
    day_month_date rus_month NOT NULL,
    garage_id INTEGER NOT NULL REFERENCES Garage (garage_id),
    detail_id INTEGER NOT NULL REFERENCES Details (detail_id),
    detail_number INTEGER NOT NULL,
    price INTEGER NOT NULL
);