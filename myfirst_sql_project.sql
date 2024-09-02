-- reading all the columns under each table characters
Select * 
from first_schema.characters;

-- i want to see the name and the guild columns
Select  name, guild
from first_schema.characters;
-- aliasing(renaming columns name)
Select  name, guild,level As character_level
from first_schema.characters;
-- how to use constants
Select  name, guild,level As character_level,1 As first_version
from first_schema.characters;
-- Dividing the experience by 100
Select  name, guild,level As character_level,1 As first_version,experience,experience/100 As Experience
from first_schema.characters;
-- add 100 to experience and divide it by level divided by 2
Select  name, guild,level As character_level,1 As first_version,experience,
          experience/100 As Experience, experience+100/level*2
from first_schema.characters;
-- using mathematical functions

Select  name, guild,level As character_level,1 As first_version,experience,
          experience/100 As Experience, experience+100/level*2,SQRT(16),SQRT(level),
-- text functions
 upper(name),lower(guild) 
from first_schema.characters;



-- order of operations
-- functions, multiplication/division,addition/substaction
SELECT (3+2+2+1) -4/2*(POW(2,2)-2)/2 As maths;
-- selecting from the table charaters where health is greater than 50 
SELECT * 
FROM first_schema.characters
WHERE health>50 ;
-- select only the rows in columns in level_saled greatter than 3
SELECT name,level,level/10 As level_scaled
FROM first_schema.characters
WHERE (level/10)>3;

-- seting my is_alive column to boolean since it was in a text format
UPDATE first_schema.characters  -- setting the tue and false values to integers 1 and 0
SET is_alive = CASE
    WHEN is_alive = 'TRUE' THEN 1
    WHEN is_alive = 'FALSE' THEN 0
    ELSE NULL -- Or some default value if needed
END;
ALTER TABLE first_schema.characters
MODIFY COLUMN is_alive BOOLEAN;
-- printing columns name,level,leve_scaled and is_alive where is_alive values are equal to TRUE
SELECT name,level,level/10 As level_scaled,is_alive
FROM first_schema.characters
WHERE is_alive=true;

-- using logical operators
SELECT name,level,is_alive,mentor_id,class
From first_schema.characters
WHERE (level>20 AND is_alive=true OR mentor_id IS NOT NULL)AND NOT (class IN('Mage','Archer'));

-- check the unique classes in my data(remove duplicates)
SELECT distinct class
From first_schema.characters;
 -- print the columns guild and class ,then sorting first by class then later by guild
SELECT  class,guild
From first_schema.characters
order by class,guild;
-- just want to print the combination of each element in class and guild to occur ones
SELECT  distinct class,guild
From first_schema.characters
order by class,guild;
-- creating multiple tables in sql
create  table first_schema.characters_alive
As(
select *
from first_schema.characters
where is_alive=true
);
create  table first_schema.characters_dead
As(
select *
from first_schema.characters
where is_alive=false
);
-- replace a table that already exist /or use if not exist
DROP TABLE IF EXISTS first_schema.characters_alive;
create  table if not exists first_schema.characters_alive
As(
select *
from first_schema.characters
where is_alive=true
);
-- set operations
-- how to use unions using the first_schema.characters_alive and first_schema.characters_dead
select * from first_schema.characters_alive
union distinct -- meaning you want the unique common rows,if use ALL it means u want all the union
select * from first_schema.characters_dead;

-- change data type 
select id,name,item_type,power ,date_added,rarity
from first_schema.items
union distinct 
select id,name,class ,level ,last_active,experience
from first_schema.characters;

-- how to use backets
select name ,level,
case 
when level>20 then "high"
when level=20 then "meduim"
else "low"
end as backets
from first_schema.characters;
-- agreggations
select sum(level) ,avg(level),min(level),max(level) AS max_level,count(level),max(experience),max(class)
from first_schema.characters;

-- using aggregated functions to perform on strings
SELECT COUNT(class), MIN(class), MAX(class), GROUP_CONCAT(class SEPARATOR ",")
FROM first_schema.characters;
-- count the number of rows
select count(*)
from first_schema.characters;
-- waant to print the experiences between bdifferent from the max and the min of experience(uncorrelated subqueries)
select name, experience
FROM first_schema.characters
where experience>(select min(experience) FROM first_schema.characters) AND experience<(select Max(experience) FROM first_schema.characters);

-- find the difference between a character experience and their mentor(correlated subqueries)
 select id AS mentee_id,mentor_id,
 (
  select experience
  from first_schema.characters mentor_table
  where id= mentee_table.mentor_id
 ) - experience as experience_difference
FROM first_schema.characters mentee_table
where mentor_id >0;
-- using derive table in sql
select *
 FROM 
(select name, level,class,
case
when class='Mage' then level*0.5
when class in("aecher","warrior") then level*0.75
else level*1.5
end as power_level
FROM first_schema.characters
)as devired_table
where power_level >=15;

-- commun table expresion
with  power_level_table as (
 select name, level,
   case
      when class='Mage' then level*0.5
	  when class in("aecher","warrior") then level*0.75
	  else level*1.5
   end as power_level
FROM first_schema.characters
)
 select *from power_level_table
 where power_level >=15;
 
 -- using joins
  -- i want to know for each character how many items the have in their inventory
  Select *
  from first_schema.characters
  join first_schema.inventory
  on characters.id=inventory.character_id
  join first_schema.items
  on inventory.item_id=items.id;
  
  -- self join(joinning a table to it self)
  select mentee_character.name as mentee,mentor_character.name as mentor
  from first_schema.characters as mentee_character
  join first_schema.characters as mentor_character
  on mentee_character.id=mentor_character.mentor_id;
  
  -- a character can use any item for which the power level
  -- is equal or greater tha the character experience
  -- divided by 100
  -- list of all characters and the items they can use
  select characters.name,characters.experience/100 as expo,items.name,items.power,characters.class
  from first_schema.characters
  join first_schema.items
  on items.power <= characters.experience/100   
  order by characters.name;
  
  -- inner joins similar to joins
   Select *
  from first_schema.characters
  join first_schema.inventory
  on characters.id=inventory.character_id
  inner join first_schema.items
  on inventory.item_id=items.id;
  
  -- left join(the id character must be identical ti the id item)
   select*
   from first_schema.characters
  left join first_schema.inventory
  on characters.id=inventory.character_id;

  -- right join 
  select*
from first_schema.characters
right join first_schema.inventory
on characters.id=inventory.character_id;

-- full outer joins(combination of the inner ,left and right joins)



  -- maximum level within each class(single grouping field)
select  class,max(level)
from first_schema.characters
group by class;

-- multiple grouping field
-- average  power by item type and rarity combination
select  item_type,rarity ,avg(power)
from first_schema.items
group by item_type,rarity 
order by item_type;


-- item_name,item_type,avg_power-by_type
-- chaimail armor,armor,69.5
-- elven bow,waepon,85.58
select min(name),item_type,AVG(power) as popo
from first_schema.items
group by item_type
having popo >=80;
-- windows functions
select name,item_type ,power ,sum(power)over(order by power) as sum_power
from first_schema.items ;

select name,item_type ,power ,sum(power)over(partition by item_type) as sum_power
from first_schema.items ;

select name,item_type ,power ,sum(power)over(partition by item_type order by power) as sum_power
from first_schema.items ;

-- numbering funtions row_number(),dense_rank(),rank()
select item_id,value,
row_number() over (order by value) as 'row_number',
dense_rank() over (order by value) as 'dense rank',
rank() over (order by value) as ' rank'
from first_schema.inventory
 




   
   
   
   
   
   
   
   
   
   
   
  