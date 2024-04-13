
----------------- DATA CLEANING ----------------------

-- Remove table rows filled with column names
DELETE
FROM saxony_auction_data
WHERE info = 'info' AND status = 'status';



-- assign better column names
EXEC SP_RENAME 'saxony_auction_data.auction_id', 'auction_id', 'COLUMN';
EXEC SP_RENAME 'saxony_auction_data.selling_price', 'selling_price', 'COLUMN';
EXEC SP_RENAME 'saxony_auction_data.starting_bid', 'starting_bid', 'COLUMN';



-- delete useless column 'column1'
ALTER TABLE saxony_auction_data
DROP COLUMN column1;



-- remove the last thre letters, which were the .cent values, which are 0 anyway
UPDATE saxony_auction_data 
SET
	selling_price = LEFT(selling_price, LEN(selling_price) -3),
	starting_bid = LEFT(starting_bid, LEN(starting_bid) -3)



-- remove the '.' and ',' from sold_at and limit_price, so that we can change the type to numeric
UPDATE saxony_auction_data 
SET
	saxony_auction_data.selling_price = SQ.selling_price,
	saxony_auction_data.starting_bid = SQ.starting_bid
FROM (SELECT	auction_id,
		REPLACE(REPLACE(selling_price, '.', ''), ',', '') selling_price,
		REPLACE(REPLACE(starting_bid, '.', ''), ',', '') starting_bid
	  FROM saxony_auction_data) SQ
JOIN saxony_auction_data	
ON saxony_auction_data.auction_id = SQ.auction_id;



-- so far all column are nvarchars, so i assign more fitting types for them
-- SP_HELP auction_data; to get table information
-- changing the types to a more usable type for money
ALTER TABLE saxony_auction_data
ALTER COLUMN selling_price NUMERIC(19,2);
ALTER TABLE saxony_auction_data
ALTER COLUMN starting_bid NUMERIC(19,2);



-- auction_id is a good primary key in my opinion, so i define it as PK
ALTER TABLE saxony_auction_data
ADD CONSTRAINT auctionPK PRIMARY KEY (auction_id);



-- extract the city name from 'info' column and add it as new column
ALTER TABLE saxony_auction_data
ADD city nvarchar(100);



UPDATE saxony_auction_data
SET city = REVERSE(SUBSTRING(REVERSE(info), 1, PATINDEX('%[0-9]%', REVERSE(info)) - 2));



-- delete city name from info column
UPDATE saxony_auction_data
SET info = SUBSTRING(info, 1, (LEN(info) - LEN(city) - 1));

SELECT * from saxony_auction_data;


