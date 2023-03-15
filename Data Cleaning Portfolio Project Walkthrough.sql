/*
Cleaning Data in SQL queries
*/

SELECT *
FROM PortofolioProject..NashvilleHousing

--------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortofolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

-----------------------------------------------
--Populate property Address data

SELECT *
FROM PortofolioProject..NashvilleHousing
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

----------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortofolioProject..NashvilleHousing

-- split with something different in Owner Address

SELECT OwnerAddress 
FROM PortofolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortofolioProject..NashvilleHousing

--------------
-- Change Y and N and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
	END
FROM PortofolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END

----------------------
-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
					) row_num
FROM PortofolioProject..NashvilleHousing
)

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
----ORDER BY PropertyAddress

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-------------
-- Delete Unused Columns

SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

------------------
---------------------
