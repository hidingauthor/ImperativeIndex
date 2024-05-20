# Proc4
####################
#Class 4: A series of dependent statements
###################################################

CREATE PROCEDURE Proc_4(
						IN i INTEGER, 
						IN k INTEGER, 
						OUT res bigint
						) AS $$

  BEGIN
  
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
											sale, 
											item_r 
									WHERE 
											ss_item_sk = i_item_sk;
  
  CREATE TEMPORARY TABLE saleDate AS 
									SELECT 
											ss_item_sk sk2, 
											d_year, 
											d_date 
									FROM 
											sale, 
											date_dim 
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