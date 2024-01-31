-- 1 total trips
SELECT COUNT(DISTINCT trip_id) as total_trips FROM trip_details;

-- 2 check duplicate tripid
SELECT trip_id, COUNT(trip_id) FROM trip_details
	GROUP BY trip_id HAVING COUNT(trip_id) > 1;

-- 3 total drivers
SELECT COUNT(DISTINCT driverid) as total_drivers FROM trips;

-- 4 total earnings
 select sum(fare) as total_earnings from trips;
 
 -- 5 total completed trips
 select count(distinct tripid) as trips from trips;
 
 -- 6 total searches
 select sum(searches) as total_searches from trip_details;
 
 -- 7 total searches which got estimate
 select sum(searches_got_estimate) as total_completed_searches from trip_details;
 
 -- 8 total searches for quotes
 select sum(searches_for_quotes) as total_search_quotes from trip_details;
 
 -- 9 total searches which got quotes
 select sum(searches_got_quotes) as total_got_quotes from trip_details; 
 
 -- 10 total driver cancelled
 select (count(*) - sum(driver_not_cancelled)) as total_driver_cancelled from trip_details; 
 
 -- 11 total customer cancelled
 select (count(*) - sum(customer_not_cancelled)) as total_customer_cancelled from trip_details; 
 
 -- 12 total otp entered
 delete from trip_details
	where end_ride = 0 and otp_entered = 1;

 select sum(otp_entered) as total_otp_entered from trip_details; 
 
 -- 13 total end rides
 select sum(end_ride) as total_end_rides from trip_details; 

-- 14 average distance per trip
select avg(distance) from trips;

-- 15 average fare per trip
select avg(fare) from trips;

-- 16 total distance travelled
select sum(distance) from trips;

-- 17 total fare
select sum(fare) from trips;

-- 18 which is the most used payment method
select a.method from payment a inner join
(select top 1 faremethod,count(distinct tripid) as trip_count from trips
group by faremethod
order by trip_count desc) b
on a.id=b.faremethod;

-- 19 the highest payment was made through which method
select a.method from payment a inner join
(select top 1 *from trips
order by fare desc) b
on a.id=b.faremethod;

select a.method from payment a inner join
(select top 1 faremethod,sum(fare) as fare from trips
group by faremethod
order by fare desc) b
on a.id=b.faremethod;

-- 20 which two locations had the most trips
select * from 
	(select *,dense_rank() over(order by trip_count desc) rnk
	from
		(SELECT loc_from, loc_to, COUNT(DISTINCT tripid) AS trip_count FROM trips
		  GROUP BY
			loc_from, loc_to
		) a) b
		WHERE rnk = 1;

-- 21 top 5 earning drivers
select * from 
(select *,dense_rank() over(order by fare desc) rnk
from
(select driverid,sum(fare) as fare from trips
group by driverid)b)c
where rnk < 6;

-- 22 which duration had more trips
select * from
(select *,RANK() over(order by cnt desc) rnk
from
(select duration, count(distinct tripid) as cnt from trips
group by duration)b)c
where rnk =1;

-- 23 which driver , customer pair had more orders
select * from 
	(select *,dense_rank() over(order by trip_count desc) rnk
	from
		(SELECT custid, driverid, COUNT(DISTINCT tripid) AS trip_count FROM trips
		  GROUP BY
			custid, driverid
		) a) b
		WHERE rnk = 1;

-- 24 search to estimate rate
select sum(searches_got_estimate) *100.0 /sum(searches) from trip_details;

-- 25 estimate to search for quote rates
select sum(searches_for_quotes) *100.0 /sum(searches_got_estimate) from trip_details;

-- 26 quote acceptance rate
select sum(searches_got_quotes) *100.0 /sum(searches_for_quotes) from trip_details;

-- 27 quote to booking rate
select sum(otp_entered) *100.0 /sum(searches_got_quotes) from trip_details;

-- 28 booking cancellation rate
select 100.0 * (1 - (sum(customer_not_cancelled)*1.0 / sum(searches)*1.0)) AS cancellation_rate from trip_details;

-- 29 conversion rate
select sum(end_ride) *100.0 /sum(searches) from trip_details;

-- 30 which area got highest trips in which duration
select * from
(select *, rank() over(partition by duration order by cnt desc) as rnk
from
(select duration, loc_from, count(distinct tripid) as cnt from trips
group by duration,loc_from)a)b
where rnk=1;

select * from
(select *, rank() over(partition by loc_from order by cnt desc) as rnk
from
(select duration, loc_from, count(distinct tripid) as cnt from trips
group by duration,loc_from)b)c
where rnk=1;

-- 31 which area got the highest fares, cancellations,trips,
select * from -- highest fare
(select *,rank() over(order by fare desc) as rnk
from
(select loc_from, sum(fare) as fare from trips
group by loc_from)b)c
where rnk=1;

select * from -- highest driver cancellations
(select t.loc_from,
        COUNT(*) - SUM(td.driver_not_cancelled) AS driver_cancelled,
        RANK() OVER (ORDER BY COUNT(*) - SUM(td.driver_not_cancelled) DESC) AS rnk
    FROM
        trips t
    JOIN
        trip_details td ON t.tripid = td.trip_id
GROUP BY t.loc_from) c
WHERE rnk = 1;


select * from -- highest customer cancellations
(select t.loc_from,
        COUNT(*) - SUM(td.customer_not_cancelled) AS customer_cancelled,
        RANK() OVER (ORDER BY COUNT(*) - SUM(td.customer_not_cancelled) DESC) AS rnk
    FROM
        trips t
    JOIN
        trip_details td ON t.tripid = td.trip_id
GROUP BY t.loc_from) c
WHERE rnk = 1;

select * from -- highest trips
(select *,rank() over(order by trips desc) as rnk
from
(select loc_from, count(distinct tripid) as trips from trips
group by loc_from)b)c
where rnk=1;

-- 32 which duration got the highest trips and fares
select * from -- highest trips
(select *,rank() over(order by trips desc) as rnk
from
(select duration, count(distinct tripid) as trips from trips
group by duration)b)c
where rnk=1;

select * from -- highest fares
(select *,rank() over(order by fare desc) as rnk
from
(select duration, sum(fare) as fare from trips
group by duration)b)c
where rnk=1;

-- 