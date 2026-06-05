CREATE TABLE countries (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    geom SDO_GEOMETRY
);

CREATE TABLE cities (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    geom SDO_GEOMETRY
);

CREATE TABLE roads (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    geom SDO_GEOMETRY
);