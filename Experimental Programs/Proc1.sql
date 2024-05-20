# Proc1
####################
#Class 1: A statement with a consumer statement
###################################################

CREATE PROCEDURE proc_1(
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
												item;
	  CREATE TEMPORARY TABLE aggItems AS 
										SELECT 
												* 
										FROM 
												item_r;
	  WHILE i < k loop
	      insert into aggItems 
							SELECT 
									* 
							FROM 
									item_r 
							WHERE 
									i_item_sk = i;
	      i := i + 1;
	  END loop;
	  
	  SELECT 
			count(*) 
	  INTO 
			res 
	  FROM 
			aggItems;	  
	  
	  END;
	  
	$$ LANGUAGE plpgsql;