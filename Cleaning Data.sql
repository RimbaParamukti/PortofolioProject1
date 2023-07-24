/*
Cleaning Data
*/



-- STANDARIDZE DATE FORMAT
SELECT SaleDate
from NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDateConverted
from NashvilleHousing

--------------------------------------------------------------------
-- Populate Property Address Data
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- ISNULL(data yangkosong, Value data)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------
-- Breaking Out Address Into Individual Colums (Address, City, State)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM NashvilleHousing
 

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--Owner Address
SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
add OwnerSplitCIty Nvarchar(255)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Update NashvilleHousing
SET OwnerSplitCIty = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM NashvilleHousing

------------------------------------------------------------------------------
--Change Y and N to Yes and No in SOld As Vacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing
ORDER BY 1

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------------
--Remove Duplicate
WITH RowNumCTE AS (
 SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate, 
					LegalReference
					ORDER BY 
						UniqueID) as Rows_num
 FROM NashvilleHousing
 )
 Select *
 FROM RowNumCTE
 WHERE Rows_num > 1 
 ORDER BY PropertyAddress

 --delete unused columns
 SELECT *
 FROM  NashvilleHousing
 
 ALTER TABLE NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE NashvilleHousing
 DROP COLUMN SaleDate