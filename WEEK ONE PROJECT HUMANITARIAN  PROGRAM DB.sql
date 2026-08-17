#create the database

create database humanitarianprogramdb;
use humanitarianprogramdb;

# create the tables

create table jurisdiction_hierarchy (
    id int auto_increment primary key,
    name varchar(30) not null unique,
    level varchar(20) not null check (level in ('County', 'Sub-County', 'Village')),
    parent varchar(30),
    foreign key (parent) references jurisdiction_hierarchy(name) on delete cascade
);

create table village_locations (
    village_id int auto_increment primary key,
    village varchar(30) not null unique,
    total_population int not null check (total_population >= 0),
    foreign key (village) references jurisdiction_hierarchy(name) on delete cascade
);

create table beneficiary_partner_data (
    partner_id int auto_increment primary key,
    partner varchar(30) not null,
    village varchar(30) not null,
    beneficiaries int not null check (beneficiaries >= 0),
    beneficiary_type varchar(30) not null check (beneficiary_type in ('Individuals', 'Households')),
    foreign key (village) references village_locations(village) on delete cascade
);

# insert sample data
insert into jurisdiction_hierarchy (id, name, level, parent) values
(1, 'Nairobi', 'County', null),
(2, 'Kiambu', 'County', null),
(3, 'Mombasa', 'County', null),
(4, 'Westlands', 'Sub-County', 'Nairobi'),
(5, 'Kasarani', 'Sub-County', 'Nairobi'),
(6, 'Lari', 'Sub-County', 'Kiambu'),
(7, 'Gatundu South', 'Sub-County', 'Kiambu'),
(8, 'Kisauni', 'Sub-County', 'Mombasa'),
(9, 'Likoni', 'Sub-County', 'Mombasa'),
(10, 'Parklands', 'Village', 'Westlands'),
(11, 'Kangemi', 'Village', 'Westlands'),
(12, 'Roysambu', 'Village', 'Kasarani'),
(13, 'Githurai', 'Village', 'Kasarani'),
(14, 'Kiamwangi', 'Village', 'Lari'),
(15, 'Lari Town', 'Village', 'Lari'),
(16, 'Kamwangi', 'Village', 'Gatundu South'),
(17, 'Kisauni Town', 'Village', 'Kisauni'),
(18, 'Mtopanga', 'Village', 'Kisauni'),
(19, 'Likoni Town', 'Village', 'Likoni'),
(20, 'Shika Adabu', 'Village', 'Likoni');
 
 
insert into village_locations (village_id, village, total_population) values
(1, 'Parklands', 15000),
(2, 'Kangemi', 18000),
(3, 'Roysambu', 13000),
(4, 'Githurai', 12500),
(5, 'Kiamwangi', 12800),
(6, 'Lari Town', 9485),
(7, 'Kamwangi', 5212),
(8, 'Kisauni Town', 20500),
(9, 'Mtopanga', 15500),
(10, 'Likoni Town', 12000),
(11, 'Shika Adabu', 9000);

insert into beneficiary_partner_data (partner_id, partner, village, beneficiaries, beneficiary_type) values
(1, 'IRC', 'Parklands', 1450, 'Individuals'),
(2, 'NRC', 'Parklands', 50, 'Households'),
(3, 'SCI', 'Kangemi', 1123, 'Individuals'),
(4, 'IMC', 'Kangemi', 1245, 'Individuals'),
(5, 'CESVI', 'Roysambu', 5200, 'Individuals'),
(6, 'IMC', 'Githurai', 70, 'Households'),
(7, 'IRC', 'Githurai', 2100, 'Individuals'),
(8, 'SCI', 'Kiamwangi', 1800, 'Individuals'),
(9, 'IMC', 'Lari Town', 1340, 'Individuals'),
(10, 'CESVI', 'Kamwangi', 55, 'Households'),
(11, 'IRC', 'Kisauni Town', 4500, 'Individuals'),
(12, 'SCI', 'Kisauni Town', 1670, 'Individuals'),
(13, 'IMC', 'Mtopanga', 1340, 'Individuals'),
(14, 'CESVI', 'Likoni Town', 4090, 'Individuals'),
(15, 'IRC', 'Shika Adabu', 2930, 'Individuals'),
(16, 'SCI', 'Shika Adabu', 5200, 'Individuals');

