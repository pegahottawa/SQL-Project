
select *
FROM public.nashville_housing_data_for_data_cleaning

--Populate Property Address Data 

select 
  a.propertyaddress,
  a.parcelid,
  b.propertyaddress,
  b.parcelid,
  COALESCE(a.propertyaddress ,b.propertyaddress) 
FROM public.nashville_housing_data_for_data_cleaning as a
join public.nashville_housing_data_for_data_cleaning as b
on a.parcelid =  b.parcelid and a."UniqueID " <> b."UniqueID " 
where a.propertyaddress is null

update  public.nashville_housing_data_for_data_cleaning
set propertyaddress = COALESCE(a.propertyaddress ,b.propertyaddress) 
FROM public.nashville_housing_data_for_data_cleaning as a
join public.nashville_housing_data_for_data_cleaning as b
on a.parcelid =  b.parcelid and a."UniqueID " <> b."UniqueID " 
where a.propertyaddress is null


--Breaking out Address into Individul Columns (Adress, City, Sate)

select 
 substring(propertyaddress,1, position(',' in propertyaddress)-1) as Address,
 substring(propertyaddress,position(',' in propertyaddress)+1,
                           LENGTH(propertyaddress)) as City 

FROM public.nashville_housing_data_for_data_cleaning

alter table nashville_housing_data_for_data_cleaning
add PropertySplitAddress varchar(255)

update public.nashville_housing_data_for_data_cleaning
set  PropertySplitAddress = substring(propertyaddress,1, 
                            position(',' in propertyaddress)-1)

alter table public.nashville_housing_data_for_data_cleaning
add PropertySplitCity varchar(255)

update public.nashville_housing_data_for_data_cleaning
set PropertySplitCity =  substring(propertyaddress,
                         position(',' in propertyaddress)+1,
                         LENGTH(propertyaddress)) 

select 
SPLIT_PART(owneraddress, ',', 1) as OwnerAddress,
SPLIT_PART(owneraddress, ',', 2) as OwnerCity,
SPLIT_PART(owneraddress, ',', 3) as OwnerState
FROM public.nashville_housing_data_for_data_cleaning

alter table nashville_housing_data_for_data_cleaning
add OwnerSplitAddress varchar(255)

update nashville_housing_data_for_data_cleaning
set OwnerSplitAddress = SPLIT_PART(owneraddress, ',', 1) 

alter table nashville_housing_data_for_data_cleaning
add OwnerSplitCity varchar(255)

update nashville_housing_data_for_data_cleaning
set OwnerSplitCity = SPLIT_PART(owneraddress, ',', 2) 

alter table nashville_housing_data_for_data_cleaning
add OwnerSplitState varchar(255)

update nashville_housing_data_for_data_cleaning
set OwnerSplitState = SPLIT_PART(owneraddress, ',', 3) 

--Change Y and N to Yes and No in "sold As Vacant" Field 

select 
  distinct soldasvacant,
  count(soldasvacant)
  FROM public.nashville_housing_data_for_data_cleaning
  group by soldasvacant
  order by 2

  select 
    soldasvacant,
    case when soldasvacant ='Y' then 'Yes'
         when soldasvacant ='N' then 'No'
         else soldasvacant
         end 
 FROM public.nashville_housing_data_for_data_cleaning
 
 update nashville_housing_data_for_data_cleaning
 set soldasvacant = case when soldasvacant ='Y' then 'Yes'
         when soldasvacant ='N' then 'No'
         else soldasvacant
         end 
         
--Remove Duplicates         
          
with a as (         
 select *,
 row_number()over(partition by parcelid,
                       propertyaddress,
                       saleprice,saledate,legalreference
                       ) as row_num
 FROM public.nashville_housing_data_for_data_cleaning
) delete 
from a
 where row_num > 1
                       

 --Delete Unused Columns 
 
 alter table public.nashville_housing_data_for_data_cleaning
 --drop column owneraddress,
 drop column saledate
  
  
  
  
  
  
  
  


