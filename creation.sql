CREATE DATABASE Compound

CREATE TABLE Develop_Company (
   company_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(200)
);


CREATE TABLE compound (
    compo_ID INT  IDENTITY(1,1) PRIMARY KEY,
    comp_Name VARCHAR(100) NOT NULL,
    ExDate DATE,
    address VARCHAR(200),
    Company_ID INT NOT NULL,
    FOREIGN KEY (Company_ID) REFERENCES Develop_Company(company_id) ON DELETE CASCADE
);


CREATE TABLE customer (
    customer_id INT  IDENTITY(1,1) PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Budget DECIMAL(10,2) CHECK (Budget >= 0)
);

CREATE TABLE customer_phone (
    Customer_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (Customer_id, phone_number),
    FOREIGN KEY (Customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);


CREATE TABLE Employee (
    Emp_ID INT  IDENTITY(1,1) PRIMARY KEY,
    E_Number VARCHAR(20) UNIQUE NOT NULL,
    E_commission DECIMAL(10,2) CHECK (E_commission >= 0),
    Site VARCHAR(100),
    F_Name VARCHAR(50) NOT NULL,
    L_Name VARCHAR(50) NOT NULL,
    B_Date DATE,
    E_Salary DECIMAL(10,2) CHECK (E_Salary >= 0)
);


CREATE TABLE Employee_Company (
    Emp_id INT NOT NULL,
    Company_id INT NOT NULL,
    PRIMARY KEY (Emp_id, Company_id),
    FOREIGN KEY (Emp_id) REFERENCES Employee(Emp_ID) ON DELETE CASCADE,
    FOREIGN KEY (Company_id) REFERENCES Develop_Company(company_id) ON DELETE CASCADE
);


CREATE TABLE Emp_customer (
    Emp_ID INT NOT NULL,
    customer_id INT NOT NULL,
    PRIMARY KEY (Emp_ID, customer_id),
    FOREIGN KEY (Emp_ID) REFERENCES Employee(Emp_ID) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);


CREATE TABLE Payment (
    pay_id INT  IDENTITY(1,1) PRIMARY KEY,
    pay_Date DATE NOT NULL,
    pay_method VARCHAR(50) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);


CREATE TABLE Unit_Type (
    Unit_ID INT  IDENTITY(1,1) PRIMARY KEY,
    Unit_name VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Area DECIMAL(10,2) CHECK (Area > 0),
    Status VARCHAR(50) CHECK (Status IN ('available', 'sold', 'reserved')),
    compound_ID INT NOT NULL,
    FOREIGN KEY (compound_ID) REFERENCES compound(compo_ID) ON DELETE CASCADE
);


CREATE TABLE service (
    Service_ID INT  IDENTITY(1,1) PRIMARY KEY,
    Service_Name VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE Compound_Service (
    Compound_ID INT NOT NULL,
    Service_ID INT NOT NULL,
    PRIMARY KEY (Compound_ID, Service_ID),
    FOREIGN KEY (Compound_ID) REFERENCES compound(compo_ID) ON DELETE CASCADE,
    FOREIGN KEY (Service_ID) REFERENCES service(Service_ID) ON DELETE CASCADE
);

CREATE TABLE popularity (
    pop_ID INT IDENTITY(1,1) PRIMARY KEY,
    ad_count INT CHECK (ad_count >= 0),
    cus_rate DECIMAL(3,2) CHECK (cus_rate BETWEEN 0 AND 5),
    search_volume INT CHECK (search_volume >= 0),
    customer_ID INT NOT NULL,
    compound_ID INT NOT NULL,
    FOREIGN KEY (customer_ID) REFERENCES customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (compound_ID) REFERENCES compound(compo_ID) ON DELETE CASCADE
);


CREATE TABLE Company_phone (
    company_ID INT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (company_ID, phone),
    FOREIGN KEY (company_ID) REFERENCES Develop_Company(company_id) ON DELETE CASCADE
);


CREATE TABLE Company_Customer (
    Company_ID INT NOT NULL,
    Customer_id INT NOT NULL,
    PRIMARY KEY (Company_ID, Customer_id),
    FOREIGN KEY (Company_ID) REFERENCES Develop_Company(company_id) ON DELETE CASCADE,
    FOREIGN KEY (Customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);

