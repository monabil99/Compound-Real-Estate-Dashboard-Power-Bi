
--1 Show all compounds with the name of the developer company
CREATE or ALTER VIEW Compound_With_Company 
with encryption
AS
SELECT
    c.compo_ID,
    c.comp_Name,
    c.ExDate,
    c.address AS compound_address,
    d.name AS developer_name,
    d.address AS developer_address
FROM compound c
JOIN Develop_Company d ON c.Company_ID = d.company_id;

select* from Compound_With_Company

--2 Displaying ready units for sale only in all compounds
CREATE  or ALTER VIEW Available_Units 
with encryption
AS
SELECT
    u.Unit_ID,
    u.Unit_name,
    u.Price,
    u.Area,
    u.Status,
    c.comp_Name
FROM Unit_Type u
JOIN compound c ON u.compound_ID = c.compo_ID
WHERE u.Status = 'available';

select* from Available_Units

--3 Find out which compounds are most popular in terms of advertising, searches, and reviews.

CREATE or ALTER VIEW Popular_Compounds 
with encryption
AS
SELECT
    c.comp_Name,
    AVG(p.cus_rate) AS avg_rating,
    SUM(p.ad_count) AS total_ads,
    SUM(p.search_volume) AS total_searches
FROM popularity p
JOIN compound c ON p.compound_ID = c.compo_ID
GROUP BY c.comp_Name

select* from Popular_Compounds 
ORDER BY avg_rating DESC;

--4 Display customer relationships with companies

CREATE  or ALTER VIEW Customer_Company_Relation 
with encryption
AS
SELECT
    cu.customer_id,
    cu.Fname,
    cu.Lname,
    dc.name AS company_name
FROM Company_Customer cc
JOIN customer cu ON cc.Customer_id = cu.customer_id
JOIN Develop_Company dc ON cc.Company_ID = dc.company_id;

select* from Customer_Company_Relation 

--5 Total payments per customer

CREATE or ALTER  VIEW Total_Payments_Per_Customer 
with encryption
AS
SELECT
    c.customer_id,
    c.Fname,
    c.Lname,
    SUM(p.pay_id) AS total_payments
FROM customer c
JOIN Payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.Fname, c.Lname;

select * from Total_Payments_Per_Customer 

-- 6 Compare prices and spaces between compounds
CREATE or ALTER VIEW Unit_Stats_Per_Compound 
with encryption
AS
SELECT
    co.comp_Name,
    COUNT(*) AS total_units,
    AVG(u.Price) AS avg_price,
    AVG(u.Area) AS avg_area
FROM Unit_Type u
JOIN compound co ON u.compound_ID = co.compo_ID
GROUP BY co.comp_Name;

select* from Unit_Stats_Per_Compound

----------------------------------------------------------------------------------------------------------------

--To prevent the deletion of an employee linked to clients
CREATE  or ALTER TRIGGER trg_Prevent_Delete_Emp
ON Employee
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Emp_customer ec ON d.Emp_ID = ec.Emp_ID
    )
    BEGIN
       print('Cannot delete an employee who is associated with customers');
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Employee WHERE Emp_ID IN (SELECT Emp_ID FROM deleted);
    END
END;

----------------------------------------------------------------------------------------------------------

--Add a new client
CREATE or ALter  PROCEDURE sp_AddNewCustomer
    @Fname VARCHAR(50),
    @Lname VARCHAR(50),
    @Email VARCHAR(100),
    @Budget DECIMAL(10,2),
    @Phone VARCHAR(20)
AS
BEGIN
    DECLARE @NewCustomerID INT;

    INSERT INTO customer (Fname, Lname, Email, Budget)
    VALUES (@Fname, @Lname, @Email, @Budget);

    SET @NewCustomerID = SCOPE_IDENTITY();

    INSERT INTO customer_phone (Customer_id, phone_number)
    VALUES (@NewCustomerID, @Phone);
END;

EXEC sp_AddNewCustomer 'Ahmed', 'Kamel', 'ahmed.kamel@example.com', 1500000, '01012345678';

--Update unit status

CREATE or ALTER PROCEDURE sp_UpdateUnitStatus
    @UnitID INT,
    @NewStatus VARCHAR(50)
AS
BEGIN
    IF @NewStatus NOT IN ('available', 'sold', 'reserved')
    BEGIN
        print('For an incorrect condition.');
        RETURN;
    END

    UPDATE Unit_Type
    SET Status = @NewStatus
    WHERE Unit_ID = @UnitID;