# select the data  availability
select * from  jurisdiction_hierarchy;      
select * from village_locations;                 
select * from beneficiary_partner_data;   


#  task 1: aggregate functions, group by & case when
#Total beneficiaries per partner (convert households to individuals).
#Count the number of villages served per partner.
#Compute the average beneficiaries per village.
#Identify partners serving more than 5000 beneficiaries (HAVING).
#Find villages with multiple partners (HAVING).
select 
    partner, 
    sum(case 
            when beneficiary_type = 'Households' then beneficiaries * 6 
            else beneficiaries 
        end) as total_individuals_reached
from beneficiary_partner_data
group by partner;

#  confirm household conversion is actually applying (NRC reported 50 households at Parklands, expect 300 not 50):

select partner, sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) as total_individuals_reached
from beneficiary_partner_data
group by partner
having partner = 'NRC';

#SUM, COUNT, AVG, GROUP BY, HAVING, CASE WHEN
# COUNT :(DISTINCT village): 	Unique villages per partner
select 
    partner, 
    count(distinct village) as villages_served
from beneficiary_partner_data
group by partner;

# AVERAGE : Average beneficiaries per village
select 
    village, 
    avg(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) as avg_beneficiaries
from beneficiary_partner_data
group by village;


# SUM : Total beneficiaries per partner
select 
    partner, 
    sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) as total_beneficiaries
from beneficiary_partner_data
group by partner
having total_beneficiaries > 5000;

# COUNT (partner) : Number of partner records per village
select 
    village, 
    count(partner) as partner_count
from beneficiary_partner_data
group by village
having partner_count > 1;

#FIND VILLAGES WITH MULTIPLES PARTNERS(HAVING)
# confirm multi-partner villages match what you'd expect (Parklands, Githurai, Kisauni Town, Shika Adabu):

select village, count(*) as row_count
from beneficiary_partner_data
group by village
having count(*) > 1;


# joins & combined queries
#Join beneficiary_partner_data and village_locations to calculate coverage per village (beneficiaries / total_population).
#Create a combined query showing all villages and partners serving them, including villages with no partners using UNION.
#Concepts: INNER JOIN, LEFT JOIN, UNION
select * from village_locations;
select * from beneficiary_partner_data;
# Coverage per village (INNER JOIN)
select 
    v.village,
    v.total_population,
    sum(case 
            when b.beneficiary_type = 'Households' then b.beneficiaries * 6 
            else b.beneficiaries 
        end) as total_beneficiaries,
    (sum(case 
            when b.beneficiary_type = 'Households' then b.beneficiaries * 6 
            else b.beneficiaries 
        end) / v.total_population) * 100 as coverage_percentage
from village_locations v
inner join beneficiary_partner_data b on v.village = b.village
group by v.village, v.total_population
order by coverage_percentage desc;

select * from village_locations v
inner join beneficiary_partner_data b on v.village = b.village;

# Combined query — served vs unserved villages (LEFT JOIN + UNION)
#Using LEFT JOIN, which naturally includes villages with no partners (NULL on the partner side):
select v.village, b.partner
from village_locations v
left join beneficiary_partner_data b on v.village = b.village
order by v.village;

# UNSERVED
select * from village_locations v
left join beneficiary_partner_data b on v.village = b.village;

# Using UNION, to explicitly label each village as Served or Unserved:
select village, 'Served' as status
from beneficiary_partner_data
union
select village, 'Unserved' as status
from village_locations
where village not in (select village from beneficiary_partner_data);




# 3. Nested Queries / Subqueries
#Find villages where coverage is above the average village coverage.
#Find partners who serve more than the average number of beneficiaries.
#Concepts: nested queries, subqueries, aggregation

