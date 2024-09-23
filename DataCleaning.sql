
##Cleaning data in SQL queries


Select *
From NashvilleHousing;

##Standarize Data format

select SaleDate
from NashvilleHousing;

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate);

Alter table NashvilleHousing
Add saledateconverted Date;

update NashvilleHousing
set saledateconverted = CONVERT(date,SaleDate);


##Populate property address data

select a.ParcelID , a.PropertyAddress,b.ParcelID ,b.PropertyAddress ,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

##Breaking out address into separte columns (address,city,state)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
 ,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from NashvilleHousing



Alter table NashvilleHousing
Add Propertysplitaddress  nvarchar(255);

update NashvilleHousing
set Propertysplitaddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter table NashvilleHousing
Add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));


-- split owneraddress with easier way
Select OwnerAddress
From NashvilleHousing;


select 
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
From NashvilleHousing;

Alter table NashvilleHousing
Add ownersplitaddress  nvarchar(255);

update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3);

Alter table NashvilleHousing
Add ownersplitcity  nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),2);

Alter table NashvilleHousing
Add ownersplitstate  nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),1);


Select *
From NashvilleHousing;


##change y and n to yes and no in 'sold as vacant' field

select distinct(soldasvacant), count(soldasvacant)
From NashvilleHousing
group by SoldAsVacant
order by 2 ;


select SoldAsVacant
,case when soldasvacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
From NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end


##remove duplicates

with rownumCTE as (
 select *,
 ROW_NUMBER()over(
 partition by parcelid,
              propertyaddress,
			  saleprice,
			  saledate,
			  legalreference
			  order by 
			   uniqueid
			   ) row_num
 From NashvilleHousing
)
--delete then we use select to see if all the duplicates are deleted
select *
from rownumCTE
where row_num > 1
order by PropertyAddress





--delete unused columns

Select *
From NashvilleHousing

alter table NashvilleHousing
drop column saledate