END;

EXEC sp_UpdateUnitStatus @UnitID = 5, @NewStatus = 'sold';

---------------------------------------------------------------------------------------------

 --To calculate the potential commission for an employee based on the sales percentage

 CREATE FUNCTION fn_CalculateCommission(
    @EmpID INT,
    @SaleAmount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @CommissionRate DECIMAL(10,2);
    SELECT @CommissionRate = E_commission
    FROM Employee
    WHERE Emp_ID = @EmpID;

    RETURN ISNULL(@SaleAmount * @CommissionRate / 100, 0);
END;

SELECT dbo.fn_CalculateCommission(1, 500000) AS CommissionAmount;

-------------------------------------------------------------------------------------------------------------

--Know each employee's sales
SELECT 
    e.Emp_ID,
    e.F_Name + ' ' + e.L_Name AS EmployeeName,
    COUNT(uc.customer_id) AS NumberOfCustomers
FROM 
    Employee e
JOIN 
    Emp_customer uc ON e.Emp_ID = uc.Emp_ID
GROUP BY 
    e.Emp_ID, e.F_Name, e.L_Name
ORDER BY 
    NumberOfCustomers DESC;
--Companies with the largest number of compounds

SELECT 
    d.name AS CompanyName,
    COUNT(c.compo_ID) AS NumberOfCompounds
FROM 
    Develop_Company d
JOIN 
    compound c ON d.company_id = c.Company_ID
GROUP BY 
    d.name
ORDER BY 
    NumberOfCompounds DESC;

--Highest budget clients
SELECT TOP 10 
    Fname + ' ' + Lname AS FullName,
    Budget
FROM 
    customer
ORDER BY 
    Budget DESC;

--Services available in each compound

SELECT 
    comp.comp_Name,
    s.Service_Name
FROM 
    Compound_Service cs
JOIN 
    compound comp ON cs.Compound_ID = comp.compo_ID
JOIN 
    service s ON cs.Service_ID = s.Service_ID
ORDER BY 
    comp.comp_Name;

--To view more compounds that offer services

SELECT 
    c.comp_Name AS CompoundName,
    COUNT(cs.Service_ID) AS NumberOfServices
FROM 
    compound c
JOIN 
    Compound_Service cs ON c.compo_ID = cs.Compound_ID
GROUP BY 
    c.comp_Name
ORDER BY 
    NumberOfServices DESC;

------------------------------------------------------------------------------------------------------------------
select * from
[dbo].[customer] order by Budget DESC

--- the next 2 Q for Markting 


select c.Fname +' '+ c.Lname as [FullName] , c.Budget,
	case 
		when Budget >= 40000 then 'VIP'
		when Budget >= 30000 then 'Premium'
		when Budget >= 20000 then 'Gold'
		when Budget >= 10000 then 'Standard'
		end as  Customer_Categories 
from customer c
order by c.Budget desc;

----------------------------------------------------
select c.Fname +' '+ c.Lname as [FullName] , c.Budget ,
	case 
		when Budget >= 40000 then 'VIP'
		when Budget >= 30000 then 'Premium'
		when Budget >= 20000 then 'Gold'
		when Budget >= 10000 then 'Standard'
		end as  Customer_Categories ,ph.phone_number
from customer c join customer_phone ph
on c.customer_id = ph.Customer_id
order by c.Budget desc;

------------------------------------------------------
-- if the oldest man more then 60 then he'll get 20 % salary

select e.F_Name+' '+e.L_Name as [Full Name], B_Date	, E_Salary,
case	
	when  DATEDIFF(YEAR,e.B_Date,GETDATE()) >40 then e.E_Salary *1.20
	else e.E_Salary
	end AS AddSalaryForOldet
from Employee e
WHERE B_Date = (SELECT MIN(B_Date) FROM Employee);

------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxx
SELECT *
FROM Employee
WHERE B_Date = (SELECT MIN(B_Date) FROM Employee);

-----------------------------------------------------------
update Employee
set E_Salary=E_Salary * 1.20
where B_Date =(select Min(B_Date) from Employee) and DATEDIFF(YEAR,B_Date,GETDATE())>59;


-----------------------Show the Gdo------------------
select e.F_Name+' '+e.L_Name as [Full Name], B_Date	, E_Salary
from Employee e
where B_Date = (Select min(B_Date) from Employee)

--------we will improve the most payment have been paid with-----------------------------------


-- azft 3 compound

select top (3)d.comp_Name , p.cus_rate
from compound d join popularity p
on d.compo_ID =p.compound_ID
order by p.cus_rate asc;

----------------------------------------------------------------------------------------------

-- function
--	Q1
--Top ten compounds in terms of rating
create or alter function  fn_Top10RatedCompounds()
returns table
as
return 
(
    select top(10) cus_rate,c.comp_Name ,c.address
    from popularity p ,compound c 
	where p.compound_ID=c.compo_ID
	order by cus_rate desc

)
select * from fn_Top10RatedCompounds()


--Q2
--Top 10 clients who searched for compounds

create or alter function  fn_Top10CustomersBySearchVolume()
returns table
as
return 
(
select top(10) concat(c.Fname,c.Lname) as ful_name ,
       c.Email ,p.search_volume  ,com.comp_Name     
       from customer c,popularity p ,compound com
       where c.customer_id=p.customer_ID and p.compound_ID=com.compo_ID
       order by search_volume desc

)
select * from fn_Top10CustomersBySearchVolume()

--Q3
--How many times is each compound searched?
select c.comp_Name, count(p.customer_ID) as SearchCount
from Compound c
LEFT JOIN Popularity p on c.compo_ID = p.compound_ID
group by c.comp_Name

---------------------------------------------------------------------------------------------


--Customers with more than one phone number
-- Detect customers who have multiple contact numbers
SELECT 
    c.customer_id,
    c.Fname + ' ' + c.Lname AS Full_Name,
    COUNT(cp.phone_number) AS Phone_Count
FROM customer c
JOIN customer_phone cp ON c.customer_id = cp.Customer_id
GROUP BY c.customer_id, c.Fname, c.Lname
HAVING COUNT(cp.phone_number) > 1;


-- Most popular compounds based on customer ratings
-- Top-rated compounds based on customer feedback
SELECT 
    c.comp_Name,
    AVG(p.cus_rate) AS Average_Rating,
    COUNT(p.customer_ID) AS Number_of_Ratings
FROM compound c
JOIN popularity p ON c.compo_ID = p.compound_ID
GROUP BY c.comp_Name
ORDER BY Average_Rating DESC


--Find available units with the largest area and lowest price
-- Show best value available units (large area and low price)
SELECT 
    Unit_name,
    Area,
    Price,
    compound_ID
FROM Unit_Type
WHERE Status = 'available'
ORDER BY Area DESC, Price ASC;

==7-- Revenue projection: total customer budgets per compound
-- Estimate total customer buying potential per compound---addname of customer
SELECT 
    c.comp_Name,
    SUM(cu.Budget) AS Total_Budget
FROM customer cu
JOIN popularity p ON cu.customer_id = p.customer_ID
JOIN compound c ON p.compound_ID = c.compo_ID
GROUP BY c.comp_Name
ORDER BY Total_Budget DESC;

--Revision--8--Monthly sales report with unit statuses using GROUPING SETS
SELECT 
    c.comp_Name AS Compound,
    ut.Status,
    COUNT(*) AS Unit_Count,
    SUM(ut.Price) AS Total_Value
FROM Unit_Type ut
JOIN compound c ON ut.compound_ID = c.compo_ID
GROUP BY GROUPING SETS ((c.comp_Name, ut.Status), (c.comp_Name), (ut.Status), ())
ORDER BY Compound, Status;


9--Customer interactions with employees across companies
SELECT 
    cu.Fname + ' ' + cu.Lname AS Customer_Name,
    e.F_Name + ' ' + e.L_Name AS Employee_Name,
    dc.name AS Company
FROM Emp_customer ec
JOIN customer cu ON cu.customer_id = ec.customer_id
JOIN Employee e ON e.Emp_ID = ec.Emp_ID
JOIN Employee_Company emc ON emc.Emp_id = e.Emp_ID
JOIN Develop_Company dc ON dc.company_id = emc.Company_id
ORDER BY Customer_Name;

10--View creation: Available units per compound for UI use
CREATE VIEW AvailableUnits AS
SELECT 
    u.Unit_ID,
    u.Unit_name,
    u.Price,
    u.Area,
    c.comp_Name,
    dc.name AS Developer
FROM Unit_Type u
JOIN compound c ON c.compo_ID = u.compound_ID
JOIN Develop_Company dc ON dc.company_id = c.Company_ID
WHERE u.Status = 'available';


--Revision--11--. RANK units in each compound by price (Window Function)
SELECT 
    u.Unit_ID,
    u.Unit_name,
    c.comp_Name,
    u.Price,
    RANK() OVER (PARTITION BY u.compound_ID ORDER BY u.Price DESC) AS Price_Rank
FROM Unit_Type u
JOIN compound c ON u.compound_ID = c.compo_ID;


12--Payment method distribution for analysis
SELECT 
    pay_method,
    COUNT(*) AS Payment_Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM Payment
GROUP BY pay_method
ORDER BY Payment_Count DESC;


13--Total value of sold units per developer
SELECT 
    dc.name AS Developer,
    SUM(u.Price) AS Total_Sales
FROM Unit_Type u
JOIN compound c ON u.compound_ID = c.compo_ID
JOIN Develop_Company dc ON c.Company_ID = dc.company_id
WHERE u.Status = 'sold'
GROUP BY dc.name
ORDER BY Total_Sales DESC;

14--Average Budget per Customer
SELECT AVG(Budget) AS Avg_Budget FROM customer;

--Revison--15--Top 5 Services by Usage
SELECT s.Service_Name, COUNT(*) AS UsageCount
FROM Compound_Service cs
JOIN service s ON s.Service_ID = cs.Service_ID
GROUP BY s.Service_Name
ORDER BY UsageCount DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

16--Stored Procedure: Get available units for a given compound
CREATE PROCEDURE sp_GetAvailableUnits
    @CompoundName VARCHAR(100)
AS
BEGIN
    SELECT 
        u.Unit_ID,
        u.Unit_name,
        u.Price,
        u.Area,
        c.comp_Name
    FROM Unit_Type u
    JOIN compound c ON u.compound_ID = c.compo_ID
    WHERE u.Status = 'available'
      AND c.comp_Name = @CompoundName;
END;


17--revision-- ROLLUP report: Total budget per customer and company
 
SELECT 
    dc.name AS Developer,
    cu.Fname + ' ' + cu.Lname AS Customer,
    SUM(cu.Budget) AS Total_Budget
FROM Company_Customer cc
JOIN Develop_Company dc ON cc.Company_ID = dc.company_id
JOIN customer cu ON cu.customer_id = cc.Customer_id
GROUP BY ROLLUP(dc.name, cu.Fname + ' ' + cu.Lname)
ORDER BY dc.name, Customer;

18--Comparison report using CASE: Unit status classification

SELECT 
    Unit_ID,
    Unit_name,
    Price,
    Area,
    CASE 
        WHEN Price < 500000 THEN 'Low Budget'
        WHEN Price BETWEEN 500000 AND 1000000 THEN 'Medium Budget'
        ELSE 'High Budget'
    END AS Price_Range,
    CASE Status
        WHEN 'available' THEN 'Ready for sale'
        WHEN 'sold' THEN 'Completed'
        ELSE 'Pending'
    END AS Sale_Status
FROM Unit_Type;

20--CTE to find compounds where more than 1 services are provided


--nameofcustomer--21--Customers who paid using more than one payment method
SELECT customer_id,
       COUNT(DISTINCT pay_method) AS Method_Count
FROM Payment
GROUP BY customer_id
HAVING COUNT(DISTINCT pay_method) > 1;

 
22--Top 3 compounds by customer search volume
SELECT TOP 3 c.comp_Name,
             SUM(p.search_volume) AS Total_Searches
FROM popularity p
JOIN compound c ON c.compo_ID = p.compound_ID
GROUP BY c.comp_Name
ORDER BY Total_Searches DESC;


23--employee name--Most frequent customer interactions (with employees)
SELECT TOP 5 cu.Fname + ' ' + cu.Lname AS Customer,
           COUNT(*) AS Interactions
FROM Emp_customer ec
JOIN customer cu ON cu.customer_id = ec.customer_id
GROUP BY cu.Fname, cu.Lname
ORDER BY Interactions DESC;


24--payment--Detect inactive customers (no payments or popularity entries)
SELECT c.customer_id, c.Fname + ' ' + c.Lname AS Full_Name
FROM customer c
LEFT JOIN Payment p ON p.customer_id = c.customer_id
LEFT JOIN popularity pop ON pop.customer_ID = c.customer_id
WHERE p.pay_id IS NULL AND pop.pop_ID IS NULL;