select village, coverage_percentage
from (
    select v.village, 
           (sum(case when b.beneficiary_type = 'Households' then b.beneficiaries * 6 else b.beneficiaries end) / v.total_population) * 100 as coverage_percentage
    from village_locations v
    join beneficiary_partner_data b on v.village = b.village
    group by v.village, v.total_population
) as village_stats
where coverage_percentage > (
    select avg(coverage) 
    from (
        select (sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) / total_population) * 100 as coverage
        from beneficiary_partner_data b
        join village_locations v on b.village = v.village
        group by v.village
    ) as sub_table
);

# to see all villages unfiltered, plus the average, to confirm the filter makes sense:

select village, 
       (sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) / total_population) * 100 as coverage_percentage
from beneficiary_partner_data b
join village_locations v on b.village = v.village
group by v.village, total_population
order by coverage_percentage desc;

select avg(coverage) as overall_average
from (
    select (sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) / total_population) * 100 as coverage
    from beneficiary_partner_data b
    join village_locations v on b.village = v.village
    group by v.village
) as avg_check;

select partner, total_beneficiaries
from (
    select partner, sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) as total_beneficiaries
    from beneficiary_partner_data
    group by partner
) as partner_totals
where total_beneficiaries > (
    select avg(total_beneficiaries)
    from (
        select sum(case when beneficiary_type = 'Households' then beneficiaries * 6 else beneficiaries end) as total_beneficiaries
        from beneficiary_partner_data
        group by partner
    ) as avg_calc
);

#4. CTEs (Common Table Expressions)
# Create a district-level summary showing total beneficiaries, total population, coverage using a CTE.
# Rank districts by coverage using a window function inside a CTE.
# Concepts: WITH CTE, window functions
select * from jurisdiction_hierarchy;
select * from village_locations;
select * from beneficiary_partner_data;

# District-level summary — total beneficiaries, total population, coverage (using a CTE)
# district (sub-county) level summary: beneficiaries, population, coverage
with village_district as (
    select jh.name as village, jh.parent as district
    from jurisdiction_hierarchy jh
    where jh.level = 'Village'
),
village_totals as (
    select bpd.village,
           sum(case
               when bpd.beneficiary_type = 'Households' then bpd.beneficiaries * 6
               else bpd.beneficiaries
           end) as total_beneficiaries,
           vl.total_population
    from beneficiary_partner_data bpd
    join village_locations vl on bpd.village = vl.village
    group by bpd.village, vl.total_population
)
select vd.district,
       sum(vt.total_beneficiaries) as district_beneficiaries,
       sum(vt.total_population) as district_population,
       round(sum(vt.total_beneficiaries) / sum(vt.total_population), 4) as district_coverage
from village_totals vt
join village_district vd on vt.village = vd.village
group by vd.district;

#  rank districts by coverage using a window function inside a cte
with village_district as (
    select jh.name as village, jh.parent as district
    from jurisdiction_hierarchy jh
    where jh.level = 'Village'
),
village_totals as (
    select bpd.village,
           sum(case
               when bpd.beneficiary_type = 'Households' then bpd.beneficiaries * 6
               else bpd.beneficiaries
           end) as total_beneficiaries,
           vl.total_population
    from beneficiary_partner_data bpd
    join village_locations vl on bpd.village = vl.village
    group by bpd.village, vl.total_population
),
district_summary as (
    select vd.district,
           sum(vt.total_beneficiaries) as district_beneficiaries,
           sum(vt.total_population) as district_population,
           sum(vt.total_beneficiaries) / sum(vt.total_population) as district_coverage
    from village_totals vt
    join village_district vd on vt.village = vd.village
    group by vd.district
)
select district, district_coverage,
       rank() over (order by district_coverage desc) as coverage_rank
from district_summary;


# window functions
select * from beneficiary_partner_data;
select * from jurisdiction_hierarchy;
# rank partners by total beneficiaries
with partner_totals as (
    select partner,
           sum(case
               when beneficiary_type = 'Households' then beneficiaries * 6
               else beneficiaries
           end) as total_beneficiaries
    from beneficiary_partner_data
    group by partner
)
select partner, total_beneficiaries,
       rank() over (order by total_beneficiaries desc) as partner_rank
