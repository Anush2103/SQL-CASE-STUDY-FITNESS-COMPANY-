use pa

--no of users who reched out
Select Distinct count(user_id) as User_reached_out_to
From [dbo].[Product analyst Analytics Task - Updated]
Where booked_flag is not null 
select COUNT(handled_time)-
COUNT(*)dd 
from [dbo].[Product analyst Analytics Task - Updated] where handled_time is null

---3 days conversion--------------------------------------------------------------------------------------------------------
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated]),cte2 as(

select * ,DATEDIFF(day,modified_handled_slot_time,payment_time)days_number from cte where payment_time is not null)

select team_lead_id,funnel,SUM(case when days_number<=3 then 1 else 0 end)subscribers from cte2 
group by team_lead_id,funnel
order by funnel ,subscribers desc

------7 day conversion-------------------------------------------------------------------------------------------------------------------
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated]),cte2 as(

select * ,DATEDIFF(day,modified_handled_slot_time,payment_time)days_number from cte where payment_time is not null)

select team_lead_id,funnel,SUM(case when days_number<=7 then 1 else 0 end)subscribers from cte2 
group by team_lead_id,funnel
order by funnel,subscribers desc


----------------------What hours work best for connectivity and sales?-------------------------------------------------------------

with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated]),cte2 as(

select COUNT(modified_handled_slot_time)connectivity_count,datepart(hour,modified_handled_slot_time)connectivity_time_hour,
COUNT(payment_time)premium_subscribers_count,cast(count(payment_time)*100.00/COUNT(modified_handled_slot_time) as decimal(10,3))premium_conversion_percentage
from cte 
group by datepart(hour,modified_handled_slot_time)
),cte3 as(
select connectivity_count,(case when connectivity_time_hour>=0 and connectivity_time_hour<3 then '0-before_3'
when connectivity_time_hour>=3 and connectivity_time_hour<6 then '3-before_6'
when connectivity_time_hour>=6 and connectivity_time_hour<9 then '6-before_9'
when connectivity_time_hour>=9 and connectivity_time_hour<12 then '9-before_12'
when connectivity_time_hour>=12 and connectivity_time_hour<15 then '12-before_15'
when connectivity_time_hour>=15 and connectivity_time_hour<18 then  '15-before_18'
when connectivity_time_hour>=18 and connectivity_time_hour<21 then '18-before_21'
when connectivity_time_hour>=21 and connectivity_time_hour<24
then  '21-before_24'
end)time_slot,connectivity_time_hour,premium_subscribers_count,premium_conversion_percentage
from cte2)

select time_slot,SUM(connectivity_count)connectivity_count_,SUM(premium_subscribers_count)premium_subscribers_count_,
avg(premium_conversion_percentage) premium_conversion_percentage_
from cte3 group  by time_slot
order by premium_conversion_percentage_ desc ,premium_subscribers_count_ desc

---optimum time is between 9am and 12 pm

-----------------optimal days for connectivity and sales----------------------------------------------------------------------------------------------------

with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated]),cte2 as(

select COUNT(modified_handled_slot_time)connectivity_count,datepart(dw,modified_handled_slot_time)connectivity_time_weekday,
COUNT(payment_time)premium_subscribers_count,cast(count(payment_time)*100.00/COUNT(modified_handled_slot_time) as decimal(10,3))premium_conversion_percentage
from cte 
group by datepart(dw,modified_handled_slot_time))
,cte3 as(
select connectivity_count,(case when connectivity_time_weekday=1 then 'Sunday'
when connectivity_time_weekday=2 then 'Monday'
when connectivity_time_weekday=3 then'Tuesday'
when connectivity_time_weekday=4  then 'Wednesday'
when connectivity_time_weekday=5 then 'Thursday'
when connectivity_time_weekday=6  then  'Friday'
when connectivity_time_weekday=7 then 'Saturday'
end)Day_of_the_week
,connectivity_time_weekday,premium_subscribers_count,premium_conversion_percentage
from cte2)

select day_of_the_week,connectivity_time_weekday,
SUM(connectivity_count)connectivity_count_,SUM(premium_subscribers_count)premium_subscribers_count_,
avg(premium_conversion_percentage) premium_conversion_percentage_
from cte3 group  by day_of_the_week,connectivity_time_weekday
order by premium_conversion_percentage_ desc ,premium_subscribers_count_ desc


-----------------------funnel optimization----------------------------------------------------
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])

select funnel,COUNT(payment_time)premium_users_count,
COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time)premium_conversion_percentage  from cte group by funnel
---with event type------------------------------------------
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])

select funnel,event_type, COUNT(payment_time)premium_users_count,
COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time)premium_conversion_percentage  from cte group by funnel,event_type


-----coach optimization-----------------------------------------------------------------------------------
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])



select target_class,COUNT(payment_time)subscribers_count,CAST(COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time) AS decimal(10,3))as conversion_percentage
from cte 
group by target_class
order by conversion_percentage desc


-------other insights*/
/*
we see that more NRI clients have upgraded their plan to premium than Indian clients or other clients.This implies that possiblility of the premium conversion 
among the NRI clients is more.So we can introduce some customized offers and plans for these clients and also allocate best coaches to train.


*/
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])

select india_vs_nri,COUNT(payment_time)subscribers_count,CAST(COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time) AS decimal(10,3))as conversion_percentage
from cte 
group by india_vs_nri

--------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
it is observed that clients with medical condition prefer to upgrade their plans to premium.To increase the conversions:
1.Allocate coaches who are experts in specific area of clients medical condition,for example clients with diabetis should be allocated with coaches
who are expert in this field so that they can suggest customised diet plan,workout plan,protien intake plans to the clients based on their condition.

*/

with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])

select medicalconditionflag,COUNT(payment_time)subscribers_count,CAST(COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time) AS decimal(10,3))as
conversion_percentage
from cte 
group by medicalconditionflag
order by conversion_percentage desc

-----------------------------------------------------------------------------------------------------------------------------

/*
team lead with id 1140109 has high conversion percentage.*/
with cte as(
Select *,
       (select Max(Max_handled_slot_time)
               From (Values 
               (handled_time) ,
               (slot_start_time)) As Value(Max_handled_slot_time) ) 
        AS modified_handled_slot_time
From [dbo].[Product analyst Analytics Task - Updated])

select team_lead_id
,COUNT(payment_time)subscribers_count,CAST(COUNT(payment_time)*100.00/COUNT(modified_handled_slot_time) AS decimal(10,3))as
conversion_percentage
from cte group by team_lead_id
order by conversion_percentage desc