/* Questions – Write SQL queries to get data for the following requirements:*/
use ipl;
## 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select * from ipl_bidding_details;
-- (Number of wins by the bidder) ÷ (Total number of bids by the bidder) × 100

SELECT 
    bidder_id,
    COUNT(*) AS total_bids,
    SUM(CASE WHEN bid_status = 'won' THEN 1 ELSE 0 END) AS bid_wins,
    (SUM(CASE WHEN bid_status = 'won' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS win_percent
FROM ipl_bidding_details
GROUP BY bidder_id
ORDER BY win_percent DESC;
/**INFERENCE: 
-High win percentage doesn’t always correlate with a high number of bids. Some bidders bid fewer times but win almost every time (e.g., 103, 118).
-Several bidders with more bids (e.g., 119 with 10 bids) have low win rates – possibly overbidding or targeting tough auctions.
-The majority of bidders are clustered around 40–60% win rate, indicating moderate competition.*/

## 2.	Display the number of matches conducted at each stadium with the stadium name and city.
select * from ipl_match_schedule, ipl_stadium;
select count(distinct ms.match_id) as match_cnt, s.stadium_id, s.stadium_name,s.city
from ipl_match_schedule as ms
join ipl_stadium as s
on ms.STADIUM_ID = s.STADIUM_ID
group by s.stadium_id
order by match_cnt desc;
/*INFERENCE: 
-Top stadiums are in cricket-heavy cities: Mumbai, Delhi, Kolkata, Bengaluru.
-Match distribution is uneven – some stadiums host double the matches of smaller venues.
-City representation: Almost all major regions in India have at least one stadium hosting matches.
*/

## 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?
SELECT 
    s.stadium_name AS stadium_name,
   round( COUNT(CASE WHEN m.toss_Winner = m.match_Winner THEN 1 END) * 100.0 
        / COUNT(*),2) AS toss_win_match_win_percentage
FROM ipl_match m
JOIN ipl_Match_Schedule ms
    ON m.match_Id = ms.match_Id
JOIN ipl_Stadium s
    ON ms.stadium_Id = s.stadium_Id
WHERE s.stadium_Id = ms.stadium_id   
GROUP BY s.stadium_name;
/*Inference
The data reveals a significant disparity in "toss advantage" across different venues. 
While winning the toss at the Sawai Mansingh Stadium (70%) almost guarantees a win, 
it is statistically a disadvantage or negligible at the Rajiv Gandhi International 
Stadium (14.29%) and MCA Stadium (28.57%)*/

# 4.Show the total bids along with the bid team and team name.
select t.team_name,b2.bidder_name, count(bid_team) as total_bid 
from ipl_bidding_details b1
join ipl_bidder_details b2
on b1.bidder_id = b2.bidder_id
join ipl_match_schedule ms
on ms.schedule_id = b1.schedule_id
join ipl_team_standings as ts
on ms.tournmt_id = ts.tournmt_id
join ipl_team as t
on ts.team_id = t.team_id
group by t.team_name,b2.bidder_name;
/*Inference
The dataset shows perfectly uniform bidding behavior across all eight teams. 
Each team received exactly 201 total bids from the same 30 individuals, 
indicating a standardized or simulated auction environment.*/

# 5.Show the team ID who won the match as per the win details.
SELECT DISTINCT
    t.team_id,
    m.win_details
FROM ipl_team t
JOIN ipl_team_standings ts
    ON t.team_id = ts.team_id
JOIN ipl_match_schedule ms
    ON ts.tournmt_id = ms.tournmt_id
JOIN ipl_match m
    ON m.match_id = ms.match_id
   AND m.match_winner = t.team_id
ORDER BY t.team_id;
/*Inference
The dataset shows a perfectly balanced distribution of match outcomes, 
highlighting its nature as a curated or synthetic dataset for practice.

Key Insights
Performance Leader: KXIP is the most successful team in this subset with 6 wins.

Outcome Symmetry: Exactly 50% of matches were won by runs (35 runs) and 50% by wickets (7 wickets), 
showing no bias toward batting or bowling first.

Uniformity: The consistent margins (7 wickets/35 runs) suggest a standardized data model rather 
than organic match results.*/

# 6.Display the total matches played, total matches won and total matches lost by the team along with its team name.
SELECT
    t.team_name,
    COUNT(m.match_id) AS total_matches_played,
    SUM(CASE 
            WHEN m.match_winner = t.team_id THEN 1 
            ELSE 0 
        END) AS total_matches_won,
    SUM(CASE 
            WHEN m.match_winner <> t.team_id 
                 AND m.match_winner IS NOT NULL THEN 1
            ELSE 0
        END) AS total_matches_lost
FROM ipl_team t
JOIN ipl_match m
    ON t.team_id = m.team_id1
    OR t.team_id = m.team_id2
GROUP BY t.team_name
ORDER BY t.team_name;
/*Inference
Extreme Performance Gap: Chennai Super Kings (CSK) is the only team with a near-even competitive record (48% win rate), 
while the rest of the league shows an unprecedented collapse in performance.

Statistical Anomalies: Most teams (KKR, RCB, SRH) have zero wins despite playing ~30 matches, 
indicating a massive skill disparity or a highly skewed dataset.

Outlier Dominance: The league structure appears broken, as seven out of eight teams have lost 
90% or more of their total matches played.*/

# 7.Display the bowlers for the Mumbai Indians team.
SELECT p.player_name
from ipl_team_players tp
join ipl_team t 
on tp.team_id = t.team_id
join ipl_player p
on tp.player_id = p.player_id
where tp.player_role = 'Bowler' and t.team_name = 'Mumbai Indians';
/*Inference
Specialist Core: The attack relies heavily on Jasprit Bumrah’s pace and Mayank Markande’s 
spin as the only primary specialists.

All-Rounder Depth: Four out of the six bowling options are batting all-rounders, 
providing the captain with high flexibility but fewer "pure" strike bowlers.

Part-Time Cover: While Rohit Sharma and Suryakumar Yadav are listed, 
they serve as extreme backups, reinforcing a squad built on versatility over specialist volume.*/

/*8.How many all-rounders are there in each team, Display the teams with more than 4 
all-rounders in descending order.*/
select t.team_name,count(tp.player_id) as allrounder_cnt
from ipl_team_players tp
join ipl_team t
on t.team_id = tp.team_id
where player_role= 'All-Rounder'
group by t.team_name
having allrounder_cnt>4
order by allrounder_cnt desc;
/*Inference
Roster Strategy: Over 60% of the league's teams (5 out of 8) prioritize high-utility squads, 
each maintaining a deep pool of at least 5 all-rounders.

Top-Heavy Versatility: Delhi Daredevils and Kings XI Punjab lead the pack with 7 all-rounders each, 
indicating a heavy tactical reliance on multi-role players to provide batting depth and bowling options.

League Benchmark: The data suggests that having 5 or more all-rounders is 
the competitive standard for modern team construction in this format.*/

/*9.  Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
 Note the total bidders’ points in descending order and the year is the bidding year.
               Display columns: bidding status, bid date as year, total bidder’s points*/
SELECT 
    bd.bid_status,
    SUM(bp.total_points) AS total_bidding_points,
    YEAR(bd.bid_date) AS bid_year
FROM ipl_bidding_details bd
JOIN ipl_bidder_points bp
    ON bd.bidder_id = bp.bidder_id
JOIN ipl_team_standings ts
    ON bp.tournmt_id = ts.tournmt_id
JOIN ipl_match_schedule ms
    ON ms.tournmt_id = ts.tournmt_id
JOIN ipl_stadium s
    ON s.stadium_id = ms.stadium_id
JOIN ipl_team t
    ON t.team_id = ts.team_id
WHERE s.stadium_name = 'M. Chinnaswamy Stadium'
  AND t.remarks = 'CSK'
  AND ts.matches_won = ts.team_id   -- CSK won the match
GROUP BY bd.bid_status, bid_year
ORDER BY total_bidding_points DESC;

/*10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
Note 
1. Use the performance_dtls column from ipl_player to get the total number of wickets
 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.	Do not use joins in any cases.
4.	Display the following columns teamn_name, player_name, and player_role.*/
SELECT
    /* Team Name */
    (SELECT team_name
     FROM ipl_team
     WHERE team_id = (
         SELECT team_id
         FROM ipl_team_players
         WHERE player_id = p.player_id
     )) AS team_name,

    p.player_name,

    /* Player Role */
    (SELECT player_role
     FROM ipl_team_players
     WHERE player_id = p.player_id) AS player_role

FROM ipl_player p
WHERE p.player_id IN (
    SELECT tp.player_id
    FROM ipl_team_players tp
    WHERE tp.player_role IN ('Bowler', 'All-Rounder')
)
AND (
    SELECT COUNT(DISTINCT
        CAST(REGEXP_SUBSTR(p2.performance_dtls, '[0-9]+') AS SIGNED)
    )
    FROM ipl_player p2
    WHERE CAST(REGEXP_SUBSTR(p2.performance_dtls, '[0-9]+') AS SIGNED)
          >
          CAST(REGEXP_SUBSTR(p.performance_dtls, '[0-9]+') AS SIGNED)
) < 5;
/*Inference
Historic Impact: Sunil Narine is a top-3 all-time wicket-taker in the league, 
consistently outperforming specialist bowlers with his mystery spin.

Versatile Legends: Both players are rare "dual-threat" icons, 
being two of only three players in history to have taken an IPL hat-trick and scored an IPL century.

Role Evolution: While Shane Watson is listed as a bowler here, 
his career transitioned into a primary batsman role at CSK, 
whereas Narine evolved from a specialist bowler to a high-impact opening all-rounder.*/

# 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
select ROUND(
        SUM(CASE WHEN bid.bid_status = 'Won' THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*),
        2
    ) as percentage, bd.BIDDER_NAME
from ipl_bidder_details bd
join ipl_bidder_points bp
on bd.bidder_id = bp.bidder_id
join ipl_match_schedule ms
on bp.tournmt_id = ms.tournmt_id
join ipl_match m
on m.match_id = m.match_id
join ipl_bidding_details bid
on bid.bidder_id = bp.bidder_Id
group by bd.BIDDER_NAME
order by percentage desc;
/*Inference
Elite Predictors: Megaduta Dheer holds a perfect 100% toss-win record, 
followed closely by Aryabhatta Parachure (91%), 
marking them as the most tactically successful or luckiest bidders in the set.

Mid-Range Cluster: Half of the participants fall between 40% and 60%, 
suggesting a standard probability distribution for a coin-toss outcome for the majority of bidders.

Bottom Outliers: Three bidders (Krishan Valimbe, Gagan Panda, and Ronald D'Souza) 
failed to win a single toss (0%), creating a massive 100-point performance gap across the leaderboard.*/

/*12.	find the IPL season which has a duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration*/
 with cte as  (
 select tournmt_id,tournmt_name, datediff(TO_DATE,FROM_DATE) as duration, dense_rank() over(order by datediff(TO_DATE,FROM_DATE) desc) as rnk
 from ipl_tournament
 order by duration desc)
 select tournmt_id,tournmt_name, duration from cte
 where rnk = 1;
 /*Inference
Identical Window: The IPL maintained a strictly consistent 53-day schedule across both years, 
despite being the largest and longest seasons in the tournament's early history.

Peak Saturation: Both seasons featured 9 teams and 76 matches, 
which remained the "max duration" benchmark for nearly a decade until the league expanded to 10 teams in recent years.

Broadcaster Stability: The identical duration suggests a standardized broadcasting 
slot designed to maximize viewership within a fixed 7.5-week window before the onset of the monsoon season.*/

/*13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
Only use joins for the above query queries.*/
select bp.bidder_id, bd.bidder_name, sum(bp.total_points) as total_points, month(bdd.bid_date) as bid_month, year(bdd.bid_date) as bid_year
from ipl_bidder_details bd
join ipl_bidder_points bp
on bd.bidder_id = bp.bidder_id
join ipl_bidding_details bdd
on bp.bidder_id = bdd.bidder_id
where year(bdd.bid_date) = 2017
group by bp.bidder_id, bd.bidder_name,bid_month, bid_year 
order by bid_month asc,total_points desc ;
/*Inference
Peak Performance Period: The data shows a massive spike in bidding activity in May (Month 5) 
compared to April (Month 4), with total points nearly doubling for top bidders like Aryabhatta Parachure.

Consistency vs. Volatility: While high-ranking bidders like Aryabhatta Parachure 
maintained dominance across both months, mid-tier bidders showed significant fluctuation, 
suggesting that May might have featured higher-value or more frequent bidding opportunities.

Engagement Distribution: A small group of "power bidders" (top 5) contributes the vast majority of points, 
whereas the bottom 10% of the list remains largely inactive with 0 points, 
indicating a highly concentrated competitive environment.*/

# 14.	Write a query for the above question using sub-queries by having the same constraints as the above question.
SELECT 
    bidder_id,
    (SELECT bidder_name 
     FROM ipl_bidder_details bd 
     WHERE bd.bidder_id = bp.bidder_id) AS bidder_name,
    (SELECT SUM(total_points) 
     FROM ipl_bidder_points bp2
     WHERE bp2.bidder_id = bp.bidder_id
       AND YEAR((SELECT bid_date 
                 FROM ipl_bidding_details bdd2 
                 WHERE bdd2.bidder_id = bp2.bidder_id 
                   AND YEAR(bdd2.bid_date) = 2017 
                 LIMIT 1)) = 2017
    ) AS total_points,
    MONTH((SELECT bid_date 
           FROM ipl_bidding_details bdd3 
           WHERE bdd3.bidder_id = bp.bidder_id 
             AND YEAR(bdd3.bid_date) = 2017 
           LIMIT 1)) AS bid_month,
    2017 AS bid_year
FROM ipl_bidder_points bp
WHERE bp.bidder_id IN 
    (SELECT bidder_id 
     FROM ipl_bidding_details 
     WHERE YEAR(bid_date) = 2017)
GROUP BY 
    bidder_id, bid_month
ORDER BY 
    bid_month ASC, total_points DESC;
/*Inference
Month 4 (April) Dominance: Based on this specific raw data, April is the high-activity month. 
It features a broad range of bidders (29 individuals) contributing to a total of 259 points.

Concentrated Power: Aryabhatta Parachure remains the standout "whale" of the dataset, 
contributing roughly 13.5% of all points in April single-handedly.

Low Engagement in May: In contrast, May (Month 5) shows a significant drop-off in participation, 
with only one recorded bidder (Jayanti Chadda) contributing 5 points, 
suggesting the bidding season likely ended or peaked early in 2017.*/

/*15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
Output columns should be:
like
Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;*/

with cte as(
select bd.bidder_name, sum(bp.total_points) as total_points, 
dense_rank() over(order by sum(bp.total_points) desc) as rnk_desc,
dense_rank() over(order by sum(bp.total_points) asc) as rnk_asc
from ipl_bidder_details bd
join ipl_bidder_points bp
on bd.bidder_id = bp.bidder_id
join ipl_bidding_details bdd
on bp.bidder_id = bdd.bidder_id
where year(bdd.bid_date)=2018
group by bd.bidder_name)

select bidder_name,total_points
from cte
where rnk_desc <=3 or rnk_asc <=3
order by total_points desc;
/*Inference
Dominant Leader: Aryabhatta Parachure is the clear outlier with 210 points, 
nearly triple the score of the second-place bidder, showing a massive concentration of bidding power.

Highly Competitive Top Tier: Behind the leader, 
the gap between the 2nd and 3rd rankers is very small (5 points), 
indicating a tight race for the secondary positions.

Inactive Bottom Tier: The bottom 3 bidders all have 0 points, 
reflecting a significant group of participants who were either inactive or 
unsuccessful throughout the entire 2018 season.*/

/*16.	Create two tables called Student_details and Student_details_backup. (Additional Question - Self Study is required)

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.*/
create table student_details
(
stud_id int primary key,
stud_name varchar(50),
mail_id varchar(50) unique,
mobile_no varchar(10) unique
);

create table student_details_backup
(
stud_id int primary key,
stud_name varchar(50),
mail_id varchar(50) unique,
mobile_no varchar(10) unique
);
