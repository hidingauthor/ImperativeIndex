# Proc2
####################
#Class 2: A statement with multiple consumer statements
###################################################

CREATE PROCEDURE proc_2(
						IN i integer
						) AS $$   
    BEGIN
    CREATE TEMPORARY TABLE item_r AS 
									SELECT 
											i_item_desc, 
											i_item_sk, 
											i_color 
									FROM 
											item;
    
	CREATE TEMPORARY TABLE res1 AS 
									SELECT 
											i_item_desc 
									FROM 
											item_r, 
											store_sales 
									WHERE 
											i_item_sk = i AND 
											ss_item_sk = i_item_sk;
									
    CREATE TEMPORARY TABLE res2 AS 
									SELECT 
											i_item_desc 
									FROM 
											item_r, 
											web_sales 
									WHERE 
											i_item_sk = i AND 
											ws_item_sk = i_item_sk;
									
    CREATE TEMPORARY TABLE res3 AS 
									SELECT 
											i_item_desc 
									FROM 
											item_r, 
											catalog_sales 
									WHERE 
											i_item_sk = i AND 
											cs_item_sk = i_item_sk;
									
    SELECT 
			* 
	FROM 
			res1 
	UNION 
	SELECT 
			* 
	FROM 
			res2 
	UNION 
	SELECT 
			* 
	FROM 
			res3;
	
    END;
	
  $$ LANGUAGE plpgsql;