from partner_totals;

# rank districts within each county (region) by beneficiaries served
with village_district as (
    select jh.name as village, jh.parent as district
    from jurisdiction_hierarchy jh
    where jh.level = 'Village'
),
district_county as (
    select sub.name as district, sub.parent as county
    from jurisdiction_hierarchy sub
    where sub.level = 'Sub-County'
),
village_totals as (
    select bpd.village,
           sum(case
               when bpd.beneficiary_type = 'Households' then bpd.beneficiaries * 6
               else bpd.beneficiaries
           end) as total_beneficiaries
    from beneficiary_partner_data bpd
    group by bpd.village
),
district_summary as (
    select vd.district, dc.county,
           sum(vt.total_beneficiaries) as district_beneficiaries
    from village_totals vt
    join village_district vd on vt.village = vd.village
    join district_county dc on vd.district = dc.district
    group by vd.district, dc.county
)
select county, district, district_beneficiaries,
       rank() over (partition by county order by district_beneficiaries desc) as rank_in_county
from district_summary;

#  top performing partner per district
with village_district as (
    select jh.name as village, jh.parent as district
    from jurisdiction_hierarchy jh
    where jh.level = 'Village'
),
partner_district_totals as (
    select bpd.partner, vd.district,
           sum(case
               when bpd.beneficiary_type = 'Households' then bpd.beneficiaries * 6
               else bpd.beneficiaries
           end) as total_beneficiaries
    from beneficiary_partner_data bpd
    join village_district vd on bpd.village = vd.village
    group by bpd.partner, vd.district
)
select district, partner, total_beneficiaries
from (
    select district, partner, total_beneficiaries,
           row_number() over (partition by district order by total_beneficiaries desc) as rn
    from partner_district_totals
) ranked
where rn = 1;

# functionsconvert_to_individuals
delimiter //

create function convert_to_individuals(p_beneficiaries int, p_type varchar(30))
returns int
deterministic
begin
    declare result int;
    if p_type = 'Households' then
        set result = p_beneficiaries * 6;
    else
        set result = p_beneficiaries;
    end if;
    return result;
end //

# views
#Create view district_summary with district-level beneficiaries, population, coverage, number of partners
create view district_summary as
select
    jh.parent as district,
    sum(b.beneficiaries) as total_beneficiaries,
    sum(v.total_population) as district_population,
    (sum(b.beneficiaries) / sum(v.total_population)) * 100 as coverage_percentage,
    count(distinct b.partner) as number_of_partners
from jurisdiction_hierarchy jh
join village_locations v
    on jh.name = v.village
join beneficiary_partner_data b
    on v.village = b.village
group by jh.parent;

select * from district_summary;



#Create view partner_summary with partner name, villages served, districts reached, total beneficiaries.
create view partner_summary as
select
    b.partner as partner_name,
    count(distinct b.village) as villages_served,
    count(distinct jh.parent) as districts_reached,
    sum(b.beneficiaries) as total_beneficiaries
from beneficiary_partner_data b
join jurisdiction_hierarchy jh
    on b.village = jh.name
group by b.partner;

 select * from partner_summary;
 
# Triggers
# Trigger on beneficiary_partner_data to log a message when a new record is inserted.
# Trigger to prevent inserting negative beneficiaries.
#Concepts: CREATE TRIGGER, BEFORE INSERT

#1. trigger to prevent negative beneficiaries

delimiter //

create trigger prevent_negative_beneficiaries
before insert on beneficiary_partner_data
for each row
begin
    if new.beneficiaries < 0 then
        signal sqlstate '45000'
        set message_text = 'beneficiaries cannot be negative';
    end if;
end //
delimiter ;

select * from beneficiary_partner_data;

insert into beneficiary_partner_data
(partner, village, beneficiaries, beneficiary_type)
values
('IRC', 'Parklands', -10, 'Individuals');

# trigger to log a message when a new record is inserted

create table trigger_log (
    id int auto_increment primary key,
    message varchar(255),
    log_date timestamp default current_timestamp
);

