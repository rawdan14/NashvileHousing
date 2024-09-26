
##Cleaning data in SQL queries

Select *
FROM portofolio.dbo.NashvilleHousing

##Standarize Data format

-- Standardize Date Format

--Create a new column for converting date
ALTER TABLE portofolio.dbo.NashvilleHousing
ADD SaleDateConverted Date;

--Update the new SaleDateConverted column
Update portofolio.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- See if it works
Select SaleDateConverted
FROM portofolio.dbo.NashvilleHousing

	Select *
FROM portofolio.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

##Populate property address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portofolio.dbo.NashvilleHousing a
JOIN portofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portofolio.dbo.NashvilleHousing a
JOIN portofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

	-- Create new column for OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

-- Update OwnerSplitAddress to be included only address
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

-- Create new column for OwnerCity
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

-- Update OwnerSplitCity to be included only city
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Create new column for OwnerState
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

-- Update OwnerSplitState to be included only State
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Check the updates
Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM portofolio.dbo.NashvilleHousing

-- Convert Y and N into Yes and No
UPDATE NashvilleHousing
SET SoldAsVacant =  CASE  
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM portofolio.dbo.NashvilleHousing

-- Remove Duplicates

--Use CTE and window function to seperate them into groups
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
	ORDER BY  UniqueID
	) row_num
FROM portofolio.dbo.NashvilleHousing
)

-- If row_num > 1, it means it's duplicated value  
SELECT *
FROM RowNUMCTE
WHERE row_num > 1

--Use CTE and window function to seperate them into groups
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
	ORDER BY  UniqueID
	) row_num
FROM portofolio.dbo.NashvilleHousing
)
-- Remove Duplicates
DELETE
FROM RowNumCTE
WHERE row_num >1
