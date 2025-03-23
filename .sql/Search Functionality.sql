# Enable the User to select a product from Search

delimiter $$
create procedure Search(IN search_term varchar(100))
begin
select Product_id,product_name
from Products
where Product_name like concat('%',search_term,'%')
;
end $$

call Search('jacket');   # search successful
