/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/
select customer_id ,
	concat(case when CUSTOMER_GENDER='M' then "Mr" else "Ms" end,'.', upper(CUSTOMER_FNAME)," ",upper(CUSTOMER_LNAME)) as "Customer Name"
    ,customer_email,
    year(CUSTOMER_CREATION_DATE) as customer_creation_year ,
    case 
		when year(CUSTOMER_CREATION_DATE)<2005 then "A"
        when year(CUSTOMER_CREATION_DATE) >= 2005 and year(CUSTOMER_CREATION_DATE) < 2011 then 'B' 
        ELSE 'C'
	end as category
 from  ONLINE_CUSTOMER;
	

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/

select product_id, product_desc, product_quantity_avail, product_price, 
(product_quantity_avail * product_price) as "inventory value",
 case 
		when product_price>20000 then product_price*0.80
        when product_price>10000 then product_price*0.85
        when product_price<=10000 then product_price*0.90
	end as New_Price
from PRODUCT
 where product_id not in (select product_id from ORDER_ITEMS) order by  inventory_value desc ;


/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

select PC.Product_class_code, PC.Product_class_desc, count(P.product_id) ,
sum(p.product_quantity_avail*p.product_price) as "Inventory value"
from product P 
join
 product_class PC on P.Product_class_code=PC.Product_class_code
group by PC.Product_class_code
having Inventory_value >100000
order by Inventory_value desc ;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
select OC.customer_id,
	concat(case when CUSTOMER_GENDER='M' then "Mr" else "Ms" end,'.', upper(CUSTOMER_FNAME)," ",upper(CUSTOMER_LNAME)) as "full name",
	customer_email, customer_phone,COUNTRY from online_customer OC
    join ADDRESS A on A.ADDRESS_ID = OC.ADDRESS_ID 
    where OC.customer_id in (
			select OH.customer_id from  ORDER_HEADER OH
				where order_status = 'Cancelled'
                group by OH.customer_id
                having count( order_id) = (select count(order_id) from ORDER_HEADER OH2 where OH.customer_id = OH2.customer_id ) 
            );
 
/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */ 

select 
S.SHIPPER_NAME, CITY,count(distinct OC.customer_id) as "num of customer",count(OH.order_id) as " number of consignment" 
from ADDRESS A
join ONLINE_CUSTOMER OC on OC.ADDRESS_ID = A.ADDRESS_ID
join ORDER_HEADER OH on OC.customer_id =  OH.customer_id
join shipper S on S.SHIPPER_ID=OH.SHIPPER_ID
where S.SHIPPER_NAME='DHL'
group by CITY;

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

  select
  P.product_id, product_desc, product_quantity_avail,sum(product_quantity) as quantity_sold,
  case 
		When sum(product_quantity) is NULL then 'No Sales in past, give discount to reduce inventory'
        When PC.PRODUCT_CLASS_DESC='Electronics' or PC.PRODUCT_CLASS_DESC= 'Computer' 
			then
				case 
					when product_quantity_avail<sum(product_quantity)*0.1 then 'Low inventory, need to add inventory'
                    when product_quantity_avail<sum(product_quantity)*0.5 then 'Medium inventory, need to add some inventory'
                    else 'Sufficient inventory' 
                    
				END
		When PC.PRODUCT_CLASS_DESC='Mobiles' or PC.PRODUCT_CLASS_DESC= 'Watches' 
			then
				case 
					when product_quantity_avail<sum(product_quantity)*0.3 then 'Low inventory, need to add inventory'
                    when product_quantity_avail<sum(product_quantity)*0.7 then 'Medium inventory, need to add some inventory'
                    else 'Sufficient inventory' 
                    
				END
		else
				case 
					when product_quantity_avail<sum(product_quantity)*0.2 then 'Low inventory, need to add inventory'
                    when product_quantity_avail<sum(product_quantity)*0.6 then 'Medium inventory, need to add some inventory'
                    else 'Sufficient inventory' 
				END
			
	END as "inventory Status"
  from PRODUCT P
  left join ORDER_ITEMS O on O.PRODUCT_ID = P.PRODUCT_ID
  join PRODUCT_CLASS PC on PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
  group by P.product_id,product_desc, product_quantity_avail,PC.PRODUCT_CLASS_CODE;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */
select
 order_id ,sum(P.len*P.width*P.height) as volume 
 from ORDER_ITEMS O
join product P ON O.PRODUCT_ID=P.PRODUCT_ID
group by O.order_id
having sum(len*width*height) < (select (len*width*height) from CARTON where CARTON_ID=10)
order by volume desc
limit 1;



/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

select OC.customer_id,
	concat(case when CUSTOMER_GENDER='M' then "Mr" else "Ms" end,'.', upper(CUSTOMER_FNAME)," ",upper(CUSTOMER_LNAME)) as "full name",
    sum(PRODUCT_QUANTITY) as "total quantity",
    sum(PRODUCT_QUANTITY*PRODUCT_PRICE) as "total value"
     from ONLINE_CUSTOMER OC
     join ORDER_HEADER OH  on OH.CUSTOMER_ID= OC.CUSTOMER_ID
     join ORDER_ITEMS O on OH.order_id = O.order_id
     join PRODUCT P on P.product_id=O.product_id
     where CUSTOMER_LNAME like 'G%' and PAYMENT_MODE='Cash'
     group by OC.customer_id;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

select P.product_id,product_desc,sum(PRODUCT_QUANTITY) as total_quantity from Product P
join ORDER_ITEMS O on O.product_id =P.product_id
join ORDER_HEADER OH on OH.order_id=O.order_id
join ONLINE_CUSTOMER OC on OC.customer_id = OH.customer_id
join ADDRESS A on A.address_id = OC.address_id
where O.order_id in (select order_id from ORDER_ITEMS where product_id=201) and P.product_id != 201 and CITY NOT IN ("Bangalore" , "New Delhi")
group by P.product_id
ORDER BY total_quantity DESC;

/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

select OH.order_id,OC.customer_id,
	concat(case when CUSTOMER_GENDER='M' then "Mr" else "Ms" end,'.', upper(CUSTOMER_FNAME)," ",upper(CUSTOMER_LNAME)) as "full name",
    sum(PRODUCT_QUANTITY) as "total quantity"
	from ONLINE_CUSTOMER OC 
    join ORDER_HEADER OH on OC.customer_id = OH.customer_id
    join ORDER_ITEMS O on OH.order_id=O.order_id
    join ADDRESS A on A.address_id = OC.address_id
    where O.order_id MOD 2 =0 and PINCODE like '5%'
    group by O.order_id;
    
    