then create the trigger:

delimiter //
create trigger log_new_beneficiary
after insert on beneficiary_partner_data
for each row
begin
    insert into trigger_log(message)
    values ('new beneficiary record inserted');
end //
delimiter ;

#insert a valid record. use values that match your database:
insert into beneficiary_partner_data
(partner, village, beneficiaries, beneficiary_type)
values
('IRC', 'Parklands', 10, 'Individuals');

select * from trigger_log;

insert into beneficiary_partner_data
(partner, village, beneficiaries, beneficiary_type)
values
('IRC', 'Parklands', -10, 'Individuals');


# stored procedures
# 8. Stored Procedures
#GetPartnerReport(partner_name) → returns villages served, districts served, total beneficiaries, partner ranking.
#Concepts: CREATE PROCEDURE, input parameters, joins, aggregation
select * from jurisdiction_hierarchy;
select * from beneficiary_partner_data;
# testing the joinns used in your procedure

delimiter //
create procedure getpartnerreport(in partner_name varchar(30))
begin
    with partnertotals as (
        select
            b.partner,
            count(distinct b.village) as villages_served,
            count(distinct jh.parent) as districts_served,
            sum(convert_to_individuals(b.beneficiaries, b.beneficiary_type)) as total_beneficiaries
        from beneficiary_partner_data b
        join jurisdiction_hierarchy jh on b.village = jh.name
        group by b.partner
    ),
    rankedpartners as (
        select *, rank() over (order by total_beneficiaries desc) as partner_rank
        from partnertotals
    )
    select partner, villages_served, districts_served, total_beneficiaries, partner_rank
    from rankedpartners
    where partner = partner_name;
end //
delimiter ;
 
# calling both procedures
call getpartnerreport('IRC');
 
#GetDistrictImpact(district_name) → returns region, district population, total beneficiaries, coverage rate, number of partners.
delimiter //
create procedure getdistrictimpact(in district_name varchar(30))
begin
    with villagetotals as (
        select
            v.village, v.total_population,
            sum(convert_to_individuals(b.beneficiaries, b.beneficiary_type)) as village_beneficiaries
        from village_locations v
        join beneficiary_partner_data b on v.village = b.village
        group by v.village, v.total_population
    )
    select
        jh.parent as district,
        sum(vt.total_population) as population,
        sum(vt.village_beneficiaries) as total_reached,
        (sum(vt.village_beneficiaries) / sum(vt.total_population)) * 100 as coverage_rate,
        (select count(distinct b2.partner)
         from beneficiary_partner_data b2
         join jurisdiction_hierarchy jh2 on b2.village = jh2.name
         where jh2.parent = district_name) as partner_count
    from jurisdiction_hierarchy jh
    join villagetotals vt on jh.name = vt.village
    where jh.parent = district_name
    group by jh.parent;
end //
delimiter ;
 
# calling  both procedures
call getdistrictimpact('Westlands');
 
 
# BONUS / ADVANCED CHALLENGES
 
# partners operating in more than 3 villages
select partner, count(distinct village) as village_count
from beneficiary_partner_data
group by partner
having count(distinct village) > 3;
 
#  districts where total beneficiaries exceed 10,000
select jh.parent as district,
       sum(convert_to_individuals(b.beneficiaries, b.beneficiary_type)) as total_reached
from beneficiary_partner_data b
join jurisdiction_hierarchy jh on b.village = jh.name
group by jh.parent
having sum(convert_to_individuals(b.beneficiaries, b.beneficiary_type)) > 10000;
 
# partner dominating each district
with partnerperformance as (
    select
        partner, jh.parent as district,
        sum(convert_to_individuals(beneficiaries, beneficiary_type)) as total_reach,
        row_number() over (partition by jh.parent order by sum(convert_to_individuals(beneficiaries, beneficiary_type)) desc) as rank_in_district
    from beneficiary_partner_data b
    join jurisdiction_hierarchy jh on b.village = jh.name
    group by partner, jh.parent
)
select partner, district, total_reach
from partnerperformance
where rank_in_district = 1;
 