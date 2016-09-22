# 1. 유저(customer_id)의 첫번째(MIN) 렌탈일(rental_date)을 어떻게 뽑을 것인가? hint: MIN
DROP TEMPORARY TABLE IF EXISTS first_rental;
CREATE TEMPORARY TABLE first_rental
SELECT
	r.customer_id,
	MIN(r.rental_date) "first_time"
FROM rental r
GROUP BY 1
;

# 2. 각각의 Cohort에 포함된 유저수 구하기(답: 520, 78, 1)(=Cohort Size)
DROP TEMPORARY TABLE IF EXISTS cohort_size;
CREATE TEMPORARY TABLE cohort_size
SELECT
	LEFT(first_time, 7) "month",
	COUNT(*) num
FROM first_rental
GROUP BY 1
;

#Cohort Table
DROP TEMPORARY TABLE IF EXISTS cohort;
CREATE TEMPORARY TABLE cohort
SELECT
	date_format(fr.first_time, "%Y%m") cohort_date,
	date_format(r.rental_date, "%Y%m") rental_date,
	cs.num cohort_size,
	SUM(p.amount) revenue,
	SUM(p.amount) / cs.num RPU
FROM
	rental r
		JOIN payment p
		  ON p.rental_id = r.rental_id
		JOIN first_rental fr
		  ON r.customer_id = fr.customer_id
		JOIN cohort_size cs
		  ON cs.month = LEFT(fr.first_time, 7)
GROUP BY 1, 2
;

#Pretiffy
SELECT
	cohort_date,
	PERIOD_DIFF(rental_date, cohort_date) months_after_first_rental,
	cohort_size,
	revenue,
	RPU
FROM cohort
ORDER BY cohort_date, months_after_first_rental
;