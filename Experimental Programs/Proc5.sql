# Proc5
####################
#Class 5: A statement with consumer statements inside a loop
###################################################

CREATE PROCEDURE proc_5(
						IN i INTEGER, 
						IN k INTEGER, 
						IN m INTEGER, 
						OUT res bigint
						) AS $$

    BEGIN
	
    CREATE TEMPORARY TABLE date_r AS 
										SELECT 
												d_year, 
												d_date, 
												d_date_sk 
										FROM 
												date_dim 
										WHERE 
												d_date_sk = m;
	
    CREATE TEMPORARY TABLE sale_r AS 
										SELECT 
												ss_item_sk, 
												ss_sold_date_sk, 
												ss_customer_sk, 
												ss_quantity 
										FROM 
												store_sales 
										WHERE 
												ss_sold_date_sk = m;
	
    CREATE TEMPORARY TABLE item_r AS 
										SELECT 
												i_item_desc, 
												i_item_sk, 
												i_color 
										FROM 
												item 
										WHERE 
												i_color = 'red';
	
    CREATE TEMPORARY TABLE saleItem AS 
										SELECT 
												ss_item_sk sk1, 
												i_item_desc, 
												i_item_sk, 
												ss_customer_sk, 
												ss_quantity 
										FROM 
												sale_r, 
												item_r 
										WHERE 
												ss_item_sk = i_item_sk;
	
    CREATE TEMPORARY TABLE saleDate AS 
										SELECT 
												ss_item_sk sk2, 
												d_year, 
												d_date 
										FROM 
												sale_r, 
												date_r 
										WHERE 
												ss_sold_date_sk = d_date_sk;
	
    CREATE TEMPORARY TABLE saleItemDate AS 
										SELECT 
												d_year, 
												i_item_desc, 
												i_item_sk, 
												d_date, 
												ss_customer_sk, 
												ss_quantity 
										FROM 
												saleDate, 
												saleItem 
										WHERE 
												sk1 = sk2;
	
    CREATE TEMPORARY TABLE aggItems AS 
										SELECT 
												d_year, 
												i_item_desc, 
												i_item_sk, 
												ss_customer_sk, 
												ss_quantity, 
												d_date, 
												COUNT(*) cnt 
										FROM 
												saleItemDate 
										GROUP BY 
												ss_customer_sk, 
												ss_quantity, 
												i_item_desc, 
												i_item_sk, 
												d_date, 
												d_year;
	
    WHILE i < k loop
	
        insert into 
					saleItem 
										SELECT 
												ss_item_sk sk1, 
												i_item_desc, 
												i_item_sk, 
												ss_customer_sk, 
												ss_quantity 
										FROM 
												sale_r, 
												item_r 
										WHERE 
												ss_item_sk = i_item_sk;
		
        insert into 
					saleDate 
										SELECT 
												ss_item_sk sk2, 
												d_year, 
												d_date 
										FROM 
												sale_r, 
												date_r 
										WHERE 
												ss_sold_date_sk = d_date_sk;
		
        insert into 
					saleItemDate 
										SELECT 
												d_year, 
												i_item_desc, 
												i_item_sk, 
												d_date, 
												ss_customer_sk, 
												ss_quantity 
										FROM 
												saleDate, 
												saleItem 
										WHERE 
												sk1 = sk2;
		
        insert into 
					aggItems 
										SELECT 
												d_year, 
												i_item_desc, 
												i_item_sk, 
												ss_customer_sk, 
												ss_quantity, 
												d_date, 
												COUNT(*) cnt 
										FROM 
												saleItemDate 
										WHERE 
												i_item_sk = i 
										GROUP BY 
												ss_customer_sk, 
												ss_quantity, 
												i_item_desc, 
												i_item_sk, 
												d_date, 
												d_year;
		
        i := i + 1;
		
    END loop;
	
    CREATE TEMPORARY TABLE result AS 
										SELECT 
												count(*) cnt 
										FROM 
												aggItems, 
												customer 
										WHERE 
												ss_customer_sk = c_customer_sk AND 
												aggItems.ss_quantity < 100;
	
    SELECT 
			* 
	INTO 
			res 
	FROM 
			result;
	
    END;
	
  $$ LANGUAGE plpgsql;